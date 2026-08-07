# Proposal: Core Foundation

## Outcome

Create the smallest secure foundation on which later Context Engine changes can build: a Next.js 16 application shell, Supabase authentication and tenancy, the Phase 1 canonical entity schema, typed data-access boundaries, and pure domain validation. Delivery order follows [RFC 0004 — Delivery Strategy](../../../docs/rfcs/0004-delivery-strategy.md): WU1b host-mapping schema now, then WU2–WU3 (app wiring includes host resolution); AI infrastructure stays deferred.

## Scope

### In Scope

- Project scaffolding: Next.js 16, React 19, Node.js 20.9+, TypeScript strict, Tailwind CSS 4, ESLint flat config, Vitest, and Supabase local development
- Auth and tenancy schema: `profiles`, `workspaces`, and `memberships`
- Host mapping schema (WU1b): `domain_mappings` and `workspace_settings` (Cloudflare DNS → Vercel; app resolution in WU3 — see `host-workspace-resolution`)
- Phase 1 context schema: `entities`, `entity_properties`, and `relationships`
- RLS and least-privilege grants for every table in `public`
- Private `SECURITY DEFINER` helpers and a public `SECURITY INVOKER` `create_entity` RPC boundary
- Explicit-key entity idempotency using a request fingerprint, hashed idempotency key, transaction advisory lock, and unique constraint
- Three Supabase clients: server-session, browser auth-only, and server-only admin
- Next.js 16 `proxy.ts` for session refresh and an optimistic auth gate; authoritative workspace authorization in the server layout/RPC
- Zod 4 schemas and runtime decoders for the Phase 1 entity and relationship models
- pgTAP database contracts and Vitest domain tests

### Out of Scope

- `events`, `sources`, `evidence`, `memories`, `documents`, `context_packs`, `ai_runs`, and `access_policies` tables
- Provenance foreign keys such as `source_id`
- Entity update/delete RPCs, membership management, and workspace creation outside initial provisioning
- Per-customer OAuth callbacks on customer domains (central app auth first)
- WhatsApp, email, AI infrastructure / embeddings / pgvector, dashboards, metrics, external integrations, and file assets
- Full integration or browser E2E coverage beyond the app-shell smoke checks

## Capabilities

### New Capabilities

- `auth-tenancy`: Google OAuth provisioning creates one profile, one collision-safe personal workspace, and one owner membership. Active memberships drive read access.
- `entity-model`: One `entities` table, extensible `entity_properties`, and a directed `relationships` graph with database-enforced workspace consistency.
- `data-access`: Public/session, browser, and privileged server clients with explicit trust boundaries.
- `domain-validation`: Phase 1 entity and relationship schemas, decoders, and shared limits.
- `project-scaffolding`: A buildable Next.js 16/Tailwind 4 application with independent lint, typecheck, test, and build commands.

## Approach

Use one graph-native `entities` table with `properties JSONB`. Every tenant table includes `workspace_id`; composite foreign keys prevent child rows and relationships from crossing workspaces. Authenticated clients receive SELECT access through operation-specific RLS policies but no direct table mutations.

User-scoped entity creation uses the session-aware server client to call `public.create_entity`, a `SECURITY INVOKER` API wrapper. The wrapper delegates to an implementation in an unexposed `private` schema. That implementation is `SECURITY DEFINER`, fixes `search_path`, verifies `auth.uid()` is an active owner/admin/member, and performs the insert. The admin client remains available only for explicitly trusted system work and is not the default user write path.

Idempotency is opt-in. A supplied key MUST contain 1-256 printable ASCII characters (`!` through `~`): whitespace is invalid anywhere, the value is never trimmed, and comparison is exact and case-sensitive. The RPC hashes those validated bytes, serializes concurrent attempts with a transaction advisory lock, and stores a canonical SHA-256 request fingerprint. A retry with the same key and payload returns the original UUID; reuse with different payload is rejected. Without a key, identical payloads may create distinct entities.

## Affected Areas

| Area | Impact | Description |
|------|--------|-------------|
| `supabase/migrations/` | New | Schemas, enums, tables, constraints, indexes, triggers, RLS, grants, and functions |
| `supabase/tests/` | New | pgTAP contracts for schema, tenancy, privileges, RLS, provisioning, and idempotency |
| `src/domain/` | New | Phase 1 types, Zod schemas, decoders, limits, and errors |
| `src/infrastructure/supabase/` | New | Server, browser, admin, and proxy session utilities |
| `src/infrastructure/supabase/db/` | New | Authenticated RPC/read wrappers |
| `src/app/` and `src/proxy.ts` | New | App shell, OAuth routes, session refresh, and workspace route resolution |
| Root configuration | New | Next.js, PostCSS/Tailwind, ESLint, TypeScript, Vitest, npm scripts, and Supabase config |

## Risks

| Risk | Mitigation |
|------|------------|
| Privileged function escalation | Keep definers in unexposed `private`, set `search_path = ''`, schema-qualify every object, revoke default function execution, and test grants |
| Tenant-crossing child rows | Include `workspace_id` in child tables and enforce composite foreign keys to `(workspace_id, id)` |
| Duplicate or conflicting retries | Separate `idempotency_key_hash` from request `fingerprint`; lock and reject key reuse with a changed payload |
| Slug collisions | Use a UUID-derived suffix plus a unique constraint and retry the reservation on the rare conflicting candidate |
| Proxy treated as authorization | Restrict Proxy to token refresh and optimistic routing; re-check workspace membership in server code and the RPC |
| Secret key misuse | Keep the admin client server-only and out of user-scoped request flows |

## Rollback

For local development, run `supabase db reset` after reverting the change. Before any shared deployment, the migration must document reverse dependency order: API wrappers, private functions, trigger, tables, enums, and schemas. This change assumes no production data.

## Success Criteria

- [ ] `supabase db reset` applies the migration from an empty local database.
- [ ] `supabase test db` proves schema constraints, cross-workspace foreign keys, RLS visibility, denied direct writes, function privileges, provisioning idempotency, slug collision handling, and all idempotency branches.
- [ ] A bounded two-session concurrency harness observes advisory-lock waiting, then proves matching concurrent retries converge and conflicting concurrent retries fail deterministically.
- [ ] `npm run lint`, `npm run typecheck`, `npm test -- --run`, and `npm run build` all exit 0 independently.
- [ ] `src/proxy.ts` refreshes Supabase auth with `getClaims()` and never performs authoritative workspace authorization.
- [ ] A workspace server layout rejects a slug that the authenticated user cannot access.
- [ ] Browser bundles contain only the publishable key; privileged keys are guarded by `server-only`.
