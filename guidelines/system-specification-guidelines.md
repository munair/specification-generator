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
4. **Draft the Spec** – Use the section spine below. Write for extensibility: unknown config keys should be ignored, new components should be addable without breaking existing ones.
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
### 4. Workflow / Policy File
If the system reads policy from a Markdown or YAML file in the repository (highly recommended — see the `templates/workflow-template.md`), specify:
- **Filename and location** (`WORKFLOW.md`, `.workflow/config.yaml`, etc.)
- **Schema** (required fields, optional fields, unknown-key policy)
- **Reload semantics** (does the system re-read at runtime? restart-only?)
- **Validation** (what errors fail startup vs. warn)
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
### 6. Safety & Integration
- **Trust boundaries**: Which components have which permissions? What can external input reach?
- **Workspace isolation**: Where does work happen? How is it cleaned up? Who owns the filesystem?
- **External integrations**: APIs called, authentication model, rate-limit handling, timeout policy.
- **Failure domains**: If external service X is down, which components degrade and which fail?
### 7. Observability & Operations
- **Structured logging**: What fields appear on every log line? (run ID, component, issue ID, etc.)
- **Metrics**: What counts, rates, and latencies are exported?
- **Dashboards / status surfaces**: HTTP endpoints, CLI commands, or dashboards for operators.
- **Operator intervention points**: How does a human pause, cancel, or drain the system safely?
- **Alerts**: What conditions should page a human?
### 8. Testing Matrix
Every component needs a row. Every row needs a verification command.
| Component        | Test Type         | Verification Command                            | Green When                           |
|------------------|-------------------|-------------------------------------------------|--------------------------------------|
| Workflow Loader  | Unit              | `node --test tests/workflow-loader.test.cjs`    | All assertions pass                  |
| Tracker Client   | Integration       | `node --test tests/tracker-client.test.cjs`     | Returns normalized issue list        |
| Orchestrator     | State-machine     | `node --test tests/orchestrator.test.cjs`       | All transitions fire correctly       |
| End-to-end       | Real integration  | `scripts/e2e-smoke.sh`                          | Exit code 0 with expected log lines  |
A test matrix is the agent-era replacement for "we'll write tests later."
### 9. Agent Execution Plan (v4.0.0)
- **Branch/worktree**: `system/[service-name]`
- **Subagent delegation**: Which components can be built in parallel by independent subagents?
- **Hook requirements**: `PreToolUse(Bash:git commit)` runs the full test matrix; `Stop` blocks archival if any matrix row is red.
- **`WORKFLOW.md` reference**: Point to the file; do not restate its contents.
### 10. Extensibility
Document how to add:
- A new component
- A new field to the workflow file
- A new state to the state machine
Follow Symphony's rule: "Unknown keys are ignored for forward compatibility."
### 11. Non-Goals
List what the system will **not** do. Be specific. Common non-goals for system specs:
- No persistent database (use filesystem + restart recovery)
- No mandatory approval model (trust the tracker)
- No built-in secret management (delegate to the platform)
### 12. Open Questions
Items the spec cannot yet resolve. Each should have an owner and a resolution date.
---
## Example: Structuring a Symphony-Like Spec
A system spec for "a service that orchestrates coding agents against an issue tracker" would use this spine like so:
1. **Problem & Goals**: Eliminate manual ticket pickup; run agents in isolated workspaces; keep policy in-repo.
2. **Architecture**: Workflow Loader → Config Layer → Tracker Client → Orchestrator → Workspace Manager → Agent Runner → Logging Surface.
3. **Domain Model**: Issue, WorkflowDefinition, ServiceConfig, Workspace, RunAttempt, LiveSession, RetryEntry, RuntimeState.
4. **Workflow File**: `WORKFLOW.md` with YAML front matter; unknown keys ignored.
5. **State Machine**: IssueState (queued → running → completed/failed); RunAttempt (scheduled → active → finished); retry with exponential backoff.
6. **Safety**: Each workspace is a disposable directory; agents never touch `main`; tracker writes are agent-owned.
7. **Observability**: Structured logs with run ID; optional HTTP status surface; metrics for active runs and retry counts.
8. **Testing Matrix**: Per-component unit tests + real-tracker integration smoke test.
9. **Agent Execution Plan**: Branch `system/symphony`, subagent per component, hook-enforced test matrix.
This is not a reprint of Symphony's spec — it's what the spec looks like when compressed through this guideline's spine.
---
## Guiding Principles
- **Structure Over Prose**: Tables, state diagrams, and enumerated lists beat narrative paragraphs at the system level.
- **Stable IDs First**: Before writing the state machine, nail down how entities are identified.
- **Forward Compatibility by Default**: Unknown config keys should warn, not fail.
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
- **Companion File:** `WORKFLOW.md` or equivalent policy file at the repository root