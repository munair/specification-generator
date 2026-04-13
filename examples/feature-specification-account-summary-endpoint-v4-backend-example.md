# Feature Specification: Account Summary Endpoint

---
**Guideline Used**: `backend-feature-specification-guidelines.md`
**Domain**: Backend (AWS Lambda + DynamoDB)
**Framework Version**: v4.0.0 — Agent-Era Update
**Status**: Reference example (illustrative, not shipped)
---

> **Purpose of this example.** A deliberately realistic backend PRD that demonstrates the v4.0.0 shape: `[Backend]`-prefixed functional requirements written as machine-verifiable assertions, a fully populated Agent Execution Plan section, a Delegatable Research block that hoists recon to Explore subagents, and references to `WORKFLOW.md` instead of restated rules. Use it as a structural template when drafting a real backend PRD. The feature described is plausible but fictional.

## Introduction / Overview

The account details dashboard currently assembles its header by making three separate calls: `GET /accounts/{id}`, `GET /accounts/{id}/balance`, and `GET /accounts/{id}/positions/count`. This triples the latency of the initial dashboard render and triples the authorization cost. Introduce a single composite endpoint `GET /accounts/{id}/summary` that returns the three fields the header actually needs in one round trip, served from the existing DynamoDB `accounts` table with no new infrastructure.

## Goals

- Reduce initial dashboard header latency by collapsing three calls into one.
- Produce a response shape that a future mobile client can consume without additional work.
- Ship without introducing a new table, a new cache tier, or a new IAM role.
- Keep the existing three endpoints intact for callers that depend on them.

## Architectural Decisions

**Backend work.**
- New handler `lambdas/accounts/summary.cjs` that reads the existing `accounts` table, projects the three required fields, and returns a single JSON response.
- Authorization reuses the existing `shared/auth.cjs` middleware with no changes.
- No caching in this phase. The DynamoDB read is already well under the latency budget; caching adds a cache-invalidation story we do not need yet.

**Frontend work.**
- Out of scope for this PRD. A separate frontend PRD will replace the three-call hydration path with a single call to this endpoint. That PRD will reference this one in its Technical Considerations.

**Justification.** Every field in the response is computed from a single DynamoDB item. There is no calculation or aggregation worth doing client-side, and a server-shaped response supports future clients (mobile, API consumers) without refactoring — "Smart Backend, Simple Frontend."

## Functional Requirements

Write each requirement as a verifiable assertion the agent can self-check by running an integration test or a `curl`.

- **FR1: Backend**: `GET /accounts/{id}/summary` returns HTTP 200 with body `{accountId: string, balance: number, positionsCount: number, lastUpdated: string}` for an authorized caller whose `allowedScopes` row contains `accounts:read:summary`.
- **FR2: Backend**: The handler reads the `accounts` table via a single `GetItem` call with `ProjectionExpression="accountId, balance, positionsCount, lastUpdated"` and does not issue any other DynamoDB call in the happy path.
- **FR3: Backend**: For a caller whose token is missing or whose scopes do not include `accounts:read:summary`, the handler returns HTTP 403 with body `{error: "FORBIDDEN", message: "insufficient scope", requestId: string}`.
- **FR4: Backend**: For an unknown `accountId`, the handler returns HTTP 404 with body `{error: "NOT_FOUND", message: "no such account", requestId: string}`.
- **FR5: Backend**: For an internal error (DynamoDB timeout, unexpected exception), the handler returns HTTP 500 with body `{error: "INTERNAL", message: "internal error", requestId: string}` and emits a structured log line with `level=error`, `requestId`, and `accountId`.
- **FR6: Backend**: The response is idempotent — two successive calls with the same `accountId` within the same DynamoDB consistency window return byte-identical responses.
- **FR7: Backend**: The handler emits a structured log line on every call with `level=info`, `requestId`, `accountId`, `durationMs`, and `outcome` (`success` | `forbidden` | `not_found` | `internal_error`).
- **FR8: Backend**: p95 handler latency is under 50 ms measured by the existing `test-lambda-latency` harness (excludes cold starts).

