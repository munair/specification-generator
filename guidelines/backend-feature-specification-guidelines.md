# Rule: Backend Feature Specification / Product Requirements Document (PRD)

## Overview

The framework explicitly tells an AI Assistant: "First, build the fence. Then, explore every inch of the playground."

**v4.0.0 update**: This guideline now assumes a **tool-using agent** — not a chat-loop assistant. The agent can read files, run tests, spawn subagents, execute commands in an isolated workspace, and enforce policy through hooks. The PRD must be written with that execution model in mind.

## Goal

To guide a coding agent (and its subagents) in creating a detailed Backend Feature Specification / Product Requirements Document (PRD) in Markdown format, based on an initial user prompt. The PRD should be thorough, actionable, and suitable for a tool-using agent — or a junior developer — to implement the feature end to end: code, tests, commits, and archival.

## Agent-Era Execution Model (v4.0.0)

Before writing a PRD, assume the following about the agent that will consume it:

1. **The agent has tools.** It can read source files, run `node --test`, grep the codebase, execute AWS CLI calls in a sandbox, and commit its own work. PRDs may — and should — name the tools the agent is expected to use.
2. **The agent can spawn subagents.** For any investigation that would otherwise bloat the main context (dependency audits, cross-lambda searches, test-surface mapping), delegate to a subagent. The PRD should explicitly identify "delegatable research" sections.
3. **The agent honors in-repository policy.** A `WORKFLOW.md` or `CLAUDE.md` file in the repository root encodes project conventions (test commands, commit style, branch rules, archival hooks). The PRD must reference it rather than re-specify those rules inline.
4. **Hooks replace prose instruction for deterministic rules.** Anywhere this guideline used to say "the AI must always do X" — if X is deterministic (e.g., running tests before commit, verifying archival checkboxes), it belongs in a hook in `settings.json`, not in the PRD narrative.
5. **Work happens in an isolated workspace.** Backend features should be developed on a dedicated branch (or git worktree) named after the feature. The agent should not assume it is on `main`.
6. **Every PRD section is machine-actionable.** Write requirements the agent can verify itself — e.g., "endpoint returns HTTP 200 with `{ok: true}` for valid input" — rather than requirements that require human interpretation.

## Process

1. **Receive Initial Prompt:** The user provides a brief description or request for a new feature or functionality.
2. **Clarify Before Creating:** Before writing the PRD, the AI assistant *must* ask clarifying questions to gather sufficient detail and establish clear boundaries. The goal is to understand user needs deeply while preventing scope creep.
3. **Generate PRD:** Based on the initial prompt and the user's answers, generate a comprehensive PRD using the structure outlined below.
4. **Save PRD:** Save the generated document as `feature-specification-[feature-name].md` inside the `/documentation` directory.
5. **Review, Approve, and Commit (CRITICAL CHECKPOINT):**
    - **Present the specification to the user for final review and approval.**
    - **Prompt the user:** "I have drafted the Feature Specification. Please review it to ensure it aligns with your goals. Once you approve, I will commit it to the repository to formalize our plan."
    - **Wait for explicit user approval.**
    - **Commit the approved specification to the repository.** Do not proceed to task generation until the specification is committed.

## Clarifying Questions Framework

The agent should adapt its questions based on the prompt, prioritizing understanding over assumptions.

### Before Asking Anything — Use Tools First (v4.0.0)

The agent must **read before it asks**. Every question the codebase or the project configuration can already answer is a question the agent should answer itself, not hand back to the user. Before opening a clarifying-questions dialogue, the agent should:

- Read `WORKFLOW.md` (or `CLAUDE.md`) at the repository root for test commands, branch policy, commit style, and hook configuration. These answer a surprising number of "what framework do you use" questions without the user typing a word.
- Grep the target Lambda directory for existing handlers, shared utilities, and middleware. Naming conventions, error envelopes, and authorization patterns are usually right there in sibling files.
- Read the nearest existing handler to the one being specified. It will show the house style for request parsing, error shaping, logging, and response construction.
- Read the relevant DynamoDB table schema or infrastructure-as-code file for any table the new handler will touch. This answers access-pattern and projection questions directly.
- Scan recent `git log` output for commit-message style, scope names, and the kinds of change the project normally ships.
- Run the test command once to confirm the baseline is green. A red baseline is itself a finding worth surfacing before the specification work begins.

Only after doing those reads should the agent ask questions — and only about things the codebase genuinely cannot answer (new behavior, scope decisions, user intent).

### Essential (Always Ask)
- **Boundaries:** "What should this feature *not* do? Any explicit non-goals?"
- **Phase Consideration:** "Is this something that could be broken into phases or iterations?"
- **Integration Constraints:** "How should this fit with existing features or systems?"
- **Agent Orchestration:** "Should any phase run as a subagent (e.g., dependency audit, cross-Lambda impact analysis)? Are there hooks that must gate commits or deploys?"

### Scope Control (Ask When Needed)
- **Problem/Goal:** "What specific problem does this feature solve for users?"
- **Target User:** "Who is the primary user of this feature?"
- **Core Functionality:** "What are the 3-5 most important actions users should be able to perform?"
- **Success Definition:** "How will we know this feature is working well?"

