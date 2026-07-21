# Auth and Tenancy Specification

## Purpose

Provide Google OAuth, idempotent personal-workspace provisioning, active-membership RLS, and a Next.js 16 session-refresh boundary.

## Requirements

### Requirement: Profile Identity

`profiles.id` MUST equal and reference `auth.users.id`. The schema SHALL NOT contain a separate `profiles.user_id` column.

#### Scenario: Auth identity maps directly

- GIVEN an authenticated user UUID
- WHEN their profile and memberships are resolved
- THEN `profiles.id = auth.uid()`
- AND `memberships.profile_id = auth.uid()` is sufficient without another profile lookup column

### Requirement: OAuth Flow

The system MUST provide Google OAuth login, callback, and signout routes. Callback and return destinations MUST accept only same-origin relative paths beginning with one `/`.

#### Scenario: Successful sign-in

- GIVEN a valid Google OAuth callback
- WHEN the PKCE code is exchanged
- THEN the session is stored through `@supabase/ssr`
- AND the user is redirected to the validated relative destination or default personal workspace

#### Scenario: External destination is rejected

- GIVEN an external, protocol-relative, or malformed return destination
- WHEN login/callback handles it
- THEN the value is ignored
- AND a safe default route is used

#### Scenario: Signout clears the session

- GIVEN an authenticated user
- WHEN the signout route executes
- THEN Supabase clears the session cookies
- AND the response redirects to `/login`

### Requirement: Idempotent Provisioning

`private.provision_user(p_user_id uuid, p_email text, p_user_metadata jsonb) returns uuid` MUST idempotently upsert one profile, one personal workspace, and one active owner membership, then return the workspace UUID. Personal workspace identity MUST be constrained by unique `personal_owner_id`. A thin `private.handle_new_user()` trigger on `auth.users` INSERT MUST delegate `NEW` values to this helper and return `NEW`. Both functions MUST be definer functions with empty search path in the unexposed private schema and no direct EXECUTE grant to `PUBLIC`, `anon`, or `authenticated`.

#### Scenario: New user is provisioned

- GIVEN a new auth user
- WHEN the trigger runs
- THEN exactly one profile, one personal workspace owned by that profile, and one owner membership exist

#### Scenario: Provisioning is replayed

- GIVEN one auth user whose INSERT trigger already created the provisioning rows
- WHEN pgTAP calls `private.provision_user` again as the migration/test owner with that user's values
- THEN the helper returns the existing workspace UUID
- AND row counts remain one profile, one personal workspace, and one membership

#### Scenario: Slug bases collide

- GIVEN two users whose email/display names sanitize to the same base
- WHEN both are provisioned
- THEN both transactions succeed
- AND their workspace slugs are distinct and valid

### Requirement: Multi-Workspace RLS

`private.current_user_workspace_ids()` MUST return active workspace IDs whose membership `profile_id = auth.uid()`. It MUST be `STABLE SECURITY DEFINER`, live in the unexposed `private` schema, use `search_path = ''`, and be executable only as required for authenticated policy evaluation.

#### Scenario: Active member can read

- GIVEN a user has an active membership
- WHEN they SELECT the workspace and Phase 1 context rows
- THEN rows from that workspace are visible

#### Scenario: Inactive/nonmember cannot read

- GIVEN a user has an inactive membership or no membership
- WHEN they SELECT rows from that workspace
- THEN zero matching rows are returned

#### Scenario: Function security is hardened

- GIVEN catalog metadata for the helper
- WHEN schema, security mode, configuration, and grants are inspected
- THEN it is a definer in `private` with empty search path
- AND it has no EXECUTE grant for `PUBLIC` or `anon`

### Requirement: Role-Limited Writes

`create_entity` MUST authorize the JWT user inside the database. Active owner, admin, and member roles MAY create; viewer, inactive, unauthenticated, and nonmember callers MUST be rejected.

#### Scenario: Writer roles are accepted

- GIVEN separate active owner, admin, and member sessions
- WHEN each calls `create_entity` in their workspace
- THEN each call succeeds with `created_by = auth.uid()`

#### Scenario: Read-only or unauthorized role is rejected

- GIVEN a viewer, inactive member, nonmember, or unauthenticated caller
- WHEN `create_entity` is called
- THEN no entity is inserted

### Requirement: Next.js 16 Proxy

The app MUST use `src/proxy.ts` to refresh Supabase sessions with `getClaims()` and perform optimistic unauthenticated redirects. Proxy SHALL NOT be the authoritative workspace authorization layer.

#### Scenario: Session is refreshed

- GIVEN an expired access token and valid refresh token
- WHEN a matched request passes through Proxy
- THEN refreshed cookies are copied to request and response
- AND the request continues

#### Scenario: Workspace authorization is deferred

- GIVEN an authenticated user requests a workspace slug they cannot access
- WHEN Proxy processes the request
- THEN Proxy performs no workspace database lookup
- AND the authenticated server layout denies the workspace through an RLS-backed lookup

#### Scenario: Deprecated convention is absent

- GIVEN the application source
- WHEN request-boundary files are inspected
- THEN `src/proxy.ts` exports `proxy`
- AND no `src/middleware.ts` is present
