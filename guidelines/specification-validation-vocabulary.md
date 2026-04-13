# Specification Validation Vocabulary (v4.0.2)

## Purpose

This document is a **named failure taxonomy** for specification reviews. Every failure mode a reviewer (human or subagent) can flag when auditing a PRD, system specification, task list, or `WORKFLOW.md` has a stable identifier here, a one-line description, the guideline and section it belongs to, an example of the failure, and an example of the fix.

The pattern is adapted from OpenAI's Symphony `SPEC.md` §5.5 error taxonomy, which gives every validation failure a stable name so hooks, tooling, and reviewers can reference the same concept without re-inventing vocabulary. In Symphony the codes protect a runtime service from misconfiguration. Here they protect a specification from drift — the failure surface is different, but the value of stable names is the same.

## How to use this vocabulary

- **When auditing a PRD.** The Final Audit section in each PRD guideline (Backend, Frontend, System, Exploratory) now references these codes in parentheses after each red-flag bullet. An agent running the audit can surface the code in its report rather than re-describing the finding in prose.
- **When a reviewer (human or subagent) flags a finding.** Cite the code. `(frontend_calculates)` communicates "this PRD moves computation to the client that belongs on the server" in one token, and links to this file for the full rule.
- **When writing a hook that validates a PRD.** The hook can emit the code as the `permissionDecisionReason` so the deny signal is machine-parseable as well as human-readable.
- **When the vocabulary is missing a code you need.** Propose the addition in a pull request that also updates the guideline section that would emit it. Do not add a code without also updating the audit that surfaces it — every code should have a home in a guideline.

## Format of each entry

```
### <code_name>
**Detects.** <one-line description>
**Guideline / section.** <which guideline file and section this code belongs to>
**Failure example.** <one-line concrete example>
**Fix example.** <one-line concrete example>
```

Codes are `snake_case`, descriptive, and stable. Renaming a code is a breaking change and requires a deprecation cycle (keep the old name for one release tagged `deprecated: true`, then remove).

## Stability and versioning

- **Added codes are additive.** Adding a new code never breaks existing audits.
- **Renamed codes are breaking.** Deprecate for one release cycle before removing.
- **Code semantics are stable.** Narrowing or broadening the meaning of a code without renaming it is a silent-break and should be avoided — rename instead.
- **This file follows the forward-compatibility rule.** Unknown codes in audit output should be ignored with a warning, not rejected, so tooling tolerates codes from future versions of this vocabulary.

---

## Cross-Guideline Codes (apply to any PRD)

These codes apply to any specification — Backend, Frontend, System, or Exploratory — because they are about the shape and discipline of the specification itself, not about any one domain's content.

### missing_non_goals

**Detects.** The PRD has no Non-Goals section, or the section is present but empty.

**Guideline / section.** Backend §PRD Structure item 5; Frontend §4 PRD Structure item 7; System §13; Exploratory — implicit (via §3 Failure Mode).

**Failure example.** PRD lists ten Functional Requirements and no explicit exclusions; the agent later implements adjacent features "while it was in there."

**Fix example.** Add a Non-Goals section with at least three concrete exclusions — e.g. "No caching layer," "No schema migration," "No new IAM role."

### fr_not_verifiable

**Detects.** A functional requirement is written as a prose judgment ("handles errors gracefully", "performs well") rather than a machine-verifiable assertion.

**Guideline / section.** Backend §PRD Structure item 4; Frontend §6 Functional Requirements; System §10 Testing Matrix.

**Failure example.** `FR3: The endpoint responds quickly and reliably under load.`

**Fix example.** `FR3: Backend: p95 handler latency is under 50 ms in the test-lambda-latency harness output, measured over 1,000 calls.`

### fr_missing_layer_prefix

**Detects.** A functional requirement in a frontend or full-stack PRD has no `[Backend]` or `[Frontend]` prefix.

**Guideline / section.** Frontend §2 Architectural Boundaries; Frontend §6 Functional Requirements.

**Failure example.** `FR1: Calculate and display the put-call ratio.`

