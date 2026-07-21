# Exploration: Core Foundation

## Executive Summary

The project is greenfield. The first change should establish only the contracts needed by the app shell and the first entity write: secure tenancy, the canonical Phase 1 graph schema, session-aware Supabase access, and domain validation. Later Context Engine concepts remain design context, not requirements of this change.

## Current State

- No application or database implementation exists.
- The selected stack is Next.js 16, React 19, Node.js 20.9+, TypeScript strict, Tailwind CSS 4, Supabase, Zod 4, Vitest, and pgTAP.
- RFC 0003 supplies the long-term canonical entity model, but only `entities`, `entity_properties`, and `relationships` belong in this first slice.
- The project requires Clean Architecture, RLS-first reads, RPC-based writes, and runtime decoding of database rows.

## Decisions

### 1. Canonical Entity Model

**Decision:** Use one `entities` table with an eight-value `entity_type` enum and JSONB `properties`.

This keeps graph relationships simple and preserves the RFC's unified context surface. Typed per-entity tables would improve column-level constraints but make cross-entity traversal and later type additions expensive. Zod performs type-specific validation; database constraints still protect universal invariants.

The Phase 1 schema is deliberately limited to:

- `entities`
- `entity_properties`
- `relationships`

Events, sources, evidence, memories, context packs, and access policies are future changes. Phase 1 tables therefore contain no `source_id` foreign key.

### 2. Explicit Workspace Scope

**Decision:** Put `workspace_id` on every tenant table and enforce workspace consistency with composite foreign keys.

`entities` exposes `UNIQUE (workspace_id, id)`. `entity_properties` references `(workspace_id, entity_id)`, and each relationship endpoint references `(workspace_id, entity_id)`. This prevents cross-workspace rows independently of application code and RLS.

Foreign-key columns and RLS predicates receive matching B-tree indexes. Child-table RLS does not depend on join chains.

### 3. Profile Identity

**Decision:** `profiles.id` is the Supabase Auth user UUID and directly references `auth.users(id)`.

There is no `profiles.user_id`. Membership lookup is always:

```sql
membership.profile_id = (select auth.uid())
```

This removes an unnecessary identity indirection and prevents the contradictory lookup present in the earlier draft.

### 4. Read and Write Authorization

**Decision:** Authenticated users read through table SELECT grants plus operation-specific RLS. They do not receive direct INSERT, UPDATE, or DELETE privileges on Phase 1 tenant tables.

The read boundary is:

| Table | Authenticated SELECT rule |
|-------|---------------------------|
| `profiles` | Own row only |
| `workspaces` | Active member of workspace |
| `memberships` | Own active/inactive membership rows only |
| `entities` | Active member of row workspace |
| `entity_properties` | Active member of row workspace |
| `relationships` | Active member of row workspace |

The `create_entity` RPC additionally restricts writes to active `owner`, `admin`, and `member` roles. `viewer` is read-only. The absence of write policies and table grants is intentional and must be tested.

### 5. Privileged Function Boundary

**Decision:** No `SECURITY DEFINER` function lives in the exposed `public` schema.

- `private.current_user_workspace_ids()` is a stable definer helper used by RLS.
- `private.provision_user(uuid, text, jsonb)` is the idempotent, testable provisioning helper.
- `private.handle_new_user()` is a thin auth trigger adapter that delegates to the helper.
- `private.create_entity_impl()` performs the authorized insert.
- `public.create_entity()` is the Data API entry point and remains `SECURITY INVOKER`.

All definer functions set `search_path = ''` and schema-qualify every referenced object. Function execution is revoked from `PUBLIC` by default and re-granted narrowly. The public wrapper is executable only by `authenticated`; the private schema is not in the exposed API schemas.

The session-aware server client, not the admin client, calls user-scoped RPCs so `auth.uid()` remains available. The admin client is reserved for trusted system operations that perform their own authorization.

### 6. Entity Idempotency

**Decision:** Idempotency is explicit-key based; request fingerprinting and key identity are separate values.

For `create_entity`:

1. Validate an optional key as 1-256 printable ASCII characters (`^[!-~]{1,256}$`). Whitespace is rejected anywhere; the key is never trimmed or case-folded, so hashing and comparison use the exact validated bytes.
2. Normalize the accepted payload (`workspace_id`, `entity_type`, trimmed `name`, and JSONB `properties`) into a canonical JSONB object.
3. Store its SHA-256 as `fingerprint`.
4. When a valid key is provided, store only `SHA-256(key)` as `idempotency_key_hash`.
5. Acquire `pg_advisory_xact_lock(hashtextextended(workspace_id || ':' || key, 0))` before checking/inserting.
6. Enforce a partial unique index on `(workspace_id, idempotency_key_hash)` when the hash is non-null.
7. Return the existing UUID for the same key and fingerprint.
8. Raise a deterministic invalid-parameter error when the same key is reused for a different fingerprint.
9. Without a key, insert a new row even if another row has the same fingerprint.