### Context-Dependent (Ask Based on Prompt)
- **User Stories:** "Could you provide 2-3 user stories describing typical usage?"
- **Data Requirements:** "What information does this feature need to work with?"
- **Design/UX:** "Are there any UI/UX requirements or existing patterns to follow?"
- **Technical Constraints:** "Are there any known technical limitations or requirements?"
- **Edge Cases:** "What could go wrong? Any special scenarios to consider?"

### Questions the Agent Should NOT Ask (Look Them Up Instead)
- "What testing framework do you use?" — read `CLAUDE.md` and `package.json`.
- "Where are Lambda handlers located?" — grep the repo.
- "What's the commit message format?" — read `CLAUDE.md` or recent `git log`.
- "Is there a related handler already?" — use the Grep tool.
## Agent Delegation Strategy
Every backend PRD should explicitly identify which work is **delegatable** to subagents. This keeps the main agent's context focused on the critical path.
**Typical delegation candidates for backend features:**
| Work Item                                   | Delegate To        | Why                                                   |
|----------------------------------------------|--------------------|-------------------------------------------------------|
| Cross-Lambda dependency audit                | Explore subagent   | Broad grep/read work that pollutes main context       |
| Existing test-surface mapping                | Explore subagent   | Multi-directory investigation with summary output     |
| DynamoDB access-pattern review               | Explore subagent   | Requires reading many unrelated handlers              |
| IAM policy impact analysis                   | Explore subagent   | Scoped security question with a bounded answer        |
| Independent second opinion on the draft PRD  | Plan subagent      | Fresh context = unbiased architectural review         |
| Test generation for a utility module         | General subagent   | Parallelizable with main feature work                 |
**Format in PRD:**
```
## Delegatable Research
- [ ] Subagent (Explore): Audit all Lambdas under /lambdas/ that import `shared/auth.cjs`; report which ones would be affected by adding a new `scope` field.
- [ ] Subagent (Plan): Review the proposed DynamoDB access pattern for hot-partition risk; recommend GSI strategy.
```
The main agent should spawn these in parallel *before* writing implementation tasks so findings inform the plan.

## PRD Structure

The generated PRD should include the following sections:

1. **Introduction/Overview:** Briefly describe the feature and the problem it solves. State the primary goal.
2. **Goals:** List specific, measurable objectives for this feature.
3. **User Stories:** Detail user narratives describing feature usage and benefits.
4. **Functional Requirements:** List specific functionalities the feature must have. Use clear, numbered requirements and write each one as a **verifiable assertion** the agent can self-check (e.g., "The `/accounts/{id}/numbers` endpoint returns HTTP 200 with `{accountNumbers: string[]}` for an authorized caller").
5. **Non-Goals (Out of Scope):** Clearly state what this feature will *not* include to manage scope.
6. **Design Considerations (Optional):** Link to mockups, describe UI/UX requirements, or mention relevant components/styles if applicable.
7. **Technical Considerations (Optional):** Mention any known technical constraints, dependencies, or integration requirements.
8. **Agent Execution Plan (v4.0.0):** Name the branch or worktree, identify which sections are delegatable (see "Agent Delegation Strategy"), and list any hooks that must be wired up (e.g., `PreToolUse` on `git commit` to run tests). Reference `WORKFLOW.md`/`CLAUDE.md` instead of repeating its contents.
9. **Success Metrics:** How will the success of this feature be measured? Include both quantitative and qualitative indicators. Prefer metrics the agent can verify by running a test or reading a log.
10. **Open Questions:** List any remaining questions or areas needing further clarification.

## PRD Review Checkpoint: Final Audit

**Before finalizing the PRD, run this consolidated checklist.** It is the backend counterpart to the Final Audit in `frontend-feature-specification-guidelines.md` §5 — one structured pass covering placement, execution plan, and red flags. This audit is a review step the agent performs *on* the finished PRD before presenting it; its contents do not need to appear in the PRD itself.

### Architectural Placement