## Non-Goals

- No changes to `GET /accounts/{id}`, `GET /accounts/{id}/balance`, or `GET /accounts/{id}/positions/count`. They remain, even if unused by the dashboard, for callers that depend on them.
- No caching layer. ElastiCache, DAX, and Lambda in-memory caches are all out of scope for this phase.
- No schema change to the `accounts` table. This endpoint uses only fields that already exist.
- No pagination, filtering, or multi-account aggregation. One account per call.
- No historical data. The endpoint returns current state only.

## Technical Considerations

- **Runtime**: Node.js 20.x, CommonJS, handler at `index.handler` in `lambdas/accounts/summary.cjs`.
- **Memory / timeout**: Match the existing `/accounts/{id}` handler — 256 MB memory, 3 s timeout. Do not inflate resources for a lighter-weight endpoint.
- **IAM**: Reuse the existing `accounts-read` execution role with no scope changes. The handler reads only fields the role already has permission to read.
- **Error envelope**: All error responses follow the existing shape `{error: string, message: string, requestId: string}` defined in `shared/errors.cjs`. Do not invent a new envelope.
- **Request ID propagation**: Read `x-request-id` from the API Gateway event; fall back to a generated ULID if absent. Emit it in every log line and echo it in every response.

## Agent Execution Plan (v4.0.0)

- **Branch**: `feature/account-summary-endpoint`
- **Workspace**: Standard feature branch, no worktree required.
- **Workflow policy**: See `WORKFLOW.md` at the repository root for test commands, branch policy, commit style, and hook configuration. Do not restate those rules in this PRD or in the generated task list.
- **Required hooks**:
  - `PreToolUse(Bash:git commit)` runs `node --test tests/` and the lint gate via `pre-commit-gate.bash` (wired in `.claude/settings.json`).
  - `Stop` runs `verify-archival.bash` to block session end if the implementation log still has unchecked tasks.

### Delegatable Research

Spawn these subagents in parallel **before** proposing the high-level task plan. Each is bounded and returns a summary, not raw file content.

- [ ] **Explore subagent**: Audit every handler under `lambdas/accounts/` and report (a) which ones already import `shared/auth.cjs` and (b) which ones read the `accounts` table. Output: a short table. Goal: confirm no handler already does the composite read and that the new handler can match the house style.
- [ ] **Explore subagent**: Read `shared/errors.cjs` and report the exact error envelope shape and the list of existing error codes. Goal: use the same envelope and reuse an existing code where possible.
- [ ] **Plan subagent**: Given the three fields in the response (`balance`, `positionsCount`, `lastUpdated`), review whether the existing `accounts` table schema can serve all three from a single `GetItem` without a GSI, and flag any projection gaps. Goal: independent second opinion on the access pattern before implementation begins.

## Success Metrics

Every metric below is measurable by the agent with an existing tool. No prose judgments.

- **Latency**: p95 of `GET /accounts/{id}/summary` under 50 ms in the `test-lambda-latency` harness output (JSON, grep-able).
- **Dashboard render time**: Initial dashboard header render time drops by at least 40% (measured by the existing `dashboard-render-benchmark` script comparing three-call baseline against this endpoint).
- **Error rate**: Under 0.1% 5xx across a 1,000-call load test, measured by the `load-test-summary.cjs` script.
- **Log schema conformance**: 100% of emitted log lines parse as valid JSON and contain every required field, verified by `tests/integration/summary-log-schema.test.cjs`.

## Open Questions

None at PRD finalization time. If the Plan subagent flags a projection gap during recon, add the resolution here before generating tasks.

---

> **Why this PRD looks the way it does.** Compare against the v1.x examples in this directory: no "Testing" section listing `node --test` (that lives in `WORKFLOW.md`), no "Commit Format" section (that lives in `WORKFLOW.md`), no "Branch Policy" section (that lives in `WORKFLOW.md`). Every functional requirement is a testable assertion, not a prose statement. Recon work is hoisted to named subagents so the main agent's context stays focused on implementation. This is what the Agent-Era Update actually produces.
