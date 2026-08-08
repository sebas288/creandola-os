# AGENTS.md

## Cursor Cloud specific instructions

### Repo boundary (ideological)

This repo is **Creándola OS** only.

- **In scope:** Context Engine substrate (Postgres schema, future Next.js operator app, workspace tenancy, CRM/seguimiento memory for Creándola as client zero).
- **Out of scope here:** the public marketing landing (`creandola-landing` is a **different** repository). Do not treat landing envs, WhatsApp tokens on the landing Vercel project, or `www.somoscreandola.co` deploy config as belonging to this codebase.
- **Graphify** (or similar code-knowledge tools): optional AI-dev tooling only — not a product feature of Creándola OS.

### Business priority

1. Dogfood **Creándola’s own operation** first — WhatsApp → CRM/seguimiento ([RFC 0005](docs/rfcs/0005-client-zero-whatsapp-crm.md), case `docs/context/casos/2026-07-06-creandola-operacion-interna/`).
2. External pilots reuse the **same** Phase 1 wedge via config/content; they do not redefine the build driver.
3. Do **not** expand `entity_type` or add Conversation/Message tables without OpenSpec. Prefer `entities.properties` for Contact/Deal until WU2 locks schemas.
4. Privacy: never commit real chats, phones, tokens, or client PII.

### Product scope (current tree)

- Implemented: database foundation (`supabase/migrations`, `supabase/tests`).
- Not present yet: `src/` / `app/` / domain Zod / Vitest app tests (WU2–WU3 in `openspec/changes/core-foundation/tasks.md`).
- Target hosting (when wiring later): Vercel project `creandola-os` (`*.vercel.app` = preview/dev; `os.somoscreandola.co` = production); Supabase project `jfaeahukuekyismvxpfw`.

### Working without secrets

Docs, RFCs, OpenSpec, SQL migrations, and pgTAP contracts can be edited without any env vars. Do not block structural/ideological work on Supabase/Vercel keys.

When credentials are eventually needed for hosted smoke tests:

1. Use **this OS project’s** keys only (dashboard for `jfaeahukuekyismvxpfw`), not the landing project.
2. Copy `.env.local.example` → `.env.local` (gitignored).

Local Docker + `supabase start` is optional and only for pgTAP / concurrency harness.

### Standard commands

See `README.md` and `package.json`. Quality gates (`lint`, `typecheck`, `test`, `build`) apply once app/domain source exists.
