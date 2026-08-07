# Design: Core Foundation

## Architecture Summary

Creándola OS is one managed, multi-workspace platform. Vercel hosts the single Next.js application and Supabase provides the managed backend. Clerk, self-managed VPS, production Docker, manual backups, reverse proxies, manually managed SSL, and server-security operations are not part of the architecture.

If a Supabase Custom Domain is used, it is one platform backend domain such as `api.somoscreandola.co` for Creándola OS API/Auth/Storage, never one domain per customer. Customer frontend domains (when needed later) are configured in Vercel and are out of scope for this change; see `openspec/changes/host-workspace-resolution/`.

The foundation has three trust boundaries:

```text
Browser / Server Component
  -> Next.js Proxy refreshes and validates the session optimistically
  -> authenticated server layout resolves workspace through RLS
  -> authenticated SECURITY INVOKER RPC wrapper
  -> private SECURITY DEFINER implementation re-checks membership and writes
```

RLS protects exposed-table reads. Direct table writes are not granted to `anon` or `authenticated`; user writes go through authenticated `SECURITY INVOKER` wrappers whose SQL membership checks are authoritative. Cross-workspace integrity is enforced by constraints, not only policies. The admin / secret-key client remains server-only and is limited to provisioning, trusted jobs, and other explicitly trusted system work.

Delivery order and product wedge constraints are governed by [RFC 0004 — Delivery Strategy](../../../docs/rfcs/0004-delivery-strategy.md). Later Context Engine inventory (events, memories, embeddings, and related tables) is documented in RFC 0003 and is not part of this change.

## Database Design

### Managed Infrastructure Boundary

| Concern | Managed platform decision |
|---------|---------------------------|
| Frontend hosting | Vercel hosts one Next.js multi-workspace app |
| Authentication | Supabase Auth; Clerk is not used |
| Relational data and tenant isolation | Supabase Postgres with Row Level Security (RLS) |
| Files | Supabase Storage |
| Server-side workflows | Supabase Edge Functions; Supabase Cron/jobs when a scheduled task applies |
| Semantic search | pgvector may be enabled later if the product requires it (RFC 0004: after first production client use) |
| Backend custom domain | Optional single Supabase Custom Domain for the Creándola OS backend, such as `api.somoscreandola.co` |
| Server operations excluded | No self-managed VPS, production Docker, manual backup process, reverse proxy, manual SSL, or server-security layer |

### Schemas and Enums

- `public`: Data API tables and `public.create_entity` wrapper
- `private`: unexposed helper, trigger, and privileged implementation functions
- `entity_type`: `client`, `project`, `meeting`, `decision`, `task`, `document`, `process`, `report`
- `membership_role`: `owner`, `admin`, `member`, `viewer`
- `workspace_type`: `personal`, `team`, `organization`

`private` MUST not be added to the Supabase exposed schemas list.

### Auth and Tenancy Tables

| Table | Required columns and constraints | Required indexes |
|-------|----------------------------------|------------------|
| `profiles` | `id UUID PK REFERENCES auth.users(id) ON DELETE CASCADE`, `email TEXT UNIQUE NOT NULL`, `full_name TEXT`, `avatar_url TEXT`, timestamps | Primary/unique indexes are sufficient |
| `workspaces` | `id UUID PK`, `name TEXT NOT NULL` max 128, `slug TEXT UNIQUE NOT NULL` max 63 and lowercase slug format, `workspace_type NOT NULL`, `personal_owner_id UUID UNIQUE NULL REFERENCES profiles(id)`, `status TEXT NOT NULL`, timestamps; personal workspaces require an owner and non-personal workspaces require null | Unique slug and owner indexes plus `status` only if later queries justify it |
| `memberships` | `id UUID PK`, `workspace_id UUID NOT NULL REFERENCES workspaces ON DELETE CASCADE`, `profile_id UUID NOT NULL REFERENCES profiles ON DELETE CASCADE`, `role membership_role NOT NULL`, `status TEXT NOT NULL`, timestamps, `UNIQUE(workspace_id, profile_id)` | `(profile_id, status, workspace_id)` for helper lookup; `(workspace_id, status)` for workspace membership operations |

`profiles.id` is the auth user ID. No `profiles.user_id` column exists.

### Phase 1 Context Tables

