# RFC 0001 — Company OS Foundations

Status: Draft v2  
Date: 2026-08-07  
Owner: Creándola  
Scope: Strategic/product foundation and operating model  
Decision type: Foundational architecture  
Supersedes: Draft v1 (2026-06-28) — same document path; narrative reframed around service delivery

---

## 1. Executive summary

Creándola OS (Company OS) is the internal product/technology layer under Creándola. It is a shared company intelligence system whose core is a **Context Engine**.

The commercial and operating thesis is:

> The real opportunity is not self-serve software for SMEs.
> It is human service + agents on top of a shared operating system.
> Colombian SMEs still need someone to interpret, decide, and present — not only a tool.

The technical thesis remains:

> Company OS is not a collection of business modules. It is a Context Engine that connects tools, knowledge, decisions, processes, clients, metrics, and memory so a business can understand itself and operate better.

Creándola remains the public brand, service provider, and commercial relationship. Company OS is not a new public brand. The first product asset is still the model (ontology, relationships, events, memory rules) — now delivered as substrate for **service**, not as a standalone SME product.

Related specs (do not duplicate here):

- [RFC 0002](0002-company-ontology-v1.md) — ontology
- [RFC 0003](0003-context-engine-data-model.md) — data model
- [RFC 0004](0004-delivery-strategy.md) — delivery order and wedge constraints (**Accepted**)

---

## 2. Operating model: three layers

```txt
Delivery     → Creándola operators + agents (interpret, decide, present)
Workspace    → Tenant boundary (workspace_id, memberships, RLS, host/slug)
Shared OS    → One app, one schema, Phase 1 wedge, Context Engine services
```

| Layer | What it is | How it reuses |
|-------|------------|---------------|
| **Shared OS** | One Next.js app, one Postgres schema, shared wedge capabilities | Same code for every client |
| **Workspace** | Operating account for a company/client | Isolated data; config and content differ |
| **Delivery** | Humans + agents working in that workspace | Same playbooks; judgment and outputs differ |

Customization for a client is **configuration, content, and service delivery** inside the wedge — not a new codebase, not a per-vertical product fork, not a monorepo package per SME.

Engineering implication (locked by RFC 0004):

> One product, one schema, one app. Workspace isolation is the multi-tenant boundary.

---

## 3. Human vs agents in the wedge

### 3.1 What the human owns (non-negotiable)

In every workspace, a Creándola operator (or a designated client owner with Creándola support) owns:

1. **Interpret** — turn notes, meetings, and documents into meaning for that business.
2. **Decide** — approve decisions, priorities, and next actions that affect the client.
3. **Present** — deliver status, recommendations, and artifacts the client can act on.

The OS stores and retrieves context. It does not replace professional judgment for legal, financial, or relationship-sensitive work (e.g. early pilots such as a legal practice or accounting firm).

### 3.2 What agents may do

Agents (and any early wedge AI feature per RFC 0004) may assist **inside a workspace** when they:

| Allowed | Not allowed (yet) |
|---------|-------------------|
| Draft summaries from existing entities | Autonomous decisions without human approval |
| Suggest tasks, titles, or document outlines | Cross-workspace data access |
| Retrieve and rephrase workspace context for an operator | Context Engine AI infrastructure (memories, embeddings, `ai_runs`) before production use — see RFC 0004 |
| Stateless LLM calls over the current entity graph | “Fully autonomous agent” product positioning |

Default rule:

> **Agent drafts; human commits.**

Writes that change canonical entities require an explicit human action in the product or an approved operator workflow.

### 3.3 Sequence (unchanged principle)

```txt
Memory → Context → Search → Recommendations → Automation → Agents
```

AI may summarize, extract, classify, and draft early. Autonomous agents wait until trusted context, permissions, and validated workflows exist.

---

## 4. Background and positioning

Creándola started from a service-business reality: clients need design and software, but also strategy, operational clarity, documentation, follow-up, process management, and increasingly AI support.

Stronger positioning:

> Creándola helps businesses order and improve their operation with strategy, design, technology, documentation, and AI.

Creándola horizontals remain the practical operating layer:

```txt
Captación · Calificación · Seguimiento / CRM · Atención / WhatsApp
Documentación · Procesos internos · Automatización · Analítica / reportes
```

Company OS gives those horizontals deeper context. It does not replace them with ten vertical software products.

---

## 5. Naming and brand