**Fix example.** Split into `FR1: Backend: Calculate expiration-specific put-call ratios and include them in the chain response.` and `FR2: Frontend: Render the pre-calculated putCallRatio field from the backend response.`

### fr_uses_both_prefix

**Detects.** A functional requirement uses the removed `[Both]` prefix instead of being split into per-layer FRs.

**Guideline / section.** Frontend §2 Spanning Requirements — Always Split.

**Failure example.** `FR1: [Both]: The error envelope is { error, message, requestId }.`

**Fix example.** `FR1: Backend: Emits errors in the shared envelope shape { error, message, requestId } defined in shared/errors.cjs.` plus `FR2: Frontend: Parses the shared error envelope and surfaces the message field in the inline error banner.`

### workflow_content_restated

**Detects.** The PRD restates content that belongs in `WORKFLOW.md` — test commands, branch policy, commit style, hook configuration — inline.

**Guideline / section.** All four PRD guidelines §Agent Execution Plan; [workflow-file-guidelines.md](workflow-file-guidelines.md) §The Contract.

**Failure example.** PRD has a "Testing" section that lists `node --test tests/` and an explicit "Commit messages should use Conventional Commits" paragraph.

**Fix example.** Replace both with a single line: "See `WORKFLOW.md` at the repository root for test commands, commit style, and hook configuration."

### missing_agent_execution_plan

**Detects.** A v4.0.0-conformant PRD is missing the Agent Execution Plan section entirely.

**Guideline / section.** Backend §PRD Structure item 8; Frontend §4 PRD Structure item 12; System §11.

**Failure example.** PRD ends at Non-Goals; no branch name, no delegatable research, no hook references.

**Fix example.** Add an Agent Execution Plan section naming the branch, listing Delegatable Research items for Explore/Plan subagents, enumerating required hooks, and pointing at `WORKFLOW.md`.

### missing_delegatable_research

**Detects.** A PRD whose scope would benefit from broad recon (more than roughly five files surveyed, cross-service audit, second-opinion architectural review) has no Delegatable Research block.

**Guideline / section.** Backend §Agent Delegation Strategy; Frontend §4 item 12; System §11.

**Failure example.** A backend PRD for a new handler in `lambdas/accounts/` with no Explore-subagent task to audit the existing sibling handlers for style and shared utilities.

**Fix example.** Add `[ ] Explore subagent: Audit every handler under lambdas/accounts/ and report imports of shared/auth.cjs and shared/errors.cjs. Goal: confirm house style.`

### missing_branch_name

**Detects.** The Agent Execution Plan has no branch or worktree name.

**Guideline / section.** All four PRD guidelines §Agent Execution Plan.

**Failure example.** Agent Execution Plan lists hooks and subagents but never names the branch. The agent later commits to `main`.

**Fix example.** `Branch: feature/account-summary-endpoint. Workspace: standard feature branch, no worktree required.`

### prose_deterministic_rule

**Detects.** A rule that is deterministic (tests must pass before commit, archival checkboxes must be ticked, secrets must not be logged) is expressed as prose instruction to the agent instead of being wired into a hook.

**Guideline / section.** All four PRD guidelines §Agent-Era Execution Model; [workflow-file-guidelines.md](workflow-file-guidelines.md) §Why This Exists.

**Failure example.** PRD states "the AI must always run the test suite before committing and must never commit on main."

**Fix example.** Delete the prose. Wire `PreToolUse(Bash:git commit)` to [pre-commit-gate.bash](../templates/scripts/pre-commit-gate.bash) and let the hook enforce it. Reference the hook by name in the Agent Execution Plan.

### acceptance_criteria_not_measurable

**Detects.** A Success Metric is a prose judgment the agent cannot verify by running a command.

**Guideline / section.** Backend §PRD Structure item 9; Frontend §4 item 13; System §10.

**Failure example.** "The feature should feel responsive and handle errors gracefully."

**Fix example.** "p95 interaction latency under 300 ms measured by `interaction-latency.test.ts`; zero accessibility violations from `jest-axe` on the filter panel; 100% of error responses carry a `requestId` verified by `error-envelope.test.cjs`."

---

## Backend Guideline Codes

### missing_error_envelope

**Detects.** A backend FR emits errors with no documented envelope shape.