| Table | Required columns and constraints | Required indexes |
|-------|----------------------------------|------------------|
| `entities` | `id UUID PK`, `workspace_id UUID NOT NULL REFERENCES workspaces ON DELETE CASCADE`, `entity_type entity_type NOT NULL`, `name TEXT NOT NULL` max 256, `status TEXT NOT NULL`, `properties JSONB NOT NULL DEFAULT '{}' CHECK(jsonb_typeof(properties)='object')`, `fingerprint TEXT NOT NULL CHECK(length=64)`, `idempotency_key_hash TEXT NULL CHECK(length=64)`, `created_by UUID NOT NULL REFERENCES profiles`, timestamps, `archived_at`, `UNIQUE(workspace_id,id)` | `(workspace_id, entity_type, status)`, GIN `properties jsonb_path_ops`, partial unique `(workspace_id,idempotency_key_hash)` when non-null, `created_by` FK index |
| `entity_properties` | `id UUID PK`, `workspace_id UUID NOT NULL`, `entity_id UUID NOT NULL`, `property_key TEXT NOT NULL` max 128, `property_value JSONB NOT NULL`, `property_type TEXT NOT NULL`, timestamps, `UNIQUE(workspace_id,entity_id,property_key)`, composite FK `(workspace_id,entity_id) -> entities(workspace_id,id) ON DELETE CASCADE` | `(workspace_id,property_key)`, `(workspace_id,entity_id)` via unique index, GIN `property_value jsonb_path_ops` |
| `relationships` | `id UUID PK`, `workspace_id UUID NOT NULL`, `from_entity_id UUID NOT NULL`, `to_entity_id UUID NOT NULL`, `relationship_type TEXT NOT NULL` max 64, `confidence NUMERIC(3,2) NOT NULL DEFAULT 1 CHECK between 0 and 1`, `valid_from`, `valid_to`, `properties JSONB NOT NULL DEFAULT '{}' CHECK object`, timestamps, no self-edge, valid range check, composite FKs for both endpoints | `(workspace_id,from_entity_id,relationship_type)`, `(workspace_id,to_entity_id,relationship_type)`; endpoint FKs are covered |

No Phase 1 table references `sources`. A separate future migration will add provenance without creating a dangling dependency now.

### JSONB Query Contract

The GIN indexes use `jsonb_path_ops` and therefore target containment queries such as `properties @> $1`. Key-existence queries (`?`, `?|`, `?&`) are not part of the Phase 1 performance contract. `property_key` uses a B-tree index; `property_value` uses a separate GIN index.

## RLS and Privileges

### Table Access Matrix

| Object | `anon` | `authenticated` | Privileged backend |
|--------|--------|-----------------|--------------------|
| Public tables | No table privileges | SELECT only, filtered by RLS | Supabase secret key remains fully privileged and server-only; use only for provisioning and trusted jobs |
| `public.create_entity` | No EXECUTE | EXECUTE | Not the default user path |
| `private.current_user_workspace_ids` | No EXECUTE | EXECUTE for policy evaluation | Owner |
| `private.provision_user` | No direct EXECUTE | No direct EXECUTE | Owner only; pgTAP invokes it as the migration/test owner |
| `private.handle_new_user` | No direct EXECUTE | No direct EXECUTE | Trigger/owner only; delegates to `provision_user` |
| `private.create_entity_impl` | No EXECUTE | Narrow EXECUTE required by the invoker wrapper; schema remains unexposed | Owner |

The migration MUST revoke default function execution from `PUBLIC`, `anon`, and `authenticated` before granting the required signatures. pgTAP checks exact identities, not function names alone.

### RLS Policies

All policies specify `TO authenticated` and are operation-specific:

- `profiles_select_own`: SELECT where `id = (select auth.uid())`
- `workspaces_select_member`: SELECT where `id IN (SELECT private.current_user_workspace_ids())`
- `memberships_select_own`: SELECT where `profile_id = (select auth.uid())`
- `entities_select_member`: SELECT by row `workspace_id`
- `entity_properties_select_member`: SELECT by row `workspace_id`
- `relationships_select_member`: SELECT by row `workspace_id`

There are no authenticated INSERT, UPDATE, or DELETE policies in this change. Direct mutation attempts must fail because privileges are absent, even if a row would otherwise match a SELECT policy.

### Membership Helper

`private.current_user_workspace_ids()` returns a set of UUIDs from active memberships whose `profile_id = (select auth.uid())`. It is `STABLE SECURITY DEFINER`, uses `search_path = ''`, and schema-qualifies `public.memberships`. The definer owner can read memberships without recursive RLS evaluation.

## Provisioning Design

`private.provision_user(p_user_id uuid, p_email text, p_user_metadata jsonb) returns uuid` owns the idempotent provisioning algorithm:

1. Upsert `profiles` using `p_user_id` as `profiles.id`, `p_email`, and display values read from `p_user_metadata`.
2. Reuse a workspace with `personal_owner_id = p_user_id`, or reserve one.
3. Build a human-readable slug base from `p_user_metadata`/`p_email`, sanitize it, and append a UUID-derived suffix.
4. If the candidate collides, retry reservation with a new suffix; the unique slug constraint is authoritative.
5. Upsert `(workspace_id, p_user_id)` membership as active owner.
6. Return the personal workspace UUID.

