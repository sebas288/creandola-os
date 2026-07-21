# RFC 0002 — Company Ontology v1

Status: Draft v1  
Date: 2026-06-28  
Owner: Creándola  
Depends on: `docs/rfcs/0001-company-os-foundations.md`  
Scope: Conceptual ontology for Company OS / Context Engine  
Decision type: Product model foundation

---

## 1. Purpose

This RFC defines the first explicit ontology for Company OS.

The ontology answers:

> What is a company inside the Context Engine?

The goal is not to model every possible business detail. The goal is to define a stable v1 model that can support Creándola’s service delivery and later become the foundation for Creándola OS / Company OS software.

This RFC narrows RFC 0001 into:

- core entity types,
- required fields,
- relationships,
- events,
- states,
- memory types,
- provenance rules,
- example flows,
- and what should remain out of scope.

---

## 2. Foundational thesis

A company is not just a set of departments, tools, or documents.

Inside Company OS, a company is modeled as:

> A living network of people, clients, projects, decisions, processes, tasks, documents, events, and outcomes connected over time.

The Context Engine must preserve not only **what exists**, but also:

- why it exists,
- who created it,
- what it relates to,
- what decision produced it,
- what event changed it,
- what evidence supports it,
- what next action it implies,
- and what outcome it affected.

---

## 3. Design constraints for v1

### 3.1 Do not model the whole company yet

V1 should focus on the wedge from RFC 0001:

```txt
Clients + Projects + Meetings + Decisions + Tasks + Documents
```

This wedge is enough to validate whether the Context Engine can preserve useful operational memory.

### 3.2 Keep the ontology operational

Every entity should answer at least one of these questions:

1. Who is involved?
2. What are we working on?
3. What was decided?
4. What needs to happen next?
5. Where is the evidence?
6. What changed over time?
7. What can be reused later?

If an entity does not answer one of those questions, it probably does not belong in v1.

### 3.3 Prefer reusable primitives

Use generic primitives that can later support multiple domains.

For example:

```txt
Decision
Task
Document
Event
Metric
Process
```

are more valuable than hyper-specific objects like:

```txt
InstagramCaptionApproval
LegalInsolvencyChecklistStep
FigmaHeroRevision
```

The latter can become tags, templates, properties, or domain-specific specializations later.

---

## 4. Ontology layers

The ontology is organized into four layers:

```txt
1. Core primitives
2. Operating entities
3. Domain entities
4. Intelligence entities
```

### 4.1 Core primitives

These appear across all domains.

```txt
Entity
Relationship
Event
State
Memory
Source
Evidence
Context
```

### 4.2 Operating entities

These represent everyday work.

```txt
Company
Person
Client
Contact
Project
Meeting
Decision
Task
Document
Process
Report
```

### 4.3 Domain entities

These appear in business domains but should not dominate v1.

```txt
Lead
Opportunity
Campaign
Asset
Feature
Feedback
Metric
Invoice
Contract
```

### 4.4 Intelligence entities

These represent AI/context artifacts.

```txt
Summary
Insight
Recommendation
Prompt
Agent
ContextPack
Evaluation
```

---

## 5. V1 mandatory entities

The following entities are mandatory for v1.

They support the initial wedge:

```txt
Client → Project → Meeting → Decision → Task → Document → Report
```

---

## 6. Entity: Company

### Definition

The company or workspace being modeled.

For Creándola’s own context, this can be Creándola. For client implementations, it can be the client company.

### Required fields

```txt
id
name
display_name
status
created_at
updated_at
```

### Optional fields

```txt
description
industry
website
country
city
primary_contact_id
notes
```

### Relationships

```txt
Company has Person
Company has Client
Company owns Project
Company has Document
Company defines Process
Company tracks Metric
```

### Notes

In early validation, one workspace may represent Creándola’s internal operation and another may represent a client implementation.

---

## 7. Entity: Person

### Definition

A human actor: team member, founder, client contact, collaborator, vendor, or stakeholder.

### Required fields

```txt
id
full_name
status
created_at
updated_at
```

### Optional fields

```txt
email
phone
role_title
organization
notes
```

### Relationships

```txt
Person works_at Company
Person belongs_to Client
Person owns Task
Person attended Meeting
Person made Decision
Person authored Document
Person requested Feature
```

