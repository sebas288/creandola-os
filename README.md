# Creándola OS

**A shared company intelligence OS: Context Engine substrate for human service + agents — interpret, decide, and present — not a self-serve SME tool alone.**

Creándola OS is not another CRM, not another project manager, not another wiki. It is the operational memory layer under Creándola’s service delivery: one app, many workspaces, agents that draft, humans that commit.

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

**Early stage — foundation in active development.** The first slice (Core Foundation) is implemented and tested:

- ✅ Next.js 16 app shell with Supabase Auth (Google OAuth) and multi-workspace tenancy
- ✅ Phase 1 context model: `entities`, `entity_properties`, and `relationships` — a graph-native model with workspace-scoped integrity
- ✅ Row Level Security with least-privilege grants; user writes go through a `SECURITY INVOKER` RPC boundary into a private `SECURITY DEFINER` implementation
- ✅ Idempotent entity creation with request fingerprints, advisory locks, and deterministic retry semantics
- ✅ Domain validation with strict runtime decoders (Zod 4)
- ✅ pgTAP database contract tests + Vitest domain tests + a bounded concurrency harness

**Roadmap (designed, not yet built):** events and activity model, memories and provenance, semantic search, AI-assisted extraction and summaries, host-based workspace resolution, external integrations (WhatsApp, Google Workspace, GitHub, Figma, Stripe...).

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
| Validation | Zod 4 runtime decoders |
| Testing | Vitest, pgTAP, concurrency harness |
| Quality gates | `lint`, `typecheck`, `test`, `build` — independent, exit-0 enforced |

## Validation approach

Creándola OS is validated through real service delivery before it becomes standalone software (RFC 0001):

1. Creándola sells services → client work produces notes, decisions, tasks, and patterns
2. Patterns become templates → repeated templates become workflows
3. Workflows become product capabilities → operators + agents reuse the same OS across workspaces

Real-world pilots have shaped the model:

- **Client zero (internal):** Creándola runs its own operation on the system before adapting it to external clients. What repeats and generates value becomes a reusable horizontal.
- **Legal practice pilot:** a law firm's legal-process follow-up validated the Context Engine outside the internal pilot — process stages, entity maps, and weekly reporting, all anonymized.

**Privacy rule:** this repository never contains real client data, contracts, sensitive values, credentials, or full conversations. The repo keeps structure, decisions, templates, and reusable learning; real data lives in private authorized tools.

## Getting started

Requirements: Node.js >= 20.9, Supabase CLI, a local Supabase instance.

```bash
npm install
cp .env.local.example .env.local   # fill placeholders with your local Supabase values
supabase start                      # local Postgres + Auth
supabase db reset                   # apply migrations
npm run lint && npm run typecheck && npm test -- --run && npm run build
supabase test db                    # pgTAP contract tests
```

## Repository layout

```text
docs/rfcs/          Strategic and technical decision records (0001–0004)
openspec/           Spec-driven development artifacts (proposals, specs, designs, tasks)
supabase/           Migrations, pgTAP tests, local config
src/                Next.js application (domain, infrastructure, app routes)
docs/context/casos/ Validated real-world pilot cases (anonymized)
```

## Status

Early-stage platform under active development. The foundation is real, tested, and opinionated; the Context Engine surfaces (search, memories, AI assistance) are the next horizon.

---

*Creándola OS is the internal product/technology layer of Creándola — shared OS for service + agents, proven first in the company's own operation and in real client work (see RFC 0001).*
