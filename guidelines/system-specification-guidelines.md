# Rule: System-Level Specification Guidelines
## Overview
This guideline is for specifying **multi-component systems** — orchestrators, daemons, long-running services, and anything with non-trivial state, concurrency, or cross-component contracts. It complements the Backend and Frontend guidelines, which are optimized for single-feature PRDs (a Lambda handler, a React component).
**When to use this instead of Backend or Frontend guidelines:**
- You're specifying a service that runs continuously (a poller, a scheduler, a daemon).
- The system has ≥ 3 components that communicate with each other.
- There is a non-trivial state machine (issue lifecycles, retry backoff, reconciliation).
- Observability, concurrency control, or safety boundaries are first-class concerns.
- The system is deployable as its own unit (not a handler inside a larger app).
If you are specifying "a Lambda function" or "a React component," use the Backend or Frontend guideline instead. This one is for "a service that orchestrates Lambda functions" or "a dashboard that coordinates multiple React apps."
**Inspiration**: The structural spine of this guideline is adapted from OpenAI's Symphony `SPEC.md` — a reference specification for a long-running agent-orchestration service. Symphony itself is not a guideline; it is an example of what a rigorous system-level spec looks like. We've extracted its structure into a reusable template here.
---
## Agent-Era Execution Model (v4.0.0)
System-level work is the most natural home for agent orchestration:
1. **Spawn Plan subagents early.** System specs benefit from a second opinion on the state machine and the domain model. Delegate architectural reviews to a Plan subagent before writing.
2. **Use Explore subagents for cross-cutting concerns.** "Does any existing service already do X?" is a recon question perfect for a subagent.
3. **Hooks enforce the test matrix.** A complete test matrix (per component) should be enforced by a `Stop` hook that refuses to archive the implementation log until each row is green.
4. **Workspace isolation is mandatory.** System specs produce large, cross-cutting changes. Never work on `main`; always use a dedicated branch or worktree.
5. **The `WORKFLOW.md` contract.** At the system level, `WORKFLOW.md` may also encode deployment targets, observability endpoints, and on-call rotation — the agent should read it before writing the spec.
---
## Application Process
1. **Receive Prompt** – User describes a system they want built (e.g., "a service that polls an issue tracker and runs a coding agent on each ticket in an isolated workspace").
2. **Read the Landscape** – Before anything else, use the Explore subagent to survey existing adjacent services, shared libraries, and deployment patterns.
3. **Clarify Boundaries First** – Same "build the fence" discipline as Backend/Frontend: non-goals, phasing, integration seams. System specs fail hardest when scope is not nailed down.
4. **Draft the Spec** – Use the section spine below. Write for extensibility: unknown configuration  keys should be ignored, new components should be addable without breaking existing ones.
5. **Delegate Review** – Before finalizing, send the draft to a Plan subagent for independent architectural review. Fold findings back in.
6. **Review, Approve, Commit** – Same critical checkpoint as all other guidelines. Do not begin implementation until the spec is committed.
7. **Archive on Completion** – Follow the ARCHIVAL PROTOCOL in `implementation-tasks-creation-guidelines.md`.
---
## System Spec Structure
Use these sections in order. Each section has a purpose — do not skip, even if it seems short.
### 1. Problem & Goals
State the operational problems the system solves. Be concrete:
- What is broken or manual today?
- What does success look like (measurable, verifiable)?
- What is explicitly out of scope?
**Example (from Symphony):**
> "Turns issue execution into a repeatable daemon workflow, isolates agent execution per issue, keeps workflow policy in-repo, and provides observability for concurrent runs."
### 2. System Architecture
Name the components. Draw the boundaries. For each component, state:
- **Responsibility** (one sentence)
- **Inputs** (what it reads)
- **Outputs** (what it produces)
- **Lifecycle** (started by what, stopped by what)
A system spec without a component list is a wish list. Be explicit.
**Template:**
| Component | Responsibility | Inputs | Outputs | Lifecycle |
|-----------|----------------|--------|---------|-----------|
| ...       | ...            | ...    | ...     | ...       |
### 3. Domain Model
List the entities the system reasons about. For each:
- **Name** (stable identifier — the thing a log line would reference)
- **Fields** (what it contains)
- **Identity** (how it is uniquely identified — internal ID vs. human-readable ID)
- **Lifecycle** (created, transitioned, retired)
Distinguish stable internal IDs from display-facing identifiers. This matters for logs, retries, and reconciliation.
### 4. Service Policy / Config File