**Guideline / section.** [backend-feature-specification-guidelines.md](backend-feature-specification-guidelines.md) §PRD Review Checkpoint — Architectural Placement; Red Flags.

**Failure example.** `FR4: On invalid input, return HTTP 422.`

**Fix example.** `FR4: On invalid input, return HTTP 422 with body { error: "INVALID_INPUT", message: string, requestId: string } matching the existing shape in shared/errors.cjs.`

### unspecified_idempotency

**Detects.** A write endpoint that should be idempotent is hedged with "should probably be idempotent" without naming the idempotency key or natural key.

**Guideline / section.** [backend-feature-specification-guidelines.md](backend-feature-specification-guidelines.md) §Final Audit Red Flags.

**Failure example.** "The handler should probably be idempotent on retries."

**Fix example.** "The handler is idempotent keyed on (`accountId`, `requestId`). Two calls with the same pair within the DynamoDB consistency window return byte-identical responses and perform at most one write."

### multi_table_no_transactional_story

**Detects.** A backend FR writes to multiple tables or multiple services in one logical operation without stating the transactional story (atomic, compensating, eventually consistent) or the rollback path on partial failure.

**Guideline / section.** [backend-feature-specification-guidelines.md](backend-feature-specification-guidelines.md) §Final Audit — Architectural Placement; Red Flags.

**Failure example.** "Write the account summary to `accounts`, update the audit row in `audit_events`, and emit a Kafka event."

**Fix example.** "Single `TransactWriteItems` call writes both `accounts` and `audit_events` atomically; Kafka event is emitted after the transaction commits, with at-least-once delivery and deduplication on the consumer side keyed by `recordId`."

### iam_overreach

**Detects.** A handler is granted broader IAM permissions than the work actually needs.

**Guideline / section.** [backend-feature-specification-guidelines.md](backend-feature-specification-guidelines.md) §Final Audit — Red Flags.

**Failure example.** The new summary handler is granted `dynamodb:*` on the `accounts` table "while we're at it."

**Fix example.** The handler is granted `dynamodb:GetItem` on `arn:aws:dynamodb:*:*:table/accounts` only, matching the single read the handler actually performs.

### response_shape_driven_by_caller

**Detects.** The response shape is designed for the convenience of the current caller rather than from the data source's natural projection, locking out future clients.

**Guideline / section.** [backend-feature-specification-guidelines.md](backend-feature-specification-guidelines.md) §Final Audit — Red Flags.

**Failure example.** "Return `{ headerLine: string, subHeaderLine: string }` because that is what the dashboard header component renders."

**Fix example.** "Return `{ accountId, balance, positionsCount, lastUpdated }` projected from the `accounts` table. The dashboard composes the header lines client-side; a future mobile client can compose them differently."

### secrets_in_logs

**Detects.** Secrets, tokens, bearer headers, or full request bodies surface in structured logs.

**Guideline / section.** [backend-feature-specification-guidelines.md](backend-feature-specification-guidelines.md) §Final Audit — Red Flags; [system-specification-guidelines.md](system-specification-guidelines.md) §7.4.

**Failure example.** `log.info({ requestId, body: req.body }, "incoming request")` where `body` includes an API key.

**Fix example.** `log.info({ requestId, accountId, operation }, "incoming request")` — redacted context only; body never logged.

### streaming_in_backend_prd

**Detects.** A backend PRD specifies a streaming transport (SSE, WebSocket, long-poll, broker fan-out) instead of routing the design to the system guideline §6.

**Guideline / section.** [backend-feature-specification-guidelines.md](backend-feature-specification-guidelines.md) §Final Audit — Red Flags; [system-specification-guidelines.md](system-specification-guidelines.md) §6.

**Failure example.** A backend PRD for a single Lambda includes a Functional Requirement for "SSE heartbeat every 30 seconds with `Last-Event-ID` replay."

**Fix example.** Remove the streaming FR from the backend PRD. Write a system specification that owns the transport in §6 and have the backend PRD reference that section.

### audit_in_backend_prd

**Detects.** An audit-relevant operation is handled ad hoc inside a backend handler's success path instead of being routed to the system guideline §7.

