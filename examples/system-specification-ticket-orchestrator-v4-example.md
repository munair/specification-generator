# System Specification: Ticket Orchestrator

---
**Guideline Used**: `system-specification-guidelines.md`
**Domain**: System (multi-component service)
**Framework Version**: v4.0.0 — Agent-Era Update
**Status**: Reference example (illustrative, not shipped)
**Service Type**: Poller + Orchestrator
---

> **Purpose of this example.** A deliberately realistic system-level specification demonstrating all 14 sections from `guidelines/system-specification-guidelines.md`, including both optional cross-cutting sections — §6 Streaming Transports and §7 Audit & Compliance Records. The service is a plausible-but-fictional orchestrator that polls an issue tracker, runs a coding agent against each ticket in an isolated workspace, streams live run logs to an operator dashboard, and writes immutable audit records for every run attempt. The structure is adapted from the Symphony-inspired spine described in the guideline's Inspiration section.

## 1. Problem & Goals

**Problem.** The team currently picks up issues from the tracker by hand, runs a coding agent locally, copies the resulting diff back into the ticket, and remembers (or forgets) to note what happened. There is no visibility into concurrent runs, no audit trail, no policy enforcement, and no way to share a half-finished run with a reviewer.

**Goals.**
- Turn ticket pickup and agent execution into a repeatable daemon workflow with no manual steps on the happy path.
- Run each agent attempt in an isolated workspace so runs cannot corrupt each other's state.
- Keep workflow policy in-repository (`WORKFLOW.md`) so every run honors the same rules without a central configuration server.
- Provide live observability (a streamed feed of run-log events) to a single operator dashboard.
- Produce an immutable audit record for every run attempt, retained per the team's compliance obligation.

**Out of scope.**
- Multi-operator dashboards with per-operator filtering. One dashboard, one operator.
- Persistent relational state. The filesystem plus restart recovery is enough for this service's scale.
- A built-in approval model for agent-authored changes. Review happens in the tracker, not in this service.

## 2. System Architecture

| Component             | Responsibility                                                                 | Inputs                                     | Outputs                                  | Lifecycle                                   |
|-----------------------|--------------------------------------------------------------------------------|--------------------------------------------|------------------------------------------|---------------------------------------------|
| **Configuration Loader** | Load and validate `config/orchestrator.yaml` at startup; re-read on `SIGHUP`. | `config/orchestrator.yaml`                 | Validated `ServiceConfig` record          | Runs on start and on each `SIGHUP`          |
| **Tracker Client**       | Poll the issue tracker's HTTP API for new or updated issues on a fixed interval. | `ServiceConfig`, tracker API               | Normalized `Issue` records                | Started by orchestrator; stops on shutdown  |
| **Orchestrator**         | Dispatch eligible issues to the workspace manager; enforce concurrency caps; drive the `IssueState` machine. | `Issue` stream, `RuntimeState`             | `RunAttempt` records                     | Started on boot; runs for the process's lifetime |
| **Workspace Manager**    | Allocate and tear down isolated filesystem workspaces per `RunAttempt`.        | `RunAttempt` requests                      | `Workspace` handles; cleanup events      | Per-run; cleaned up on `RunAttempt` end     |
| **Agent Runner**         | Invoke the coding agent binary inside a workspace and capture its output frame by frame. | `Workspace` handle, `RunAttempt` context   | `LiveSession` frames; final `RunAttempt` outcome | Per-run |
| **Stream Encoder**       | Take `LiveSession` frames from the agent runner and re-emit them as a per-subscriber SSE feed. | `LiveSession` frames, subscriber list      | SSE frames to dashboard                   | Long-lived; one instance per orchestrator   |
| **Audit Writer**         | Persist an immutable audit record for every `RunAttempt` transition and outcome. | `RunAttempt` events                         | Rows in the audit store                  | Long-lived; blocks run completion on write failure |
| **Logging Surface**      | Serve structured logs and a minimal HTTP status endpoint to operators.         | All components' structured log lines       | Log stream; `GET /status` JSON            | Long-lived; runs for the process's lifetime |

