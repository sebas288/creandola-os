# RFC 0001 — Company OS Foundations

Status: Draft v1  
Date: 2026-06-28  
Owner: Creándola  
Scope: Strategic/product foundation  
Decision type: Foundational architecture

---

## 1. Executive summary

Company OS is the internal product vision Creándola will use to design, validate, and eventually implement a company intelligence layer for service businesses.

The goal is **not** to create a new public brand right now. Creándola remains the public company, service provider, and commercial relationship. Creándola OS remains the internal/product technology layer under Creándola.

The strategic thesis is:

> Company OS is not a collection of business modules. It is a company intelligence system whose core is a Context Engine: a layer that connects tools, knowledge, decisions, processes, clients, metrics, and memory so a business can understand itself and operate better.

The product should not start by replacing tools like Notion, HubSpot, Figma, GitHub, Google Drive, WhatsApp, Slack, Stripe, or Linear. Instead, it should connect them and add context.

The first product asset is not code. The first product asset is the model: the ontology, relationships, events, states, memory rules, and design principles that define how a company is represented inside the system.

---

## 2. Background

Creándola started from a service-business reality:

- clients need design and software,
- but they also need strategy,
- operational clarity,
- documentation,
- marketing improvement,
- sales follow-up,
- process management,
- automation,
- and increasingly AI support.

This means Creándola should not position itself only as a software development company. The stronger positioning is:

> Creándola helps businesses order and improve their operation with strategy, design, technology, documentation, and AI.

Previous documents defined a horizontal-first operating model:

- Captación
- Calificación
- Seguimiento / CRM
- Atención / WhatsApp
- Documentación
- Procesos internos
- Automatización
- Analítica / reportes

Those horizontals remain valid. This RFC places them inside a larger architecture: Company OS.

---

## 3. Naming and brand decisions

### 3.1 Public brand

The public brand remains:

```txt
Somos Creándola
```

Public domain:

```txt
somoscreandola.co
```

### 3.2 Internal/product engine

Creándola OS remains:

```txt
Internal/product engine under Creándola
```

It should not be positioned as a competing public company on the main Creándola landing.

### 3.3 Product vision name

For now, **Company OS** is an internal product vision and architecture name.

Do not create a new brand, landing, legal entity, or public go-to-market around it yet.

### 3.4 Category language

Strategic category:

```txt
Company Intelligence Platform
```

Core value mechanism:

```txt
Context Engine
```

Potential commercial phrasing later:

```txt
El cerebro digital de tu empresa.
```

Grounded phrasing:

```txt
Todo lo importante de tu empresa, conectado y accionable.
```

---

## 4. What Company OS is

Company OS is a company intelligence system that connects the operational memory of a business.

It should help answer questions like:

- What did we decide about this client?
- Why did we launch this campaign?
- Which feedback created this feature?
- Which process keeps breaking?
- What tasks came from the last meeting?
- Which client requests are repeating?
- Which documents explain this process?
- What changed after a release, campaign, or operational improvement?
- Where are we losing leads, time, or context?

Company OS should make a business easier to understand, operate, improve, and eventually automate.

---

## 5. What Company OS is not

Company OS is not initially:

- a replacement for Notion,
- a replacement for HubSpot,
- a replacement for Monday or ClickUp,
- a replacement for Jira or Linear,
- a replacement for Figma,
- a replacement for GitHub,
- a replacement for Google Drive,
- an ERP,
- a CRM-only tool,
- a wiki-only tool,
- an AI agent platform with no context,
- a dashboard that only displays metrics,
- a generic project management app.

Company OS should not compete directly with mature tools in their primary category.

Instead:

> It connects tools, captures context, preserves decisions, and helps the company act on what it knows.

---

## 6. Core thesis

Most companies do not only suffer from lack of tools. They suffer from lack of connected context.

They have information in:

- WhatsApp,
- email,
- Drive,
- Figma,
- GitHub,
- spreadsheets,
- CRM,
- meetings,
- notes,
- invoices,
- contracts,
- conversations,
- memory of the founder.

The problem is not that information does not exist. The problem is that information is fragmented, unlinked, and rarely converted into organizational memory.

Company OS exists to turn scattered information into actionable context.

---

## 7. The central concept: Context Engine

### 7.1 Why not just “Knowledge Graph”

A knowledge graph describes an implementation pattern.

A Context Engine describes user value.

```txt
Knowledge Graph = how information may be structured internally
Context Engine = the system that understands why information matters
```

The graph matters, but the value is context.

### 7.2 What the Context Engine must understand

The Context Engine should not only know that objects are connected.

It should know:

- why something exists,
- who requested it,
- what problem it solved,
- what decision created it,
- what evidence supported it,
- what changed because of it,
- what is still unresolved,
- who is responsible,
- what should happen next,
- which metric or outcome it affects.

