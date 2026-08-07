# Proposal: Host-Workspace Resolution (Deferred)

Status: Deferred  
Depends on: `docs/rfcs/0004-delivery-strategy.md`, completed `core-foundation` WU2–WU3  
Precondition: First paying client uses the system in production **and** a real customer frontend domain is required

## Outcome

Add host-based workspace resolution so a customer frontend domain configured in Vercel (for example `portal.cliente.com`) maps to one workspace without provisioning separate infrastructure per customer.

## Why deferred

RFC 0004 delivery strategy: build for 1, template for 10. The critical path is the slug-based app shell (`/[workspaceSlug]`) with membership re-checked in the authenticated server layout. Custom domains and pre-auth host resolution expand foundation scope before any client has a production app. This change activates only when a customer domain is actually needed.

## Scope

### In Scope (when activated)

- `domain_mappings`: normalized frontend `host` → `workspace_id`, with status and uniqueness on host
- `workspace_settings`: customer-facing branding / presentation configuration (no secrets or integration credentials)
- Request sequence: host → `domain_mappings` → `workspace_id` → `workspace_settings` → Auth → active membership → RLS → experience
- Narrow pre-auth resolver (managed Supabase Edge Function or private server-side path using server-only secret/service role) that returns only safe public presentation fields
- Authenticated re-resolution of mappings and settings through RLS before private data is rendered
- Central platform auth entry (`app.somoscreandola.co/login` and `/auth/callback`) with host-bound continuation when an unauthenticated request arrives on a customer domain
- Explicit allowlisting and secure host-bound state if per-customer callbacks are later required

### Out of Scope

- One Supabase project, Custom Domain, VPS, or Docker deployment per customer
- Treating host match alone as authorization
- Anonymous table privileges on `domain_mappings` or `workspace_settings`
- Replacing slug-based routing for workspaces that do not use a custom domain

## Host resolution contract (parked)

```text
request host
  -> domain_mappings.host
  -> workspace_id
  -> workspace_settings
  -> Supabase Auth session validation
  -> active membership validation
  -> RLS-scoped data access
  -> workspace-specific experience
```

`domain_mappings` maps a normalized frontend host to one `workspace_id`. The mapping is platform configuration, not an authorization substitute: the authenticated user's active `memberships` row and Postgres RLS remain authoritative. Customer domains point to the same Vercel deployment and never imply a separate Supabase project, database, or server.

Before Auth, the application invokes only a narrow managed Supabase Edge Function or private server-side resolver. That resolver may use a server-only secret/service role to look up the normalized host and return only `workspace_id` plus safe public presentation fields such as active status, branding, locale, and explicitly public feature flags. It MUST NOT return private workspace data, membership data, secrets, integration credentials, or authorization decisions. Secrets and integration credentials do not belong in `workspace_settings`.

After Auth, the application MUST re-resolve and validate the host mapping and settings with an authenticated Supabase client. Those reads are filtered by RLS and an active membership before any private workspace data is rendered. A host match alone never authorizes access. There is no direct unauthenticated table privilege for `domain_mappings` or `workspace_settings`.

### Proposed tables

| Table | Required columns and constraints | Required indexes |
|-------|----------------------------------|------------------|
| `domain_mappings` | `id UUID PK`, `workspace_id UUID NOT NULL REFERENCES workspaces ON DELETE CASCADE`, normalized `host TEXT UNIQUE NOT NULL`, `status TEXT NOT NULL`, timestamps | Unique host; `(workspace_id, status)` |
| `workspace_settings` | `workspace_id UUID PK REFERENCES workspaces ON DELETE CASCADE`, customer-facing branding/feature configuration in validated JSONB or typed columns, timestamps | Primary key; add targeted indexes only for queried settings |

### Proposed RLS

| Object | `anon` | `authenticated` | Privileged backend |
|--------|--------|-----------------|--------------------|
| `domain_mappings` | No table privileges | SELECT only for active members of the mapped workspace, filtered by RLS | Resolver may read only normalized host, active status, workspace ID, and safe public presentation context through a server-only path |
| `workspace_settings` | No table privileges | SELECT only for active members of the workspace, filtered by RLS | Resolver may read only explicitly public presentation fields; secrets and integration credentials are prohibited |

Policies (when activated):