A system spec without a component table is a wish list. This is the first thing to pin down.

## 3. Domain Model

| Entity         | Fields                                                                                      | Identity                                                      | Lifecycle                                                  |
|----------------|---------------------------------------------------------------------------------------------|---------------------------------------------------------------|------------------------------------------------------------|
| `Issue`        | `externalId`, `title`, `body`, `state`, `assignee`, `labels`, `updatedAt`                   | Internal `issueId = ULID`; external `externalId` for display  | Created on first poll; retired when tracker marks closed   |
| `WorkflowDefinition` | `name`, `triggerLabel`, `agentBinary`, `timeoutSeconds`, `requiredHooks`                | Name (unique per config file)                                 | Loaded at startup; static for the process lifetime         |
| `ServiceConfig` | `pollIntervalSeconds`, `maxConcurrentRuns`, `workspaceRoot`, `trackerEndpoint`, `workflowDefinitions` | Singleton (one per process)                                   | Replaced on `SIGHUP`                                       |
| `Workspace`    | `runAttemptId`, `filesystemPath`, `createdAt`                                               | `runAttemptId`                                                | Created when a `RunAttempt` starts; deleted when it ends   |
| `RunAttempt`   | `runId = ULID`, `issueId`, `workflowName`, `state`, `startedAt`, `endedAt`, `outcome`, `agentBinary` | `runId`                                                | Scheduled → active → finished; terminal states persist    |
| `LiveSession`  | `runId`, `frames[]` (streamed), `lastFrameId`                                               | `runId`                                                       | Opens when agent runner starts; closes on `RunAttempt` end |
| `RetryEntry`   | `runAttemptId`, `attemptNumber`, `backoffSeconds`, `reason`                                 | `runAttemptId + attemptNumber`                                | Created on retry; discarded after giveup or success        |
| `RuntimeState` | `activeRunCount`, `queuedRunCount`, `startedAt`                                             | Singleton                                                     | Exists for the process lifetime                            |

**Identifier discipline.** Internal IDs are ULIDs generated on record creation. The tracker's `externalId` is display-facing — it appears in logs and dashboards but is never used as a key for retries, reconciliation, or audit records. This separation matters when a tracker renumbers issues (which happens).

## 4. Service Policy / Configuration File

> **Naming reminder.** This file — `config/orchestrator.yaml` — is the **service's own** operational configuration. It is **not** the project-level `WORKFLOW.md` that tells the coding agent how to operate on the repository hosting this service's source code. In a single-service repository the two may collapse into one file; in this example they are separate.

- **Filename and location**: `config/orchestrator.yaml` at the repository root of the service's source tree.
- **Schema** (required fields):
  - `pollIntervalSeconds` (integer, 10–600)
  - `maxConcurrentRuns` (integer, 1–32)
  - `workspaceRoot` (absolute filesystem path)
  - `trackerEndpoint` (URL)
  - `workflowDefinitions` (array of `{name, triggerLabel, agentBinary, timeoutSeconds}`)
- **Schema** (optional fields):
  - `heartbeatIntervalSeconds` (integer, default 30) — SSE heartbeat period
  - `slowConsumerDisconnectSeconds` (integer, default 60)
  - `auditRetentionYears` (integer, default 1)
- **Reload semantics**: On `SIGHUP`, the Configuration Loader re-reads and re-validates. On success, the new `ServiceConfig` replaces the old. On validation failure, the old config stays in effect and an error is logged. In-flight runs are unaffected.
- **Validation**: Missing required fields fail startup. Out-of-range values for `pollIntervalSeconds` or `maxConcurrentRuns` fail startup. Invalid URLs fail startup. Invalid workflow definitions fail startup.
- **Unknown keys**: Ignored with a warning, never rejected. Forward compatibility.
- **Relationship to project `WORKFLOW.md`**: No overlap. `WORKFLOW.md` governs how the coding agent develops on this service's source code; `orchestrator.yaml` governs how the service runs at deployment time. If a rule could be expressed in either file, it belongs in `orchestrator.yaml` because it is operational, not developmental.