### Notes

Do not overbuild HR in v1. Person exists to support attribution, ownership, and context.

---

## 8. Entity: Client

### Definition

A company, business, or account served by Creándola.

### Required fields

```txt
id
name
status
created_at
updated_at
```

### Optional fields

```txt
industry
website
city
country
primary_contact_id
service_stage
notes
```

### Suggested statuses

```txt
prospect
active
paused
lost
past
internal
```

### Relationships

```txt
Client has Contact
Client owns Project
Client has Meeting
Client has Document
Client has Contract
Client has Invoice
Client provided Feedback
```

### Notes

Client is central to Creándola’s validation strategy. The first useful Company OS memory will likely be client memory.

---

## 9. Entity: Contact

### Definition

A person associated with a client or prospect.

### Required fields

```txt
id
person_id
client_id
status
created_at
updated_at
```

### Optional fields

```txt
role
influence_level
decision_power
preferred_channel
notes
```

### Relationships

```txt
Contact belongs_to Client
Contact attended Meeting
Contact requested Work
Contact gave Feedback
Contact approved Proposal
```

### Notes

Contact exists separately from Person so the same person model can later support internal team members, partners, vendors, and client stakeholders.

---

## 10. Entity: Project

### Definition

A bounded body of work for a client or internal initiative.

### Required fields

```txt
id
name
status
owner_id
created_at
updated_at
```

### Optional fields

```txt
client_id
description
start_date
target_date
priority
health
notes
```

### Suggested statuses

```txt
idea
discovery
active
blocked
paused
completed
cancelled
```

### Relationships

```txt
Project belongs_to Client
Project has Meeting
Project has Decision
Project has Task
Project has Document
Project has Report
Project uses Process
Project produced Deliverable
```

### Notes

Project should be flexible enough to represent:

- a client engagement,
- a website redesign,
- a Company OS RFC sprint,
- a marketing campaign,
- a diagnostic process,
- or an internal operational improvement.

---

## 11. Entity: Meeting

### Definition

A synchronous conversation that produces context.

This can include calls, workshops, sales conversations, diagnosis sessions, internal planning, or client reviews.

### Required fields

```txt
id
title
held_at
status
created_at
updated_at
```

### Optional fields

```txt
client_id
project_id
agenda
summary
transcript_url
recording_url
source
notes
```

### Suggested statuses

```txt
scheduled
completed
cancelled
no_show
summarized
processed
```

### Relationships

```txt
Meeting belongs_to Client
Meeting relates_to Project
Meeting had Person
Meeting produced Decision
Meeting created Task
Meeting referenced Document
Meeting generated Insight
```

### Notes

Meeting is one of the highest-value v1 entities because it captures raw operational truth before it gets lost.

---

## 12. Entity: Decision

### Definition

A choice made by the company, team, client, or project stakeholders.

Decisions are first-class because repeated confusion usually comes from undocumented decisions.

### Required fields

```txt
id
title
decision_text
status
made_at
created_at
updated_at
```

### Optional fields

```txt
rationale
alternatives_considered
owner_id
client_id
project_id
source_id
confidence
review_date
notes
```

### Suggested statuses

```txt
proposed
approved
rejected
superseded
reversed
expired
```

### Relationships

```txt
Decision made_by Person
Decision belongs_to Project
Decision came_from Meeting
Decision created Task
Decision changed Process
Decision updated RoadmapItem
Decision affected Metric
Decision supersedes Decision
Decision supported_by Evidence
```

### Notes

A good decision record should answer:

```txt
What did we decide?
Why?
Who decided?
When?
Based on what evidence?
What changes because of it?
What should be reviewed later?
```

---

## 13. Entity: Task

### Definition

A concrete action that should be done by someone.

### Required fields

```txt
id
title
status
owner_id
created_at
updated_at
```

### Optional fields

```txt
description
client_id
project_id
due_date
priority
source_id
completion_notes
notes
```

### Suggested statuses

```txt
backlog
next
in_progress
blocked
waiting
done
cancelled
```

### Relationships

```txt
Task belongs_to Project
Task assigned_to Person
Task created_by Decision
Task came_from Meeting
Task references Document
Task blocks Task
Task completes ProcessStep
Task produces Document
```

