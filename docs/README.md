# Documentation map — Creándola OS

This repository is the **Creándola OS** product (Context Engine substrate). It is **not** the public marketing site.

| Surface | Repo / place | Role |
|---------|--------------|------|
| **Creándola OS** | `sebas288/creandola-os` (this repo) | Shared company intelligence OS: workspaces, entities, RLS, future operator app |
| **Landing / brand site** | Separate repo (`creandola-landing`) | Public acquisition site for Somos Creándola (`somoscreandola.co`) — **not** part of this codebase |
| **WhatsApp Meta app** | Meta Business / Cloud API | Channel for client-zero intake into the OS; credentials live in private infra, never in git |

Do not copy env vars, WhatsApp tokens, or deploy config from the landing repo into this one. When integrations are ready, OS gets its **own** Vercel project (`creandola-os`) and Supabase project.

## RFCs

| RFC | Title | Status |
|-----|-------|--------|
| [0001](rfcs/0001-company-os-foundations.md) | Company OS Foundations | Draft (operating model) |
| [0002](rfcs/0002-company-ontology-v1.md) | Company Ontology v1 | Draft |
| [0003](rfcs/0003-context-engine-data-model.md) | Context Engine Data Model | Draft |
| [0004](rfcs/0004-delivery-strategy.md) | Delivery Strategy | Accepted (+ 0005 amendment) |
| [0005](rfcs/0005-client-zero-whatsapp-crm.md) | Client-zero WhatsApp CRM | Draft |

## Cases (anonymized learning)

| Case | Role |
|------|------|
| [2026-07-06 operación interna](context/casos/2026-07-06-creandola-operacion-interna/) | **Client zero** — first production pressure |
| [2026-06-30 despacho Laura](context/casos/2026-06-30-despacho-abogada-laura-seguimiento-procesos/) | External pilot patterns (anonymized) |
| [2026-06-28 company OS piloto](context/casos/2026-06-28-creandola-company-os-piloto/) | Early OS pilot notes |

## OpenSpec

Spec-driven change artifacts live under `openspec/`. Active foundation work: `openspec/changes/core-foundation/` (WU1/WU1b done in DB; WU2–WU3 app/domain not in tree yet).

## Privacy

No real client data, chats, phones, contracts, or credentials in this repo. Structure, decisions, and templates only.