> **Naming note.** This section is about the **service's own in-repository config/policy file** — the thing this service reads at startup. It is **not** the project-level `WORKFLOW.md` that tells the coding agent how to operate on this codebase. A project has one `WORKFLOW.md` (or `CLAUDE.md`/`AGENTS.md`) that lives alongside all of its code; a service has its own configuration  file that encodes *operational* policy. In some small projects they collapse to the same file. In larger projects (multiple services in one repo), keep them separate and name them distinctly (e.g., `config/scheduler.yaml`, `config/poller.yaml`).

If the service reads operational policy from a file in the repository (highly recommended), specify:
- **Filename and location** (`config/[service-name].yaml`, `[service-name]-policy.md`, etc.)
- **Schema** (required fields, optional fields, unknown-key policy)
- **Reload semantics** (does the service re-read at runtime? restart-only? SIGHUP?)
- **Validation** (what errors fail startup vs. warn)
- **Relationship to project `WORKFLOW.md`** (if any rules overlap, which file wins?)

**Forward compatibility rule**: Unknown keys should be ignored with a warning, not rejected. This lets the spec evolve without breaking deployed instances.

### 5. State Machine & Orchestration
For any component with non-trivial state:
- **States** (enumerated)
- **Transitions** (from → to, and the event that triggers each)
- **Invariants** (things that must be true in each state)
- **Concurrency rules** (max parallel runs, rate limits, queueing)
- **Retry policy** (backoff, max attempts, giveup condition)
- **Reconciliation** (how the system recovers after a restart — does it resume, replay, or drop in-flight work?)

A state diagram is worth writing out even if it feels obvious.

### 6. Streaming Transports

> **When to write this section.** Only if the system exposes or consumes a stream: Server-Sent Events, WebSocket, long-polling, gRPC server-streaming, Kafka/NATS/Redis PubSub fan-out, or any other "push" pattern where a client subscribes once and receives many messages. Frontend guidelines route streaming questions here; this is the canonical home for the design.

For each stream the system owns or consumes, specify:

**6.1 Transport choice and justification**
- **SSE** — one-way server-to-client, survives most proxies, browser EventSource is reliable. Good default for dashboards and live feeds.
- **WebSocket** — bidirectional, lower overhead, needs explicit reconnect logic. Choose when the client needs to send messages back over the same channel.
- **Long-polling** — fallback for restrictive environments; request/response loop with a hold timeout. Accept the per-request latency.
- **gRPC streaming** — for service-to-service streams in controlled networks; not for public browser clients.
- **Broker fan-out (Kafka/NATS/Redis)** — when multiple independent subscribers need the same feed and you want to decouple producer from consumer.

Document the tradeoff you accepted. "We chose SSE because [X, Y, Z]" beats "We use SSE."

**6.2 Message schema and framing**
- Wire format (JSON, protobuf, CBOR) and versioning policy.
- Required envelope fields: message ID (monotonic or ULID), timestamp, type, payload, schema version.
- Forward-compatibility rule: unknown fields ignored; unknown message types logged and dropped, not fatal.

**6.3 Backpressure and buffering**
- **Producer strategy** when the consumer is slow: drop oldest, drop newest, block, disconnect?
- **Buffer bounds** — how many frames does the server hold per subscriber? What happens at the limit?
- **Slow-consumer policy** — disconnect after N seconds of full buffer? Log + count the drops?

**6.4 Reconnect and resume semantics**
- **Who initiates reconnect** — client always, client-with-server-nudge, or server-push retry?
- **Backoff curve** — exponential with jitter, capped at N seconds; document the numbers.
- **Resume point** — last-seen message ID echoed on reconnect so the server can replay; or "no resume, clients accept gaps."
- **Idempotency guarantee** — if the server replays, are messages idempotent on the client side (keyed by message ID)?
- **Ordering on resume** — strictly ordered, per-partition ordered, or best-effort?