**Guideline / section.** [backend-feature-specification-guidelines.md](backend-feature-specification-guidelines.md) §Final Audit — Red Flags; [system-specification-guidelines.md](system-specification-guidelines.md) §7.

**Failure example.** A backend PRD says "write an audit row to `audit_events` before returning 200."

**Fix example.** Route audit design to a system specification that owns §7 — including the fail-closed vs. fail-open decision, retention, and PII policy. The backend PRD references the system spec section that owns the write path.

### distributed_state_in_backend_prd

**Detects.** A backend FR is really a distributed-state or concurrency problem — cross-request coordination, multi-Lambda orchestration, leader election — crammed into a single-feature PRD.

**Guideline / section.** [backend-feature-specification-guidelines.md](backend-feature-specification-guidelines.md) §Final Audit — Red Flags.

**Failure example.** "The new handler coordinates with two other Lambdas to reserve a slot, then commits the write."

**Fix example.** Write a system specification for the coordination layer. The backend PRD for each participating handler references the system spec's §5 State Machine and §2 Architecture.

---

## Frontend Guideline Codes

### frontend_calculates

**Detects.** A frontend FR performs calculation, aggregation, normalization, or schema transformation that belongs on the backend per the Architectural Boundaries framework.

**Guideline / section.** [frontend-feature-specification-guidelines.md](frontend-feature-specification-guidelines.md) §2 Common Anti-Patterns; §5 Final Audit — Red Flags.

**Failure example.** `FR2: Frontend calculates put-call ratio from callExpDateMap and putExpDateMap.`

**Fix example.** `FR2: Backend: Calculate expiration-specific put-call ratios during options chain processing and include putCallRatio in the response.` plus `FR3: Frontend: Render the pre-calculated putCallRatio field from the backend response.`

### sequential_hydration

**Detects.** The frontend makes three or more sequential API calls to hydrate a single non-gated view (user-gated drill-downs, lazy tabs, and code-split routes are explicitly carved out).

**Guideline / section.** [frontend-feature-specification-guidelines.md](frontend-feature-specification-guidelines.md) §2 Common Anti-Patterns; §5 Final Audit — Red Flags.

**Failure example.** "The dashboard header calls `/accounts/{id}`, then `/accounts/{id}/balance`, then `/accounts/{id}/positions/count` in sequence."

**Fix example.** "The dashboard header calls `/accounts/{id}/summary` which returns all three fields in a single response."

### frontend_schema_transformation

**Detects.** The frontend transforms the response schema before rendering — renaming fields, flattening nested shapes, inferring missing keys — instead of rendering the shape the server returned.

**Guideline / section.** [frontend-feature-specification-guidelines.md](frontend-feature-specification-guidelines.md) §2 Common Anti-Patterns.

**Failure example.** "The frontend maps `response.data.items[].attrs.displayName` to a flat `{ name, id }[]` before rendering."

**Fix example.** "The backend returns `{ name, id }[]` directly. The frontend renders it."

### frontend_audit_source

**Detects.** An audit-relevant event is emitted as a fire-and-forget client call — the client is the only source of truth for whether the action occurred.

**Guideline / section.** [frontend-feature-specification-guidelines.md](frontend-feature-specification-guidelines.md) §2 Audit routing; [system-specification-guidelines.md](system-specification-guidelines.md) §7.9.

**Failure example.** "The frontend posts a `consent_changed` audit event to `/api/audit` when the user clicks the consent toggle."

**Fix example.** "The server-side consent endpoint writes the audit record synchronously as part of the consent change. The frontend surfaces success or failure based on the server response, and is not the source of truth."

### frontend_streaming_spec

**Detects.** A frontend PRD specifies stream transport choice, reconnect semantics, backpressure policy, or heartbeat design — concerns that belong in the system guideline §6.

**Guideline / section.** [frontend-feature-specification-guidelines.md](frontend-feature-specification-guidelines.md) §2 Streaming routing; [system-specification-guidelines.md](system-specification-guidelines.md) §6.9.

**Failure example.** Frontend PRD says "Use SSE with 30-second heartbeat and `Last-Event-ID` replay on reconnect, capped at 30 s exponential backoff."

