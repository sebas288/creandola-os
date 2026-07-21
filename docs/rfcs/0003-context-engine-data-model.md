# RFC 0003 — Context Engine Data Model

Status: Draft v1  
Date: 2026-06-28  
Owner: Creándola  
Depends on: `docs/rfcs/0001-company-os-foundations.md`, `docs/rfcs/0002-company-ontology-v1.md`  
Scope: Implementation-neutral data model for Company OS / Context Engine  
Decision type: Product/data architecture foundation

---

## 1. Purpose

This RFC translates the Company OS ontology into an implementation-neutral data model.

It does **not** choose the final database, framework, or vendor. It defines the shape of the Context Engine so future implementation decisions can be made without losing the product model.

The goal is to represent:

- entities,
- properties,
- relationships,
- events,
- sources,
- documents,
- memories,
- permissions,
- embeddings,
- and context packs.

This RFC should guide future software design, manual prototypes, Airtable/Sheets experiments, and eventual Creándola OS product implementation.

---

## 2. Design goal

The Context Engine must answer:

```txt
What do we know?
Where did it come from?
How is it connected?
Why does it matter?
What changed over time?
Who can see it?
What should happen next?
```

A simple data model that cannot answer provenance, relationships, and time will fail.

---

## 3. Core decision

Use a **relational-first model with graph behavior**, not a specialized graph database as the first assumption.

This means:

```txt
entities table
relationships table
events table
sources table
memories table
```

can behave like a graph without requiring Neo4j or another graph database in v1.

Why:

- easier to understand,
- easier to migrate,
- easier to query for normal product workflows,
- easier to connect to dashboards,
- easier to implement with Postgres/Supabase later,
- enough for the first Company OS wedge.

A graph database can be considered later only if relationship traversal becomes the main bottleneck.

---

## 4. Data model layers

The Context Engine data model has six layers:

```txt
1. Identity and tenancy
2. Canonical entities
3. Relationships and graph edges
4. Events and temporal history
5. Sources, evidence, and provenance
6. Intelligence: memories, embeddings, insights, recommendations
```

Each layer should be useful independently, but the real value appears when they connect.

---

## 5. Identity and tenancy

Company OS must eventually support multiple companies or client workspaces.

Even if v1 is manual, the data model should avoid assuming one global workspace.

### Conceptual records

```txt
workspaces
users
memberships
roles
permissions
```

### workspace

Represents the operational context being modeled.

Examples:

```txt
Creándola internal workspace
Client A workspace
Client B workspace
```

Suggested fields:

```txt
id
name
slug
workspace_type
status
created_at
updated_at
```

Suggested workspace types:

```txt
internal
client
sandbox
template
```

### user

Represents a system user.

Suggested fields:

```txt
id
name
email
status
created_at
updated_at
```

### membership

Connects a user to a workspace.

Suggested fields:

```txt
id
workspace_id
user_id
role
status
created_at
updated_at
```

### role

Start simple:

```txt
owner
admin
member
viewer
external
```

Do not overbuild permissions in v1, but do not ignore workspace boundaries.

---

## 6. Canonical entity table

All business objects should have a canonical entity record.

This allows the Context Engine to connect different object types through one relationship/event model.

### entities

Suggested fields:

```txt
id
workspace_id
entity_type
title
summary
status
external_id
external_url
source_system
created_by
created_at
updated_at
archived_at
```

### entity_type

Examples from RFC 0002:

```txt
company
person
client
contact
project
meeting
decision
task
document
process
report
lead
opportunity
proposal
feedback
metric
campaign
asset
feature
summary
insight
recommendation
prompt
agent
context_pack
```

### Why one canonical entity table

Because the system needs to say:

```txt
Decision created Task
Meeting produced Decision
Feedback requested Feature
Document supports Decision
```

without creating custom join tables for every possible combination.

### Important constraint

The canonical entity table should not become a dumping ground for all properties.

Entity-specific data belongs in:

```txt
entity_properties
```

or typed tables later if needed.

---

## 7. Entity properties

Entity types have different fields. A flexible v1 model needs to support this without creating a full custom table for every object too early.

