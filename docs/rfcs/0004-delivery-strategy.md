# RFC 0004 — Delivery Strategy

Status: Accepted (amended 2026-08-08 by [RFC 0005](0005-client-zero-whatsapp-crm.md))  
Date: 2026-08-05  
Owner: Creándola  
Depends on: `docs/rfcs/0001-company-os-foundations.md`, `docs/rfcs/0002-company-ontology-v1.md`, `docs/rfcs/0003-context-engine-data-model.md`  
Scope: Execution order and delivery constraints for Creándola OS  
Decision type: Delivery / prioritization

---

## 1. Purpose

RFCs 0001–0003 define the product vision and Context Engine model. This RFC does **not** replace them. It governs **what ships first**, in what order, and under which infrastructure constraints.

The operating thesis:

> Build for 1 client. Template for 10. Do not build ten vertical products.

**Amendment (2026-08-08):** the “1 client” that forces the first production loop is **Creándola itself (client zero)** — especially WhatsApp commercial follow-up — not an external pilot waiting on a generic unfinished platform. See [RFC 0005](0005-client-zero-whatsapp-crm.md). Laura / Gecontri remain early *configuration* targets on the same wedge after dogfooding produces templates.

---

## 2. Wedge product

The first shippable product is one horizontal wedge shared by every early workspace (Creándola internal first; then Laura / legal processes, Gecontri / accounting, and the next eight):

- Clients
- Projects
- Meetings
- Decisions
- Tasks
- Documents

That set is already the Phase 1 entity surface in `core-foundation`. It is enough for Creándola’s own CRM memory **and** for a lawyer or Gecontri when content/config differ. What does **not** serve them is a generic unfinished platform.

Rules:

- One product, one schema, one app. Workspace isolation (already designed in the database) is the multi-tenant boundary.
- No per-vertical forks (legal OS, accounting OS, barbershop OS).
- Customization for a client is configuration and content inside the wedge, not a new codebase.
- Contact / Deal / WhatsApp thread shapes map onto Phase 1 entities + `properties` first; do not expand `entity_type` or add Message tables without OpenSpec (RFC 0005).

---

## 3. Critical path

Database Work Unit 1 of `openspec/changes/core-foundation` is complete (RLS, workspaces, idempotency, pgTAP). Host-mapping tables (`domain_mappings`, `workspace_settings`) ship as a follow-on migration before WU2 so production domains already held in Cloudflare can be represented from day one.

The critical path until a usable app exists:

1. **WU1b — Host mapping schema** (`domain_mappings`, `workspace_settings`, RLS) — database only
2. **WU2 — Pure domain layer** (Zod schemas, limits, decoders)
3. **WU3 — Data access and app shell** (Supabase clients, `proxy.ts`, OAuth, slug shell **and** host resolution / pre-auth public context)
4. **Client-zero intake (RFC 0005)** — WhatsApp Cloud API webhook → idempotent Contact/opportunity entity writes in the Creándola workspace (after or tightly with WU3)

Every day without an authenticated app is a day **Creándola operators** cannot dogfood. External pilots wait on the same shell; they do not redefine the wedge. App host resolution lands in WU3 alongside the slug shell; membership re-check in the authenticated server layout and RPC remains authoritative.

### Explicitly not on the critical path

| Deferred | Why |
|----------|-----|
| Per-customer auth callbacks on customer domains | Needs explicit allowlisting and host-bound state; central platform auth first (`os.somoscreandola.co`) |
| RFC 0003 layers 4–6 data infrastructure: `events`, `sources`, `evidence`, `memories`, `context_packs`, `ai_runs`, embeddings / pgvector | Needs real production traffic first (WhatsApp volume from client zero is the intended pressure) |
| Generic dashboards, email integrations, metrics suites | Product expansion after dogfooding works |
| Full Conversation/Message ontology tables | Start with Phase 1 entities + properties; promote when traffic proves the shape (RFC 0005) |