**6.5 Heartbeat and liveness**
- **Heartbeat frequency** and form (ping frame, empty SSE event, NOP message).
- **Client-side idle timeout** — how long without a heartbeat before the client assumes dead and reconnects.
- **Server-side dead-connection detection** — TCP keepalive settings or application-layer ping-pong.

**6.6 Fan-out and multi-subscriber semantics**
- **One-to-one** (per-user feed) vs. **one-to-many** (shared feed): different design.
- **Subscription granularity** — does the server filter, or does the client?
- **Auth scope on each message** — does every frame re-verify entitlement, or is subscription-time auth sufficient?

**6.7 Shutdown and graceful drain**
- **Shutdown signal** (SIGTERM, HTTP admin endpoint) and what it triggers.
- **Drain behavior** — stop accepting new subscriptions; continue serving existing ones for N seconds; then close with a reason code.
- **Close code taxonomy** — if the service emits WebSocket close codes, define them here.

**6.8 Testing hooks**
Every streaming contract should have a row in the Testing Matrix (§9):
- Unit test for the message encoder/decoder.
- Integration test that subscribes, receives N messages, validates ordering and schema.
- Chaos test that kills the connection mid-stream and verifies reconnect + resume.
- Slow-consumer test that confirms the documented backpressure policy.

**6.9 Frontend handoff**
The frontend PRD that consumes this stream should **not** repeat the transport, backpressure, or reconnect design — it should reference this section by name. The frontend PRD owns: the render path, the stale-frame detection UI, the reconnect-status indicator, and which user action surfaces a transport error.

### 7. Audit & Compliance Records

> **When to write this section.** Only if the system produces records that must be retained for regulatory, contractual, or forensic reasons: financial trades, authentication events, consent changes, administrative actions, data access logs, model-output provenance. Frontend guidelines route audit questions here. If the system has no such records, say so explicitly in one line and move on.

An audit record is not a log line. Logs are operational and can be rotated; audit records have retention obligations and integrity guarantees. Treat them as a first-class output of the system.

**7.1 Scope — what is and is not an audit event**
Enumerate the audit-relevant actions. For each, state:
- **Triggering event** (e.g., "order submitted", "user consent changed", "admin role grant", "model inference over threshold")
- **Who emits the record** (which component)
- **When** (synchronously on the action, or asynchronously from a queue)
- **Whether the originating action blocks on successful audit write** (see §7.7)

**7.2 Record schema**
Specify the canonical schema. Required fields for most audit records:
- **Record ID** — immutable, globally unique (ULID, UUIDv7).
- **Timestamp** — server-authoritative, monotonic, UTC, ISO-8601 with fractional seconds.
- **Actor** — who did the thing (user ID, service ID, system).
- **Action** — enumerated verb from the schema's action vocabulary.
- **Subject** — what the action was performed on (entity type + ID).
- **Outcome** — success, failure, partial, denied.
- **Context** — request ID, session ID, source IP, user agent (as applicable).
- **Before/after state** (where relevant) — the minimum state delta needed to reconstruct what changed.
- **Schema version** — for forward compatibility.

**7.3 Storage, retention, and immutability**
- **Storage tier** (database, append-only log, object storage) and durability guarantee.
- **Retention period** (e.g., 7 years for SOX trade records, 2 years for auth events) — state the regulatory source if applicable.
- **Immutability mechanism** — WORM (write-once-read-many) storage, append-only log, hash chaining, or cryptographic notarization. Document which guarantee you can actually prove.
- **Deletion policy** — beyond retention end, where do records go? Are there GDPR "right to erasure" carve-outs that override the retention floor?

**7.4 PII and secret handling**
- **What is redacted before the record is written**, and by whom.
- **Hashing and tokenization** — if a field is a hashed user ID, document the salt/pepper source.
- **Secrets policy** — no secrets, keys, tokens, or full card numbers in audit records. Ever. State this explicitly.
- **Access to identifying joins** — if the audit store holds hashed IDs, which system holds the hash→identity mapping, and who can access it?

