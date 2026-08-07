# Tasks: Core Foundation

## Review Workload Forecast

| Field | Forecast |
|-------|----------|
| Estimated changed lines | 900-1,200 |
| 400-line review risk | High |
| Recommended delivery | Three chained review units |
| Proposed chain | DB foundation -> domain -> application wiring |
| Proposed chain strategy | `stacked-to-main` |
| Decision before apply | Confirm delivery/chain strategy and refresh estimates after scaffolding |

Each implementation task below has an observable acceptance condition. Tests and production code stay in the same work unit.

## Work Unit 1: Database Foundation

- [x] **1.1 Discover local tool contracts.** Run `supabase --version`, `supabase --help`, `supabase migration new --help`, and `supabase test db --help`; record the supported commands in the implementation handoff.
  - Acceptance: the handoff contains the installed CLI version and exact commands used; no migration filename was invented manually.

- [x] **1.2 Scaffold the project and local Supabase configuration.** Create the package manifest, lockfile, `supabase/config.toml`, `.gitignore`, `.env.local.example`, and required root directories without committing secrets.
  - Acceptance: a secret scan finds no key values; `.env.local` is ignored; the example contains only `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY`, and `SUPABASE_SECRET_KEY` names/placeholders.

- [x] **1.3 Write RED pgTAP catalog tests.** Specify enums, schemas, columns, checks, unique constraints, composite foreign keys, FK indexes, JSONB operator classes, RLS enablement, and exact function security/grants.
  - Acceptance: `supabase test db` fails before the core migration for named missing contracts, including no `profiles.user_id`, no Phase 1 `source_id`, and no definer function in an exposed schema.

- [x] **1.4 Write RED pgTAP behavior tests and the concurrency harness.** Cover replay by calling `private.provision_user` as test owner after one trigger-driven auth-user insert, same-base slug collisions, per-operation RLS, denied direct writes, role-limited entity creation, cross-workspace constraints, every idempotency branch, and two-session serialization.
  - Acceptance: provisioning replay asserts the same returned workspace UUID and unchanged row counts; pgTAP distinguishes RLS invisibility from privilege errors; a bounded two-session harness plus observer fails before implementation and is able to assert advisory-lock waiting for matching and conflicting payload cases.

- [x] **1.5 Generate and implement the core migration.** Use `supabase migration new core_schema`, then add `private`, enums, six tables, constraints, indexes, provisioning trigger, RLS, and least-privilege grants.
  - Acceptance: catalog tests prove `profiles.id -> auth.users.id`, `workspace_id` exists on all tenant tables, both relationship endpoints use composite FKs, and all FK columns have usable leading indexes.

- [x] **1.6 Implement hardened function boundaries.** Add `private.current_user_workspace_ids`, idempotent `private.provision_user`, thin `private.handle_new_user`, `private.create_entity_impl`, and the `public.create_entity` invoker wrapper.
  - Acceptance: the trigger delegates to `provision_user`; pgTAP can replay the helper as migration/test owner; every definer is in `private`, has `search_path = ''`, schema-qualifies relations, and exposes only the exact EXECUTE grants in the design matrix.

- [x] **1.7 Implement explicit-key idempotency.** Validate `^[!-~]{1,256}$` without trimming/normalization/case-folding, separate `idempotency_key_hash` from canonical request `fingerprint`, lock by workspace/exact key, and reject changed-payload key reuse.
  - Acceptance: DB tests accept `!`, `~`, and a 256-character printable key; reject empty/257-character keys, space/tab/newline, other controls, DEL, and Unicode with SQLSTATE `22023`; case variants are distinct; the concurrent same-payload call is observed waiting then returns the same UUID/one row; the concurrent changed-payload call is observed waiting then fails with `22023`/unchanged original row; different-workspace keys are independent and keyless calls remain distinct.

- [x] **1.8 Verify Work Unit 1.** Reset from empty state, run database tests plus the bounded two-session concurrency harness, and inspect Supabase database/security advisors if supported by the installed CLI.
  - Acceptance: `supabase db reset`, `supabase test db`, and the concurrency harness exit 0; the harness leaves no open test transactions; all advisor findings are fixed or recorded with a reason before review.

## Work Unit 2: Pure Domain Layer

- [ ] **2.1 Write RED Vitest contracts for limits and base schemas.** Cover entity/workspace/property/relationship limits, JSON object requirements, UUIDs, enum values, and idempotency key `^[!-~]{1,256}$` parity.
  - Acceptance: paired Zod/DB fixtures accept `!`, `~`, and 256 printable characters; reject empty/257-character values, space/tab/newline, other controls, DEL, and Unicode; and prove case variants remain distinct without trimming.

- [ ] **2.2 Write RED per-type schema tests.** Cover strict schemas for all eight entity discriminants: client optional email, project optional date range, meeting optional datetime range, and strict empty objects for decision/task/document/process/report.
  - Acceptance: every type has a valid fixture; client/project/meeting have their specified invalid fixture; one parameterized test injects an unknown key into each of all eight types and every schema rejects it; no test invents workflow rules such as task status transitions.

- [ ] **2.3 Write RED decoder tests.** Cover `EntityRow` and `RelationshipRow`, including missing workspace IDs, malformed JSONB values, timestamp conversion policy, and unknown columns.
  - Acceptance: malformed rows throw `ValidationError`; valid rows return the documented domain shapes.