`private.handle_new_user()` is a thin trigger adapter: it passes `NEW.id`, `NEW.email`, and `NEW.raw_user_meta_data` to `private.provision_user()` and returns `NEW`. Replaying the helper for an existing `auth.users` row returns the same personal workspace. pgTAP therefore inserts the auth user once, records the trigger-created rows, calls the helper again as the migration/test owner, and asserts unchanged row counts. Two users with the same email prefix still receive different slugs. User metadata is used only for display values and never for authorization.

## Entity Creation Design

### API Signature

```sql
public.create_entity(
  p_workspace_id uuid,
  p_entity_type public.entity_type,
  p_name text,
  p_properties jsonb default '{}'::jsonb,
  p_idempotency_key text default null
) returns uuid
```

The public function is `SECURITY INVOKER` and contains no privileged table access other than delegating to the private implementation. User writes are authorized by SQL membership checks in the implementation; `service_role` is not the normal user-write path.

### Authorization

`private.create_entity_impl()` rejects the call unless:

- `auth.uid()` is non-null;
- the profile ID equals `auth.uid()`; and
- an active membership exists for `p_workspace_id` with role `owner`, `admin`, or `member`.

The implementation writes `created_by = auth.uid()`. `viewer` and inactive memberships are rejected.

### Idempotency Algorithm

1. Validate name and properties object. If the key is non-null, require `^[!-~]{1,256}$`: exactly 1-256 printable ASCII characters, with whitespace rejected anywhere. Do not trim, normalize, or case-fold the key.
2. Build canonical JSONB from accepted, normalized request fields.
3. Compute `v_fingerprint = SHA-256(canonical_jsonb::text)`.
4. If no key is provided, insert with `idempotency_key_hash = NULL` and return the new UUID.
5. If a key is provided, compute SHA-256 over its exact validated ASCII bytes, then acquire a transaction-level advisory lock namespaced by workspace and that exact key.
6. Look up `(workspace_id, idempotency_key_hash)`.
7. If found with the same fingerprint, return the existing UUID.
8. If found with a different fingerprint, raise SQLSTATE `22023` with a stable application error code/message.
9. Otherwise insert and return the UUID. The partial unique index is the final concurrency backstop.

The fingerprint is not globally unique. Two keyless calls with the same payload create two rows.

### Concurrency Verification

An integration harness MUST use two authenticated database sessions plus an observer session; single-session pgTAP alone cannot prove blocking behavior:

1. Session A begins a transaction, calls `create_entity`, and keeps the transaction open so its transaction advisory lock remains held.
2. Session B calls `create_entity` concurrently with the same workspace/key.
3. The observer asserts Session B is waiting on an advisory lock (`pg_stat_activity.wait_event_type = 'Lock'` and advisory `wait_event`) before Session A commits.
4. With the same payload, Session B then completes with the same UUID and one stored row.
5. With a different payload, Session B waits the same way and, after Session A commits, fails with SQLSTATE `22023`; the original row remains unchanged.

The harness MUST use bounded timeouts and always clean up transactions so a failed assertion cannot hang the suite.

### Entity Property Schemas

The database accepts any JSON object, while the Phase 1 Zod discriminated union is intentionally strict and deterministic:

| Entity type | Allowed `properties` keys |
|-------------|---------------------------|
| `client` | Optional `contact_email` string validated as email |
| `project` | Optional ISO dates `start_date`, `end_date`; if both exist, end is not before start |
| `meeting` | Optional ISO datetimes `starts_at`, `ends_at`; if both exist, end is not before start |
| `decision` | None; strict `{}` |
| `task` | None; strict `{}` |
| `document` | None; strict `{}` |
| `process` | None; strict `{}` |
| `report` | None; strict `{}` |

Unknown keys fail Zod validation for every type. These strict empty schemas avoid inventing product rules; later changes may add named keys through explicit delta specs.

## Application Design

```text
src/
  app/
    (auth)/login/page.tsx
    (auth)/auth/callback/route.ts
    (auth)/auth/signout/route.ts
    (app)/[workspaceSlug]/layout.tsx
    (app)/[workspaceSlug]/page.tsx
    globals.css
    layout.tsx
  domain/
    entities/types.ts
    entities/schemas.ts
    entities/limits.ts
    decoders.ts
    errors.ts
  infrastructure/supabase/
    server.ts
    browser.ts
    admin.ts
    proxy.ts
    db/entities.ts
    db/workspaces.ts
  proxy.ts
```

