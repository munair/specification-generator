# Changelog

All notable changes to the Specification Generator framework will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [4.0.0] - Monday, April 13, 2026

### The Agent-Era Update

All existing guidelines have been updated to assume a **tool-using coding agent** — not a chat-loop assistant. Two new guidelines and one new repository convention were added. Existing v3.x PRDs remain readable and valid; this release is tagged **4.0.0** because new v4.0.0-conformant PRDs expect a `WORKFLOW.md` policy file at the repository root, every PRD structure now includes an Agent Execution Plan section, the guideline taxonomy grew from four to six, and the recommended activation prompts changed. See [Why v4.0.0 is a Major Version](#why-v400-is-a-major-version) for the full list of expectations that shifted.

### Why This Major Version
Over the 12 months since v3.0.0, coding agents gained capabilities the framework did not model:
- **Tool use**: agents read files, run tests, grep the codebase, commit their own work
- **Subagents**: broad research and parallel work can be delegated
- **Hooks**: deterministic rules are enforced by scripts, not by prose instruction
- **Workspace isolation**: per-feature branches or git worktrees
- **Skills / slash commands**: reusable capability bundles
- **Long-running background agents**: orchestrators that consume issues from trackers
v3.x guidelines treated the "AI assistant" as a single chat loop. v4.0.0 treats it as an **agent with tools, subagents, and policy-enforcing hooks**. The framework's philosophy — "build the fence, explore the playground" — is unchanged. What changed is who's holding the shovel.

### Added
#### New Guideline: `system-specification-guidelines.md`
A fifth guideline for specifying **multi-component systems**: orchestrators, daemons, long-running services, and anything with a non-trivial state machine. Fills a gap between feature-level PRDs (Backend, Frontend) and system-level specifications.
**Section spine** (adapted from OpenAI's Symphony `SPEC.md`, extended with cross-cutting concerns that used to be homeless):
1. Problem & Goals
2. System Architecture (component table with responsibility, inputs, outputs, lifecycle)
3. Domain Model (with stable IDs)
4. Service Policy / Configuration File (the service's own in-repository configuration — distinct from the project `WORKFLOW.md`, with a naming note that explicitly disambiguates the two)
5. State Machine & Orchestration
6. **Streaming Transports** — transport choice (SSE vs. WebSocket vs. long-poll vs. gRPC streaming vs. broker fan-out), message schema and framing with forward compatibility, producer/consumer backpressure and buffer bounds, reconnect and resume semantics (last-seen ID, backoff curves, idempotency, ordering guarantees), heartbeat and liveness, multi-subscriber fan-out and per-frame auth scope, graceful shutdown and close-code taxonomy, testing hooks, and an explicit frontend handoff rule that tells frontend PRDs what to reference and what to own.
7. **Audit & Compliance Records** — scope (what is and is not an audit event), canonical record schema, storage/retention/immutability (WORM, append-only, hash chaining, GDPR carve-outs), PII and secret redaction, access control for reads and writes, export and replay paths for investigations, the **fail-closed vs. fail-open** write-path decision (with an explicit "there is no third option" rule), optional regulatory mapping table (SOX/FINRA, GDPR Article 7, SOC 2 CC6.1, etc.), and a frontend handoff rule that forbids the client from being the sole source of truth for an audit-relevant event.
8. Safety & Integration
9. Observability & Operations
10. Testing Matrix (per component, with verification commands; includes rows for Stream Encoder and Audit Writer in the example, and a "adapt test-file extensions to your stack" note)
11. Agent Execution Plan
12. Extensibility (first-class requirement; covers new components, new config fields, new streaming message types, new audit event types)
13. Non-Goals
14. Open Questions
**Use when**: specifying a service with ≥ 3 communicating components, or a service that owns a streaming transport or an audit/compliance obligation. **Do not use when**: specifying a single Lambda or single React component — the existing Backend or Frontend guideline is the right fit there.
#### New Guideline: `workflow-file-guidelines.md`
Defines the `WORKFLOW.md` in-repository policy file convention. `WORKFLOW.md` (or `CLAUDE.md`, `AGENTS.md`, `.cursorrules` depending on harness) is the **single source of truth** for project-wide rules:
- Test commands and pass criteria
- Branch policy (feature branches, worktrees, main protection)
- Commit message format
- Hook configuration
- Subagent delegation defaults
- Archival protocol reference
- Project-specific conventions
**The rule**: If a rule applies to every feature in this project, it belongs in `WORKFLOW.md` — not restated in every PRD. PRDs reference the file; hooks enforce it; agents read it.
#### New Template: `templates/workflow-template.md`
A reference `WORKFLOW.md` with:
- Optional YAML front matter (forward-compatible: unknown keys ignored)
- Test command section (backend/frontend/lint/typecheck)
- Branch policy section
- Commit style section
- Reference hook configuration for `.claude/settings.json`
- Subagent delegation defaults
- Archival protocol reference
- Project-specific placeholder section
- Forward compatibility rule
#### Agent-Era Execution Model Section
Every existing guideline gained a new section explaining the execution model agents operate under:
1. The agent has tools (reads files, runs tests, commits)
2. The agent can spawn subagents (Explore for recon, Plan for second opinions)
3. The agent honors in-repository policy (reads `WORKFLOW.md`)
4. Hooks replace prose instruction for deterministic rules
5. Work happens in an isolated workspace (branch or worktree)
6. Requirements must be machine-verifiable (test assertions, not prose)
#### Agent Delegation Strategy (Backend & Frontend Guidelines)
A new section in both the Backend and Frontend guidelines with a table of typical delegation candidates and a standard "Delegatable Research" format for PRDs to hoist recon work to subagents before writing implementation tasks.
#### Consolidated Final Audit (Frontend Guideline)
The frontend guideline's three previously separate audit checklists — the v2.x Boundary Checklist, the v3.0.0 Architectural Audit, and the early-v4 Agent Orchestration Audit — are now consolidated into a single **Final Audit** at §5. It covers architectural placement, agent execution plan, and red flags in one pass, without the overlap that had accumulated from three additive revisions. Red-flag items include prose rules the agent must "remember" (should be hooks), acceptance criteria that aren't machine-verifiable, restated `WORKFLOW.md` contents inline, sequential task lists that could be parallelized with subagents, streaming transport specified in a frontend PRD rather than routed to the System guideline, and `3+` (not `2+`) sequential API calls to hydrate a non-gated view — user-gated drill-downs, lazy tabs, and code-split routes are explicitly carved out.
#### Spanning Requirements — Always Split (Frontend Guideline)
When a single feature requirement touches both layers, the frontend guideline now **always** instructs splitting into per-layer FRs. The previous `[Both]` escape hatch is removed; its only example (error envelope schema) was itself a case that should be split (backend defines and emits; frontend parses and renders). A new "How to identify a spanning requirement" paragraph replaces the escape hatch with a concrete three-question test.
#### Recon Findings Section (Exploratory Guideline)
New Section 0.5 — **before the creative sections** — for summarized Explore subagent output. Section 0 instructs the agent to run recon first; the findings live upstream of §1 The Spark so recon actually informs the creative work instead of following it.
#### Agent Execution Model Section (Tasks Guideline)
A new first-class section in the Implementation Tasks guideline explaining how tasks are now executed by tool-using agents, including:
- Tasks executed directly (not suggestions)
- Isolated workspace requirement
- Hook-enforced deterministic rules
- `[parallel]` marker for parallelizable tasks
- Delegatable research hoisted to subagents
- Every task has a verification step
- `WORKFLOW.md` contract
#### New Task Format (v4.0.0)
The task format example now includes:
- Branch name at the top
- Reference to `WORKFLOW.md` (not restated)
- Required hooks listed explicitly
- `Phase 0: Recon` for subagent-delegated research
- `[parallel]` markers on independent phases
- Explicit verification commands on every sub-task
- Delegated Work summary section

### Changed
- **README.md**: Major rewrite of the "Getting Started" section with v4.0.0 activation prompts, migration guide from v3.x, and explicit guidance on when to use the new System guideline. "What You'll Find Here" rewritten to include all six guidelines (previously listed only four). Stale v2.x Getting Started block removed. Doubled tagline consolidated. Marketing language thinned.
- **guidelines/README.md**: Updated to document six guidelines (was four). Decision matrix gained rows for multi-component services, orchestrators, cross-Lambda coordination, streaming/real-time services, audit-sensitive features, and repository setup. Stale v3.x Quick Reference block removed — consolidated to one v4.0.0 block.
- **Clarifying Questions**: Each guideline now includes "Questions the Agent Should NOT Ask (Look Them Up Instead)" to push the agent toward tool use before asking.
- **PRD Structure**: Every PRD structure now includes an explicit "Agent Execution Plan" section (branch name, delegatable research, required hooks, `WORKFLOW.md` reference).
- **`guidelines/system-specification-guidelines.md`**: Section 4 renamed "Workflow / Policy File" → "Service Policy / Configuration File" with a naming note that disambiguates it from the project-level `WORKFLOW.md`. Sections 8–14 renumbered to accommodate the new Streaming Transports and Audit & Compliance Records sections.
- **`guidelines/frontend-feature-specification-guidelines.md`**: Streaming and audit decision-framework rows now **route** to `system-specification-guidelines.md` §6/§7 instead of reproducing partial guidance. The previous `[Both]` spanning-requirement escape hatch is removed. Three overlapping audit checklists consolidated into one Final Audit. The "2+ sequential API calls" red flag softened to `3+` with a user-gated carve-out.
- **`templates/workflow-template.md`**: Hook JSONC rewritten to a valid Claude Code schema — `matcher` + nested `hooks[].type`/`command`. The earlier draft used a top-level `pattern` key that the Claude Code schema does not support; anyone who copied the template verbatim would have shipped a broken hook. A reference `pre-commit-gate.sh` script is included that parses stdin and only runs tests/lint/typecheck when the Bash command contains `git commit`. Test Commands block reframed as "delete what doesn't apply."
- **`package.json`**: `main: "README.md"` removed (docs-only package); `private: true`, explicit `files` list, and a no-op `test` script added. Bumped to 4.0.0.

### Fixed

- **`.claude/hooks/protect-env.sh`** — the `.env`-protection hook had bypass vectors closed before v4.0.0 shipped:
  - **Fail-closed on parse errors.** `jq` failures, missing input, and unexpected tool shapes now deny rather than pass through. Previously a malformed hook input resulted in empty variables and silent allow.
  - **Shell-quote stripping before matching.** `bash -c 'printenv'` and `sh -c "cat .env"` are caught. Previously the word-boundary regex failed inside quoted subcommand content.
  - **`.env.example` allowlist scoped to path fields only.** Decoy strings like `cat .env # see .env.example` no longer bypass the block. Previously the allowlist was checked against the full command string.
  - **Redirect and subshell boundaries added.** `head <.env`, `$(cat .env)`, and backtick subshells are now caught by the path-boundary regex.
  - **Env-dump coverage extended.** `export -p`, `declare -x`, `/proc/*/environ`, `ps -E` (macOS), and `ps eww`/`ps eaww` (BSD-style standalone `e` flag) are now blocked alongside `env`/`printenv`.
  - **Bulk archive from repo root.** `tar`/`rsync`/`cpio` sourced from `.`/`./`/`$PWD` and `cp -r .`, `zip -r .` are now blocked. These tools copy the repository wholesale — including the real `.env` — without ever naming it, so they bypassed the literal-string match.
  - **Case-insensitive matching.** `.ENV` blocks on macOS, where HFS+ is case-insensitive by default.
  - **Denial logging** to `~/.claude/protect-env.log` with timestamp, tool name, and reason — a minimal audit trail.
  - Verified against a 33-case deny/allow test suite covering all of the above.
- **`.claude/settings.json`** — matcher extended to cover `Task|WebFetch|WebSearch|NotebookEdit` (previously only `Read|Write|Edit|Bash|Grep|Glob`). `.env*` deny rules duplicated from `Read` to `Edit`/`Write`/`Grep`/`Glob` as defense-in-depth: if the hook script errors or is deleted, the permissions layer still blocks those tools.
- **`guidelines/implementation-tasks-creation-guidelines.md` task-format example** — the fenced template had a dropped `### Relevant Files` header, an orphan bullet list outside the fence, and a stray trailing fence. An agent copying the template verbatim would have produced a malformed document. The fenced example now has `### Relevant Files` and `### Delegated Work` subsections inside the fence, the orphan block outside is removed, and the fence is balanced.

### Unchanged (Still Valid from v3.0.0)
- The "build the fence, explore the playground" philosophy
- The `[Backend/Frontend]` prefix requirement in functional requirements
- The Architectural Boundaries Framework and Architectural Audit
- The 5-Question Decision Framework
- The ARCHIVAL PROTOCOL (now additionally hook-enforceable)
- The Quick Start vs. Full PRD distinction
- The `/documentation/specifications/active/ | completed/` and `/documentation/tasks/active/ | completed/` directory conventions. v4.0.0 also ships `.gitkeep` scaffolding so these directories exist on a fresh clone — previously the convention was documented but the directories had to be created by hand.

### Migration Guide: v3.x → v4.0.0
**PRD format is not broken.** Existing v3.x PRDs remain valid. To fully adopt v4.0.0:
1. **Copy `templates/workflow-template.md`** to your project root as `WORKFLOW.md`. Fill in test commands, branch policy, and project-specific rules.
2. **Wire up hooks** from the template into `.claude/settings.json` (or your harness equivalent). Start with `PreToolUse(Bash:git commit)` running tests, and `Stop` running archival verification.
3. **Audit existing PRDs**: wherever they restate a rule that now lives in `WORKFLOW.md`, delete the duplication and add a reference.
4. **Update activation prompts** to mention `WORKFLOW.md` and subagent delegation. See `README.md` for the new prompt templates.
5. **For your next multi-component project**, use `system-specification-guidelines.md` instead of cramming it into a Backend PRD.

#### Worked Example: Before and After

A concrete v3.x → v4.0.0 rewrite of a representative PRD snippet.

**v3.x PRD (excerpt)** — rules restated inline:

```markdown
## Testing

The following must pass before any commit:
- `node --test tests/` for backend tests
- `npm run lint` for linting
- `npm run typecheck` for TypeScript

## Branch Policy

Work on a feature branch named `feature/[slug]`. Do not commit to `main`.
Rebase on `main` before opening a PR.

## Commit Format

Use Conventional Commits: `feat(scope): message`. Reference the PRD in the body.

## Functional Requirements
- FR1: Backend: Add a new endpoint `/accounts/{id}/summary` that returns...
- FR2: Backend: The endpoint must be authenticated via the existing middleware...
```

**v4.0.0 PRD (excerpt)** — rules hoisted into `WORKFLOW.md`, referenced:

```markdown
## Agent Execution Plan

- **Branch**: `feature/account-summary-endpoint` (see `WORKFLOW.md` branch policy)
- **Tests, lint, typecheck, commit format**: inherited from `WORKFLOW.md`
- **Required hooks**: `PreToolUse(Bash:git commit)` runs tests (enforced by `.claude/settings.json`)
- **Delegatable research**:
  - `[Explore subagent]` Map existing `/accounts/*` handlers and their auth middleware usage.
  - `[Explore subagent]` Identify DynamoDB access patterns already used for the `accounts` table.

## Functional Requirements
- FR1: Backend: Add a new endpoint `/accounts/{id}/summary` that returns...
- FR2: Backend: The endpoint must be authenticated via the existing middleware...
```

The testing, branch-policy, and commit-format sections are gone — they live in `WORKFLOW.md` and are enforced by hooks. Only the **work that is specific to this feature** remains in the PRD.

### What This Solves

**Before v4.0.0**:
- Every PRD repeated the same rules about test commands, commit style, and branch policy
- Rules drifted between PRDs written at different times
- The framework assumed a chat-loop AI that would "remember" things
- No home for multi-component system specifications
- No mechanism to parallelize independent research or implementation work
- No way to enforce deterministic rules beyond prose exhortation

**After v4.0.0**:
- Rules live in `WORKFLOW.md`, enforced by hooks, referenced by PRDs
- Multi-component systems have a dedicated guideline with a proven section spine
- Explore and Plan subagents are first-class citizens in the workflow
- Parallelizable work is marked explicitly and delegated automatically
- Workspace isolation is mandatory and specified in every PRD
- Acceptance criteria are machine-verifiable test assertions, not prose judgments

### Inspiration

The new System guideline's section spine was adapted from OpenAI's Symphony `SPEC.md` — a reference specification for a long-running agent-orchestration service. Symphony itself is not a guideline; it is an example of what a rigorous system-level spec looks like. This framework extracted its structure into a reusable template.

### Why v4.0.0 is a Major Version
The underlying PRD format is not broken: v3.x PRDs remain readable and valid. v4.0.0 is released as a major version because producing a **v4.0.0-conformant** artifact requires expectations a v3.x project will not have in place:
1. A `WORKFLOW.md` policy file at the repository root. Every v4.0.0 PRD references it; every activation prompt expects it.
2. An Agent Execution Plan section in every PRD structure (branch name, delegatable research, required hooks, workflow file reference).
3. A guideline taxonomy that grew from four to six. Cross-references between guidelines were re-wired to include `system-specification-guidelines.md` and `workflow-file-guidelines.md`.
4. Deterministic rules that v3.x guidelines ask the agent to "remember" now migrate to hooks. The Tasks guideline assumes archival verification is wired into a `Stop` hook; Backend/Frontend guidelines assume test gating is wired into a `PreToolUse(Bash:git commit)` hook.
5. Activation prompts that mention `WORKFLOW.md` and subagent delegation. The v3.x prompt style (no workflow reference, no recon subagent) no longer produces a complete v4.0.0 PRD.

**Compatibility**: Teams that do not adopt `WORKFLOW.md` and hooks can continue using v3.x guidelines verbatim — nothing in v4.0.0 invalidates a v3.x PRD. Mixing v4.0.0 guidelines into a project without the supporting `WORKFLOW.md` is possible but will produce PRDs that reference a file the project does not have.


## [3.0.0] - Tuesday, November 4, 2025

### Major Architectural Framework Addition

**BREAKING CHANGES**: Complete architectural decision framework for frontend/backend responsibility separation.

### Added

- **Section 2: Architectural Boundaries Framework** (113 lines)
  - **Backend Responsibilities**: Business logic, data aggregations, heavy computations, multi-symbol operations, data normalization, security operations, caching, external API integration
  - **Frontend Responsibilities**: UI state management, presentation logic, progressive disclosure, client-side validation, visual calculations, user preferences
  - **5-Question Decision Framework**: Systematic approach to determine where work belongs
    1. Does this require data from multiple sources?
    2. Is this a calculation or transformation?
    3. Will multiple clients need this?
    4. Does this affect performance?
    5. Is this security-sensitive or rate-limited?
  - **Common Anti-Patterns**: Concrete examples of wrong vs correct PRD approaches
  - **Options Trading Context Examples**: Real-world scenarios showing proper separation
  - **When Frontend Work is Appropriate**: Clear guidelines for legitimate client-side work

- **Enhanced Clarifying Questions Framework**
  - Added **Architectural Placement** verification
  - Added **API Design** considerations
  - Added **Data Flow** questions
  - Added **Performance** optimization guidance
  - Expanded **Data Requirements** section with 4 specific questions for data features
  - Added architectural checkboxes to **Boundary Checklist**

- **Mandatory Architectural Decisions Section in PRD Structure**
  - **Quick Start PRD**: Added "Architectural Decisions" section with [Backend/Frontend] prefix requirement
  - **Full PRD**: Added detailed "Architectural Decisions" section with justification requirements
  - **Format Specification**: `FR1: [Backend/Frontend]: Specific requirement`
  - **Example Format**: `FR1: Backend: Calculate expiration-specific P/C ratios during options chain processing`

- **PRD Review Checkpoint: Architectural Audit**
  - 5-point checklist before finalizing PRD
  - Red flags detection (frontend calculations, multiple API calls, data normalization in frontend, complex business logic in React)
  - Systematic prevention of architectural mistakes

- **Enhanced Examples Section**
  - Updated Quick Start example with architectural decisions
  - New **Architectural Boundary Example** showing BAD vs GOOD PRD
  - Moving Average Indicators example with complete frontend/backend separation
  - Full PRD structure updated to include Architectural Decisions

### Changed

- **Guiding Principles Enhancement**
  - Added **"Smart Backend, Simple Frontend"** principle
  - Added **"Backend-First Thinking"** principle
  - Added **"Single Source of Truth"** principle
  - Reordered principles to emphasize architectural thinking

- **File Organization Updates**
  - PRD location changed from `/documentation/` to `/documentation/specifications/active/`
  - Archive location changed from `/documentation/specifications/` to `/documentation/specifications/completed/`
  - More granular folder structure for better organization

- **Application Process Enhancement**
  - Step 3 now requires architectural placement verification
  - Step 5 now saves to `/documentation/specifications/active/`
  - Step 9 now archives to `/documentation/specifications/completed/`

### Why This Major Version

**Version 3.0.0 represents a fundamental paradigm shift in how AI assistants generate PRDs**:

1. **Prevents Common AI Mistakes**: AI assistants naturally default to putting business logic in frontend because they think linearly through user flows. The explicit architectural boundaries framework **forces correct decisions upfront**.

2. **Systematic Decision Making**: The 5-question framework produces consistent, architecturally sound PRDs instead of ad-hoc decisions that vary by context or AI assistant mood.

3. **Self-Auditing Capability**: The Architectural Audit checklist enables AI assistants to verify their own work before presenting to humans, reducing review cycles.

4. **Concrete Learning Through Examples**: The wrong/right PRD comparisons teach patterns better than abstract principles. AI assistants learn from concrete examples more effectively than theoretical guidance.

5. **Breaking Structural Change**: The mandatory [Backend/Frontend] prefix in functional requirements changes the PRD format fundamentally. This is not backward compatible with PRDs expecting generic "The system must..." requirements.

### The Problem This Solves

**Before v3.0.0**, AI-generated PRDs frequently contained these anti-patterns:
- "Frontend calculates P/C ratio from options data"
- "Frontend fetches multiple symbols and compares Greeks"
- "Frontend aggregates volume data across expirations"
- "Frontend calculates moving averages from price history"

**After v3.0.0**, the framework forces explicit architectural decisions:
- "Backend includes P/C ratio in response payload"
- "Backend multi-symbol comparison endpoint returns normalized comparison data"
- "Backend includes aggregated volume metrics in expiration summary"
- "Backend includes SMA-20/50/200 in market data response"

### Impact on AI-Generated PRDs

Teams adopting v3.0.0 gain:

- **Consistency**: All PRDs follow "Smart Backend, Simple Frontend" principle
- **Future-Proofing**: Backend APIs designed to support future clients (mobile, desktop, API consumers)
- **Performance**: Heavy computations happen on backend, not repeated in every client
- **Maintainability**: Business logic in one place, not duplicated across frontend components
- **Security**: Security-sensitive operations explicitly assigned to backend
- **DRY Principle**: Data transformations happen once on backend, not repeatedly on each client

### Migration Guide

**From v2.x to v3.0.0**:

1. **Functional Requirements Format Change**: Update all functional requirements to use architectural prefix
   - Old: `FR1: The system must calculate P/C ratios`
   - New: `FR1: Backend: Calculate P/C ratios during options chain processing`

2. **Add Architectural Decisions Section**: All PRDs now require explicit architectural decisions section before functional requirements

3. **Apply Decision Framework**: For each requirement, answer the 5 questions to determine placement

4. **Run Architectural Audit**: Before finalizing PRD, verify checklist and check for red flags

5. **Update Examples**: Review existing PRDs for frontend calculations, aggregations, or multi-step API calls and refactor to backend

### Framework Philosophy

**"Smart Backend, Simple Frontend"**: Business logic and calculations belong on backend; frontend focuses on presentation and UX.

**"Backend-First Thinking"**: For data features, start by designing the ideal API response, then build frontend to consume it.

**"Single Source of Truth"**: Data transformations happen once on backend, not repeatedly on each client.

### Real-World Validation

This framework was developed after observing systematic mistakes in AI-generated PRDs across multiple projects:
- Options trading platforms putting Greeks calculations in React components
- Multi-symbol comparison features making parallel frontend API calls
- Volume aggregation happening in browser instead of Lambda functions
- Moving average calculations duplicated across web and potential mobile clients

The architectural framework eliminates these patterns **before implementation begins**, saving days of refactoring.

### Breaking Changes

1. **PRD Format**: Functional requirements now require [Backend/Frontend] prefix
2. **PRD Structure**: "Architectural Decisions" section now mandatory in both Quick Start and Full PRD
3. **File Locations**: Active PRDs move from `/documentation/` to `/documentation/specifications/active/`
4. **Decision Process**: Step 3 of Application Process now requires architectural verification
5. **Examples Format**: All examples updated to show architectural separation

### Why "Major" Not "Minor"

This is a **major version** because:
- PRD format changes are not backward compatible
- Workflow changes require different AI prompting
- Existing PRD templates need updating
- Migration requires manual review of architectural decisions
- The framework fundamentally changes how AI assistants think about feature specifications

## [2.0.0] - Monday, November 3, 2025

### Major Framework Completion

**BREAKING CHANGES**: Complete framework restructuring with consistent naming convention and addition of critical fourth guideline.

### Added

- **Fourth Essential Guideline: Implementation Tasks Creation**
  - `implementation-tasks-creation-guidelines.md` completes the framework
  - Contains the critical **ARCHIVAL PROTOCOL** (lines 13-61) for proper task completion workflow
  - Provides granular task breakdown methodology with over-engineering prevention
  - Interactive check-in process for high-level plan approval before detailed tasks
  - Domain-specific testing approaches (Backend: Node.js native, Frontend: Vitest + RTL)
  - Three-File Rule and inline-first implementation principles
  - Executable bash commands with verification steps

- **Consistent Naming Convention Across All Guidelines**
  - Established pattern: `[descriptor]-[action]-guidelines.md`
  - `backend-feature-specification-guidelines.md`
  - `frontend-feature-specification-guidelines.md`
  - `exploratory-feature-specification-guidelines.md`
  - `implementation-tasks-creation-guidelines.md`

- **Complete Cross-Reference System**
  - All PRD guidelines now reference the ARCHIVAL PROTOCOL
  - Closed-loop workflow from PRD creation → task generation → implementation → archival
  - Prevents systematic archival errors through temporal knowledge gap elimination

- **Domain-Specific Templates**
  - New backend-specification-template.md (Lambda/API focus)
  - New frontend-specification-template.md (React/TypeScript focus)
  - New exploratory-specification-template.md (creative ideation)
  - All templates include archival cross-references

### Changed

- **Repository Structure Reorganization**
  - All guidelines now in canonical source repository
  - Comprehensive README updates with framework lifecycle documentation
  - Enhanced decision matrix for guideline selection
  - Quick reference commands for all four guidelines

- **Enhanced Documentation**
  - Guidelines README now documents complete 4-guideline framework
  - Updated all templates with domain headers and archival sections
  - Enhanced examples with guideline attribution and archival notes
  - Cross-repository standardization complete

### Fixed

- **Systematic Archival Errors Eliminated**
  - Root cause: Archival protocol was buried at document end without visual emphasis
  - Solution: Prominent **ARCHIVAL PROTOCOL** section at top of task generation guideline
  - All PRD guidelines now cross-reference this protocol
  - Executable verification commands prevent incomplete archival

### Documentation Improvements

- **Complete Specification Lifecycle Documentation**
  - Phase 1: PRD Generation (Backend/Frontend/Exploratory guidelines)
  - Phase 2: Task Breakdown (Implementation Tasks Creation guideline)
  - Phase 3: Implementation with full test coverage
  - Phase 4: Archival following ARCHIVAL PROTOCOL

- **Framework Philosophy Clarification**
  - "First, build the fence. Then, explore every inch of the playground"
  - Boundary-first approach prevents scope creep while enabling thoroughness
  - Progressive disclosure patterns for UI complexity management

### Framework Maturity

This release represents the **completion of the core framework**:

- ✅ **4 Essential Guidelines**: PRD generation (3) + Task creation (1)
- ✅ **Domain-Specific Patterns**: Backend, Frontend, Exploratory
- ✅ **Testing Standards**: Node.js native (Backend), Vitest + RTL (Frontend)
- ✅ **Archival Protocol**: Systematic completion workflow
- ✅ **Consistent Naming**: All guidelines follow established pattern
- ✅ **Cross-References**: Complete integration across framework
- ✅ **Real-World Examples**: Battle-tested in production

### Why This Major Version

**Version 2.0.0 marks framework completion**:

1. **Critical Missing Component Added**: Implementation tasks creation guideline with ARCHIVAL PROTOCOL
2. **Breaking Structural Change**: Consistent naming convention across all guidelines
3. **Complete Workflow Integration**: Closed-loop from ideation through archival
4. **Framework Maturity**: All essential components now present and integrated

### Migration Guide

**From v1.x to v2.0.0**:

1. **Guideline References**: Update any references to use new naming convention:
   - `guidelines-for-creatively-generating-feature-specifications.md` → `frontend-feature-specification-guidelines.md` or `backend-feature-specification-guidelines.md`
   - `guidelines-for-freeform-feature-specification-generation.md` → `exploratory-feature-specification-guidelines.md`
   - New: `implementation-tasks-creation-guidelines.md` for task generation

2. **Task Generation**: Now use `implementation-tasks-creation-guidelines.md` with ARCHIVAL PROTOCOL

3. **Archival Workflow**: Follow new ARCHIVAL PROTOCOL (lines 13-61) with executable verification

### Impact

Teams adopting v2.0.0 gain:
- **Complete Framework**: All four essential guidelines present
- **Systematic Workflow**: No gaps from ideation to archival
- **Error Prevention**: ARCHIVAL PROTOCOL eliminates systematic mistakes
- **Consistency**: Domain-first organization with clear patterns
- **Production-Ready**: Battle-tested across multiple repositories

## [1.1.0] - Wednesday, August 20, 2025

### Added
- **Real-world validation with persistent display CSS Grid solution**
  - Complete feature specification showing UI/UX optimization
  - Framework application notes documenting creative exploration → formal specification → implementation journey
  - Technical solution: CSS Grid approach eliminating text wrapping while maintaining accessibility

- **Framework evolution and institutionalized learnings**
  - Feature tagging strategy with descriptive naming approach (`persistent-display-css-grid-solution`)
  - Implementation journey best practices: Freeform → Formal → Implementation flow
  - Testing integration guidelines for aligning tests with component structure changes
  - Documentation lifecycle: Complete process from creative exploration to archived specifications

- **Enhanced guidelines with real-world insights**
  - Freeform guidelines: Added Section 7 with comprehensive tagging strategy and benefits
  - Formal guidelines: Added Section 6 with tagging process and implementation best practices
  - Examples README: Updated with new example and framework evolution insights

### Documentation Improvements
- **Three-way framework clarification**: Resolved contradiction between "Two Ways" and actual three approaches
- **Enhanced practical understanding**: Emphasized tools with potential rather than guaranteed outcomes
- **Flexible usage patterns**: Clarified that approaches can be used independently or in combination
- **Creative intent recognition**: Positioned freeform as intentional exploration, not just fallback
- **Professional presentation**: Improved table formatting and documentation clarity

### Framework Maturity
- **Battle-tested examples**: Two real-world implementations (budget filtering + persistent display)
- **Proven process**: Complete journey from creative exploration to production implementation
- **Institutionalized learning**: Key patterns and best practices captured for future teams
- **Adoption readiness**: Framework transformed from theoretical to proven methodology

### Why This Matters

This release demonstrates the framework's effectiveness through **two battle-tested examples**:

1. **[Budget Filtering](examples/feature-specification-for-budget-filtering.md)** (Business Logic) - Complex feature with 5 explicit constraints
2. **[Persistent Display](examples/feature-specification-persistent-display-css-grid-solution.md)** (UI/UX) - Technical layout optimization with accessibility focus

The first uses the [guidelines for creatively generating feature specifications](guidelines/guidelines-for-creatively-generating-feature-specifications.md) and the second uses the [guidelines for freeform feature specification generation](guidelines/guidelines-for-freeform-feature-specification-generation.md).

### Impact
Teams adopting this framework now have:
- Concrete examples of different feature types (business logic + UI/UX)
- Complete implementation journeys to follow
- Institutionalized best practices and tagging strategies
- Proof that the approach works in real-world scenarios

## [1.0.0] - Monday, August 18, 2025

### Added
- **Complete framework for AI-generated feature specifications**
  - Guidelines for AI assistants to create comprehensive PRDs
  - Clarifying Questions Framework with prioritized categories
  - PRD Structure templates (Quick Start and Full Process)
  - Guiding Principles including "Creative Abandon Within Scope"

- **Manual template approach**
  - Simple template for straightforward features (6 sections)
  - Full template for complex features (14 sections + quality checklist)
  - Both templates align perfectly with AI-generated guidelines

- **Real-world validation**
  - Budget filtering feature specification example
  - Successfully implemented in production with record delivery time
  - Demonstrates framework effectiveness in practice

- **Supporting tools**
  - Freeform exploration guidelines for creative brainstorming
  - Examples directory with battle-tested specifications
  - Comprehensive documentation and getting started guides

### Features
- **Two complementary approaches**: AI-generated and manual templates
- **Boundary-first methodology**: "First, build the fence. Then, explore every inch of the playground"
- **Scope control**: Prevents AI scope creep through structured questioning
- **Quality assurance**: Built-in testing requirements and success metrics
- **Enterprise considerations**: Privacy, security, compliance, and audit sections

### Documentation
- Clear README with approach comparison table
- Organized repository structure with guidelines/, templates/, and examples/ directories
- Real-world examples showing framework effectiveness
- Professional package metadata and versioning

---

## Version History

- **4.0.0**: Agent-Era Update — tool-using agents, subagents, hooks, `WORKFLOW.md` convention, System guideline
- **3.0.0**: Architectural Decision Framework — mandatory `[Backend/Frontend]` prefix, 5-Question Decision Framework, Architectural Audit
- **2.0.0**: Framework completion with fourth guideline, ARCHIVAL PROTOCOL, and consistent naming convention
- **1.1.0**: Second example specification and institutionalized learnings
- **1.0.0**: Initial stable release with framework, templates, and first example
