# RFC 0005 — Client-zero first: Creándola WhatsApp CRM

Status: Draft v1  
Date: 2026-08-08  
Owner: Creándola  
Depends on: RFC 0001, RFC 0002, RFC 0003, RFC 0004  
Scope: Business priority and CRM data-model direction for the first production workspace  
Decision type: Delivery / product prioritization (amends RFC 0004 order, not the Phase 1 schema)

---

## 1. Purpose

RFCs 0001–0004 already describe Creándola OS as a Context Engine substrate for **service + agents**, with **client zero = Creándola’s own operation** documented under `docs/context/casos/2026-07-06-creandola-operacion-interna/`.

This RFC records a **business-level correction of delivery pressure**:

> The first production workspace that must feel pain and force the product forward is **Creándola itself**, starting with **WhatsApp-sourced commercial follow-up (CRM)**, not an unfinished generic platform waiting on Laura / Gecontri.

External pilots remain valuable and anonymized in `docs/context/casos/`. They do **not** displace dogfooding as the primary build driver.

---

## 2. What changed vs prior docs

| Topic | Prior emphasis (esp. RFC 0004) | Updated emphasis (this RFC) |
|-------|--------------------------------|-----------------------------|
| Who waits first | “Paying clients waiting” (Laura, Gecontri) | **Creándola operators** using the OS daily |
| WhatsApp | Explicitly **deferred** until after the wedge app works | **First integration candidate** for client-zero intake (Meta Cloud API app already exists) |
| First useful surface | Phase 1 wedge UI for meetings/docs | Same Phase 1 primitives, but **driven by WhatsApp → contact/opportunity memory** |
| CRM | “Not a CRM-only tool” (still true as product category) | **CRM/seguimiento is a horizontal Creándola must run on the OS** (see horizontals in RFC 0001 §4) |
| Graphify / code graphs | Not mentioned | **Out of product scope.** Optional AI-dev tooling; useful analogy only (structure + provenance for *code*, not company memory) |

Unchanged and still correct:

- One product, one schema, one app; workspace isolation.
- Agent drafts; human commits.
- No self-managed production Docker; Vercel + Supabase Cloud.
- No inventing vertical forks (legal OS, accounting OS).
- Repo never stores real client PII, full chats, or credentials.

---

## 3. Why Creándola-first is the right wedge pressure

1. **No negotiation friction** — entity model and stages can change without an external approval cycle.
2. **High-volume WhatsApp** — edge cases (ambiguous messages, duplicate contacts, crossed threads) appear faster than on a low-volume pilot.
3. **Live demo** — selling horizontals later can show the operator OS working on Creándola’s own pipeline, not only mockups.
4. **Already aligned with cases** — `operacion-interna` already marks CRM / WhatsApp as Alta and states WhatsApp is integrated technically and must feed operational triage.

This does **not** cancel Laura / Gecontri learning. It reorders **who the software must serve first**.

---

## 4. CRM data-model direction (conceptual → Phase 1 mapping)

Proposed commercial objects (from business discussion) and how they map to the **existing** model without expanding the DB enum yet:

| Business object | Intent | Map onto current Phase 1 / ontology |
|-----------------|--------|-------------------------------------|
| **Contact** | Person who writes on WhatsApp | Ontology **Contact** (RFC 0002 §9). Phase 1 DB enum has `client` today; Contact may start as `client` properties **or** a later enum/extension — **do not expand `entity_type` without an OpenSpec change**. Prefer `phone` / `source` / `stage` in `properties` until WU2 schemas exist. |
| **Conversation** | One WhatsApp thread | Prefer **source/event-shaped** data later (RFC 0003 layers 4–5). Interim: `document` or `process` entity with channel metadata is acceptable only as a temporary operator aid — not a permanent ontology claim. |
| **Message** | Single inbound/outbound unit | Same as Conversation: belongs to **events/sources**, not a Phase 1 wedge type. Store raw payloads outside this repo; OS keeps structured memory + provenance pointers. |
| **Deal / Opportunity** | Commercial pipeline item | Aligns with **Lead / oportunidad** in `operacion-interna.md`. Can be a `client` (prospect) or `project`-adjacent entity with `stage` / `value` / `project_type` in properties. Confirm whether Contact and Deal stay separate (recommended if one contact can spawn multiple deals). |

### Stages (must be confirmed against real Creándola flow)

Draft pipeline (not locked):

```txt
nuevo → calificando → propuesta_enviada → negociacion → cliente_activo → inactivo
```

Replace with the **actual** stages from daily WhatsApp practice before writing Zod schemas or UI.

### Open product questions (block schema expansion)

1. Is the central object **Contact**, **Deal**, or both?
2. Exact stage list and who may move stages (human only vs agent draft).
3. WhatsApp provider path: **Meta Cloud API** (preferred — app already created) vs Twilio / 360dialog / Evolution.
4. Which fields are required on first inbound message vs filled during calificación.

---

## 5. WhatsApp Cloud API (Meta) — assumed starting point

Creándola already has a Meta app and production env vars on related Vercel projects (landing). For Creándola OS intake, the usual remaining work is operational, not “whether to use WhatsApp”:

1. Verified business phone number on the WhatsApp product.
2. Business Verification for production messaging limits.
3. Webhook → OS endpoint (Edge Function or Next route) that creates/updates Contact/Deal memory via `create_entity` (human-visible triage; agents may draft only).
4. Long-lived System User token (not 24h test tokens).
5. Message Templates for outbound starts outside the 24h window.

Privacy: webhooks and message bodies live in private infra / Supabase; this git repo keeps schemas, playbooks, and anonymized learning only.

---

## 6. Delivery implications (amends RFC 0004)

Critical path remains WU1b → WU2 → WU3 for an authenticated app shell. **Additionally:**

1. Treat **workspace = Creándola internal** as the first production tenant.
2. After (or tightly with) WU3, prioritize **WhatsApp webhook → entity writes** for client-zero over generic dashboards.
3. Do **not** block WU2/WU3 on Conversation/Message tables. Use Phase 1 entities + properties first; promote to events/sources when traffic proves the shape.
4. Laura / Gecontri stay as **configuration + content** on the same wedge once dogfooding produces templates.

Hosting note (infra, not schema): production app target is Vercel project `creandola-os` with production host `os.somoscreandola.co`; preview/dev uses the Vercel-assigned `*.vercel.app` URL. Supabase Cloud project ref for this OS: `jfaeahukuekyismvxpfw`.

---

## 7. Explicitly out of scope for this RFC

- Implementing Graphify (or any code-knowledge-graph tool) inside Creándola OS.
- Expanding `entity_type` enum or adding Message tables in this change set.
- Storing real WhatsApp transcripts in git.
- Replacing Meta Cloud API with a third-party bridge unless Meta path is blocked.

---

## 8. Success criteria

- [ ] README / RFC 0004 / internal case agree that **Creándola WhatsApp CRM dogfooding** is the first production pressure.
- [ ] Stage list and Contact vs Deal decision written into `operacion-interna` (or a follow-on OpenSpec) before Zod schemas lock them.
- [ ] WU2/WU3 proceed without waiting on events/memories tables.
- [ ] First webhook path can create an idempotent Contact/opportunity entity in the Creándola workspace without committing PII to git.