## 5. State Machine & Orchestration

**`IssueState`.**
- States: `queued` → `running` → `completed` | `failed`
- Transitions:
  - `queued → running` when the orchestrator dispatches the issue to the workspace manager and the agent runner starts.
  - `running → completed` when the agent runner exits 0 and writes a successful audit record.
  - `running → failed` when the agent runner exits non-zero, times out, or the audit write fails (fail-closed; see §7.7).
- Invariants:
  - At most `maxConcurrentRuns` issues are in state `running` at any moment.
  - Every `running → {completed, failed}` transition emits exactly one audit record.

**`RunAttempt`.**
- States: `scheduled → active → finished`
- Transitions:
  - `scheduled → active` when the workspace is allocated and the agent runner starts.
  - `active → finished` when the agent runner exits (regardless of outcome).
- Retry policy: On `failed` outcome with a retriable reason (agent binary crash, transient tracker error), schedule a new `RunAttempt` with exponential backoff — 60 s, 300 s, 900 s — and give up after three attempts. Terminal (`giveup`) state persists for the audit record.
- Reconciliation on restart: On process start, the orchestrator reads `workspaceRoot` for any dangling workspaces, inspects their last recorded state from the audit store, and either resumes (if the audit shows `active` with a recent heartbeat) or marks them `failed` with reason `restarted_during_run` and schedules a retry.

## 6. Streaming Transports

The service exposes a live run-log stream to the operator dashboard.

**6.1 Transport choice — SSE, with justification.**
- Server-to-client only; no need for bidirectional.
- EventSource is reliable across the dashboard's supported browsers.
- Survives the reverse proxy in place without special configuration.
- The team operates a single dashboard, so broker-based fan-out would be overkill.
- Explicitly rejected: WebSocket (no need for client-to-server frames), long-polling (latency), gRPC streaming (not a browser-friendly transport).

**6.2 Message schema and framing.**
- Wire format: JSON frames, one per SSE event.
- Envelope: `{id: ULID, ts: string (ISO-8601), runId: ULID, type: string, payload: object, schemaVersion: integer}`.
- Frame types: `run_started`, `run_log_line`, `run_agent_event`, `run_finished`, `heartbeat`.
- Forward compatibility: unknown fields ignored; unknown `type` values logged by the client and dropped, not fatal.

**6.3 Backpressure and buffering.**
- Per-subscriber bounded buffer of 1,000 frames.
- Producer policy when the buffer is full: drop oldest. The operator sees frame gaps (visible as a numbered gap) rather than stalling the whole stream.
- Dropped-frame metric exported so the operator can tell the difference between "slow network" and "silent run".

**6.4 Reconnect and resume semantics.**
- Client initiates reconnect on EventSource error, with exponential backoff capped at 30 s.
- Server accepts a `Last-Event-ID` header on reconnect and replays every frame with a higher `id` from an in-memory ring buffer (60 seconds of history).
- Frames are idempotent on the client side; replay is safe.
- Ordering guarantee on resume: strictly ordered by `id` within a `runId`; best-effort across `runId` values.

**6.5 Heartbeat and liveness.**
- Server emits a `heartbeat` frame every 30 s (configurable via `heartbeatIntervalSeconds`).
- Client-side idle timeout: 90 s without a `heartbeat` or data frame triggers reconnect.
- Server-side dead-connection detection: if a subscriber's send buffer stays full for 60 s, disconnect with close code `1013` ("try again later") and log the event.