Example:

```txt
Weak graph:
Campaign A → Feature B → Feedback C

Context Engine:
Campaign A was created because Segment X repeatedly asked for Problem Y.
Feature B was prioritized after Decision D in Meeting M.
Feedback C showed that the message was unclear.
The next action is to update the offer page and measure conversion for 30 days.
```

---

## 8. Architecture overview

```txt
Company OS
│
├── Context Engine
│   ├── Knowledge
│   ├── Graph
│   ├── Memory
│   ├── Events
│   ├── Search
│   ├── Files
│   ├── Permissions
│   ├── Analytics
│   ├── Notifications
│   └── AI
│
├── Operating Domains
│   ├── Brand
│   ├── Marketing
│   ├── Sales
│   ├── Customer
│   ├── Product
│   ├── Design
│   ├── Finance
│   ├── Operations
│   └── HR
│
└── External Integrations
    ├── GitHub
    ├── Figma
    ├── Google Workspace
    ├── Drive
    ├── WhatsApp
    ├── Slack
    ├── Stripe
    ├── HubSpot
    ├── Meta
    └── Other tools
```

### 8.1 Core services are not modules

Knowledge, search, analytics, permissions, memory, files, notifications, AI, and graph capabilities should be core services, not independent modules competing for attention.

They support every operating domain.

### 8.2 Operating domains are business surfaces

Operating domains are where users recognize their work:

- Brand
- Marketing
- Sales
- Customer
- Product
- Design
- Finance
- Operations
- HR

These domains should not become isolated silos. Every domain should use the same Context Engine.

---

## 9. Design principles

### Principle 1 — Context before automation

Do not automate workflows that are not understood.

Sequence:

```txt
Memory → Context → Search → Recommendations → Automation → Agents
```

### Principle 2 — Integrate before replacing

Do not start by replacing tools. Start by connecting them.

### Principle 3 — Services before modules

Knowledge, search, graph, permissions, analytics, memory, and AI are shared services.

### Principle 4 — Human judgment first

The system should augment strategic and operational judgment, not hide it behind blind automation.

### Principle 5 — Every object needs provenance

The system should preserve where information came from:

- source,
- author,
- date,
- related client/project,
- confidence,
- evidence,
- decisions produced.

### Principle 6 — Every decision should become memory

A decision without context becomes repeated confusion.

### Principle 7 — No software before validated workflow

If the workflow has not been validated manually or semi-manually, document it before building it.

### Principle 8 — Reuse before invention

Before creating a new capability, check whether it belongs to an existing horizontal, domain, workflow, entity, event, or relationship.

### Principle 9 — AI basic from day one, autonomous later

AI can summarize, extract, classify, and retrieve early.

Autonomous agents should wait until the system has enough trusted context, permissions, and event history.

### Principle 10 — The model is an asset

The ontology, relationships, events, and memory rules are not implementation details. They are strategic assets.

---

## 10. Company ontology: first model

The root question is:

> What is a company inside this system?

A company is modeled as a set of actors, assets, processes, decisions, events, and outcomes connected over time.

### 10.1 Core entity groups

#### Organization entities

```txt
Company
Team
Role
Person
Client
Contact
Partner
Vendor
```

#### Work entities

```txt
Project
Task
Workflow
Process
SOP
Checklist
Automation
```

#### Commercial entities

```txt
Lead
Opportunity
Proposal
Contract
Invoice
Payment
Offer
Segment
```

#### Product/design entities

```txt
Product
Feature
RoadmapItem
Release
DesignFile
Component
Asset
```

#### Brand/marketing entities

```txt
Brand
Campaign
Channel
ContentPiece
Ad
LandingPage
Message
Audience
```

#### Knowledge entities

```txt
Document
Note
Meeting
Decision
Learning
Research
Experiment
Question
Answer
```

#### Customer entities

```txt
Feedback
Ticket
Request
NPSResponse
Testimonial
CaseStudy
```

#### Measurement entities

```txt
Metric
KPI
Objective
KeyResult
Report
Insight
```

#### AI entities

```txt
Prompt
Agent
Model
Memory
ContextPack
Evaluation
```

---

## 11. Relationships

Relationships define context.

Initial relationship examples:

```txt
Client has Contact
Project belongs_to Client
Person owns Task
Task relates_to Project
Meeting produced Decision
Decision created Task
Task implements Decision
Document describes Process
Process uses Checklist
Automation handles Workflow
Campaign promotes Offer
ContentPiece belongs_to Campaign
LandingPage captures Lead
Lead becomes Opportunity
Opportunity receives Proposal
Proposal becomes Contract
Invoice bills Client
Feedback requests Feature
Feature belongs_to Product
Feature appears_in Release
Release impacts Metric
Metric measures Objective
Research supports Decision
Prompt used_by Agent
Agent acts_on Workflow
ContextPack includes Document
```