**Fix example.** Frontend PRD says "Consume the run-log SSE feed owned by the orchestrator per system specification §6. The frontend owns the render path, the disconnected indicator, and the manual-reconnect action; it does not own the transport."

### missing_accessibility_criteria

**Detects.** An interactive frontend FR has no machine-verifiable accessibility criterion — no `role`, `aria-label`, keyboard-path assertion, or `jest-axe` reference.

**Guideline / section.** [frontend-feature-specification-guidelines.md](frontend-feature-specification-guidelines.md) §5 Final Audit.

**Failure example.** `FR5: Add a filter panel above the strike table.`

**Fix example.** `FR5: The filter panel renders with role="group" and aria-label="Strike table filters"; every control is keyboard-reachable with visible focus; zero jest-axe violations.`

### spanning_requirement_not_split

**Detects.** A feature requirement touches both layers but is written as one FR instead of being split into per-layer FRs.

**Guideline / section.** [frontend-feature-specification-guidelines.md](frontend-feature-specification-guidelines.md) §2 Spanning Requirements — Always Split.

**Failure example.** `FR1: Hide unaffordable strikes from traders with a configured budget.`

**Fix example.** `FR1: Backend: Accept maxBudget as an optional query parameter and annotate each returned row with affordable: boolean.` plus `FR2: Frontend: Hide affordable=false rows by default and surface a "Show hidden strikes" toggle that operates on already-fetched data.`

---

## System Guideline Codes

### missing_component_table

**Detects.** §2 System Architecture has no component table, or the table has fewer columns than the required (Component, Responsibility, Inputs, Outputs, Lifecycle).

**Guideline / section.** [system-specification-guidelines.md](system-specification-guidelines.md) §2.

**Failure example.** Section 2 describes the architecture as prose paragraphs.

**Fix example.** Replace the prose with a table listing each component with its responsibility, inputs, outputs, and lifecycle. A system spec without a component table is a wish list.

### missing_stable_ids

**Detects.** Domain model entities have no stable internal identifier distinct from their display-facing identifier, so logs and retries reference the wrong field.

**Guideline / section.** [system-specification-guidelines.md](system-specification-guidelines.md) §3.

**Failure example.** `Issue: { number: int, title: string, state: string }` — `number` is both the log reference and the tracker's display ID, which gets renumbered on import.

**Fix example.** `Issue: { issueId: ULID (stable internal), externalId: string (display), title, state }`. Logs reference `issueId`; the operator dashboard shows `externalId`.

### missing_state_machine

**Detects.** A component with non-trivial state has no enumerated state machine — no states, no transitions, no trigger events.

**Guideline / section.** [system-specification-guidelines.md](system-specification-guidelines.md) §5.

**Failure example.** "The orchestrator runs issues to completion."

**Fix example.** "IssueState: `queued → running → completed|failed`. Trigger: `queued → running` when orchestrator dispatches; `running → completed` on agent exit 0; `running → failed` on non-zero exit, timeout, or audit-write failure."

### missing_concurrency_rules

**Detects.** A service that runs work in parallel has no explicit concurrency cap, rate limit, or queueing rule.

**Guideline / section.** [system-specification-guidelines.md](system-specification-guidelines.md) §5.

**Failure example.** "The orchestrator starts runs as issues arrive."

**Fix example.** "At most `maxConcurrentRuns` runs are in state `running` at any moment. Excess runs queue in FIFO order and wait for a slot."

### missing_reconciliation_design

**Detects.** The spec does not state how the system recovers after a restart — does it resume, replay, or drop in-flight work?

**Guideline / section.** [system-specification-guidelines.md](system-specification-guidelines.md) §5.

**Failure example.** "On restart, the orchestrator starts fresh."

**Fix example.** "On restart, the orchestrator reads `workspaceRoot` for dangling workspaces, inspects their last recorded audit state, and either resumes (if audit shows `active` with recent heartbeat) or marks them `failed` with reason `restarted_during_run` and schedules a retry."

### audit_semantics_not_chosen