### entity_properties

Suggested fields:

```txt
id
entity_id
property_key
property_value
property_type
source_id
confidence
created_at
updated_at
```

### property_type

```txt
text
number
boolean
date
datetime
json
url
email
phone
enum
```

### Example properties

For a client:

```txt
industry = legal
city = Medellín
service_stage = active
primary_channel = WhatsApp
```

For a task:

```txt
due_date = 2026-07-05
priority = high
owner_id = person_123
```

For a decision:

```txt
rationale = Context Engine describes value better than Knowledge Graph
confidence = high
review_date = 2026-09-01
```

### Future option

If an entity type becomes critical and stable, it can later get a typed table:

```txt
clients
tasks
decisions
meetings
```

But v1 should start flexible enough to validate the ontology.

---

## 8. Relationships

Relationships are the graph edge layer.

### relationships

Suggested fields:

```txt
id
workspace_id
from_entity_id
relationship_type
to_entity_id
source_id
confidence
valid_from
valid_to
created_by
created_at
updated_at
archived_at
```

### relationship_type

Examples:

```txt
belongs_to
has
owns
assigned_to
managed_by
came_from
created_by
produced_by
captured_from
supported_by
creates
blocks
implements
updates
completes
triggers
references
summarizes
explains
describes
relates_to
supersedes
affects
measures
improves
reduces
increases
```

### Relationship example

```txt
from_entity: decision_001
relationship_type: creates
to_entity: task_008
source: meeting_summary_003
confidence: high
```

Human-readable:

```txt
Decision 001 creates Task 008, based on Meeting Summary 003.
```

### Relationship rules

1. A relationship should have a source whenever possible.
2. A relationship should support confidence.
3. A relationship can expire.
4. A relationship should be queryable in both directions.
5. Relationships should not hide event history.

---

## 9. Events

Events record that something happened.

Entities represent current objects. Events represent change over time.

### events

Suggested fields:

```txt
id
workspace_id
event_type
primary_entity_id
actor_entity_id
source_id
occurred_at
recorded_at
summary
data
created_at
```

### event_type examples

```txt
client.created
client.status_changed
project.created
project.status_changed
meeting.scheduled
meeting.completed
meeting.summarized
decision.proposed
decision.made
decision.superseded
task.created
task.assigned
task.status_changed
task.completed
document.created
document.updated
process.documented
report.generated
summary.generated
insight.generated
recommendation.generated
context.updated
memory.created
memory.updated
```

### event_related_entities

Events often involve multiple entities.

Suggested fields:

```txt
id
event_id
entity_id
role
created_at
```

Example roles:

```txt
primary
actor
client
project
source
output
mentioned
affected
```

### Event example

```txt
event_type: meeting.completed
primary_entity_id: meeting_123
actor_entity_id: person_001
related_entities:
  - client_002 as client
  - project_004 as project
  - document_009 as output
```

Human-readable:

```txt
Meeting 123 was completed by Person 001 for Client 002 and Project 004, producing Document 009.
```

---

## 10. Sources and provenance

Sources are where knowledge comes from.

Without sources, the system becomes untrustworthy.

### sources

Suggested fields:

```txt
id
workspace_id
source_type
source_system
title
url
external_id
author_entity_id
captured_at
created_at
metadata
```

### source_type examples

```txt
manual_entry
meeting_transcript
meeting_recording
document
email
whatsapp
github
figma
drive
calendar
system_generated
ai_generated
web
repo_file
```

### evidence records

Evidence connects a claim, memory, decision, or relationship to the source material that supports it.

Suggested fields:

```txt
id
workspace_id
source_id
entity_id
relationship_id
memory_id
event_id
quote
location
confidence
created_at
```

### location examples

```txt
line 42
page 3
00:14:22
paragraph 8
message id abc123
commit sha xyz789
```

### Provenance rule

Any important context should be able to answer:

```txt
Where did this come from?
Who created or confirmed it?
When was it last verified?
How confident are we?
```

---

## 11. Documents and files

A document can be both:

1. an entity in the graph,
2. and a source of evidence.

This distinction matters.

Example:

```txt
Document entity: Proposal for Client A
Source: Google Doc URL or markdown file that contains the proposal
```

### documents

If a separate typed table is needed later:

```txt
id
entity_id
workspace_id
document_type
title
body
summary
url
storage_path
version
status
created_at
updated_at
```

### file_assets

For binary or external files:

```txt
id
workspace_id
entity_id
source_id
file_name
mime_type
url
storage_path
size_bytes
checksum
created_at
```

### Document strategy v1

Do not ingest everything immediately.

Start with:

- repo docs,
- diagnostic notes,
- meeting summaries,
- proposals,
- reports,
- SOPs,
- checklists.

---

## 12. Memories

Memory is curated context, not raw data.

### memories

Suggested fields:

```txt
id
workspace_id
memory_type
title
summary
scope
validity
confidence
created_by
created_at
updated_at
review_at
archived_at
```

### memory_type

```txt
strategic
client
operational
decision
process
product
brand
ai
```

### memory_related_entities

```txt
id
memory_id
entity_id
relationship_role
created_at
```

### memory_sources

```txt
id
memory_id
source_id
evidence_id
created_at
```

### Memory example

```txt
memory_type: strategic
title: Horizontals before verticals
summary: Creándola should design reusable horizontals before building vertical industry adaptations.
related_entities: Company OS, Creándola, Horizontales
sources: docs/horizontales-creandola.md, docs/progreso-creandola.md
confidence: high
```

---

## 13. Context packs

A context pack is a curated bundle of relevant context for a task, question, agent, or workflow.

Examples:

```txt
Client diagnostic context pack
Proposal writing context pack
Monthly report context pack
Feature planning context pack
Agent execution context pack
```

### context_packs

Suggested fields:

```txt
id
workspace_id
title
purpose
scope
created_by
created_at
updated_at
```

### context_pack_items

Suggested fields:

```txt
id
context_pack_id
item_type
item_id
reason
priority
created_at
```

### item_type examples

```txt
entity
relationship
event
memory
source
document
evidence
metric
```

### Why context packs matter

AI should not receive the whole company context.

It should receive the smallest useful context pack for the task.

---

## 14. Embeddings and semantic retrieval

Embeddings should support retrieval, not replace structured relationships.

### embeddings

Suggested fields:

```txt
id
workspace_id
object_type
object_id
embedding_model
embedding_vector
content_hash
created_at
updated_at
```

### object_type examples

```txt
entity
source
document
memory
event
relationship
context_pack
```

### Embedding rules

1. Embed summaries and useful chunks, not every raw byte blindly.
2. Keep content hashes to avoid duplicate embeddings.
3. Store the model name used.
4. Rebuild embeddings when content changes meaningfully.
5. Never rely only on embeddings for permission checks.

### Search pipeline concept

```txt
query
↓
permission filter
↓
semantic retrieval
↓
structured relationship expansion
↓
source/evidence selection
↓
answer with references
```

---

## 15. Permissions model

Permissions should exist conceptually from the start even if v1 implementation is simple.

### access_policies

Suggested fields:

```txt
id
workspace_id
subject_type
subject_id
resource_type
resource_id
action
condition
created_at
updated_at
```

### subject_type

```txt
user
role
team
external_contact
agent
```

### resource_type

```txt
workspace
entity
source
document
memory
context_pack
relationship
event
```

### action

```txt
read
create
update
delete
share
execute
approve
```

### Initial rule

V1 can start workspace-scoped:

```txt
User can access records in workspace if membership is active.
```

But the model must leave room for:

- client-level isolation,
- document-level privacy,
- external collaborator access,
- AI/agent access constraints.

---

## 16. AI-generated artifacts

AI outputs should be stored as first-class artifacts when they influence decisions or actions.

### ai_runs

Suggested fields:

```txt
id
workspace_id
run_type
model
prompt_id
input_context_pack_id
output_entity_id
status
started_at
completed_at
created_by
metadata
```

### ai_run_sources