### Notes

Tasks are not the whole product. They are a bridge between context and action.

Company OS should not try to become a full task manager initially. It should preserve why a task exists and what context it carries.

---

## 14. Entity: Document

### Definition

Any durable artifact that stores knowledge, evidence, process, proposal, report, research, or deliverable.

### Required fields

```txt
id
title
document_type
status
created_at
updated_at
```

### Optional fields

```txt
url
body
summary
author_id
client_id
project_id
source_system
version
notes
```

### Suggested document types

```txt
note
proposal
contract
report
sop
checklist
research
brief
meeting_summary
decision_log
asset_reference
rfc
template
```

### Suggested statuses

```txt
draft
active
archived
superseded
approved
```

### Relationships

```txt
Document authored_by Person
Document belongs_to Client
Document relates_to Project
Document describes Process
Document supports Decision
Document produced_by Task
Document references Document
Document supersedes Document
```

### Notes

Document is not limited to Markdown. It may point to Google Docs, Drive files, PDFs, Figma files, repo docs, or generated summaries.

---

## 15. Entity: Process

### Definition

A repeatable way of doing work.

### Required fields

```txt
id
name
status
owner_id
created_at
updated_at
```

### Optional fields

```txt
description
domain
client_id
project_id
trigger
output
notes
```

### Suggested statuses

```txt
observed
documented
validated
automated
deprecated
```

### Relationships

```txt
Process belongs_to Company
Process belongs_to Client
Process has Document
Process uses Checklist
Process creates Task
Process measured_by Metric
Process handled_by Automation
Decision changed Process
```

### Notes

Process is important because Creándola’s value is not only delivery; it is turning repeated chaos into repeatable systems.

---

## 16. Entity: Report

### Definition

A periodic or one-time summary of progress, metrics, decisions, risks, and next actions.

### Required fields

```txt
id
title
period
status
created_at
updated_at
```

### Optional fields

```txt
client_id
project_id
summary
metrics
insights
recommendations
url
notes
```

### Suggested statuses

```txt
draft
sent
reviewed
archived
```

### Relationships

```txt
Report belongs_to Client
Report summarizes Project
Report includes Metric
Report includes Decision
Report includes Task
Report created Insight
Report recommended Action
```

### Notes

Reports are important because value should be visible monthly.

---

## 17. V1 optional but expected entities

These are useful soon, but not mandatory for the first manual model.

### Lead

Represents an inbound or outbound commercial opportunity before it becomes a client/project.

Suggested statuses:

```txt
new
contacted
qualifying
diagnostic_scheduled
proposal_needed
won
lost
paused
```

### Opportunity

A qualified commercial possibility.

### Proposal

A scoped offer sent to a lead or client.

### Feedback

Client/user input that may create tasks, decisions, process changes, product ideas, or reports.

### Metric

A measured value used to determine whether something improved.

### Campaign

A marketing effort tied to audience, message, asset, channel, leads, and results.

### Asset

A reusable design, content, brand, product, or marketing artifact.

### Feature

A product capability or requested improvement.

---

## 18. Relationship vocabulary v1

Relationships should be named consistently.

### Ownership and belonging

```txt
belongs_to
has
owns
assigned_to
managed_by
```

Examples:

```txt
Project belongs_to Client
Task assigned_to Person
Document belongs_to Project
```

### Origin and provenance

```txt
came_from
created_by
produced_by
captured_from
supported_by
```

Examples:

```txt
Task came_from Meeting
Decision supported_by Document
Report produced_by Task
```

### Work and execution

```txt
creates
blocks
implements
updates
completes
triggers
```

Examples:

```txt
Decision creates Task
Task updates Document
Automation triggers Event
```

### Knowledge and context

```txt
references
summarizes
explains
describes
relates_to
supersedes
```

Examples:

```txt
Document explains Process
Meeting summarizes Project
Decision supersedes Decision
```

### Business impact

```txt
affects
measures
improves
reduces
increases
```

Examples:

```txt
Process affects Metric
Release improves Metric
Campaign increases Lead volume
```

---

## 19. Relationship rules

### Rule 1 — Relationships should carry evidence

A relationship should not be treated as true without source context.

Minimum metadata:

```txt
source_type
source_id
created_at
created_by
confidence
```

### Rule 2 — Relationships may expire

Some relationships are temporary.

Example:

```txt
Person owns Task
```

can change.

Support later:

```txt
valid_from
valid_to
```

### Rule 3 — Relationships should explain why context exists

A relationship should help answer “why is this connected?”

Bad:

```txt
Task relates_to Client
```

Better:

```txt
Task came_from Meeting
Meeting belongs_to Client
```

---

## 20. Event model v1

Events are timestamped changes or observations.

They are necessary because a company changes over time.

### Event schema concept

```txt
event_id
event_type
timestamp
actor_id
primary_entity_type
primary_entity_id
related_entities
source_type
source_id
summary
data
```

### Required event families

#### Client/project events

```txt
client.created
client.status_changed
project.created
project.status_changed
project.health_changed
```

#### Meeting events

```txt
meeting.scheduled
meeting.completed
meeting.summarized
meeting.processed
```

#### Decision events

```txt
decision.proposed
decision.made
decision.superseded
decision.reversed
```

#### Task events

```txt
task.created
task.assigned
task.status_changed
task.completed
task.cancelled
```

#### Document events

```txt
document.created
document.updated
document.approved
document.superseded
```

#### Process events

```txt
process.observed
process.documented
process.validated
process.automated
process.deprecated
```

#### Report events

```txt
report.generated
report.sent
report.reviewed
```

#### AI/context events

```txt
summary.generated
insight.generated
recommendation.generated
context.updated
memory.created
memory.updated
```

---

## 21. State model v1

States are current conditions. Events explain how they changed.

### Project states

```txt
idea
discovery
active
blocked
paused
completed
cancelled
```

### Task states

```txt
backlog
next
in_progress
blocked
waiting
done
cancelled
```

### Decision states

```txt
proposed
approved
rejected
superseded
reversed
expired
```

### Document states

```txt
draft
active
approved
archived
superseded
```

### Process states

```txt
observed
documented
validated
automated
deprecated
```

### Client states

```txt
prospect
active
paused
lost
past
internal
```

---

## 22. Memory model v1

Memory is not raw storage. Memory is curated, source-backed context that should survive time.

### Memory record concept

```txt
memory_id
title
summary
memory_type
scope
related_entities
source_ids
created_at
updated_at
validity
confidence
```

### Memory types

#### Strategic memory

Long-term business decisions, positioning, product direction, and principles.

Example:

```txt
Creándola should design horizontals before verticals.
```

#### Client memory

Stable facts about a client relationship.

Example:

```txt
Client prefers WhatsApp for urgent operational coordination.
```

#### Operational memory

Reusable facts about how work is done.

Example:

```txt
Proposal follow-up should happen within 48 hours.
```

#### Decision memory

Important choices with rationale.

Example:

```txt
Company OS will use Context Engine language instead of Knowledge Graph language.
```

#### Process memory

Validated steps for repeatable work.

Example:

```txt
Diagnostic calls produce decisions, tasks, risks, and next actions.
```

#### Product memory

Important product assumptions, constraints, or validated patterns.

Example:

```txt
Autonomous agents should wait until context, permissions, and events are stable.
```

### What should not become memory

```txt
secrets
raw credentials
temporary task states
unverified assumptions
private personal data without purpose
raw transcripts without summaries
stale implementation details
```

---

## 23. Context rules

Context is created when entities, relationships, events, and memory are connected with provenance.

### Context requires at least three parts

```txt
Entity + Relationship/Event + Source
```

Example:

```txt
Decision: Use Context Engine language
Event: decision.made
Source: RFC 0001
```

### Context should answer

```txt
What happened?
Why did it happen?
Who was involved?
What evidence supports it?
What changed because of it?
What should happen next?
```

---

## 24. Provenance rules

Every important object should eventually track provenance.

Minimum provenance fields:

```txt
source_type
source_id
source_url
created_by
created_at
last_verified_at
confidence
```

### Source types

```txt
manual_entry
meeting_transcript
document
email
whatsapp
github
figma
drive
calendar
system_generated
ai_generated
```

### AI provenance

AI-generated content should be marked.

Suggested fields:

```txt
ai_generated: true/false
model
prompt_id
input_sources
human_reviewed_by
human_reviewed_at
```

---

## 25. Initial flows

### Flow 1 — Meeting to action

```txt
Meeting completed
↓
Summary generated
↓
Decisions extracted
↓
Tasks extracted
↓
Documents referenced
↓
Project context updated
↓
Next actions visible
```

Entities involved:

```txt
Meeting
Summary
Decision
Task
Document
Project
Person
```

Events:

```txt
meeting.completed
summary.generated
decision.made
task.created
context.updated
```

### Flow 2 — Client diagnosis

```txt
Client/prospect enters
↓
Diagnostic conversation occurs
↓
Pain points captured
↓
Process gaps identified
↓
Opportunities documented
↓
Proposal or next action created
```

Entities involved:

```txt
Client
Contact
Meeting
Document
Decision
Task
Proposal
```

Events:

```txt
client.created
meeting.completed
document.created
decision.made
task.created
proposal.sent
```

### Flow 3 — Process documentation

```txt
Repeated problem observed
↓
Process documented
↓
Checklist created
↓
Owner assigned
↓
Report shows improvement or issue
```

Entities involved:

```txt
Process
Document
Checklist
Task
Metric
Report
```

Events:

```txt
process.observed
process.documented
task.assigned
report.generated
```

### Flow 4 — Feedback to product/service improvement

```txt
Feedback received
↓
Request grouped with similar feedback
↓
Decision made
↓
Task or feature created
↓
Change shipped or process updated
↓
Metric monitored
```

Entities involved:

```txt
Feedback
Request
Decision
Task
Feature
Process
Metric
Report
```

Events:

```txt
feedback.received
decision.made
task.created
feature.requested
metric.changed
```

---

## 26. Domain mapping

### Sales / Customer

Core entities:

```txt
Lead
Client
Contact
Opportunity
Meeting
Task
Proposal
Feedback
Report
```

### Operations

Core entities:

```txt
Process
SOP
Checklist
Task
Decision
Document
Automation
Metric
```

### Product / Design

Core entities:

```txt
Feature
RoadmapItem
DesignFile
Asset
Feedback
Task
Release
Metric
```

### Brand / Marketing

Core entities:

```txt
Brand
Campaign
Channel
ContentPiece
Asset
LandingPage
Lead
Metric
```

### Finance

Core entities:

```txt
Proposal
Contract
Invoice
Payment
Metric
Report
```

### AI / Intelligence

Core entities:

```txt
Prompt
Agent
Model
Summary
Insight
Recommendation
ContextPack
Evaluation
```

---

## 27. Out of scope for v1

Do not model deeply yet:

- complete HR system,
- full accounting,
- payroll,
- inventory,
- ERP-level procurement,
- detailed permission engine,
- full graph database implementation,
- autonomous agent execution,
- complex multi-tenant billing,
- all possible vertical-specific objects.

These can come later after the Context Engine wedge is validated.

---

## 28. Acceptance criteria for ontology v1

This ontology is useful if it can represent these questions:

1. What do we know about a client?
2. What projects are active for that client?
3. What meetings happened?
4. What decisions came from those meetings?
5. What tasks were created?
6. Who owns the tasks?
7. Which documents explain the work?
8. Which processes are documented or missing?
9. What changed since last month?
10. What should happen next?

If the ontology cannot answer these, it is incomplete.

---

## 29. Deterministic decisions from this RFC

This RFC establishes:

1. V1 does not model the whole company.
2. V1 starts with clients, projects, meetings, decisions, tasks, documents, processes, and reports.
3. Decisions are first-class entities.
4. Events are required to understand time and change.
5. Memory is curated context, not raw storage.
6. Every important object should have provenance.
7. Context requires entity + relationship/event + source.
8. AI-generated content must be distinguishable from human-authored content.
9. Relationships should carry evidence and confidence.
10. Existing horizontals map cleanly into this ontology.

---

## 30. Next RFC

The next RFC should be:

```txt
RFC 0003 — Context Engine Data Model
```

It should translate this ontology into an implementation-neutral data model:

```txt
entities
entity_properties
relationships
events
sources
documents
memories
embeddings
permissions
```

It should not choose a final database yet, but it should prepare the system for a future relational-first implementation.