**Detects.** §7.7 Failure Semantics is ambiguous — the spec does not explicitly choose fail-closed or fail-open for audit-write failure.

**Guideline / section.** [system-specification-guidelines.md](system-specification-guidelines.md) §7.7.

**Failure example.** "The audit writer is best-effort and retries on failure."

**Fix example.** "Fail-closed. If the audit writer cannot persist a record for a `RunAttempt` transition, the transition does not happen. 60 s backoff, 5 attempts, then `failed` with reason `audit_write_failed` and operator alert. There is no third option — chosen explicitly."

### missing_forward_compat_rule

**Detects.** A service configuration schema or message schema does not state its unknown-key / unknown-field policy.

**Guideline / section.** [system-specification-guidelines.md](system-specification-guidelines.md) §4, §6.2, §12.

**Failure example.** "`config/orchestrator.yaml` supports `pollIntervalSeconds`, `maxConcurrentRuns`, `workspaceRoot`."

**Fix example.** Add: "Unknown keys are ignored with a warning, never rejected. Forward compatibility."

### missing_test_matrix_row

**Detects.** A component named in §2 has no corresponding row in the §10 Testing Matrix.

**Guideline / section.** [system-specification-guidelines.md](system-specification-guidelines.md) §10.

**Failure example.** §2 names eight components; §10 lists seven rows.

**Fix example.** Add the missing row with a type (Unit / Integration / Chaos / End-to-end), a verification command, and a "green when" condition.

### test_matrix_row_no_verification_command

**Detects.** A testing matrix row has no runnable command — just a prose description of what is tested.

**Guideline / section.** [system-specification-guidelines.md](system-specification-guidelines.md) §10.

**Failure example.** `| Audit Writer | Integration | "test that failures block the run" | passes |`

**Fix example.** `| Audit Writer | Integration | node --test tests/audit-writer.test.cjs | Fail-closed path blocks transition on write error |`

### streaming_no_backpressure_policy

**Detects.** §6 Streaming Transports is present but §6.3 Backpressure and Buffering is unstated — the producer policy on slow consumer is missing.

**Guideline / section.** [system-specification-guidelines.md](system-specification-guidelines.md) §6.3.

**Failure example.** "The server streams run-log frames to subscribers over SSE."

**Fix example.** "Per-subscriber bounded buffer of 1,000 frames. Policy on full: drop oldest. Dropped-frame metric exported. Slow-consumer disconnect after 60 s of full buffer with close code 1013."

### streaming_no_resume_semantics

**Detects.** §6.4 is unstated — no last-seen-ID, no backoff curve, no ordering guarantee on reconnect.

**Guideline / section.** [system-specification-guidelines.md](system-specification-guidelines.md) §6.4.

**Failure example.** "Clients reconnect on disconnect."

**Fix example.** "Clients reconnect with exponential backoff capped at 30 s. Server accepts `Last-Event-ID` header and replays every frame with a higher ID from a 60 s in-memory ring buffer. Strictly ordered by `id` within a `runId`; best-effort across `runId`s."

### streaming_no_heartbeat

**Detects.** §6.5 is unstated — no heartbeat frequency, no client-side idle timeout, no dead-connection detection.

**Guideline / section.** [system-specification-guidelines.md](system-specification-guidelines.md) §6.5.

**Failure example.** "The stream stays open until the client closes it."

**Fix example.** "Server emits a `heartbeat` frame every 30 s. Client idle-reconnects after 90 s without a frame. Server disconnects a subscriber whose send buffer stays full for 60 s with close code 1013."

### audit_no_retention

**Detects.** §7.3 is unstated — no retention period, no immutability mechanism, no deletion policy.

**Guideline / section.** [system-specification-guidelines.md](system-specification-guidelines.md) §7.3.

**Failure example.** "Audit records are stored in a database and kept for a long time."

**Fix example.** "Append-only log file on local disk, rotated daily, each rotated file sealed with SHA-256 recorded in the next day's header. 1-year retention. Records past retention move to cold storage via a separate cron job. No in-service deletion path."

### audit_no_pii_policy

**Detects.** §7.4 is unstated — no redaction rule, no secrets policy, no hashing scheme.