| Concern | Decision |
|---------|----------|
| Public brand | Somos Creándola (`somoscreandola.co`) |
| Product/tech layer | Creándola OS — internal under Creándola |
| Vision name | Company OS — internal architecture name only |
| Category | Company Intelligence Platform |
| Core mechanism | Context Engine |

Do not create a new brand, landing, legal entity, or public GTM around Company OS yet.

Grounded phrasing when needed later: *Todo lo importante de tu empresa, conectado y accionable.*

---

## 6. What Company OS is

A company intelligence system that connects the operational memory of a business. It should help answer:

- What did we decide about this client?
- What tasks came from the last meeting?
- Which documents explain this process?
- Which client requests are repeating?
- Where are we losing leads, time, or context?

It should make a business easier to understand, operate, improve, and eventually automate — **with humans still owning interpretation, decision, and presentation**.

---

## 7. What Company OS is not

Not initially: a Notion/HubSpot/Linear/Figma/GitHub/Drive replacement; an ERP; a CRM-only tool; a wiki-only tool; an AI agent platform with no context; a metrics-only dashboard; a generic PM app; a self-serve SME SaaS that replaces Creándola’s service relationship.

Instead:

> It connects tools, captures context, preserves decisions, and helps operators and clients act on what the company knows.

---

## 8. Core thesis: fragmented context

Most companies do not only suffer from lack of tools. They suffer from lack of connected context — WhatsApp, email, Drive, meetings, notes, contracts, and founder memory.

Company OS exists to turn scattered information into actionable context **so service delivery can scale without inventing a new product per client**.

---

## 9. Context Engine

### 9.1 Why not only “Knowledge Graph”

```txt
Knowledge Graph = how information may be structured internally
Context Engine = the system that understands why information matters
```

### 9.2 What it must understand

Not only that objects are connected, but why something exists, who requested it, what decision created it, what evidence supported it, what is unresolved, who is responsible, and what should happen next.

```txt
Weak graph:
Campaign A → Feature B → Feedback C

Context Engine:
Campaign A was created because Segment X repeatedly asked for Problem Y.
Feature B was prioritized after Decision D in Meeting M.
The next action is to update the offer page and measure conversion for 30 days.
```

Detail: RFC 0002 (ontology), RFC 0003 (data model).

---

## 10. Architecture overview

```txt
Company OS
│
├── Context Engine (shared services)
│   Knowledge · Graph · Memory · Events · Search · Files
│   Permissions · Analytics · Notifications · AI
│
├── Operating Domains (views over the same engine)
│   Brand · Marketing · Sales · Customer · Product
│   Design · Finance · Operations · HR
│
└── External Integrations
    GitHub · Figma · Google Workspace · WhatsApp · Slack · Stripe · …
```

Core services are **not** competing modules. Operating domains are business surfaces over one Context Engine. Integrations pull context before replacing tools.

---

## 11. Design principles

1. **Context before automation** — do not automate workflows that are not understood.
2. **Integrate before replacing** — connect tools first.
3. **Services before modules** — shared Context Engine services.
4. **Human judgment first** — augment; do not hide judgment behind blind automation.
5. **Service before self-serve software** — validate through delivery; OS is substrate.
6. **Every object needs provenance** — source, author, date, evidence, decisions produced.
7. **Every decision should become memory** — decisions without context become repeated confusion.
8. **No software before validated workflow** — document before building.
9. **Reuse before invention** — prefer horizontals and existing entities over new vertical packages.
10. **AI assist early, autonomous later** — agent drafts; human commits.
11. **The model is an asset** — ontology and memory rules are strategic, not incidental.

---

## 12. Ontology and data model (pointers)

Full ontology: **RFC 0002**. Canonical data model and tenancy: **RFC 0003**.

A company is modeled as actors, assets, processes, decisions, events, and outcomes connected over time. Relationships carry context; events make the system temporal; memory preserves useful context with provenance and scope.

Phase 1 wedge entities (also RFC 0004):

```txt
Clients · Projects · Meetings · Decisions · Tasks · Documents
```

---

## 13. Search, permissions, AI (summary)

**Search** evolves: exact → semantic → contextual answers → recommendations.

**Permissions** must not assume global visibility. Early versions can be simple; the model must support workspace/company/client/project/role boundaries (workspace isolation is already the multi-tenant boundary in implementation).

**AI** early: summaries, extraction, classification, draft generation, meeting/task extraction, report drafts — always workspace-scoped and human-committed for canonical writes.