Slug routes (`/[workspaceSlug]`) remain supported. Custom frontend hosts resolve via `domain_mappings` after WU3 wiring.

---

## 4. AI policy

Distinguish three kinds of AI work:

| Kind | Status |
|------|--------|
| AI as a **development tool** (agents, docs, analysis while building) | Unrestricted |
| **One** visible product AI feature in the wedge (for example meeting summary or assisted document drafting) | Allowed if **stateless** relative to the data model: LLM call over existing workspace entities only; no new memory tables, no embeddings store, no event pipeline |
| Context Engine **AI infrastructure** (RFC 0003 layers 4–6: memories, context packs, `ai_runs`, embeddings/pgvector, event/provenance pipelines) | Blocked until the first client uses the system in production |

A wedge AI feature must not smuggle in the deferred platform inventory. If it needs persistence beyond the Phase 1 entity graph, it waits.

---

## 5. Infrastructure: managed-first

Paying clients require uptime, backups, and security. Laura handles data under professional secrecy; Gecontri handles third-party financial data. Workspace isolation is already designed in Postgres RLS; hosting must not depend on a self-managed VPS.

| Concern | Decision |
|---------|----------|
| App hosting | Vercel — one Next.js multi-workspace app |
| DNS / edge DNS | Cloudflare holds DNS for platform and customer frontend domains; optional orange-cloud proxy; **Vercel is the application origin** |
| Backend | Supabase Cloud (Auth, Postgres, RLS, Storage, Edge Functions; Cron/jobs when needed) — treat as production infrastructure from day one (PITR, region, backups). OS project ref: `jfaeahukuekyismvxpfw` |
| Region | Choose a Supabase region close to primary operators/clients; document the choice at project creation |
| App project | Vercel project `creandola-os` — preview/dev on `*.vercel.app`; production host `os.somoscreandola.co` |
| Customer frontend domains | Cloudflare DNS → Vercel project domain; app resolves host via `domain_mappings`; never one Supabase project or Custom Domain per customer |
| Optional platform backend domain | Single Supabase Custom Domain (for example `api.somoscreandola.co`) only if required |
| Explicitly excluded | Self-managed VPS, production Docker, manual backup process, self-managed reverse proxy/SSL, Clerk, server-security layer as a product concern |

Local Supabase remains optional for development and pgTAP only. Preferred Cloud Agent mode is hosted Supabase (see `AGENTS.md`).

---

## 6. Relationship to other RFCs

- **0001–0003** remain the vision and model. Do not treat deferred layers as cancelled.
- **This RFC** wins on **order and priority of delivery** when they conflict with expanding the foundation.
- OpenSpec change `core-foundation` implements the wedge foundation. Delivery strategy for later changes must cite this RFC when claiming priority.

---

## 7. Success criteria for this strategy

- [ ] WU1b host-mapping migration + pgTAP pass; WU2 and WU3 of `core-foundation` complete; lint, typecheck, test, and build pass independently.
- [ ] First authenticated Creándola operator can open the internal workspace by slug and create Phase 1 entities.
- [ ] Client-zero WhatsApp intake can create/update an idempotent Contact/opportunity entity (RFC 0005) without storing raw chat bodies in git.
- [ ] WU3 resolves a mapped Cloudflare→Vercel host to a workspace without treating host alone as authorization.
- [ ] Production target is Supabase Cloud + Vercel (`creandola-os`, `os.somoscreandola.co`) with Cloudflare DNS; no self-managed production host.
- [ ] No `events` / `memories` / embeddings / `ai_runs` tables ship before first **dogfood** production use.
- [ ] At most one stateless wedge AI feature may ship before those tables; it uses existing entity data only.

---

## 8. Open questions

- Exact Creándola commercial stages and whether Contact and Deal stay separate (RFC 0005 §4) — decide before locking Zod schemas.
- Which single wedge AI feature (if any) ships first after WU3 — WhatsApp triage assist vs meeting summary vs assisted drafting — decided with dogfooding, not only external pilots.
- Exact Supabase Cloud region at project provisioning time.