**6.6 Fan-out and multi-subscriber semantics.**
- One-to-many (shared feed). The operator dashboard is the intended subscriber; the transport supports multiple subscribers without change.
- Subscription granularity: server filters by `runId` if the client requests a specific run; otherwise, the full firehose.
- Auth scope: subscription-time auth is sufficient for this service. Per-frame auth re-verification is not required because all subscribers are operator-role.

**6.7 Shutdown and graceful drain.**
- `SIGTERM` triggers shutdown. The orchestrator stops accepting new subscriptions immediately, continues serving in-flight frames for up to 10 s, then closes every connection with code `1012` ("server restart").
- Close code taxonomy:
  - `1000` — normal end of stream
  - `1012` — server restart
  - `1013` — slow consumer disconnected

**6.8 Testing hooks.**
- Unit test for the envelope encoder/decoder (round-trips every `type`).
- Integration test that subscribes, receives 100 frames, validates ordering and schema.
- Chaos test that kills the connection mid-stream and verifies reconnect with `Last-Event-ID` replays the expected frames.
- Slow-consumer test that confirms the drop-oldest policy and disconnects after the configured window.

**6.9 Frontend handoff.**
The operator dashboard (a separate React application, not specified here) consumes this stream. The dashboard's frontend PRD must **not** repeat the transport, backpressure, or reconnect design — it references this §6 by name. The dashboard owns: the render path, the "disconnected" indicator, the "resuming" indicator, the stale-frame badge, and the operator action to manually reconnect.

## 7. Audit & Compliance Records

Every `RunAttempt` transition and outcome produces an audit record. These records are a first-class output of the system, not a side effect of logging.

**7.1 Scope — what is and is not an audit event.**
| Triggering event | Emitted by | When | Blocks action? |
|------------------|------------|------|----------------|
| `RunAttempt` scheduled | Orchestrator | Synchronously on dispatch | Yes (see §7.7) |
| `RunAttempt` started | Agent Runner | Synchronously at runner exec | Yes |
| `RunAttempt` completed | Agent Runner | Synchronously on exit 0 | Yes |
| `RunAttempt` failed | Agent Runner or Orchestrator | Synchronously on failure | Yes |
| `WorkflowDefinition` change at `SIGHUP` | Configuration Loader | Synchronously on reload | No (logged only) |

Out of scope as audit events (operational logs only): pollIng cadence ticks, heartbeat frames, slow-consumer disconnects, internal metrics updates.

**7.2 Record schema.**
- `recordId` — ULID, immutable, globally unique.
- `timestamp` — server-authoritative, monotonic, UTC, ISO-8601 with fractional seconds.
- `actor` — `agent-runner@<runId>` for runner-emitted records; `orchestrator@<process-id>` for orchestrator-emitted records.
- `action` — enumerated verb: `run_scheduled`, `run_started`, `run_completed`, `run_failed`, `config_reloaded`.
- `subject` — `{type: "run_attempt", id: runId}` or `{type: "workflow_definition", name: string}`.
- `outcome` — `success` | `failure` | `partial`.
- `context` — `{issueId, externalId, workflowName, trackerEndpoint}`.
- `beforeState`, `afterState` — `IssueState` or `RunAttempt` state delta. Optional; emitted for state-change records.
- `schemaVersion` — integer, currently `1`. Incremented when the schema evolves in a non-additive way.

**7.3 Storage, retention, and immutability.**
- Storage tier: append-only log file on local disk, rotated daily, with each rotated file sealed with a SHA-256 hash recorded in the next day's log header.
- Retention: `auditRetentionYears` from the service configuration (default 1 year). No hard upper bound.
- Immutability mechanism: append-only file + daily hash chaining. The service can prove that no record written before a given hash was modified.
- Deletion policy: Records past the retention window are archived to cold storage and deleted from the hot log by a separate archival cron job (not part of this service). No in-service deletion path.
- GDPR erasure: The `actor` field for human-initiated actions contains only a stable hash of the operator's identity; the hash-to-identity mapping lives in a separate system with its own erasure handling.

