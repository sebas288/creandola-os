# AGENTS.md

## Cursor Cloud specific instructions

### Product scope (current repo state)

Creándola OS is designed as **Next.js on Vercel + Supabase Cloud** (no self-managed Docker in production). In this repository today, the **implemented and testable surface is the database foundation** (`supabase/migrations`, `supabase/tests`). There is **no `src/` / `app/` / `pages/` directory yet**, so `npm run dev`, `npm run build`, `npm run lint`, `npm run typecheck`, and `npm test` cannot succeed until Work Units 2–3 land (see `openspec/changes/core-foundation/tasks.md`).

### Preferred local mode: production-like (no Docker)

Cloud agents and contributors may develop **against a hosted Supabase project** instead of `supabase start` (Docker):

1. `npm install`
2. Copy `.env.local.example` → `.env.local` and fill with **hosted** values from the Supabase dashboard (Project Settings → API):
   - `NEXT_PUBLIC_SUPABASE_URL` → `https://<project-ref>.supabase.co`
   - `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY` → publishable / anon key
   - `SUPABASE_SECRET_KEY` → secret / service_role key (server-only)
3. Apply migrations to the remote project when needed (`supabase link` + `supabase db push`), not via local Docker.
4. When the Next.js app exists: `npm run dev` (reads `.env.local`).

Do **not** assume a local stack on ports `54321`/`54322` unless Docker was explicitly requested for that session.

### What Docker local mode is for

`supabase start` + `supabase db reset` + `supabase test db` + `node supabase/tests/concurrency-harness.mjs` require Docker and the Supabase CLI. Use that path only when validating pgTAP / concurrency against a disposable local Postgres. The harness hard-codes `postgresql://postgres:postgres@127.0.0.1:54322/postgres`.

### Standard commands

See `README.md` and `package.json` scripts. Quality gates (`lint`, `typecheck`, `test`, `build`) are the intended gates once app/domain source and configs exist; they are not currently runnable as-is.