- [ ] **2.4 Implement Phase 1 types and limits.** Create entity/relationship types and constants with names that distinguish entity name, workspace name, property key, relationship type, slug, and idempotency key limits.
  - Acceptance: TypeScript compiles with no duplicate `name`/`title` concept; `IDEMPOTENCY_KEY_MAX_LENGTH` is 256 with printable-ASCII/no-whitespace semantics; constants match the database contract asserted by tests.

- [ ] **2.5 Implement Zod 4 schemas.** Create the discriminated entity union and relationship schema with the specified refinements.
  - Acceptance: all schema tests pass and inferred TypeScript types are assignable to the exported domain interfaces.

- [ ] **2.6 Implement decoders and errors.** Decode only Phase 1 database rows and map Zod failures to stable domain errors.
  - Acceptance: decoder tests pass; no Event/Source/Memory/ContextPack/AccessPolicy decoder exists in this change.

- [ ] **2.7 Verify Work Unit 2.** Run unit tests, typecheck, and a dependency-boundary scan.
  - Acceptance: `npm test -- --run` and `npm run typecheck` exit 0; `src/domain` imports none of `next`, `react`, `@supabase/*`, or `server-only`.

## Work Unit 3: Data Access and App Shell

- [ ] **3.1 Write RED client-boundary tests/static assertions.** Specify environment variable names, per-request client creation, browser/admin separation, and server-only protection.
  - Acceptance: tests fail before clients exist and explicitly reject privileged key references from browser-importable modules.

- [ ] **3.2 Implement server and browser Supabase clients.** Use `@supabase/ssr`, publishable keys, and current cookie adapters.
  - Acceptance: server client reads/writes cookies through the request boundary; browser client exposes auth operations by convention and contains no secret-key environment reference.

- [ ] **3.3 Implement the admin client.** Use `SUPABASE_SECRET_KEY`, `import 'server-only'`, disabled session persistence/refresh, and per-request/job construction.
  - Acceptance: a client-component import fixture fails the build; no user-scoped `createEntity` wrapper imports the admin client.

- [ ] **3.4 Implement authenticated DB wrappers.** Add entity RPC/read wrappers and workspace-by-slug lookup using the server-session client and domain decoders.
  - Acceptance: `createEntity` calls only `public.create_entity`; every returned row passes through the Phase 1 decoder; inaccessible workspaces are represented without leaking existence.

- [ ] **3.5 Write RED Proxy/auth-routing tests.** Cover `getClaims()`, refreshed request/response cookies, matcher exclusions, unauthenticated redirects, safe return paths, and the prohibition on workspace DB authorization in Proxy.
  - Acceptance: tests fail before `src/proxy.ts` exists and include protocol-relative/external redirect rejection.

- [ ] **3.6 Implement Next.js 16 Proxy.** Create `src/proxy.ts` plus the Supabase proxy utility; perform session refresh and optimistic auth gating only.
  - Acceptance: the exported function is named `proxy`; no `middleware.ts` exists; no Proxy module queries workspaces or injects a trusted workspace ID header; `getSession()` is not used for authorization.

- [ ] **3.7 Implement OAuth routes.** Add login, callback, and signout behavior with PKCE exchange and validated same-origin relative destinations.
  - Acceptance: successful callback reaches the requested relative route; `https://evil.example`, `//evil.example`, and malformed destinations fall back safely; signout clears the session.

- [ ] **3.8 Implement the authenticated workspace shell.** Add root layout/styles and `[workspaceSlug]` layout/page; resolve membership in server code through RLS.
  - Acceptance: an authenticated member can load their workspace; a nonmember gets non-disclosing not-found/forbidden behavior even if Proxy allowed the request.

- [ ] **3.9 Configure the Next.js 16/Tailwind 4 toolchain.** Add `next.config.ts`, `tsconfig.json`, `eslint.config.mjs`, `postcss.config.mjs`, `vitest.config.ts`, scripts, and `@import "tailwindcss"`.
  - Acceptance: no `next lint` script and no unnecessary `tailwind.config.ts`; Node engine is `>=20.9`; lint, typecheck, test, and build scripts are separate.

- [ ] **3.10 Document repository conventions.** Add/update `AGENTS.md` with the trust boundaries, `private` function rule, RLS/write model, idempotency semantics, Next.js 16 Proxy convention, and local docs-first requirement.
  - Acceptance: a reviewer can locate every required convention by heading or search term and no text recommends `middleware.ts`, legacy anon/service-role keys as the default, or public definer functions.

- [ ] **3.11 Verify Work Unit 3 and full slice.** Run all quality and database gates from a clean state.
  - Acceptance: `npm run lint`, `npm run typecheck`, `npm test -- --run`, `npm run build`, `supabase db reset`, and `supabase test db` all exit 0 independently; browser artifact inspection finds no secret key.

## Deferred Work

- Integration/E2E flow tests beyond this app-shell slice
- Entity update/delete, membership management, and workspace-management RPCs
- Events, sources, evidence, memories, context packs, `ai_runs`, embeddings/pgvector, and access policies (RFC 0004: after first production client use)
- Host-based workspace resolution and customer frontend domains — see `openspec/changes/host-workspace-resolution/`
- UUIDv7 and generated-column optimization decisions