- `domain_mappings_select_member`: SELECT where `workspace_id IN (SELECT private.current_user_workspace_ids())`
- `workspace_settings_select_member`: SELECT where `workspace_id IN (SELECT private.current_user_workspace_ids())`

### Central authentication and custom frontend domains

Initial authentication entry point remains the central platform domain:

- Login: `https://app.somoscreandola.co/login`
- Callback: `https://app.somoscreandola.co/auth/callback`

The callback exchanges the Supabase Auth PKCE code, establishes the SSR session, and redirects to a safe same-origin relative destination. The initial phase does not claim that a customer frontend domain receives the central session. When an unauthenticated request arrives on a customer domain, the app routes the user to the central app or uses a host-bound, server-side continuation/reference; it never accepts an arbitrary cross-origin return URL. A callback hosted on a customer domain is a later phase and requires explicit domain allowlisting plus a secure host-bound state/continuation design.

## Requirements sketch (for future specs)

### Host-Based Workspace Resolution

The application MUST resolve the customer experience from the request host in this order: request host, `domain_mappings`, `workspace_id`, `workspace_settings`, Supabase Auth session, active membership, RLS-scoped data, and workspace experience. `domain_mappings` MUST map frontend domains configured in Vercel; it MUST NOT be treated as a Supabase Custom Domain.

#### Scenario: Known customer host resolves a workspace

- GIVEN a normalized host exists in `domain_mappings`
- WHEN a request reaches the single Next.js app on Vercel
- THEN the app obtains the mapped `workspace_id`
- AND loads that workspace's `workspace_settings`
- AND continues only after Supabase Auth and active membership validation

#### Scenario: Unknown host is not authorized by host alone

- GIVEN a host is absent from `domain_mappings` or the user lacks an active membership
- WHEN the request attempts to load workspace data
- THEN the app does not expose tenant data
- AND RLS remains the final database boundary

#### Scenario: Pre-auth resolver returns only safe public context

- GIVEN a request has a normalized host but no validated Supabase Auth session
- WHEN the managed Edge Function or private server-side resolver performs host resolution
- THEN it may read only non-sensitive `domain_mappings` fields and explicitly public `workspace_settings` presentation fields using a server-only secret/service role when required
- AND it returns no membership, private tenant data, secrets, integration credentials, or authorization decision
- AND it does not grant direct unauthenticated table access

#### Scenario: Authenticated request re-resolves through RLS

- GIVEN Supabase Auth validates the session
- WHEN the application renders a customer workspace
- THEN it re-resolves `domain_mappings` and `workspace_settings` through authenticated RLS-backed reads
- AND an active membership for the resolved `workspace_id` is required before private data is rendered
- AND host resolution alone never authorizes access

#### Scenario: Customer domain does not provision infrastructure

- GIVEN a workspace has `portal.cliente.com` or another custom frontend domain
- WHEN Vercel routes that domain to the app
- THEN the request uses the same Next.js deployment, Supabase project, and multi-workspace database
- AND no customer-specific VPS, Docker deployment, Supabase Custom Domain, or backend is created

#### Scenario: Customer frontend domain uses central authentication

- GIVEN a user visits a customer frontend domain served by the Vercel-hosted app
- WHEN authentication is required
- THEN the flow uses the central `app.somoscreandola.co/login` and `app.somoscreandola.co/auth/callback` routes
- AND the app routes the user back using a host-bound, server-side continuation/reference or leaves the user on the central app
- AND the flow does not assume that the customer domain receives the central session in this phase

#### Scenario: Per-customer callback is deferred further

- GIVEN a future requirement for callbacks hosted on customer domains
- WHEN the auth architecture is extended
- THEN the callback may be enabled per customer domain through explicit configuration
- AND the customer domain is explicitly allowlisted
- AND a secure host-bound state/continuation design is approved and implemented
- AND the central callback remains the initial supported flow

## Risks

| Risk | Mitigation |
|------|------------|
| Host treated as authorization | Re-check membership via RLS after Auth; never grant anon table access |
| Secret leakage via settings | Prohibit secrets/credentials in `workspace_settings`; resolver returns public fields only |
| Scope creep before production use | Keep this change Deferred until RFC 0004 preconditions are met |

## Rollback

Drop `domain_mappings` and `workspace_settings` (and related policies/functions) after removing app resolver paths. Slug-based workspace routing remains the fallback.