**7.4 PII and secret redaction.**
- **What is redacted before write**: agent runner stdout/stderr **never** lands in audit records. Only the `outcome` and a short `reasonCode` do. (The full stdout/stderr is an operational log, not an audit record.)
- **Hashing**: any field that would contain an operator human identity (none in this service's records) would be HMAC-SHA-256 hashed with a salt from the platform secret store. Not applicable here — all actors are `agent-runner` or `orchestrator`.
- **Secrets policy**: No secrets, API tokens, bearer headers, or full request bodies ever appear in audit records. Ever.
- **Access to identifying joins**: Not applicable for this service.

**7.5 Access control.**
- Read access: the single operator role and a compliance auditor role.
- Write access: only the Audit Writer component. No other component may write to the audit store.
- Delete access: no runtime code path. The out-of-band archival cron job is the only deleter, and its runs are themselves audited to the same store.
- Audit of audit: a human operator reading the audit store is logged by the surrounding access control layer (not this service). For this service's scale, that is sufficient.

**7.6 Export and replay path.**
- Export format: JSONL, one record per line, ordered by `timestamp`.
- Export cadence: on-demand via a CLI command `orchestrator audit export --from <ts> --to <ts>`.
- Replay: the audit log is sufficient to reconstruct the `IssueState` and `RunAttempt` history for any issue. Operational logs (stdout/stderr) are not required for replay.
- Legal hold: records flagged `legalHold=true` are excluded from the archival cron's delete pass until the flag is removed. The flag is set via a separate CLI command, which is itself audited.

**7.7 Failure semantics — the critical decision.**

**Fail-closed.** If the Audit Writer cannot persist a record for a `RunAttempt` transition, the transition does not happen. The orchestrator pauses the transition, retries the write (60 s backoff, 5 attempts), and if all attempts fail, marks the `RunAttempt` as `failed` with reason `audit_write_failed` and alerts the operator via the `GET /status` endpoint.

Rationale: the whole point of the audit trail is to be able to reconstruct what the service did. A transition that succeeds silently without an audit record defeats the trail. Fail-closed is the only correct choice here.

Operational remediation: the operator runs `orchestrator audit recover` to identify any transitions that were rolled back due to audit-write failure and re-schedule them. This command is itself audited.

**Not fail-open with catchup.** Acceptable only when the action is reversible or the obligation permits eventual consistency. Neither is true here.

**There is no third option.**

**7.8 Regulatory mapping.**

Not applicable for this service — the team has no external regulatory obligation around run-attempt records. The table is kept so reviewers can't skip the question.

| Event          | Framework | Clause / Rule | Retention |
|----------------|-----------|---------------|-----------|
| *(none)*       | *(n/a)*   | *(n/a)*       | *(n/a)*   |

**7.9 Frontend handoff.**

The operator dashboard is **not** the source of truth for any audit-relevant event. If the dashboard shows a run-attempt outcome, that outcome is read from the server's audit store, not inferred from a fire-and-forget client call. This service writes the record; the dashboard displays what the server acknowledged.

## 8. Safety & Integration

- **Trust boundaries**: The Tracker Client has outbound network access to the tracker only. The Agent Runner has filesystem access only to its assigned workspace. The Stream Encoder has outbound network access only to accepted SSE subscribers. No component has write access to another component's filesystem space.
- **Workspace isolation**: Each `RunAttempt` gets a fresh directory under `workspaceRoot/<runId>/`. The Workspace Manager creates it on allocation and removes it when the `RunAttempt` finishes. Workspaces are disposable; agents may never touch `main` or any shared directory.
- **External integrations**:
  - Issue tracker: authenticated HTTPS calls, bearer token from the platform secret store, 30 s request timeout, exponential backoff on 5xx (3 tries, 60 s / 300 s / 900 s).
  - Agent binary: invoked as a subprocess with the workspace as its working directory and a `RUNSIGNAL_*` environment variable set for interruption.
- **Failure domains**: If the tracker is unreachable, the Tracker Client backs off and the orchestrator idles; in-flight runs are unaffected. If the filesystem fills up, the Workspace Manager fails new allocations and the orchestrator reports `queued` count growth via `GET /status`.

## 9. Observability & Operations

- **Structured logging fields on every line**: `timestamp`, `level`, `component`, `runId` (if applicable), `issueId` (if applicable), `event`, and any event-specific fields. JSON lines to stdout; the platform's log collector takes it from there.
- **Metrics**: `active_run_count`, `queued_run_count`, `runs_started_total`, `runs_completed_total`, `runs_failed_total`, `audit_write_failures_total`, `sse_subscribers_count`, `sse_frames_dropped_total`, `tracker_poll_latency_ms`.
- **Status surface**: `GET /status` returns JSON with `{uptime, activeRunCount, queuedRunCount, lastPollAt, lastAuditWriteOk}`.
- **Operator intervention**: `orchestrator drain` (stops accepting new work, lets in-flight runs finish), `orchestrator pause` (halts poll loop), `orchestrator audit recover` (requeue runs blocked by audit-write failure).
- **Alerts**:
  - Any `audit_write_failures_total` increment pages immediately.
  - `queued_run_count > 0` for more than 10 minutes pages.
  - `tracker_poll_latency_ms` p95 > 5 seconds for 5 minutes pages.

## 10. Testing Matrix

Every component has a row. Every row has a verification command. Adapt extensions to your stack — this example uses Node.js native test.

| Component             | Test Type         | Verification Command                                 | Green When                                                  |
|-----------------------|-------------------|------------------------------------------------------|-------------------------------------------------------------|
| Configuration Loader  | Unit              | `node --test tests/config-loader.test.cjs`           | All required-field, range, and unknown-key assertions pass  |
| Tracker Client        | Integration       | `node --test tests/tracker-client.test.cjs`          | Returns normalized issue list against mock tracker          |
| Orchestrator          | State machine     | `node --test tests/orchestrator.test.cjs`            | All `IssueState` and `RunAttempt` transitions fire correctly|
| Workspace Manager     | Unit              | `node --test tests/workspace-manager.test.cjs`       | Allocate and teardown leave no leftover files               |
| Agent Runner          | Integration       | `node --test tests/agent-runner.test.cjs`            | Captures every frame type from a mock agent binary          |
| Stream Encoder        | Unit              | `node --test tests/stream-encoder.test.cjs`          | Round-trips every frame type and replays on `Last-Event-ID` |
| Stream Encoder        | Chaos             | `node --test tests/stream-encoder-chaos.test.cjs`    | Drop-oldest policy fires; disconnects on slow consumer      |
| Audit Writer          | Integration       | `node --test tests/audit-writer.test.cjs`            | Fail-closed path blocks the transition on write error       |
| Audit Writer          | Immutability      | `node --test tests/audit-immutability.test.cjs`      | Daily hash chain verifies; modifications detected           |
| Logging Surface       | Integration       | `node --test tests/logging-surface.test.cjs`         | `GET /status` JSON shape matches schema                     |
| End-to-end            | Real integration  | `bash scripts/e2e-smoke.bash`                        | Exit code 0 with expected log lines across a full run       |

This is the agent-era replacement for "we'll write tests later." The `Stop` hook in the project's `WORKFLOW.md` refuses to archive the implementation log until every row is green.

## 11. Agent Execution Plan (v4.0.0)

- **Branch**: `system/ticket-orchestrator`
- **Workspace**: git worktree under `.worktrees/ticket-orchestrator/` because the cross-component changes are large enough that a branch on the main checkout would block other work.
- **Subagent delegation**: One subagent per component. The Configuration Loader, Tracker Client, Orchestrator, Workspace Manager, Agent Runner, Stream Encoder, Audit Writer, and Logging Surface can be built in parallel because their only shared contracts are the types in `src/types/domain.d.ts`, which are authored first by the main agent before the subagents are spawned.
- **Hook requirements**:
  - `PreToolUse(Bash:git commit)` runs the full Testing Matrix via `pre-commit-gate.bash`.
  - `Stop` runs `verify-archival.bash` and additionally verifies every Testing Matrix row is green.
- **Project `WORKFLOW.md` reference**: See `WORKFLOW.md` at the repository root for test commands, commit style, branch policy, and hook configuration. Do not restate in the implementation tasks.

### Delegatable Research

- [ ] **Explore subagent**: Audit any existing polling-service code in this repository and in sibling services the team operates. Report which of them have a reusable tracker client, workspace manager, or audit writer. Goal: avoid rebuilding a component that already exists.
- [ ] **Explore subagent**: Read the issue tracker's API documentation and report the pagination shape, rate limits, and the `updatedAt` field semantics. Goal: size the poll interval and backoff curves correctly.
- [ ] **Plan subagent**: Review the `IssueState` / `RunAttempt` state machine for race conditions on restart. Specifically: can a restart during `running` produce a double-run? Output: a short analysis with a recommended reconciliation rule.
- [ ] **Plan subagent**: Review the fail-closed audit decision for this service's obligation profile. Confirm that fail-closed is the right call and that the operational remediation path is sufficient.

## 12. Extensibility

- **Adding a new component**: Add a row to §2 System Architecture, a lifecycle in §5 State Machine (if stateful), a row in §10 Testing Matrix, and a subagent in §11 Delegatable Research. No change to existing components required.
- **Adding a new field to `orchestrator.yaml`**: Add it to §4 Schema (optional fields) with a default value. Unknown keys are ignored; old deployments continue to work.
- **Adding a new state to `IssueState` or `RunAttempt`**: Update §5, add the transition, extend the audit schema's `action` enum with the new verb, and increment `schemaVersion` if the change is non-additive.
- **Adding a new streaming message type**: Add to §6.2 frame types. Clients ignore unknown types, so old dashboards continue to work. No version bump required.
- **Adding a new audit event type**: Add to §7.1 scope table, §7.2 schema `action` enum, and increment the audit `schemaVersion`. Migrate readers before writers.

The rule everywhere: **unknown keys are ignored for forward compatibility**.

## 13. Non-Goals

- **No persistent database.** Filesystem plus restart recovery plus audit log is sufficient for this service's scale. Adding Postgres is a separate PRD if scale demands it.
- **No mandatory approval model.** The tracker is the source of truth for whether an issue should be worked on. This service trusts it.
- **No built-in secret management.** Secrets come from the platform secret store. This service never persists a secret.
- **No built-in code review model.** Agent-produced changes are reviewed in the tracker, not in this service.
- **No web UI.** The operator dashboard is a separate application; this service exposes JSON over HTTP and SSE.

## 14. Open Questions

| Question | Owner | Resolve by |
|----------|-------|------------|
| Does the tracker API support delta polling (since-timestamp) or only full-list polling? | Team lead | Before task generation |
| Is the local filesystem acceptable for audit log storage in the production environment, or does compliance require object storage? | Compliance contact | Before §7 is finalized |
| What is the exact retention window for audit records per the team's obligation profile? | Compliance contact | Before §7.3 is finalized |

---

> **Why this spec looks the way it does.** Compare against the other two v4.0.0 examples in this directory: this one populates all 14 sections because a multi-component service needs every one of them. Both cross-cutting sections are present (§6 Streaming Transports and §7 Audit & Compliance Records). Every component has a row in the Testing Matrix. The audit decision is fail-closed, made explicitly, with rationale. Recon is hoisted to four subagents (two Explore, two Plan). Nothing in this spec restates a rule from `WORKFLOW.md`. This is what the Agent-Era Update produces at the system level.