- ☐ Is every functional requirement prefixed `Backend:` and written as a verifiable assertion (HTTP status, response shape, measurable latency)?
- ☐ Are all write endpoints that should be idempotent explicitly specified as idempotent, with the idempotency key or natural key named?
- ☐ Does the handler stay within its own service boundary (no cross-Lambda reads, no hidden coupling to another handler's internal state)?
- ☐ Is the error envelope specified — either by reference to an existing shared shape or, if truly new, defined explicitly — with every error code the endpoint can emit?
- ☐ Does the response shape support future clients (mobile, API consumers) without reshaping, and is it projected from the data source in a way that does not lock out those future clients?
- ☐ If the feature touches multiple tables or multiple services in one write, is the transactional story stated explicitly (atomic, compensating, eventually consistent) rather than assumed?
- ☐ Is the IAM scope the feature requires the minimum the work actually needs — no "while we're at it" expansions?
- ☐ Are streaming, real-time push, or cross-component state-machine requirements routed to `system-specification-guidelines.md` §6 rather than specified inline in a backend PRD?
- ☐ Are audit-relevant operations routed to `system-specification-guidelines.md` §7 rather than handled ad hoc in this handler's success path?

### Agent Execution Plan

- ☐ Is the branch or worktree name specified?
- ☐ Is Delegatable Research broken out for Explore or Plan subagents, with each item bounded and expected to return a summary rather than raw file content?
- ☐ Are the hooks that gate deterministic rules (pre-commit tests, lint, archival verification) named explicitly, and does the PRD assume they exist rather than restating the rules they enforce?
- ☐ Does the PRD reference `WORKFLOW.md` (or `CLAUDE.md`) at the repository root rather than restating test commands, commit style, or branch policy inline?
- ☐ Are the acceptance criteria machine-verifiable — every one of them runnable as a test assertion, `curl` invocation, or log-line match, with no prose judgments like "looks right" or "handles errors gracefully"?

### Red Flags — Rewrite the PRD if Any Apply

- "The handler should probably be idempotent" with no explicit specification of how idempotency is achieved.
- A backend FR that is really a distributed-state or concurrency problem (cross-request coordination, multi-Lambda orchestration, streaming push) — these are system-level concerns and belong in a system specification, not a backend PRD.
- Fail-open behavior on an audit-relevant write path where fail-closed is the correct choice. The audit section in `system-specification-guidelines.md` §7.7 is explicit that there is no third option; make the call.
- Missing error envelope. A backend endpoint that emits errors without a documented shape is an endpoint that clients will parse differently across every integration.
- Response shape driven by a specific current client's convenience rather than by the data source's natural projection. Response shape is a product decision that outlives any single caller; design it to be stable.
- Secrets, tokens, or full request bodies surfacing in structured logs. PII and secrets never leave the request-handling boundary; logs carry redacted context, nothing more.
- IAM overreach — a handler granted `dynamodb:*` when it needs `GetItem` on one table.
- Prose rules the agent must "remember" — commit style, branch policy, test commands. These belong in hooks and in `WORKFLOW.md`, not in PRD narrative.
- Restated `WORKFLOW.md` contents inline. If a section of the PRD could be deleted by copying one sentence from `WORKFLOW.md` into it, delete the section and reference the file instead.
- Acceptance criteria that are not machine-verifiable. "The endpoint responds quickly" is not a criterion; "p95 latency under 50 ms in `test-lambda-latency` output" is.
- A flat sequential task list in the PRD's Agent Execution Plan when the research work is genuinely parallelizable across independent Explore subagents.
- Multi-table writes with no transactional story, no rollback path, and no reconciliation design on partial failure.

## Guiding Principles

- **Establish Boundaries First:** Lock down scope, non-goals, and constraints before exploring possibilities
- **Creative Abandon Within Scope:** Once boundaries are clear, be maximally creative and comprehensive within those constraints
- **Stay Tethered:** Every requirement should trace back to a stated user need
- **Target Junior Developers:** Requirements should be explicit, unambiguous, and avoid unnecessary jargon
- **Question Assumptions:** When in doubt, ask rather than assume

## Output Requirements

- **Format:** Markdown (`.md`)
- **Location:** `/documentation/specifications/active/` (during development); move to `/documentation/specifications/completed/` after deployment
- **Filename:** `feature-specification-[feature-name].md`

## Archival Cross-Reference

**IMPORTANT**: When archiving implementation logs, follow the **ARCHIVAL PROTOCOL** in `implementation-tasks-creation-guidelines.md`.

Key requirements:
1. Mark ALL tasks complete (`- [ ]` → `- [x]`)
2. Rename from `implementing-` to `implementation-log-`
3. Move to `documentation/tasks/completed/`

**DO NOT** attempt to archive without following the protocol checklist.

## Final Instructions

1. **Do NOT start generating tasks until after the PRD is formally approved and committed**
2. **Ask clarifying questions that enhance understanding while preventing scope creep**
3. **Use the user's answers to create a comprehensive yet focused PRD**
4. **If the scope seems too large, suggest breaking the feature into phases**

## Feature Tagging Strategy

After successful implementation and testing, tag the feature with a descriptive name that reflects the core solution approach:

### Tagging Guidelines:
- **Use the feature specification name**: `[feature-name]-[solution-approach]`
- **Be specific and searchable**: `persistent-display-css-grid-solution`
- **Include the technical approach**: `user-authentication-oauth2-integration`
- **Avoid generic version tags**: Use descriptive tags instead of `v1.2.3`

### Examples:
- `persistent-display-css-grid-solution` ✅
- `user-preferences-local-storage` ✅
- `real-time-notifications-websocket` ✅
- `v0.5.1` ❌ (too generic)

### When to Tag:
- After successful implementation and testing
- Before version bumps (which come after documentation updates)
- When the feature is production-ready

### Tagging Process:
1. **Implementation Complete**: Feature is implemented, tested, and working
2. **Create Descriptive Tag**: Use `git tag [feature-name]-[solution-approach]`
3. **Document the Tag**: Reference the tag in commit messages and documentation
4. **Version Management**: Reserve version bumps for after documentation updates and housekeeping