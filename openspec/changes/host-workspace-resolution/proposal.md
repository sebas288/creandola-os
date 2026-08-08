# Proposal: Host-Workspace Resolution

Status: Active (split delivery)  
Depends on: `docs/rfcs/0004-delivery-strategy.md`, `core-foundation` WU1  
Decision: **1C + 2A** — database tables now (WU1b); app host resolution in WU3; Cloudflare DNS → Vercel origin

## Outcome

Map customer frontend hosts (already held in Cloudflare) to one workspace so a single Vercel Next.js app can serve many domains without per-customer infrastructure.

## Delivery split

| Slice | When | What |
|-------|------|------|
| **WU1b — Schema** | Now, before WU2 | `domain_mappings`, `workspace_settings`, indexes, RLS SELECT for members, no authenticated writes |
| **WU3 — App wiring** | With app shell | Pre-auth narrow resolver (safe public fields only), authenticated RLS re-resolution, central auth + host-bound continuation notes |

Slug routes remain. Host match alone never authorizes access.

## Infrastructure boundary (2A)

```text
Customer / platform DNS in Cloudflare
  -> CNAME/A to Vercel (orange cloud optional)
  -> single Next.js deployment
  -> domain_mappings.host -> workspace_id
  -> workspace_settings (public presentation)
  -> Supabase Auth + active membership + RLS
```

- Cloudflare: DNS (and optional proxy). Not the application runtime.
- Vercel: hosts the app; add each customer hostname in the Vercel project.
- Supabase: one project; never one Custom Domain / project per customer.

## Scope

### In Scope (WU1b — now)

- `domain_mappings`: normalized lowercase `host` → `workspace_id`, status, unique host
- `workspace_settings`: `workspace_id` PK, presentation JSONB (object only; no secrets)
- RLS: authenticated SELECT for active members; no anon/authenticated INSERT/UPDATE/DELETE
- Writes via service_role / migration owner / future admin tooling only

### In Scope (WU3 — with app shell)

- Request sequence: host → mapping → settings → Auth → membership → RLS → experience
- Narrow pre-auth resolver (Edge Function or server-only secret path) returning only safe public fields
- Authenticated re-resolution through RLS before private data
- Central auth: `os.somoscreandola.co/login` and `/auth/callback`; no claim that customer domains receive the central session in this phase
- Note: public marketing site (`creandola-landing` / `www.somoscreandola.co`) is a separate repository and is not the OS auth host

### Out of Scope

- One Supabase project, Custom Domain, VPS, or Docker deployment per customer
- Treating host match alone as authorization
- Anonymous table privileges on these tables
- Per-customer OAuth callbacks (later; needs allowlisting)
- Replacing slug routing for workspaces without a custom domain

## Tables

| Table | Required columns and constraints | Required indexes |
|-------|----------------------------------|------------------|
| `domain_mappings` | `id UUID PK`, `workspace_id UUID NOT NULL REFERENCES workspaces ON DELETE CASCADE`, normalized `host TEXT UNIQUE NOT NULL` (lowercase ASCII hostname, no scheme/port/path), `status TEXT NOT NULL`, timestamps | Unique host; `(workspace_id, status)` |
| `workspace_settings` | `workspace_id UUID PK REFERENCES workspaces ON DELETE CASCADE`, `presentation JSONB NOT NULL DEFAULT '{}'` object check, timestamps | Primary key |

## RLS

| Object | `anon` | `authenticated` | Privileged backend |
|--------|--------|-----------------|--------------------|
| `domain_mappings` | No table privileges | SELECT only for active members of the mapped workspace | Service role / admin for writes; pre-auth resolver reads safe fields only via server-only path |
| `workspace_settings` | No table privileges | SELECT only for active members | Same; presentation fields only in pre-auth responses; secrets prohibited in this table |

Policies:

- `domain_mappings_select_member`
- `workspace_settings_select_member`

## Risks

| Risk | Mitigation |
|------|------------|
| Host treated as authorization | Re-check membership via RLS after Auth; no anon grants |
| Secret leakage via settings | Only `presentation` JSONB; no credentials column |
| DNS misconfiguration | Document Cloudflare → Vercel hostname checklist in WU3 / AGENTS.md |

## Rollback

Drop `domain_mappings` and `workspace_settings` after removing app resolver paths. Slug routing remains.