**7.5 Access control**
- **Who can read the records** (enumerate roles or services).
- **Who can write** (only the emitting components).
- **Who can delete** — typically no one; only retention-policy enforcement.
- **Audit of audit** — if a human reads audit records, is that read itself audited? For regulated workloads, yes.

**7.6 Export and replay path**
- **Export format** (JSONL, Parquet, CSV) and cadence (on-demand, scheduled).
- **Replay** — can you reconstruct system state from the audit log alone? If not, document the gaps.
- **Legal hold** — how is a subset of records marked non-deletable for an open investigation?

**7.7 Failure semantics — the critical design decision**
When the audit write fails, does the originating action proceed?

- **"Fail closed"** — the action blocks and fails if the audit record cannot be written. Required for most regulated workloads (trades, consent, admin actions). Document the user-facing error and the operational remediation.
- **"Fail open with catchup"** — the action proceeds; audit is queued for asynchronous write with retry. Acceptable only when the action is reversible or the audit obligation permits eventual consistency. Document the maximum acceptable lag and the alert that fires if the queue grows unbounded.

There is no third option. Choose explicitly; do not leave this ambiguous.

**7.8 Regulatory mapping (if applicable)**
One short table naming the obligation each audit event satisfies:

| Event              | Framework   | Clause / Rule             | Retention |
|--------------------|-------------|---------------------------|-----------|
| Trade submitted    | SOX / FINRA | 17 CFR 240.17a-4          | 6 years   |
| Consent changed    | GDPR        | Article 7(1)              | Duration of processing + 3 years |
| Admin role grant   | SOC 2       | CC6.1                     | 1 year    |

Leave the table empty if no regulatory obligation applies, but the section header stays so reviewers can't skip the question.

**7.9 Frontend handoff**
The frontend PRD must **not** be the sole source of truth for an audit event. If a user action is audit-relevant, the record is written on the server side of that action, not from a fire-and-forget client call. The frontend's role is to surface success/failure to the user based on the server's response.

### 8. Safety & Integration
- **Trust boundaries**: Which components have which permissions? What can external input reach?
- **Workspace isolation**: Where does work happen? How is it cleaned up? Who owns the filesystem?
- **External integrations**: APIs called, authentication model, rate-limit handling, timeout policy.
- **Failure domains**: If external service X is down, which components degrade and which fail?

### 9. Observability & Operations
- **Structured logging**: What fields appear on every log line? (run ID, component, issue ID, etc.)
- **Metrics**: What counts, rates, and latencies are exported?
- **Dashboards / status surfaces**: HTTP endpoints, CLI commands, or dashboards for operators.
- **Operator intervention points**: How does a human pause, cancel, or drain the system safely?
- **Alerts**: What conditions should page a human?

### 10. Testing Matrix
Every component needs a row. Every row needs a verification command.

| Component        | Test Type         | Verification Command                            | Green When                           |
|------------------|-------------------|-------------------------------------------------|--------------------------------------|
| Config Loader    | Unit              | `node --test tests/config-loader.test.js`       | All assertions pass                  |
| Tracker Client   | Integration       | `node --test tests/tracker-client.test.js`      | Returns normalized issue list        |
| Orchestrator     | State-machine     | `node --test tests/orchestrator.test.js`        | All transitions fire correctly       |
| Stream Encoder   | Unit              | `node --test tests/stream-encoder.test.js`      | Round-trips all message types        |
| Audit Writer     | Integration       | `node --test tests/audit-writer.test.js`        | Fail-closed path blocks on error     |
| End-to-end       | Real integration  | `scripts/e2e-smoke.sh`                          | Exit code 0 with expected log lines  |

> **Adapt test-file extensions to your project's conventions.** The examples above assume Node.js native test; use `.test.ts`, `.spec.js`, `.test.py`, or whatever fits your stack.

A test matrix is the agent-era replacement for "we'll write tests later."

### 11. Agent Execution Plan (v4.0.0)
- **Branch/worktree**: `system/[service-name]`
- **Subagent delegation**: Which components can be built in parallel by independent subagents?
- **Hook requirements**: `PreToolUse(Bash:git commit)` runs the full test matrix; `Stop` blocks archival if any matrix row is red.
- **Project `WORKFLOW.md` reference**: Point to the file; do not restate its contents.

