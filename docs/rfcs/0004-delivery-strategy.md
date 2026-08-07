# RFC 0004 — Delivery Strategy

Status: Accepted  
Date: 2026-08-05  
Owner: Creándola  
Depends on: `docs/rfcs/0001-company-os-foundations.md`, `docs/rfcs/0002-company-ontology-v1.md`, `docs/rfcs/0003-context-engine-data-model.md`  
Scope: Execution order and delivery constraints for Creándola OS  
Decision type: Delivery / prioritization

---

## 1. Purpose

RFCs 0001–0003 define the product vision and Context Engine model. This RFC does **not** replace them. It governs **what ships first**, in what order, and under which infrastructure constraints when paying clients are waiting.

The operating thesis:

> Build for 1 client. Template for 10. Do not build ten vertical products.

---

## 2. Wedge product

The first shippable product is one horizontal wedge shared by every early client (Laura / legal processes, Gecontri / accounting and third-party financial data, and the next eight):

- Clients
- Projects
- Meetings
- Decisions
- Tasks
- Documents

That set is already the Phase 1 entity surface in `core-foundation`. It is enough for a lawyer and for Gecontri. What does **not** serve them is a generic unfinished platform.

Rules:

- One product, one schema, one app. Workspace isolation (already designed in the database) is the multi-tenant boundary.
- No per-vertical forks (legal OS, accounting OS, barbershop OS).
- Customization for a client is configuration and content inside the wedge, not a new codebase.

---

## 3. Critical path

Database Work Unit 1 of `openspec/changes/core-foundation` is complete (RLS, workspaces, idempotency, pgTAP).

The only critical path until a usable app exists:

1. **WU2 — Pure domain layer** (Zod schemas, limits, decoders)
2. **WU3 — Data access and app shell** (Supabase clients, `proxy.ts`, OAuth, `[workspaceSlug]` layout)

Every day without an authenticated app is a day clients wait. No other OpenSpec change outranks finishing WU2–WU3.

### Explicitly not on the critical path

| Deferred until first paying client uses production | Why |
|----------------------------------------------------|-----|
| Host-based workspace resolution (`domain_mappings`, `workspace_settings`, pre-auth resolver, custom frontend domains) | See `openspec/changes/host-workspace-resolution/` |
| RFC 0003 layers 4–6 data infrastructure: `events`, `sources`, `evidence`, `memories`, `context_packs`, `ai_runs`, embeddings / pgvector | Needs real production traffic first |
| Per-customer auth callbacks on customer domains | Needs host resolution and explicit allowlisting |
| WhatsApp, email integrations, dashboards, metrics | Product expansion after the wedge works |

Workspace resolution for this delivery phase remains **slug-based** (`/[workspaceSlug]`), with membership re-checked in the authenticated server layout and RPC.

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
| Backend | Supabase Cloud (Auth, Postgres, RLS, Storage, Edge Functions; Cron/jobs when needed) |
| Region | Choose a Supabase region close to primary clients; document the choice at project creation |
| Customer frontend domains | Configured in Vercel when needed; never one Supabase project or Custom Domain per customer |
| Optional platform backend domain | Single Supabase Custom Domain (for example `api.somoscreandola.co`) only if required |
| Explicitly excluded | Self-managed VPS, production Docker, manual backup process, reverse proxy, manual SSL, Clerk, server-security layer as a product concern |

Local Supabase remains for development and pgTAP only.

---

## 6. Relationship to other RFCs

- **0001–0003** remain the vision and model. Do not treat deferred layers as cancelled.
- **This RFC** wins on **order and priority of delivery** when they conflict with expanding the foundation.
- OpenSpec change `core-foundation` implements the wedge foundation. Delivery strategy for later changes must cite this RFC when claiming priority.

---

## 7. Success criteria for this strategy

- [ ] WU2 and WU3 of `core-foundation` complete; lint, typecheck, test, and build pass independently.
- [ ] First authenticated user can open a workspace by slug and create Phase 1 entities.
- [ ] Production target is Supabase Cloud + Vercel; no self-managed production host.
- [ ] No `events` / `memories` / embeddings / `ai_runs` tables ship before first production client use.
- [ ] At most one stateless wedge AI feature may ship before those tables; it uses existing entity data only.
- [ ] Host/custom-domain resolution stays in `host-workspace-resolution` until a real customer domain is required.

---

## 8. Open questions

- Which single wedge AI feature (if any) ships first after WU3 — meeting summary vs assisted drafting — decided with the first pilot client.
- Exact Supabase Cloud region at project provisioning time.
