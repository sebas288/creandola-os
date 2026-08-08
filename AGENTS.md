# AGENTS.md

## Cursor Cloud specific instructions

### Business priority (read first)

- **Client zero = Creándola’s own operation**, especially WhatsApp → CRM/seguimiento ([RFC 0005](docs/rfcs/0005-client-zero-whatsapp-crm.md), case `docs/context/casos/2026-07-06-creandola-operacion-interna/`).
- External pilots (Laura, Gecontri, …) reuse the **same** Phase 1 wedge via config/content; they do not redefine the first build driver.
- Do **not** expand `entity_type` or add Conversation/Message tables without an OpenSpec change. Prefer `entities.properties` for Contact/Deal fields until WU2 locks schemas.
- **Graphify** (code knowledge graphs) is optional AI-dev tooling only — not part of the product Scope.
- Privacy: never commit real chats, phones, tokens, or client PII.

### Product scope (current repo state)

Creándola OS targets **Next.js on Vercel + Supabase Cloud** (no self-managed Docker in production).

- Vercel project: `creandola-os` — preview/dev = `*.vercel.app`; production host = `os.somoscreandola.co`
- Supabase project ref: `jfaeahukuekyismvxpfw` (`https://jfaeahukuekyismvxpfw.supabase.co`)

In this repository today, the **implemented and testable surface is the database foundation** (`supabase/migrations`, `supabase/tests`). There is **no `src/` / `app/` / `pages/` directory yet**, so `npm run dev`, `npm run build`, `npm run lint`, `npm run typecheck`, and `npm test` cannot succeed until Work Units 2–3 land (see `openspec/changes/core-foundation/tasks.md`).

### Preferred local mode: production-like (no Docker)

1. `npm install`
2. Copy `.env.local.example` → `.env.local` and fill with **hosted** values from the Supabase dashboard for project `jfaeahukuekyismvxpfw` (Settings → API):
   - `NEXT_PUBLIC_SUPABASE_URL` → `https://jfaeahukuekyismvxpfw.supabase.co`
   - `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY` → publishable / anon key
   - `SUPABASE_SECRET_KEY` → secret / service_role key (server-only)
3. Apply migrations remotely when needed (`supabase link` + `supabase db push`), not via local Docker.
4. When the Next.js app exists: `npm run dev` (reads `.env.local`).

**Note:** Vercel env vars marked **Sensitive** cannot be pulled back via CLI after creation. Prefer Cursor secrets or re-paste keys when agents need them locally.

Do **not** assume a local stack on ports `54321`/`54322` unless Docker was explicitly requested for that session.

### What Docker local mode is for

`supabase start` + `supabase db reset` + `supabase test db` + `node supabase/tests/concurrency-harness.mjs` require Docker and the Supabase CLI. Use that path only when validating pgTAP / concurrency against a disposable local Postgres. The harness hard-codes `postgresql://postgres:postgres@127.0.0.1:54322/postgres`.

### Standard commands

See `README.md` and `package.json` scripts. Quality gates (`lint`, `typecheck`, `test`, `build`) are the intended gates once app/domain source and configs exist; they are not currently runnable as-is.