**Guideline / section.** [system-specification-guidelines.md](system-specification-guidelines.md) §7.4.

**Failure example.** "Audit records contain whatever the runner emits."

**Fix example.** "Agent runner stdout/stderr never lands in audit records — only the outcome and a short reasonCode. No secrets, tokens, bearer headers, or full request bodies. Ever."

### audit_no_access_control

**Detects.** §7.5 is unstated — no enumerated read/write/delete roles.

**Guideline / section.** [system-specification-guidelines.md](system-specification-guidelines.md) §7.5.

**Failure example.** "The audit store is readable by the operator."

**Fix example.** "Read: operator and compliance-auditor roles. Write: Audit Writer component only. Delete: no runtime code path; only the out-of-band archival cron, which is itself audited."

### service_policy_confused_with_workflow

**Detects.** §4 Service Policy / Configuration File conflates the service's own operational configuration with the project-level `WORKFLOW.md`.

**Guideline / section.** [system-specification-guidelines.md](system-specification-guidelines.md) §4 naming note; [workflow-file-guidelines.md](workflow-file-guidelines.md) §How This Integrates.

**Failure example.** "`config/orchestrator.yaml` is this service's `WORKFLOW.md`."

**Fix example.** "`config/orchestrator.yaml` is the **service's** operational configuration, read at startup. `WORKFLOW.md` at the repository root is the **project's** policy file for the coding agent. In a multi-service repo they stay separate; in a single-service repo they may collapse into one file but are named distinctly."

---

## Implementation Tasks Guideline Codes

### task_no_verification_step

**Detects.** A task in an implementation log has no "verify by X" step — the task is an instruction without a completion check.

**Guideline / section.** [implementation-tasks-creation-guidelines.md](implementation-tasks-creation-guidelines.md) §Agent Execution Model item 6.

**Failure example.** `- [ ] 1.1 Add utilities/new-utility.cjs with function X(input).`

**Fix example.** `- [ ] 1.1 Add utilities/new-utility.cjs with function X(input). Verify: node --test tests/utilities/new-utility.test.cjs exits 0.`

### missing_parallel_markers

**Detects.** Independent phases or tasks are listed sequentially without `[parallel]` markers when they could be delegated to parallel subagents.

**Guideline / section.** [implementation-tasks-creation-guidelines.md](implementation-tasks-creation-guidelines.md) §Agent Execution Model item 4.

**Failure example.** Phase 1 edits `src/components/X.tsx`, Phase 2 edits `src/utilities/Y.ts`, Phase 3 edits `src/hooks/Z.ts` — listed sequentially with no shared files.

**Fix example.** Mark Phases 1, 2, and 3 with `[parallel]` and spawn one subagent per phase.

### recon_inline_instead_of_hoisted

**Detects.** Broad investigation (cross-file audit, dependency mapping, style survey) is inlined as a task in the main plan instead of being hoisted to Phase 0 as a subagent task.

**Guideline / section.** [implementation-tasks-creation-guidelines.md](implementation-tasks-creation-guidelines.md) §Agent Execution Model item 5.

**Failure example.** `- [ ] 2.3 Grep for all callers of formatCurrency and update them.`

**Fix example.** `Phase 0: Recon - [ ] 0.1 [Explore subagent] Map all callers of formatCurrency across /lambdas/ and report affected handlers.` Then Phase 2 references the finding.

### missing_branch_name_in_tasks

**Detects.** An implementation log has no Branch line at the top, so the agent has no workspace to check out.

**Guideline / section.** [implementation-tasks-creation-guidelines.md](implementation-tasks-creation-guidelines.md) §Task Format Example.

**Failure example.** Implementation log starts with Phase 0 immediately after the title.

**Fix example.** Add `Branch: feature/account-summary-endpoint` on line 3, directly under the title.

### restated_workflow_content_in_tasks

**Detects.** An implementation log restates test commands, commit style, or branch policy that already lives in `WORKFLOW.md`.

**Guideline / section.** [implementation-tasks-creation-guidelines.md](implementation-tasks-creation-guidelines.md) §Agent Execution Model item 7.

