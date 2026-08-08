# Creándola OS

**A shared company intelligence OS: Context Engine substrate for human service + agents — interpret, decide, and present — not a self-serve SME tool alone.**

Creándola OS is not another CRM, not another project manager, not another wiki. It is the operational memory layer under Creándola’s service delivery: one app, many workspaces, agents that draft, humans that commit.

**Not this repo:** the public marketing site (`creandola-landing` / `somoscreandola.co`) is a separate codebase for brand and acquisition. This repository is only the OS.

## Why this exists

Most companies don't suffer from a lack of tools. They suffer from a lack of connected context. Their information lives in WhatsApp, email, Drive, Figma, GitHub, spreadsheets, CRM, meetings, notes, contracts, and the founder's memory.

The problem isn't that the information doesn't exist. The problem is that it's fragmented, unlinked, and rarely converted into organizational memory. Creándola OS exists to turn scattered information into actionable context.

## Core concept: Context Engine

A knowledge graph describes how information is structured. A Context Engine describes why information matters.

The Context Engine doesn't just know that objects are connected — it knows:

- why something exists and who requested it
- what problem it solved and what decision created it
- what evidence supported it and what changed because of it
- what is still unresolved, who is responsible, and what should happen next

> Weak graph: Campaign A → Feature B → Feedback C
>
> Context Engine: Campaign A was created because Segment X repeatedly asked for Problem Y. Feature B was prioritized after Decision D in Meeting M. The next action is to update the offer page and measure conversion for 30 days.

## Design principles

| Principle | Meaning |
|---|---|
| Context before automation | Don't automate workflows you don't understand. Memory → Context → Search → Recommendations → Automation → Agents |
| Integrate before replacing | Start by connecting existing tools, not by replacing them |
| Human judgment first | Agent drafts; human commits. Interpret / decide / present stay with operators |
| Service before self-serve | Validate through delivery; the OS is substrate, not a vertical product per SME |
| Every object needs provenance | Source, author, date, confidence, evidence, and the decisions it produced |
| Every decision becomes memory | A decision without context becomes repeated confusion |
| The model is an asset | The ontology, relationships, events, and memory rules are strategic assets, not implementation details |

## Current state

**Early stage — database foundation is real; app shell is not in the tree yet.**

Implemented and tested in-repo:

- ✅ Phase 1 context model in Postgres: `entities`, `entity_properties`, and `relationships` — graph-native, workspace-scoped integrity
- ✅ Row Level Security with least-privilege grants; user writes go through a `SECURITY INVOKER` RPC boundary into a private `SECURITY DEFINER` implementation
- ✅ Idempotent entity creation with request fingerprints, advisory locks, and deterministic retry semantics
- ✅ pgTAP database contract tests + a bounded concurrency harness (`supabase/tests`)
- ✅ Host-mapping tables (`domain_mappings`, `workspace_settings`) for Cloudflare → Vercel host resolution

Designed in RFCs / OpenSpec but **not present as application source yet** (no `src/` / `app/`):

- ⏳ Next.js 16 app shell, Supabase Auth wiring, Zod 4 domain layer, Vitest suites (Work Units 2–3 in `openspec/changes/core-foundation/tasks.md`)

**First production pressure (RFC 0005):** dogfood Creándola’s own WhatsApp commercial follow-up on this OS before optimizing for external pilots.

**Roadmap (designed, not yet built):** events and activity model, memories and provenance, semantic search, AI-assisted extraction, WhatsApp webhook → entity intake, host-based workspace resolution in the app, other integrations (Google Workspace, GitHub, Figma, Stripe...).

## Architecture

```text
Browser / Server Component
  → Next.js Proxy (session refresh, optimistic routing only)
  → authenticated server layout (RLS-backed workspace resolution)
  → SECURITY INVOKER RPC wrapper
  → private SECURITY DEFINER implementation (authoritative membership check + write)
```

Key decisions:

- One managed, multi-workspace platform on **Vercel + Supabase** (Postgres, Auth, Storage, Edge Functions) — no self-managed infrastructure
- Vercel project `creandola-os`: preview/dev on `*.vercel.app`; production host `os.somoscreandola.co`
- Supabase Cloud project for the OS: `jfaeahukuekyismvxpfw`
- Single `entities` table with extensible `properties JSONB` + directed `relationships` graph
- `workspace_id` on every tenant table with composite foreign keys — cross-workspace integrity enforced by constraints, not just policies
- RLS for reads; no direct table mutations for authenticated clients
- Strict trust boundaries between publishable, session, and server-only clients

## Tech stack

| Layer | Choice |
|---|---|
| Framework | Next.js 16, React 19, TypeScript (strict) |
| Styling | Tailwind CSS 4 |
| Backend | Supabase (Postgres, Auth, RLS, Edge Functions) |
| Validation | Zod 4 runtime decoders (WU2) |
| Testing | Vitest (WU2+), pgTAP, concurrency harness |
| Quality gates | `lint`, `typecheck`, `test`, `build` — independent, exit-0 enforced (once app source exists) |

## Validation approach

Creándola OS is validated through real service delivery before it becomes standalone software (RFC 0001 + RFC 0005):

1. Creándola runs its own operation on the OS (client zero) — especially WhatsApp → CRM/seguimiento
2. Patterns become templates → repeated templates become workflows
3. Workflows become product capabilities → operators + agents reuse the same OS across workspaces
4. External pilots (e.g. legal process follow-up) reuse the same wedge via configuration and content

Real-world pilots that shaped the model:

- **Client zero (internal):** Creándola’s own operation — highest priority for production dogfooding ([RFC 0005](docs/rfcs/0005-client-zero-whatsapp-crm.md), `docs/context/casos/2026-07-06-creandola-operacion-interna/`).
- **Legal practice pilot:** anonymized process follow-up validated Context Engine concepts outside the internal case.

**Privacy rule:** this repository never contains real client data, contracts, sensitive values, credentials, or full conversations. The repo keeps structure, decisions, templates, and reusable learning; real data lives in private authorized tools.

## Getting started

Requirements: Node.js >= 20.9. Prefer **hosted Supabase** (project `jfaeahukuekyismvxpfw`) for day-to-day work. Local Supabase CLI + Docker is optional and only needed for pgTAP / concurrency harness.

```bash
npm install
cp .env.local.example .env.local   # fill with hosted Supabase URL + keys
# Optional local DB tests only:
#   supabase start && supabase db reset && supabase test db
npm run lint && npm run typecheck && npm test -- --run && npm run build   # after WU2/WU3 source exists
```

See `AGENTS.md` for Cloud Agent notes.
## Repository layout

```text
docs/rfcs/          Strategic and technical decision records (0001–0005)
docs/context/casos/ Validated real-world pilot cases (anonymized); client zero first
docs/README.md      Doc map + OS vs landing boundary
openspec/           Spec-driven development artifacts (proposals, specs, designs, tasks)
supabase/           Migrations, pgTAP tests, local config
src/                Next.js application (planned — WU2/WU3; not in tree yet)
```

Full documentation index: [`docs/README.md`](docs/README.md).
## Status

Early-stage platform under active development. The foundation is real, tested, and opinionated; the Context Engine surfaces (search, memories, AI assistance) are the next horizon.

---

*Creándola OS is the internal product/technology layer of Creándola — shared OS for service + agents, proven first in the company's own operation and in real client work (see RFC 0001).*
