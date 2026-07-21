# Domain Validation Specification

## Purpose

Provide pure Zod 4 validation and runtime decoding for the Phase 1 entity and relationship contracts only.

## Requirements

### Requirement: Discriminated Entity Schemas

The domain MUST export a base entity schema and a discriminated union for client, project, meeting, decision, task, document, process, and report. Universal fields MUST match the database contract: UUIDs, `name` length 1-256, status, object-valued properties, and timestamps where present. Every per-type properties schema MUST be strict and reject unknown keys.

The Phase 1 properties contract is:

| Type | Allowed keys |
|------|--------------|
| `client` | Optional `contact_email` email string |
| `project` | Optional ISO dates `start_date` and `end_date` |
| `meeting` | Optional ISO datetimes `starts_at` and `ends_at` |
| `decision`, `task`, `document`, `process`, `report` | No keys; strict `{}` |

#### Scenario: All supported types parse

- GIVEN one valid fixture for each of the eight entity types
- WHEN the discriminated union parses each fixture
- THEN all fixtures succeed with their specific inferred type

#### Scenario: Invalid universal value fails

- GIVEN an unsupported type, empty/overlong name, malformed UUID, or array-valued properties
- WHEN the base/union schema parses it
- THEN Zod returns a validation failure

### Requirement: Explicit Cross-Field Rules

Cross-field validation MUST be limited to documented invariants. In this slice: a project `end_date` cannot precede `start_date`; a meeting `ends_at` cannot precede `starts_at`; and relationship `valid_to` cannot precede `valid_from`. Client contact email, when present, MUST be valid but SHALL NOT be required without a product rule.

#### Scenario: Invalid project range fails

- GIVEN project properties with `end_date < start_date`
- WHEN the project schema parses them
- THEN validation fails at the end-date field

#### Scenario: Invalid meeting range fails

- GIVEN meeting properties with `ends_at < starts_at`
- WHEN the meeting schema parses them
- THEN validation fails at the end-time field

#### Scenario: Optional client email is validated

- GIVEN a client with no contact email
- WHEN parsed
- THEN validation succeeds
- BUT GIVEN a present malformed contact email
- THEN validation fails

#### Scenario: Unknown property keys are rejected for every type

- GIVEN a parameterized fixture covering client, project, meeting, decision, task, document, process, and report
- WHEN one unknown key is added to each otherwise valid `properties` object
- THEN every one of the eight strict schemas rejects its fixture as an unknown key

### Requirement: Relationship Schema

The relationship schema MUST use `from_entity_id` and `to_entity_id`, validate UUIDs, require a non-empty relationship type up to 64 characters, constrain confidence to 0-1, require object-valued properties, reject self-edges, and validate optional validity ordering.

#### Scenario: Invalid relationship fails

- GIVEN a self-edge, out-of-range confidence, or inverted validity range
- WHEN parsed
- THEN validation fails

### Requirement: Phase 1 DB Row Decoders

Runtime decoders MUST exist for `EntityRow` and `RelationshipRow`. Every database read wrapper for those models MUST decode before returning. Decoders for events, sources, memories, context packs, and access policies SHALL NOT be required in this change.

#### Scenario: Malformed row is rejected

- GIVEN a Phase 1 row missing `workspace_id` or containing invalid JSONB shape
- WHEN its decoder parses it
- THEN a stable `ValidationError` is thrown

#### Scenario: Valid row is decoded

- GIVEN a valid entity or relationship row
- WHEN decoded
- THEN a typed domain value is returned according to the documented timestamp representation

### Requirement: Named Limit Constants

`src/domain/entities/limits.ts` MUST define unambiguous constants for entity name (256), workspace name (128), workspace slug (63), property key (128), relationship type (64), and idempotency key (1-256 printable ASCII characters). Idempotency whitespace is rejected anywhere; keys are not trimmed, normalized, or case-folded. Database RPC validation and Zod schemas MUST enforce `^[!-~]{1,256}$`, and tests MUST assert every boundary.

#### Scenario: Limits match across layers

- GIVEN each limit value
- WHEN Zod boundary tests and database constraint/RPC tests run at max and max+1
- THEN both layers accept/reject the same inputs
- AND no ambiguous generic `MAX_NAME_LENGTH` represents two different database columns

#### Scenario: Idempotency key semantics match across layers

- GIVEN the keys `!`, `~`, and a 256-character printable-ASCII key
- WHEN validated by Zod and the database RPC
- THEN both layers accept all three
- BUT GIVEN an empty key, 257 printable characters, space/tab/newline, another ASCII control, DEL (`U+007F`), or a Unicode character
- THEN both layers reject it without trimming
- AND keys differing only by case remain distinct

### Requirement: Framework Independence

The domain layer MUST remain pure TypeScript plus Zod and SHALL NOT import Next.js, React, Supabase, or `server-only`.

#### Scenario: Dependency boundary is clean

- GIVEN all `src/domain` imports
- WHEN scanned during verification
- THEN no prohibited framework import is found