```txt
id
ai_run_id
source_id
entity_id
memory_id
created_at
```

### AI output types

```txt
summary
insight
recommendation
draft
task_extraction
decision_extraction
classification
```

### Human review fields

AI-generated artifacts that affect clients, decisions, or tasks should support:

```txt
human_reviewed_by
human_reviewed_at
review_status
review_notes
```

### Rule

AI can suggest context. Humans approve important operational memory and client-facing decisions.

---

## 17. Metrics and analytics

Analytics should be connected to context, not isolated dashboards.

### metrics

Suggested fields:

```txt
id
workspace_id
name
metric_type
unit
owner_entity_id
created_at
updated_at
```

### metric_values

```txt
id
metric_id
value
period_start
period_end
source_id
created_at
```

### metric_type examples

```txt
lead_count
conversion_rate
response_time
task_completion
revenue
retention
nps
cycle_time
```

### Context connection

Metrics should connect to:

```txt
Campaign
Lead
Project
Process
Report
Decision
Feature
```

Example:

```txt
Decision: change WhatsApp intake script
Metric: lead qualification rate
Relationship: Decision affects Metric
Event: metric.changed
```

---

## 18. Suggested conceptual schema

Implementation-neutral schema:

```txt
workspaces
users
memberships
entities
entity_properties
relationships
events
event_related_entities
sources
evidence
documents
file_assets
memories
memory_related_entities
memory_sources
context_packs
context_pack_items
embeddings
access_policies
ai_runs
ai_run_sources
metrics
metric_values
```

This does not mean all tables must be built immediately.

For manual validation, these can be represented in:

- Markdown docs,
- Google Sheets,
- Airtable,
- Notion databases,
- repo files,
- or a small Postgres prototype later.

---

## 19. Minimum viable data model

For the first manual or semi-manual prototype, only these objects are mandatory:

```txt
workspaces
entities
relationships
events
sources
memories
context_packs
```

And only these entity types are mandatory:

```txt
client
project
meeting
decision
task
document
process
report
```

This is enough to validate:

```txt
Meeting → Decisions → Tasks → Documents → Report
```

---

## 20. Example: meeting to decision to task

### Step 1 — Create meeting entity

```txt
entity_type: meeting
title: Client diagnostic call
status: completed
```

### Step 2 — Create source

```txt
source_type: meeting_transcript
title: Transcript — Client diagnostic call
url: drive/transcript-url
```

### Step 3 — Create event

```txt
event_type: meeting.completed
primary_entity: meeting
source: transcript
```

### Step 4 — Extract decision entity

```txt
entity_type: decision
title: Prioritize WhatsApp intake before automation
decision_text: The client should first standardize WhatsApp intake before adding advanced automation.
```

### Step 5 — Create relationship

```txt
Meeting produced Decision
Decision supported_by Source
```

### Step 6 — Extract task entity

```txt
entity_type: task
title: Draft WhatsApp intake script
status: next
owner: consultant
```

### Step 7 — Create relationship

```txt
Decision creates Task
Task belongs_to Project
```

### Step 8 — Create memory if durable

```txt
memory_type: process
summary: For this client, WhatsApp intake must be standardized before automation.
source: diagnostic meeting
```

---

## 21. Example: document to process memory

```txt
Document: SOP — Lead qualification
Process: Lead qualification
Relationship: Document describes Process
Event: process.documented
Memory: Lead qualification uses urgency, budget, owner dependency, and expected result as scoring criteria.
```

This allows the system to answer:

```txt
¿Cómo calificamos leads para este cliente?
```

with source-backed context.

---

## 22. Example: feedback to repeated pattern

```txt
Feedback A: client says leads arrive without context
Feedback B: another client says WhatsApp starts cold
Feedback C: internal team repeats same issue
```

The system can create:

```txt
Insight: Lead intake lacks context across multiple clients.
Recommendation: Build a reusable intake template.
Memory: Captación and Calificación should include source, need, urgency, and next action.
```

This is how services become product capabilities.

---

## 23. Manual prototype format

Before building custom software, this data model can be validated manually.

### Option A — Google Sheets / Airtable

