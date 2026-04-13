# System Specification: [Service Name]

---
**Domain**: System (multi-component service)
**Guideline**: `system-specification-guidelines.md`
**Testing Approach**: Per-component matrix with verification commands
**Service Type**: [Orchestrator | Poller | Daemon | Stream Processor | Scheduler]
---

> **How to use this template.** Work the sections in order. Each section has a one-line prompt; replace it with the content for your system. For long-form guidance on what goes in each section, see `guidelines/system-specification-guidelines.md` — it is the authoritative reference. Do not skip sections; if one is genuinely not applicable, leave the header in place and state in one line why.

## 1. Problem & Goals

*State the operational problem the system solves, what success looks like (measurable and verifiable), and what is explicitly out of scope. Be concrete — "what is broken or manual today?" is a good opening sentence.*

## 2. System Architecture

*Name the components. Draw the boundaries. For each component give a one-sentence responsibility, its inputs, its outputs, and its lifecycle. A system spec without a component table is a wish list.*

| Component | Responsibility | Inputs | Outputs | Lifecycle |
|-----------|----------------|--------|---------|-----------|
| …         | …              | …      | …       | …         |

## 3. Domain Model

*List the entities the system reasons about. For each: stable identifier (the thing a log line references), fields, identity rule (internal ID vs. human-readable ID), and lifecycle (created → transitioned → retired). Distinguish stable internal IDs from display-facing identifiers — this matters for logs, retries, and reconciliation.*

## 4. Service Policy / Configuration File

*If the service reads operational policy from an in-repository file at startup, specify filename and location (for example `config/[service-name].yaml`), schema (required and optional fields, unknown-key policy), reload semantics (restart-only, SIGHUP, runtime re-read), validation rules, and the relationship to the project-level `WORKFLOW.md`.*

> **Naming reminder.** This file is the **service's own** operational configuration. It is **not** the project's `WORKFLOW.md`, which tells the coding agent how to operate on the repository. In single-service repositories the two may collapse into one file; in multi-service repositories, keep them separate and name them distinctly. Forward compatibility: unknown keys are ignored with a warning, never rejected.

## 5. State Machine & Orchestration

*For any component with non-trivial state, enumerate states, transitions (from → to and the triggering event), invariants (what must be true in each state), concurrency rules (max parallel runs, rate limits, queueing), retry policy (backoff, max attempts, giveup condition), and reconciliation on restart (resume, replay, or drop in-flight work).*

## 6. Streaming Transports

*Delete this section if the system neither exposes nor consumes a stream. Otherwise specify: (6.1) transport choice and justification (SSE / WebSocket / long-polling / gRPC streaming / broker fan-out) with the tradeoff you accepted; (6.2) message schema and framing with forward-compatibility rule; (6.3) backpressure and buffer bounds; (6.4) reconnect and resume semantics including last-seen ID, backoff curve, idempotency, and ordering guarantees; (6.5) heartbeat frequency and liveness detection; (6.6) fan-out and multi-subscriber semantics including per-frame auth scope; (6.7) shutdown and graceful drain including close-code taxonomy; (6.8) testing hooks (encoder round-trip, chaos, slow consumer); (6.9) frontend handoff — which side owns render, reconnect UX, and stale-frame detection.*

## 7. Audit & Compliance Records

*Delete this section if the system produces no records that must be retained for regulatory, contractual, or forensic reasons. Otherwise specify: (7.1) scope — what is and is not an audit event and which component emits each; (7.2) canonical record schema (record ID, timestamp, actor, action, subject, outcome, context, before/after state, schema version); (7.3) storage, retention, immutability mechanism (WORM, append-only, hash chaining), deletion policy including any GDPR erasure carve-outs; (7.4) PII and secret redaction rules; (7.5) access control (who reads, who writes, who deletes, and whether audit reads are themselves audited); (7.6) export and replay paths for investigations including legal hold; (7.7) failure semantics — **fail-closed** (block the originating action on audit-write failure) or **fail-open with catchup** (async queue with documented max lag and alert). There is no third option — choose explicitly; (7.8) optional regulatory mapping table; (7.9) frontend handoff — the client must not be the sole source of truth for an audit-relevant event.*

