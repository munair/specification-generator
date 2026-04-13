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

The agent should adapt its questions based on the prompt, prioritizing understanding over assumptions. Before asking anything, the agent should **first use its tools** — read `CLAUDE.md`/`WORKFLOW.md`, grep the target Lambda directory, and read adjacent handlers. Do not ask questions the codebase can answer.

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