**AI later:** autonomous agents only after entities, relationships, events, permissions, and workflow validation are trusted (and after RFC 0004 unblocks Context Engine AI infrastructure).

Use cheap models for extraction; reserve expensive models for hard reasoning. Do not use expensive models for every task.

---

## 14. MVP wedge and workflow

Do not model the entire company first. Start with the wedge above.

```txt
1. A meeting/note/document enters (often via operator or assisted capture).
2. The system (or agent draft) extracts entities.
3. Decisions, tasks, risks, and open questions are identified.
4. They link to client/project.
5. They become searchable in the workspace.
6. Next actions are proposed (draft).
7. A human commits and presents a simple report to the client.
```

Example questions the wedge must answer:

```txt
¿Qué sabemos de este cliente?
¿Qué decidimos en la última reunión?
¿Qué tareas salieron de este diagnóstico?
¿Qué problemas se repiten entre clientes?
```

---

## 15. Validation strategy

Validate Company OS through service delivery before treating it as a standalone software product.

```txt
Creándola sells services
↓
Client work produces notes, decisions, tasks, documents, patterns
↓
Patterns become templates
↓
Repeated templates become workflows
↓
Repeated workflows become product capabilities
↓
Capabilities harden into the Creándola OS layer
↓
Operators + agents reuse the same OS across workspaces
```

This reduces product risk and keeps the product grounded in real client work (internal client-zero and anonymized external pilots).

---

## 16. What not to build yet

Do not build yet:

- full dashboard / CRM / ERP / PM suite,
- autonomous agents as the product,
- deep integrations with every tool,
- complex permissions beyond workspace membership needs,
- graph DB or vector DB infrastructure before RFC 0004 allows,
- new public brand or Company OS landing,
- vertical product packages (legal OS, accounting OS, …) before the model is stable,
- monorepo packaging used as a stand-in for per-client capabilities.

Do build/document first:

- ontology and Phase 1 entities,
- authenticated multi-workspace shell,
- operator workflows for interpret / decide / present,
- templates and manual validation,
- at most one stateless wedge AI assist after the shell works (RFC 0004).

---

## 17. Build criteria

Before building software for any capability:

1. Has this workflow been validated manually or semi-manually in delivery?
2. Does it repeat across multiple clients/workspaces?
3. Does it save time, improve service quality, or improve decisions?
4. Can it become a reusable horizontal capability on the shared OS?
5. Does it create or enrich context?
6. Can its value be reported in the service relationship?
7. Can it start with existing tools before custom software?

If most answers are no, document it first and keep delivering the service.

---

## 18. RFC map (actual)

```txt
RFC 0001 — Company OS Foundations (this document)
RFC 0002 — Company Ontology v1
RFC 0003 — Context Engine Data Model
RFC 0004 — Delivery Strategy (Accepted)
```

Later RFCs may cover deeper memory/provenance rules, events detail, integrations, and AI infrastructure — without contradicting the operating model here or the delivery constraints in RFC 0004.

---

## 19. Open questions

1. Who is the default “human committer” per pilot: Creándola operator only, or client owner with Creándola review?
2. Which single wedge AI assist ships first after WU3 — meeting summary vs assisted drafting (also RFC 0004 §8)?
3. What is the first measurable outcome of the service+OS loop: saved time, fewer missed follow-ups, clearer decisions, or monthly report quality?
4. How much client data should enter the system during early validation (privacy-preserving by default in-repo)?

---

## 20. Deterministic decisions from this RFC

1. Creándola remains the public brand; no new Company OS brand now.
2. Creándola OS is the internal/product technology layer under Creándola.
3. The commercial opportunity is **service + agents over a shared OS**, not self-serve SME software alone.
4. The core technical concept is the **Context Engine**.
5. Delivery uses three layers: Shared OS / Workspace / Delivery.
6. Humans own interpret / decide / present; **agent drafts, human commits**.
7. One product, one schema, one app; workspace isolation is the multi-tenant boundary.
8. Customization is configuration, content, and service — not vertical codebase forks.
9. Knowledge and related capabilities are core services, not competing modules.
10. The first wedge is clients / projects / meetings / decisions / tasks / documents.
11. Integrate existing tools before replacing them.
12. Autonomous agents come after trusted context and validated workflows; AI infrastructure follows RFC 0004.

---

## 21. One-sentence foundation

> Company OS is Creándola’s shared operating system for company intelligence — a Context Engine that holds workspace context so Creándola can deliver human service and agent assistance: interpret, decide, and present — without building a separate product for every SME.