A separate bounded integration harness uses two database sessions and an observer: one transaction holds the advisory lock, the concurrent RPC is observed waiting in `pg_stat_activity`, and release proves both the matching-payload and conflicting-payload outcomes.

This avoids silently treating two legitimate entities with identical payloads as one and closes the earlier mismatch between lookup and inserted hashes.

### 7. JSONB Indexes

**Decision:** Index only operators the first slice expects.

- `entities.properties`: GIN with `jsonb_path_ops` for `@>` containment.
- `entity_properties.property_value`: separate GIN with `jsonb_path_ops`.
- `entity_properties (workspace_id, property_key)`: B-tree for tenant/key filtering.

A multicolumn GIN over `property_key TEXT` and `property_value JSONB` is rejected because plain text has no built-in default GIN operator class and the query operators differ. Key equality and JSONB containment can be combined by PostgreSQL with bitmap index operations when selective.

### 8. Collision-Safe Provisioning

**Decision:** A personal workspace has `personal_owner_id UUID UNIQUE`, nullable for non-personal workspaces.

`private.provision_user(p_user_id, p_email, p_user_metadata)` upserts the profile by `id`, reuses the existing personal workspace by `personal_owner_id`, upserts the owner membership, and returns the workspace UUID. The auth trigger delegates once to this helper. A slug is based on a sanitized human prefix plus a UUID-derived suffix; reservation is protected by the unique constraint and retries on the rare candidate conflict. Two users with the same email prefix therefore produce different slugs. pgTAP can replay the helper for an existing auth user and prove that it does not create another workspace.

User metadata supplies display text only. It is never used for authorization.

### 9. Next.js 16 Request Boundary

**Decision:** Use `src/proxy.ts`, not deprecated `src/middleware.ts`.

Proxy calls `supabase.auth.getClaims()` to validate/refresh the JWT, copies refreshed cookies to request and response, and performs only an optimistic unauthenticated redirect. It may parse the candidate workspace slug from the pathname, but it does not query the database, validate membership, or inject a trusted workspace ID header.

The authenticated workspace layout resolves the slug with the session-aware server client and RLS. The RPC independently verifies membership, so Proxy is never an authorization boundary.

### 10. Cookie and Key Conventions

**Decision:** Follow `@supabase/ssr` cookie handling and current Supabase key names.

- Public clients use `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY`.
- The server-only admin client uses `SUPABASE_SECRET_KEY`; legacy service-role fallback is allowed only for local compatibility.
- Auth cookies use `SameSite=Lax` and `Secure` in production.
- `HttpOnly` is not required because the browser Supabase client must access the refresh token to maintain the shared SSR session.
- User-specific/auth-refresh responses must not be shared-cacheable.

### 11. Toolchain Verification

**Decision:** Keep quality commands independent.

Next.js 16 no longer runs lint during `next build`, and `next lint` was removed. The project therefore defines and runs separate scripts for ESLint, TypeScript, Vitest, and the production build. Tailwind CSS 4 uses `postcss.config.mjs` with `@tailwindcss/postcss` and `@import "tailwindcss"`; no `tailwind.config.ts` is required for this slice.

## Testing Order

1. Write pgTAP contracts for schema, grants, RLS, provisioning, functions, composite foreign keys, and idempotency, plus the two-session concurrency harness.
2. Implement the migration until those contracts pass.
3. Write Vitest contracts for Phase 1 schemas, decoders, and limits.
4. Implement the pure domain layer.
5. Add clients, Proxy, authenticated workspace resolution, and the minimal app shell.
6. Run lint, typecheck, unit tests, database tests, and build independently.

## Deferred Decisions

- UUIDv7 adoption before production-scale ingestion
- Provenance and source modeling
- Entity mutation RPCs beyond create
- Role and membership administration flows
- Frequently queried generated columns for JSONB properties
- Integration and E2E test harness

## Primary References Checked

- [Next.js 16 upgrade guide](https://nextjs.org/docs/app/guides/upgrading/version-16)
- [Next.js Proxy convention](https://nextjs.org/docs/app/getting-started/proxy)
- [Supabase SSR client and Proxy guide](https://supabase.com/docs/guides/auth/server-side/nextjs)
- [Supabase SSR advanced cookie guidance](https://supabase.com/docs/guides/auth/server-side/advanced-guide)
- [Supabase Row Level Security](https://supabase.com/docs/guides/database/postgres/row-level-security)
- [Supabase database functions and privileges](https://supabase.com/docs/guides/database/functions)
- [Supabase API keys](https://supabase.com/docs/guides/getting-started/api-keys)
- [Tailwind CSS with Next.js](https://tailwindcss.com/docs/installation/framework-guides/nextjs)
- [PostgreSQL JSONB indexing](https://www.postgresql.org/docs/current/datatype-json.html#JSON-INDEXING)
- [PostgreSQL advisory locks](https://www.postgresql.org/docs/current/explicit-locking.html#ADVISORY-LOCKS)
