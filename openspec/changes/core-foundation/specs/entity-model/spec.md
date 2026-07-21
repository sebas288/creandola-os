# Entity Model Specification

## Purpose

Define the Phase 1 canonical entity graph and its database-enforced tenant and idempotency invariants. Later Context Engine tables are outside this specification.

## Requirements

### Requirement: Canonical Entities

The system MUST provide one `entities` table with `id`, `workspace_id`, `entity_type`, `name`, `status`, object-valued `properties`, `fingerprint`, nullable `idempotency_key_hash`, `created_by`, timestamps, and `archived_at`. `entity_type` MUST allow only client, project, meeting, decision, task, document, process, and report. Entity names MUST be non-empty and at most 256 characters.

#### Scenario: Valid entity is created

- GIVEN an active member with role owner, admin, or member
- WHEN `create_entity` receives a valid workspace, type, name, and JSON object properties
- THEN it returns the inserted UUID
- AND `created_by` equals the authenticated profile ID
- AND the stored fingerprint is the canonical request SHA-256

#### Scenario: Invalid universal fields are rejected

- GIVEN an unsupported entity type, empty/overlong name, or non-object properties
- WHEN entity creation is attempted
- THEN the database rejects the request without inserting a row

### Requirement: Explicit-Key Idempotency

`create_entity` MUST treat an idempotency key as scoped to one workspace. A non-null key MUST match `^[!-~]{1,256}$`: exactly 1-256 printable ASCII characters. Whitespace is invalid anywhere; the RPC MUST NOT trim, normalize, or case-fold the value. It MUST hash the exact validated bytes separately from the canonical request fingerprint and serialize concurrent attempts with a transaction advisory lock. The fingerprint itself SHALL NOT be unique.

#### Scenario: Idempotency ASCII boundaries are enforced identically

- GIVEN the one-character keys `!` and `~`, plus a 256-character key composed of printable ASCII
- WHEN the database RPC and Zod schema validate them
- THEN both layers accept all three values
- BUT GIVEN an empty key, 257 printable characters, space/tab/newline, another ASCII control, DEL (`U+007F`), or a Unicode character
- THEN both layers reject the value without inserting a row
- AND the RPC uses SQLSTATE `22023`

#### Scenario: Key identity is exact

- GIVEN two otherwise identical calls using `Request-1` and `request-1`
- WHEN both are submitted in one workspace
- THEN they are treated as different idempotency keys

#### Scenario: Same key and payload is replayed

- GIVEN a successful entity creation with an idempotency key
- WHEN the same workspace, key, and normalized payload are submitted again
- THEN the original UUID is returned
- AND exactly one row exists for that workspace/key hash

#### Scenario: Key is reused with changed payload

- GIVEN an idempotency key already used in a workspace
- WHEN the same key is submitted with a different accepted payload
- THEN the RPC raises SQLSTATE `22023`
- AND the original row is unchanged

#### Scenario: Keyless identical calls remain distinct

- GIVEN two calls with identical payload and no idempotency key
- WHEN both succeed
- THEN they return different UUIDs
- AND two rows exist

#### Scenario: Same key in different workspaces is independent

- GIVEN the same idempotency key is used in two authorized workspaces
- WHEN both calls succeed
- THEN each workspace has its own entity

#### Scenario: Concurrent replay with matching payload serializes

- GIVEN Session A holds open a transaction after creating an entity with one workspace/key/payload
- WHEN Session B calls `create_entity` concurrently with the same workspace/key/payload
- THEN an observer session sees Session B waiting on an advisory lock before Session A commits
- AND after Session A commits, Session B returns the same UUID
- AND exactly one row exists

#### Scenario: Concurrent key conflict serializes before rejection

- GIVEN Session A holds open a transaction after creating an entity with one workspace/key/payload
- WHEN Session B calls concurrently with the same workspace/key but a different payload
- THEN an observer session sees Session B waiting on an advisory lock before Session A commits
- AND after Session A commits, Session B raises SQLSTATE `22023`
- AND the original row remains unchanged

### Requirement: Entity Properties

`entity_properties` MUST include `workspace_id`, `entity_id`, `property_key`, `property_value`, `property_type`, and timestamps. `(workspace_id, entity_id, property_key)` MUST be unique, and `(workspace_id, entity_id)` MUST reference the matching entity composite key with cascade delete.

#### Scenario: Cross-workspace property is rejected

- GIVEN an entity in workspace A
- WHEN a property row supplies workspace B with that entity ID
- THEN the composite foreign key rejects it

#### Scenario: Property indexing matches queries

- GIVEN the table indexes are inspected
- THEN a B-tree index supports workspace/property-key equality
- AND a separate `jsonb_path_ops` GIN index supports `property_value @>`
- AND no unsupported multicolumn text/JSONB GIN index is required

### Requirement: Directed Relationships

`relationships` MUST include `workspace_id`, `from_entity_id`, `to_entity_id`, `relationship_type`, confidence between 0 and 1, optional validity bounds, object-valued properties, and timestamps. Both endpoints MUST use composite foreign keys to entities in the same workspace. Self-edges and `valid_to < valid_from` MUST be rejected.

#### Scenario: Same-workspace entities are linked

- GIVEN two entities in one workspace
- WHEN a valid directed relationship is inserted through a future authorized write path or database fixture
- THEN it is queryable by indexed from/to endpoint predicates

#### Scenario: Cross-workspace relationship is rejected

- GIVEN endpoints in different workspaces
- WHEN a relationship attempts to reference them
- THEN at least one composite foreign key rejects the row independently of RLS

### Requirement: Phase 1 Scope Boundary

The migration SHALL NOT create or reference events, sources, evidence, memories, context packs, or access policies.

#### Scenario: No dangling Phase 2 dependency

- GIVEN Phase 1 catalog metadata
- WHEN foreign keys and columns are inspected
- THEN neither `entity_properties` nor `relationships` contains `source_id`
- AND no foreign key references a table absent from the migration

### Requirement: Tenant Read Policies

RLS MUST be enabled on all Phase 1 context tables. Authenticated SELECT policies MUST scope each row by its own `workspace_id` and active membership. Direct authenticated INSERT, UPDATE, and DELETE privileges/policies SHALL be absent.

#### Scenario: Members see only authorized rows

- GIVEN users in different workspaces
- WHEN each queries entities, properties, and relationships
- THEN each result contains only rows from active memberships
- AND inaccessible rows produce zero results rather than an assumed exception

#### Scenario: Direct table mutation is denied

- GIVEN an authenticated member who can read a workspace
- WHEN they attempt direct INSERT, UPDATE, or DELETE on Phase 1 tables
- THEN the operation is denied
