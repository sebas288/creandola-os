# Data Access Layer Specification

## Purpose

Define separate public-session, browser-auth, and privileged backend clients without allowing the privileged client to become the default user authorization path.

## Requirements

### Requirement: Three Supabase Clients

The system MUST provide these clients:

| Client | File | Key | Responsibility |
|--------|------|-----|----------------|
| Server | `src/infrastructure/supabase/server.ts` | Publishable | Per-request SSR reads and user-scoped RPC calls using session cookies |
| Browser | `src/infrastructure/supabase/browser.ts` | Publishable | OAuth/auth-state operations only by project convention |
| Admin | `src/infrastructure/supabase/admin.ts` | Secret | Explicit trusted backend operations with prior authorization |

The public environment names MUST be `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY`. The privileged name MUST be `SUPABASE_SECRET_KEY`; a documented legacy service-role fallback MAY be used only when local tooling lacks secret-key support.

#### Scenario: Browser bundle contains no privileged key

- GIVEN the production browser artifacts
- WHEN environment references and bundle strings are inspected
- THEN no secret or service-role key value/name is reachable from client code

#### Scenario: Admin import is server-only

- GIVEN a client component imports the admin module
- WHEN `npm run build` executes
- THEN the build fails because the module imports `server-only`

#### Scenario: User-scoped RPC preserves identity

- GIVEN an authenticated entity-creation request
- WHEN the data wrapper calls `create_entity`
- THEN it uses the server-session client
- AND the database can read `auth.uid()` from the user's JWT
- AND the admin client is not imported by that wrapper

### Requirement: Per-Request Client Isolation

Server and admin clients MUST be constructed inside the request/job boundary and SHALL NOT be stored as mutable module-global clients carrying user session state.

#### Scenario: Requests do not share sessions

- GIVEN two requests from different users on a reused server process
- WHEN server clients are created
- THEN each reads only its own request cookies
- AND neither request observes the other's session

### Requirement: SSR Cookie Handling

The application MUST use current `@supabase/ssr` cookie adapters. Auth cookies MUST use `SameSite=Lax` and `Secure` in production. They SHALL NOT be forced to `HttpOnly`, because the browser client participates in refresh-token maintenance. Auth-refresh responses MUST propagate the library's cache-prevention headers.

#### Scenario: Production cookie attributes are safe

- GIVEN production HTTPS
- WHEN auth cookies are set or refreshed
- THEN `SameSite=Lax` and `Secure` are applied
- AND the response is not shared-cacheable

#### Scenario: Local development remains usable

- GIVEN localhost over HTTP
- WHEN auth cookies are set
- THEN `Secure` is not forced
- AND the browser client can maintain the SSR session

### Requirement: Open Redirect Prevention

Login, callback, and Proxy return paths MUST accept only same-origin relative paths beginning with exactly one `/`. External URLs, protocol-relative paths, backslash variants, and malformed encodings MUST fall back safely.

#### Scenario: Relative path is accepted

- GIVEN `redirectTo=/acme/entities`
- WHEN authentication completes
- THEN the user is redirected to `/acme/entities`

#### Scenario: Unsafe destination is rejected

- GIVEN `https://evil.example`, `//evil.example`, or an equivalent encoded value
- WHEN authentication completes
- THEN it is ignored
- AND the default workspace route is used

### Requirement: Runtime Row Decoding

Every Phase 1 entity or relationship row returned by a data wrapper MUST pass through its domain decoder before reaching application code.

#### Scenario: Malformed database row does not escape

- GIVEN a row missing `workspace_id` or containing invalid properties
- WHEN a data wrapper receives it
- THEN decoding raises a stable domain validation error
- AND untyped data is not returned