### Relationship metadata

Every relationship should eventually support metadata:

```txt
source
created_at
created_by
confidence
valid_from
valid_to
evidence
notes
```

---

## 12. Events

Events are what make the system temporal.

Without events, the system only stores static information.

Initial event examples:

```txt
lead.created
lead.qualified
meeting.scheduled
meeting.completed
decision.made
task.created
task.assigned
task.completed
proposal.sent
contract.signed
invoice.sent
invoice.paid
feedback.received
feature.requested
release.shipped
metric.changed
document.created
document.updated
process.documented
automation.triggered
campaign.launched
campaign.ended
report.generated
```

### Event requirements

Every event should eventually include:

```txt
event_id
event_type
timestamp
actor
entity
related_entities
source
data
summary
```

---

## 13. Memory

Memory is the system’s ability to preserve useful context over time.

### 13.1 Memory types

```txt
Strategic memory
Operational memory
Client memory
Product memory
Brand memory
Decision memory
Process memory
AI memory
```

### 13.2 Memory rules

Memory should be:

- source-backed,
- scoped,
- permission-aware,
- updatable,
- explainable,
- linked to entities and events.

### 13.3 What should become memory

Good memory candidates:

- strategic decisions,
- recurring client preferences,
- process rules,
- lessons learned,
- common objections,
- repeated feature requests,
- operating constraints,
- validated patterns,
- recurring risks.

Bad memory candidates:

- temporary task state,
- unverified assumptions,
- raw transcripts without summary,
- secrets,
- credentials,
- private data without purpose,
- stale implementation details.

---

## 14. Search and retrieval

Search should evolve in layers:

### Layer 1 — Exact search

Find known docs, clients, tasks, decisions, notes, and records.

### Layer 2 — Semantic search

Find conceptually related material even when words differ.

### Layer 3 — Contextual answers

Answer questions with references:

```txt
Question: ¿Qué decidimos sobre el onboarding?
Answer: Summary + linked decisions + meetings + tasks + docs.
```

### Layer 4 — Recommendations

Suggest next actions based on context:

```txt
This lead has no next action.
This process has repeated failures.
This feature request appears in three clients.
This campaign produced leads but no proposals.
```

---

## 15. Permissions

Permissions cannot be an afterthought.

The system will eventually contain sensitive company context.

Permission dimensions:

```txt
workspace
company
client
project
domain
entity type
field
source
role
actor
```

Early versions can be simple, but the model should not assume everything is globally visible.

---

## 16. AI strategy

### 16.1 AI from the beginning

AI should be used early for:

- summaries,
- extraction,
- classification,
- tagging,
- search assistance,
- draft generation,
- meeting/task extraction,
- report drafts.

### 16.2 Autonomous AI later

Agents should come later, after:

- entities are clear,
- relationships are stable,
- events are captured,
- permissions exist,
- context quality is high,
- workflows are validated.

### 16.3 Model policy

Use model roles:

```txt
Reasoning/coding model → hard strategy, architecture, product work, code
Cheap extraction model → classification, summarization, tagging
Embedding model → retrieval and memory
Multimodal model → screenshots, documents, visual assets
```

Do not use expensive models for every task.

---

## 17. Operating domains

Operating domains are not separate products at first. They are views and workflows over the same context engine.

### 17.1 Brand

Identity, messaging, assets, campaigns, content, tone, visuals.

### 17.2 Marketing

Channels, campaigns, funnels, SEO, ads, email, content calendar, growth experiments.

### 17.3 Sales

Leads, opportunities, CRM, proposals, follow-up, contracts, renewals.

### 17.4 Customer

Feedback, tickets, requests, NPS, testimonials, community, case studies.

### 17.5 Product

Ideas, backlog, roadmap, features, releases, architecture, testing.

### 17.6 Design

Components, Figma, templates, illustrations, motion, video, design systems.

### 17.7 Finance

Revenue, expenses, cash flow, profitability, budgets, invoices, payments.

### 17.8 Operations

SOPs, processes, checklists, responsibilities, handoffs, automations.

### 17.9 HR

Roles, onboarding, team capacity, responsibilities, vacations, performance context.

---

## 18. Integrations

The integration strategy is:

> Pull context from tools without trying to replace them too early.

Initial integration targets should be chosen by validated workflow, not by hype.

Potential integrations:

```txt
Google Drive / Docs
Google Calendar
Gmail
WhatsApp Business
GitHub
Figma
Slack / Discord
Stripe / payment tools
HubSpot / CRM tools
Meta / Instagram / Ads
Airtable / Sheets
```

Each integration should answer:

1. What context does it provide?
2. Which entities does it create or enrich?
3. Which events does it emit?
4. Which decisions or actions can it support?
5. Does it need write access, or is read-only enough?

---

## 19. MVP conceptual wedge

Do not start by modeling the entire company.

Start with:

```txt
Clients + Projects + Meetings + Decisions + Tasks + Documents
```

This wedge matches what Creándola already does with clients.

### MVP workflow

```txt
1. A meeting/note/document enters.
2. The system extracts entities.
3. The system identifies decisions, tasks, risks, and open questions.
4. The system links them to client/project/domain.
5. The system makes them searchable.
6. The system proposes next actions.
7. The system can generate a simple report.
```

### MVP question examples

```txt
¿Qué sabemos de este cliente?
¿Qué decidimos en la última reunión?
¿Qué tareas salieron de este diagnóstico?
¿Qué problemas se repiten entre clientes?
¿Qué procesos ya están documentados?
¿Qué oportunidades están sin próxima acción?
```

---

## 20. Relationship with Creándola horizontals

Existing Creándola horizontals remain the practical operating layer:

```txt
Captación
Calificación
Seguimiento / CRM
Atención / WhatsApp
Documentación
Procesos internos
Automatización
Analítica / reportes
```

Company OS gives them deeper context.

Mapping:

```txt
Captación → Lead, Campaign, LandingPage, Channel, Message
Calificación → Lead, Opportunity, Score, Need, Segment
Seguimiento → Task, NextAction, Owner, PipelineState
WhatsApp → Conversation, Contact, Event, Summary
Documentación → Document, SOP, Process, Checklist
Procesos → Workflow, Role, Handoff, Status
Automatización → Trigger, Action, Automation, Event
Reportes → Metric, Insight, Report, Recommendation
```

---

## 21. Validation strategy

Creándola should validate Company OS through service delivery before turning it into a standalone software product.

Sequence:

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
Product capabilities become Creándola OS / Company OS software layer
```

This reduces product risk and keeps the product grounded in real client work.

---

## 22. What not to build yet

Do not build yet:

- a full dashboard,
- a full CRM,
- a full ERP,
- a full project manager,
- autonomous agents,
- deep integrations with every tool,
- complex permissions engine,
- graph database infrastructure,
- vector database infrastructure,
- new public brand,
- public Company OS landing,
- vertical product packages before the model is stable.

Do build/document first:

- ontology,
- entities,
- relationships,
- events,
- example workflows,
- decision rules,
- templates,
- manual validation processes.

---

## 23. Build criteria

Before building software for any capability, answer:

1. Has this workflow been validated manually or semi-manually?
2. Does it repeat across multiple clients/projects?
3. Does it save time, improve sales, reduce chaos, improve service quality, or improve decision-making?
4. Can it become a reusable horizontal capability?
5. Does it create or enrich context in the Company OS?
6. Can its value be reported monthly?
7. Can it start with existing tools before custom software?

If most answers are no, document it first.

---

## 24. Initial RFC roadmap

Recommended next RFCs:

```txt
RFC 0002 — Company Ontology v1
RFC 0003 — Context Engine Data Model
RFC 0004 — Memory and Provenance Rules
RFC 0005 — Events and Activity Model
RFC 0006 — MVP Workflow: Client → Meeting → Decision → Task → Report
RFC 0007 — Tooling and Integration Strategy
RFC 0008 — AI Layer: Basic AI Now, Agents Later
```

---

## 25. Open questions

1. What is the first real client workflow to model end-to-end?
2. Should the first manual system live in Google Drive, Airtable, Notion, or repo docs?
3. Which entities are mandatory for v1 and which should wait?
4. How much client data should enter the system during early validation?
5. What should be the first measurable outcome: saved time, fewer missed leads, faster documentation, better follow-up, or clearer decisions?
6. What is the minimum report that proves monthly value?

---

## 26. Deterministic decisions from this RFC

This RFC establishes the following decisions:

1. Creándola remains the public brand.
2. No new brand is created now.
3. Company OS is an internal product vision, not an immediate public product.
4. Creándola OS remains the internal/product technology layer under Creándola.
5. The core concept is **Context Engine**.
6. The future category is **Company Intelligence Platform**.
7. Knowledge is a core service, not a module.
8. AI is a layer over context, not the center of the product.
9. The first asset is the ontology/model, not code.
10. The first wedge is clients/projects/meetings/decisions/tasks/documents.
11. Company OS should integrate existing tools before replacing them.
12. Autonomous agents come after trusted context, memory, search, events, and permissions.

---

## 27. One-sentence foundation

> Company OS is Creándola’s internal vision for a company intelligence platform: a Context Engine that connects tools, knowledge, decisions, processes, clients, metrics, and memory so businesses can understand themselves, operate with less chaos, and make better decisions.