### 12. Extensibility
Document how to add:
- A new component
- A new field to the service policy/configuration  file
- A new state to the state machine
- A new streaming message type (forward compatibility)
- A new audit event type (schema migration)

Follow the rule: "Unknown keys are ignored for forward compatibility."

### 13. Non-Goals
List what the system will **not** do. Be specific. Common non-goals for system specs:
- No persistent database (use filesystem + restart recovery)
- No mandatory approval model (trust the tracker)
- No built-in secret management (delegate to the platform)

### 14. Open Questions
Items the spec cannot yet resolve. Each should have an owner and a resolution date.
---
## Example: Structuring a Symphony-Like Spec

A system spec for "a service that orchestrates coding agents against an issue tracker" would use this spine like so:

1. **Problem & Goals**: Eliminate manual ticket pickup; run agents in isolated workspaces; keep policy in-repo.
2. **Architecture**: Config Loader → Tracker Client → Orchestrator → Workspace Manager → Agent Runner → Logging Surface.
3. **Domain Model**: Issue, WorkflowDefinition, ServiceConfig, Workspace, RunAttempt, LiveSession, RetryEntry, RuntimeState.
4. **Service Policy / Config File**: `config/orchestrator.yaml` with required and optional fields; unknown keys ignored. Separate from the project `WORKFLOW.md`.
5. **State Machine**: IssueState (queued → running → completed/failed); RunAttempt (scheduled → active → finished); retry with exponential backoff.
6. **Streaming Transports**: SSE feed of live run-log frames to the operator dashboard; last-seen-ID resume; 30s heartbeat; slow-consumer disconnect after 60s.
7. **Audit & Compliance Records**: Immutable record per RunAttempt (actor=agent-id, subject=issue-id, outcome=success/failure); 1-year retention; fail-closed on audit-write error.
8. **Safety**: Each workspace is a disposable directory; agents never touch `main`; tracker writes are agent-owned.
9. **Observability**: Structured logs with run ID; optional HTTP status surface; metrics for active runs and retry counts.
10. **Testing Matrix**: Per-component unit tests + real-tracker integration smoke test + SSE chaos test + audit-write fail-closed test.
11. **Agent Execution Plan**: Branch `system/symphony`, subagent per component, hook-enforced test matrix.

This is not a reprint of Symphony's spec — it's what the spec looks like when compressed through this guideline's spine.
---
## Guiding Principles
- **Structure Over Prose**: Tables, state diagrams, and enumerated lists beat narrative paragraphs at the system level.
- **Stable IDs First**: Before writing the state machine, nail down how entities are identified.
- **Forward Compatibility by Default**: Unknown configuration  keys should warn, not fail.
- **Extensibility Is a First-Class Section**: Document how to extend the system in the spec itself.
- **Test Matrix Is Non-Negotiable**: Every component gets a row; every row gets a verification command.
- **Observability Is Part of Design**: If you can't name what to log, you can't name what went wrong.
- **Isolation Over Coordination**: Prefer designs where components can restart independently.
---
## Archival Cross-Reference
**IMPORTANT**: When archiving implementation logs, follow the **ARCHIVAL PROTOCOL** in `implementation-tasks-creation-guidelines.md`.
Key requirements:
1. Mark ALL tasks complete (`- [ ]` → `- [x]`)
2. Rename from `implementing-` to `implementation-log-`
3. Move to `documentation/tasks/completed/`
For system specs, the archival hook should additionally verify that every row in the Testing Matrix is green before allowing archival to complete.
---
## Output Requirements
- **Format:** Markdown (`.md`)
- **Location:** `/documentation/specifications/active/` (during development), `/documentation/specifications/completed/` (after completion)
- **Filename:** `system-specification-[service-name].md`
- **Service Config File:** A service-specific configuration  file describing runtime policy (see §4). Distinct from the project-level `WORKFLOW.md`. In a single-service repository the two may collapse into one file; in multi-service repositories, keep them separate so every service owns its configuration  file and the project owns `WORKFLOW.md`.