### Supabase Clients

| Client | Key | Responsibility |
|--------|-----|----------------|
| Server | Publishable | Per-request SSR client using cookies; authenticated reads and user-scoped RPC calls |
| Browser | Publishable | OAuth initiation, logout/auth state only; no application table queries by convention |
| Admin | Secret (legacy service-role fallback only where needed locally) | Explicit trusted system operations; created per request/job and guarded by `server-only` |

No client is stored in module-global mutable state.

### Next.js 16 Proxy

`src/proxy.ts` exports `async function proxy(request)` and delegates cookie/session handling to `src/infrastructure/supabase/proxy.ts`.

It MUST:

- call `supabase.auth.getClaims()`, not trust `getSession()` for authorization;
- copy refreshed cookies to both request and response;
- apply cache-prevention headers delivered by current `@supabase/ssr` cookie callbacks;
- exclude static assets and metadata from its matcher; and
- redirect unauthenticated protected paths to `/login` with a validated relative return path.

It MUST NOT query the workspace database or accept a client-supplied workspace ID header as trusted state. The `[workspaceSlug]` server layout performs the authoritative RLS-backed lookup and returns not-found/forbidden behavior when inaccessible.

### Cookies and Redirects

Auth cookies use `SameSite=Lax` and `Secure` in production. They are not forced to `HttpOnly`, because `@supabase/ssr` requires the browser client to participate in refresh-token maintenance. OAuth return destinations accept only same-origin relative paths beginning with a single `/`; protocol-relative and external URLs are rejected.

## Toolchain Design

- Node.js minimum: 20.9
- Next.js 16 uses `proxy.ts` and Turbopack defaults
- ESLint uses flat config and the standalone CLI
- Tailwind CSS 4 uses `postcss.config.mjs` plus `@import "tailwindcss"`
- Separate scripts: `lint`, `typecheck`, `test`, `build`
- `.env.local.example` documents names only; `.env.local` is ignored and never committed

## Verification Matrix

| Contract | Proof |
|----------|-------|
| Profile identity | Catalog assertion: `profiles.id -> auth.users.id`; no `user_id` column |
| Tenant integrity | Composite FK tests reject mismatched workspace/child and both relationship endpoints |
| RLS visibility | Switch JWT claims for two users and compare row counts, not exception behavior |
| Direct write denial | Authenticated INSERT/UPDATE/DELETE attempts fail by privilege/policy |
| Role boundary | owner/admin/member RPC succeeds; viewer/inactive/nonmember fails |
| Provisioning | Insert auth user once, then call `private.provision_user` again as test owner; the same workspace UUID is returned and row counts remain one profile/personal workspace/membership; colliding base slugs remain distinct |
| Function hardening | No definer in exposed schemas; every definer has empty search path; exact EXECUTE grants match matrix |
| Idempotency | Paired DB/RPC and Zod tests accept `!`, `~`, and 256-character boundary keys; reject empty/257-character keys, space/tab/newline, ASCII controls, DEL (`U+007F`), and Unicode; case variants remain distinct; the two-session harness observes advisory waiting and proves same/different-payload outcomes |
| JSONB indexes | Catalog checks expected operator class and separate B-tree/GIN indexes |
| Proxy | Unit/static checks use `proxy.ts`, `getClaims()`, safe matcher, and no workspace DB query |
| Quality gates | `npm run lint`, `npm run typecheck`, `npm test -- --run`, `npm run build`, `supabase db reset`, `supabase test db`, and the bounded concurrency harness all exit 0 |

## Open Questions

- Confirm the exact Google metadata keys in a real local OAuth callback; provisioning already has safe display fallbacks.
- Decide before production whether UUIDv7 is worth the extension dependency.
- Integration/E2E coverage remains a later slice after the app exposes meaningful user workflows.

## Verified Primary Documentation

- [Next.js 16 upgrade guide](https://nextjs.org/docs/app/guides/upgrading/version-16)
- [Next.js Proxy](https://nextjs.org/docs/app/getting-started/proxy)
- [Supabase SSR for Next.js](https://supabase.com/docs/guides/auth/server-side/nextjs)
- [Supabase SSR advanced guide](https://supabase.com/docs/guides/auth/server-side/advanced-guide)
- [Supabase RLS](https://supabase.com/docs/guides/database/postgres/row-level-security)
- [Supabase database functions](https://supabase.com/docs/guides/database/functions)
- [Supabase API keys](https://supabase.com/docs/guides/getting-started/api-keys)
- [Tailwind CSS Next.js guide](https://tailwindcss.com/docs/installation/framework-guides/nextjs)