**Failure example.** The log has a "Testing" section listing `npm test`, `npm run lint`, `npm run typecheck`.

**Fix example.** Replace with: "See `WORKFLOW.md` for test commands. Hooks enforce them on commit."

---

## Workflow File Codes

### missing_workflow_file

**Detects.** A project following v4.0.0 has no `WORKFLOW.md` (or `CLAUDE.md` / `AGENTS.md` / `.cursorrules`) at the repository root.

**Guideline / section.** [workflow-file-guidelines.md](workflow-file-guidelines.md) §The Contract.

**Failure example.** The project's root directory has no policy file; PRDs restate conventions inline every time.

**Fix example.** Copy [templates/workflow-template.md](../templates/workflow-template.md) to `WORKFLOW.md` at the repository root; fill in test commands, branch policy, commit style.

### workflow_front_matter_not_a_map

**Detects.** The YAML front matter in `WORKFLOW.md` is malformed — a list, a scalar, or invalid YAML.

**Guideline / section.** [workflow-file-guidelines.md](workflow-file-guidelines.md) §Forward Compatibility.

**Failure example.** Front matter is `--- project\n---`.

**Fix example.** Front matter is `--- project: my-repo\nversion: 1\n---`.

### workflow_unknown_keys_rejected

**Detects.** A harness or tool rejects unknown keys in the `WORKFLOW.md` front matter instead of ignoring them with a warning.

**Guideline / section.** [workflow-file-guidelines.md](workflow-file-guidelines.md) §Forward Compatibility.

**Failure example.** Harness errors with "unknown key `archival_mode`" when a `WORKFLOW.md` from a newer version is loaded.

**Fix example.** Harness logs `warning: ignoring unknown key archival_mode` and proceeds.

---

## Exploratory Guideline Codes

### missing_recon_findings

**Detects.** An exploratory spec skips §0.5 Recon Findings and dives straight into §1 The Spark, producing speculation instead of grounded creative work.

**Guideline / section.** [exploratory-feature-specification-guidelines.md](exploratory-feature-specification-guidelines.md) §0 and §0.5.

**Failure example.** The exploratory document starts at "The Spark" with no recon summary above it.

**Fix example.** Spawn an Explore subagent with a bounded question, summarize the findings into §0.5 in three to five bullets, then open §1.

### exploration_overrode_boundaries

**Detects.** An exploratory spec proposes ideas that directly contradict a constraint already established in `WORKFLOW.md`, a committed system spec, or a recent PRD — because recon was skipped.

**Guideline / section.** [exploratory-feature-specification-guidelines.md](exploratory-feature-specification-guidelines.md) §0.

**Failure example.** Exploratory spec proposes a second audit store when §7.3 of an existing system spec already mandates a single append-only store.

**Fix example.** The recon subagent would have flagged the existing §7.3 before §1 opened. Re-run recon, fold the constraint into §0.5 as "hidden constraint," and pivot §1 to augmentation instead of replacement.

---

## Conformance Profiles

The vocabulary above is one list. When auditing, use the profile that matches the specification type:

- **Core profile — applies to every PRD.** The cross-guideline codes plus the codes for the specification's domain guideline.
- **Extension profile — applies when the specification touches streaming or audit.** Adds the streaming codes and audit codes from the system guideline section even if the spec itself is a backend or frontend PRD, because those concerns route to system §6 / §7.
- **Integration profile — applies when the specification coordinates multiple components or services.** Adds the distributed-state and multi-table codes.

A failing Core code should block the PRD. A failing Extension code should route the concern to a system specification. A failing Integration code should route the concern to a system specification and add a Delegatable Research item for an independent Plan-subagent review.

---

## What This Vocabulary Is Not

- **Not a lint rule set.** These are review findings, not auto-fixable style issues. A human or reviewer subagent decides whether to accept or reject a flagged finding.
- **Not exhaustive.** Every guideline release may add codes. The vocabulary is a living artifact.
- **Not a substitute for reading the guideline.** Each code points at the guideline section that owns it — the vocabulary is an index, not a replacement.
- **Not a judgment on intent.** A code like `frontend_calculates` names a pattern, not a person. The fix lives in the PRD, not in the contributor.