| Event | Framework | Clause / Rule | Retention |
|-------|-----------|---------------|-----------|
| …     | …         | …             | …         |

## 8. Safety & Integration

*Trust boundaries (which components have which permissions, what external input can reach). Workspace isolation (where work happens, how it is cleaned up, who owns the filesystem). External integrations (APIs called, authentication model, rate-limit handling, timeout policy). Failure domains (if external service X is down, which components degrade and which fail).*

## 9. Observability & Operations

*Structured logging fields that appear on every log line (run ID, component, entity ID). Metrics — counts, rates, latencies. Dashboards and status surfaces (HTTP endpoints, CLI commands). Operator intervention points (how a human pauses, cancels, or drains the system safely). Alerts — what conditions should page a human.*

## 10. Testing Matrix

*Every component gets a row. Every row gets a verification command. Adapt test-file extensions to your stack (`.test.js`, `.test.ts`, `.spec.js`, `.test.py`, etc.).*

| Component | Test Type | Verification Command | Green When |
|-----------|-----------|---------------------|------------|
| …         | Unit      | …                   | …          |
| …         | Integration | …                 | …          |
| End-to-end | Real integration | …            | Exit code 0 with expected log lines |

## 11. Agent Execution Plan (v4.0.0)

- **Branch/worktree**: `system/[service-name]`
- **Subagent delegation**: [Which components can be built in parallel by independent subagents?]
- **Hook requirements**: `PreToolUse(Bash:git commit)` runs the full testing matrix; `Stop` blocks archival if any matrix row is red.
- **Project `WORKFLOW.md` reference**: [Point at the project's `WORKFLOW.md`; do not restate its contents.]
- **Delegatable research**:
  - [ ] [Explore subagent]: …
  - [ ] [Plan subagent]: …

## 12. Extensibility

*Document how to add: a new component; a new field to the service policy / configuration file; a new state to the state machine; a new streaming message type (forward-compatibility rule); a new audit event type (schema migration). The rule everywhere: unknown keys are ignored for forward compatibility.*

## 13. Non-Goals

*List what the system will NOT do. Be specific. Common system-level non-goals: no persistent database (use filesystem + restart recovery); no mandatory approval model (trust the source); no built-in secret management (delegate to the platform).*

## 14. Open Questions

*Items the spec cannot yet resolve. Each should have an owner and a resolution date.*

---

## Archival Cross-Reference

**IMPORTANT**: When archiving implementation logs, follow the **ARCHIVAL PROTOCOL** in `implementation-tasks-creation-guidelines.md`.

Key requirements:
1. Mark ALL tasks complete (`- [ ]` → `- [x]`)
2. Rename from `implementing-` to `implementation-log-`
3. Move to `documentation/tasks/completed/`

For system specs, the archival hook should additionally verify that every row in the Testing Matrix is green before allowing archival to complete.

---

## Quick Checklist

☐ Problem and goals stated in concrete, measurable terms
☐ Component table populated — responsibility, inputs, outputs, lifecycle
☐ Domain entities have stable internal identifiers distinct from display identifiers
☐ Service policy / configuration file schema specified with forward-compatibility rule
☐ State machine enumerated with transitions, invariants, and concurrency rules
☐ Streaming Transports section completed or explicitly marked not applicable
☐ Audit & Compliance Records section completed or explicitly marked not applicable, with fail-closed vs. fail-open decision made explicitly
☐ Observability fields named; operator intervention points documented
☐ Testing matrix has one row per component, each with a verification command
☐ Agent Execution Plan names the branch, subagent delegation strategy, required hooks, and `WORKFLOW.md` reference
☐ Extensibility rules stated for every mutable part of the system
☐ Non-goals explicit
☐ Open questions have owners and resolution dates
☐ Archival workflow understood