Tables:

```txt
Entities
Relationships
Events
Sources
Memories
Context Packs
```

Pros:

- quick,
- visual,
- easy to edit,
- good for validation.

Cons:

- weak permissions,
- weak provenance,
- hard to scale.

### Option B — Markdown in repo

Files:

```txt
docs/context/entities.md
docs/context/relationships.md
docs/context/events.md
docs/context/memories.md
```

Pros:

- versioned,
- works well with AI agents,
- simple.

Cons:

- not good for many records,
- not ideal for nontechnical users.

### Option C — Small Postgres/Supabase prototype later

Pros:

- durable,
- queryable,
- permissions possible,
- product-ready path.

Cons:

- requires implementation discipline,
- can become premature if workflows are not validated.

### Recommendation

Start with Markdown + Sheets/Airtable for validation. Move to Postgres only when repeated workflows are proven.

---

## 24. Query patterns the model must support

### Client context

```txt
What do we know about Client X?
```

Needs:

```txt
Client entity
Projects
Meetings
Decisions
Tasks
Documents
Memories
Reports
```

### Decision history

```txt
Why did we decide to do Y?
```

Needs:

```txt
Decision
Source
Evidence
Meeting
Related tasks
Superseded decisions
```

### Next actions

```txt
What needs attention this week?
```

Needs:

```txt
Tasks
Statuses
Due dates
Owners
Blocked states
Client/project relationships
```

### Repeated patterns

```txt
What problems repeat across clients?
```

Needs:

```txt
Feedback
Meetings
Processes
Memories
Insights
Tags/properties
Relationships
```

### Monthly report

```txt
What changed this month?
```

Needs:

```txt
Events
Completed tasks
Decisions
New documents
Metrics
Risks
Recommendations
```

---

## 25. Data quality rules

### Rule 1 — No important context without source

Important memories, decisions, and recommendations should reference sources.

### Rule 2 — AI output must be labeled

The system must distinguish:

```txt
human-authored
AI-generated
AI-assisted
human-reviewed
```

### Rule 3 — Use confidence values

Suggested confidence values:

```txt
low
medium
high
verified
```

### Rule 4 — Avoid permanent memory from temporary state

A task being due tomorrow is not long-term memory.

A recurring rule about how proposals are followed up may be memory.

### Rule 5 — Prefer small context packs

Do not pass all company data into AI. Build focused context packs.

---

## 26. What not to implement yet

Do not implement yet:

- graph database,
- autonomous agents,
- advanced permission engine,
- all integrations,
- document ingestion pipeline for everything,
- universal dashboard,
- vector-only memory,
- full CRM replacement,
- full project management tool.

Do validate:

- can we model client context?
- can we capture decisions?
- can we connect decisions to tasks?
- can we generate a useful report?
- can we identify repeated patterns?
- can AI retrieve context with sources?

---

## 27. Deterministic decisions from this RFC

This RFC establishes:

1. The Context Engine should start relational-first with graph behavior.
2. Specialized graph databases are not required for v1.
3. Every important object should have a canonical entity record.
4. Entity-specific fields can start as flexible properties.
5. Relationships are first-class records.
6. Events are required for temporal history.
7. Sources and evidence are required for trust.
8. Memories are curated records, not raw storage.
9. Context packs are the unit of focused AI context.
10. Embeddings support retrieval but do not replace structured relationships.
11. Permissions must be considered from the beginning, even if simple.
12. AI-generated artifacts must be traceable and reviewable.
13. Manual validation can happen before custom software.

---

## 28. Next step

After this RFC, the next practical deliverable should be a manual prototype template for the first wedge:

```txt
docs/templates/context-engine-manual-prototype.md
```

or the horizontal operating templates:

```txt
docs/templates/diagnostico-horizontal.md
docs/templates/crm-horizontal.csv
docs/templates/reporte-mensual-horizontal.md
docs/templates/propuesta-horizontal.md
```

Recommended next step:

> Create the manual Context Engine prototype template first, then the horizontal templates.

That creates a bridge between the RFC model and real client validation.
