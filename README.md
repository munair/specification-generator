# Specification Generator


*A framework for guiding tool-using coding agents to create comprehensive feature specifications through structured creativity*
> **v4.0.0 — The Agent-Era Update**
>
> This release upgrades the framework from "how to guide a chat-loop AI" to "how to guide a tool-using agent with subagents, hooks, and workspace isolation." See the [What's New in v4.0.0](#whats-new-in-v400) section below, or jump straight to [Getting Started with v4.0.0](#getting-started-with-v400).


## The Problem with AI-Generated Specifications

Tool-using coding agents are incredibly powerful at generating detailed technical documentation, but they often suffer from two critical flaws when creating product specifications:

1. **Scope Creep** - They get excited and design elaborate solutions that far exceed what was actually requested
2. **Assumption-Making** - They fill in gaps with their own interpretations rather than asking clarifying questions

The result? Beautiful, comprehensive documents that solve the wrong problem entirely.

v4.0.0 adds a third concern the original framework didn't address: **agent-era execution**. Modern agents read files, run tests, spawn subagents, and commit their own work. PRDs written for a chat-loop assistant underutilize those capabilities — or worse, assume rules the agent has no way to enforce.

## The Solution: Creative Abandon Within Scope

This repository contains a framework that solves both problems through a simple but powerful metaphor:

> **"First, build the fence. Then, explore every inch of the playground."**

### Key Principles

1. **Boundaries First, Creativity Second** - Define the fence before exploring the playground
2. **Smart Backend, Simple Frontend** - Business logic on backend, presentation on frontend
3. **Architectural Decision Making** - Systematic work placement prevents common AI mistakes

### How It Works

The framework operates on a two-phase approach:

#### Phase 1: Build the Fence (Boundary Establishment)
The AI assistant **must** establish clear boundaries before any creative work begins:
- What should this feature *not* do?
- Can this be broken into phases?
- How does it integrate with existing systems?

#### Phase 2: Explore the Playground (Creative Abandon)
Once boundaries are locked down, the AI assistant is encouraged to be **maximally creative and comprehensive** within those constraints.

#### Phase 1b: Architectural Decision Making (full-stack features)
For full-stack applications, the framework enforces **explicit architectural boundaries** between frontend and backend before creative exploration begins:
- **Smart Backend, Simple Frontend** - Business logic belongs on backend
- **5-Question Decision Framework** - Systematic placement of work
- **Architectural Audit** - Self-verification before PRD finalization

This approach leverages the AI's natural strengths (creativity, thoroughness, pattern recognition) while preventing its weaknesses (scope creep, assumption-making, architectural mistakes).

## What's New in v4.0.0
v4.0.0 is a **major release** that upgrades every guideline for the agent-era execution model. Three things changed:

### 1. All existing guidelines now assume a tool-using agent
Backend, Frontend, Exploratory, and Tasks guidelines each gained a new **Agent-Era Execution Model** section plus targeted updates throughout. The changes are surgical — the "build the fence, explore the playground" philosophy is intact — but every guideline now expects:
- The agent has tools (reads files, runs tests, commits)
- The agent can spawn subagents (delegate broad research, parallelize independent work)
- The agent honors in-repository policy (reads `WORKFLOW.md`)
- Deterministic rules live in hooks, not PRD prose
- Work happens in an isolated workspace (branch or git worktree)
- Requirements are machine-verifiable (test assertions, not prose judgments)
PRDs written under v4.0.0 are shorter and more actionable because they **reference** project conventions instead of restating them.

### 2. New guideline: System-Level Specifications
A new guideline — `system-specification-guidelines.md` — fills a gap in the taxonomy. The existing Backend and Frontend guidelines are optimized for single-feature PRDs (a Lambda handler, a React component). They are not the right tool for specifying a multi-component service with a state machine, concurrency, and observability.
The new guideline uses a section spine adapted from OpenAI's Symphony `SPEC.md`, extended with cross-cutting system concerns:
1. Problem & Goals
2. System Architecture (component table)
3. Domain Model (with stable IDs)
4. Service Policy / Configuration File (distinct from project `WORKFLOW.md`)
5. State Machine & Orchestration
6. **Streaming Transports** — SSE/WebSocket/long-poll, backpressure, reconnect/resume, heartbeat
7. **Audit & Compliance Records** — schema, retention, immutability, fail-closed vs. fail-open write path
8. Safety & Integration
9. Observability & Operations
10. Testing Matrix (per component, with verification commands)
11. Agent Execution Plan
12. Extensibility
13. Non-Goals
14. Open Questions
**Use it when**: you're specifying an orchestrator, daemon, long-running service, or any system with ≥ 3 communicating components. **Don't use it when**: you're specifying a single Lambda or a single React component — the Backend or Frontend guideline is the right fit there.

### 3. New convention: `WORKFLOW.md` as the in-repository policy contract
v4.0.0 formalizes an in-repository policy file — `WORKFLOW.md` (or `CLAUDE.md`, `AGENTS.md`, `.cursorrules`, depending on your harness) — as the **single source of truth** for project-wide rules:
- Test commands and pass criteria
- Branch policy (feature branches, worktrees, main protection)
- Commit message format
- Hook configuration
- Subagent delegation defaults
- Archival protocol reference
- Project-specific conventions
A reference template lives at `templates/workflow-template.md`. The companion guideline — `guidelines/workflow-file-guidelines.md` — explains how to integrate it.
**Before v4.0.0**: Every PRD restated the same rules ("tests must pass before commit," "use Conventional Commits"). Rules drifted. Agents "forgot."
**After v4.0.0**: Rules live in `WORKFLOW.md`. Hooks enforce them. PRDs reference them. Everything is shorter, more accurate, and automatically consistent.

---

## Getting Started with v4.0.0

### If you're new to the framework
1. **Read this README** to understand the philosophy.
2. **Copy `templates/workflow-template.md`** to your project root as `WORKFLOW.md`. Customize the test commands, branch policy, and commit style to match your project.
3. **Wire up hooks** in `.claude/settings.json` (or your harness equivalent) that enforce the deterministic rules from your `WORKFLOW.md`. The template shows a reference configuration.
4. **Pick the right guideline for your feature**:
   - Single Lambda / API endpoint → `guidelines/backend-feature-specification-guidelines.md`
   - Single React component → `guidelines/frontend-feature-specification-guidelines.md`
   - Multi-component system / service → `guidelines/system-specification-guidelines.md`
   - Creative brainstorming → `guidelines/exploratory-feature-specification-guidelines.md`
5. **Activate the agent**: "Follow `guidelines/[name].md`. `WORKFLOW.md` is at the repository root. Feature request: [YOUR REQUEST]."
6. **Let the agent use its tools first**. It should read `WORKFLOW.md`, grep the target directory, and delegate recon to subagents before asking you clarifying questions.
7. **Approve and commit the PRD** at the critical checkpoint, then generate tasks with `guidelines/implementation-tasks-creation-guidelines.md`.

> **Want to see a real, working `WORKFLOW.md`?** This repository has one at its root: [`/WORKFLOW.md`](WORKFLOW.md). It is the specification-generator project's own policy file, written under the v4.0.0 shape — this framework eats its own dog food. Use it as a worked example alongside the [`templates/workflow-template.md`](templates/workflow-template.md) starting point.

### If you're migrating from v3.x
1. **Add `WORKFLOW.md` to your repo.** Copy the template, fill in your project's rules.
2. **Wire up the reference hooks** from the template into `.claude/settings.json`.
3. **Audit existing PRDs**: wherever they restate a rule that now lives in `WORKFLOW.md`, delete the duplication and add a reference.
4. **Update your activation prompts** to mention `WORKFLOW.md`. Example: `"Follow frontend-feature-specification-guidelines.md. WORKFLOW.md is at the repository root. Feature request: ..."`
5. **For your next system-level project** (an orchestrator, daemon, or multi-component service), use the new `system-specification-guidelines.md` instead of cramming it into a Backend PRD.
6. **No PRD format break**: v4.0.0 does not change the `[Backend/Frontend]` prefix requirement from v3.0.0. Existing PRDs remain valid.

### New Activation Prompts
```bash
# Backend feature (v4.0.0)
"Follow guidelines/backend-feature-specification-guidelines.md for a Lambda function.
WORKFLOW.md is at the repository root — read it first. Use Explore subagents for any
codebase-wide research. Feature request: [REQUEST]"
# Frontend feature (v4.0.0)
"Follow guidelines/frontend-feature-specification-guidelines.md for a React component.
WORKFLOW.md is at the repository root — read it first. Use Explore subagents for any
component-tree audit. Feature request: [REQUEST]"
# System-level spec (v4.0.0, NEW)
"Follow guidelines/system-specification-guidelines.md for a multi-component service.
WORKFLOW.md is at the repository root — read it first. Use a Plan subagent to review the
draft architecture before finalizing. System description: [DESCRIPTION]"
# Exploratory (v4.0.0)
"Follow guidelines/exploratory-feature-specification-guidelines.md. Spawn an Explore
subagent first to survey the existing codebase for adjacent prior art. Topic: [TOPIC]"
# Task generation from approved PRD (v4.0.0)
"Follow guidelines/implementation-tasks-creation-guidelines.md for the approved PRD
at [PATH]. Spawn recon subagents for the PRD's Delegatable Research section before
proposing the high-level plan."
```
---

## Guideline Taxonomy: Domain-First Organization

The framework now provides **six specialized guidelines** — four for PRD generation (Backend, Frontend, Exploratory, System), one for task generation (Implementation Tasks), and one for the repository-level policy contract (Workflow File):

### Backend Feature Specifications
**File**: `guidelines/backend-feature-specification-guidelines.md`

**For**: Lambda functions, APIs, data processing, backend services

**Characteristics**:
- Dependency-free testing patterns (Node.js native modules only)
- Service architecture and integration points
- Data validation and transformation logic
- Error handling and recovery strategies
- Performance and scalability requirements

**Best for**: Backend systems, serverless functions, API endpoints, data pipelines

### Frontend Feature Specifications
**File**: `guidelines/frontend-feature-specification-guidelines.md`

**For**: React/TypeScript applications, UI components, user interfaces

**Characteristics**:
- **Architectural Boundaries Framework (NEW)** - Explicit frontend/backend separation
- **5-Question Decision Framework** - Systematic work placement
- Component-based architecture patterns
- State management and context design
- User experience and accessibility requirements
- Visual design and responsive layout
- Progressive disclosure and performance optimization
- **Mandatory [Backend/Frontend] prefix** in functional requirements

**Best for**: Web applications, dashboards, trading interfaces, user-facing features

### Exploratory Feature Specifications
**File**: `guidelines/exploratory-feature-specification-guidelines.md`

**For**: Creative ideation, novel solutions, brainstorming sessions

**Characteristics**:
- Freeform creative exploration
- Dream scenario visualization
- Failure mode analysis
- Metaphor development
- Constraint-free initial thinking
- **v4.0.0**: Recon subagents can survey the codebase before the creative work begins — exploration is now cheaper and broader

**Best for**: Innovative features, strategic initiatives, when systematic approaches aren't working, creative rescue scenarios

### System-Level Specifications (NEW in v4.0.0)
**File**: `guidelines/system-specification-guidelines.md`
**For**: Multi-component services, orchestrators, daemons, long-running systems
**Characteristics**:
- Symphony-inspired section spine (Problem → Architecture → Domain Model → State Machine → Safety → Observability → Testing Matrix)
- Explicit component table (responsibility, inputs, outputs, lifecycle)
- Stable entity IDs for logging and reconciliation
- Forward-compatible schema (unknown keys ignored)
- Per-component testing matrix with verification commands
- Designed for subagent-per-component parallel implementation
**Best for**: Agent orchestrators, polling daemons, multi-Lambda workflows, any system with ≥ 3 communicating components

### The `WORKFLOW.md` Convention (NEW in v4.0.0)
**Guideline**: `guidelines/workflow-file-guidelines.md`
**Template**: `templates/workflow-template.md`
**Purpose**: Single source of truth for project-wide rules that agents must honor.
**Contains**:
- Test commands and pass criteria
- Branch policy
- Commit format
- Hook configuration
- Subagent delegation defaults
- Archival protocol reference
- Project-specific conventions
**Rule**: If a rule applies to every feature in the project, it belongs in `WORKFLOW.md` — not restated in each PRD.

## When to Use Which Guideline

| Scenario                                | Recommended Guideline   | Why                                                                 |
|-----------------------------------------|-------------------------|---------------------------------------------------------------------|
| Lambda function development             | Backend                 | Specialized for serverless architecture and dependency-free testing |
| React component features                | Frontend                | Optimized for component architecture and state management           |
| API endpoint creation                   | Backend                 | Focuses on service integration and data transformation              |
| Dashboard UI improvements                | Frontend                | Emphasizes UX, accessibility, and progressive disclosure            |
| Data processing pipelines                | Backend                 | Handles performance, error recovery, and scalability                |
| Trading interface features               | Frontend                | Component composition, real-time updates, user workflows            |
| Novel, unexplored solutions              | Exploratory → Domain    | Creative exploration, then migrate to domain-specific spec          |
| When systematic approach fails           | Exploratory             | Creative rescue when structured thinking isn't working              |
| Simple bug fixes                         | Backend or Frontend     | Use Quick Start variant for straightforward fixes                   |
| **Multi-component service / daemon**    | **System (v4.0.0)**     | **State machine, concurrency, observability are first-class**       |
| **Agent orchestrator / poller**         | **System (v4.0.0)**     | **Workflow file, subagent-per-component, testing matrix**           |
| **Cross-Lambda coordination layer**     | **System (v4.0.0)**     | **≥ 3 components; isolation over coordination**                     |

## The Complete Specification Lifecycle

### 1. Feature Specification (PRD Creation)
Choose the appropriate guideline (Backend, Frontend, or Exploratory) and generate a comprehensive PRD.

**Critical Checkpoint**: PRD must be reviewed, approved, and committed before implementation begins.

### 2. Task Generation
Using `implementation-tasks-creation-guidelines.md`, break the approved PRD into atomic, actionable tasks.

**Location**: `/documentation/tasks/active/implementing-[feature-name].md`

### 3. Implementation
Execute tasks with full test coverage and documentation.

### 4. Archival
Follow the **ARCHIVAL PROTOCOL** in `implementation-tasks-creation-guidelines.md`:
- Mark ALL tasks complete (`- [ ]` → `- [x]`)
- Rename from `implementing-` to `implementation-log-`
- Move to `/documentation/tasks/completed/`

**Cross-Reference**: All PRD guidelines include archival protocol references to ensure proper completion workflow.

## Why Domain-First Organization?

**Traditional Problem**: Generic guidelines try to serve all domains, resulting in:
- Vague patterns that don't match real architectures
- Missing domain-specific best practices
- Confusion about which testing approach to use
- Unclear integration patterns

**Domain-First Solution**:
- **Immediate Clarity**: Filename tells you exactly when to use it
- **Precise Patterns**: Backend testing uses Node.js native modules; Frontend uses Vitest
- **Better Sorting**: Domain-first naming groups related guidelines together
- **Future-Proof**: Easy to add new domains (mobile, embedded, etc.)

## The Framework in Action

Here's how a typical specification process unfolds:

1. **User provides initial request** - "I need a Lambda function to process account data"
2. **Choose domain guideline** - Backend (Lambda function)
3. **AI establishes boundaries first** - "What should this NOT do?"
4. **AI confirms scope and phasing** - "Can this be broken down?"
5. **Creative exploration begins** - Within the established constraints
6. **Comprehensive PRD generated** - Thorough but focused on backend patterns

### Sample Interaction Flow

```
User: "I need a Lambda function to fetch Schwab account numbers"

AI: "I'll use the backend feature specification guidelines. Before designing
this Lambda, let me establish boundaries:
- What should this function NOT do?
- Are there any existing Lambda functions this shouldn't overlap with?
- What's the expected request volume (affects concurrency settings)?"

User: "Don't include account positions or balances, don't duplicate the
account details function, expect ~100 requests/hour."

AI: "Perfect! Now I can design a comprehensive Lambda function specification
focused on account number retrieval, with proper DynamoDB integration,
authorization, and dependency-free testing..."
```

## What You'll Find Here

### `guidelines/backend-feature-specification-guidelines.md`

The backend PRD guideline, containing:
- **Agent-Era Execution Model** (v4.0.0) — tool-using agent expectations
- **Lambda / serverless patterns** — API design, dependency-free testing
- **Architectural Boundaries Framework** — where work belongs
- **Data validation, authorization, DynamoDB integration**
- **Agent Delegation Strategy** (v4.0.0) — what to hoist to subagents
- **Archival cross-reference**

### `guidelines/frontend-feature-specification-guidelines.md`

The frontend PRD guideline, containing:
- **Agent-Era Execution Model** (v4.0.0)
- **Architectural Boundaries Framework** — frontend vs. backend decision making
- **5-Question Decision Framework** — systematic work placement
- **Spanning Requirements** (v4.0.0) — splitting cross-layer requirements
- **Routing hints** (v4.0.0) — streaming and audit requirements are owned by the backend/system guidelines; the frontend guideline points to them
- **Agent Orchestration Audit** (v4.0.0) — a pre-finalization checkpoint for red flags
- **Component architecture, state management, progressive disclosure**
- **Testing patterns (Vitest + React Testing Library)**
- **Archival cross-reference**

### `guidelines/exploratory-feature-specification-guidelines.md`

The creative exploration guideline, containing:
- **The Spark** — problem identification without constraints
- **Recon subagent integration** (v4.0.0) — broader exploration, less context pollution
- **Dream Scenario, failure mode analysis, metaphor development**
- **Migration path** to a domain-specific formal spec
- **Archival cross-reference**

### `guidelines/system-specification-guidelines.md` *(new in v4.0.0)*

The multi-component system guideline, containing:
- **Section spine** adapted from OpenAI's Symphony `SPEC.md`
- **System Architecture** — component table (responsibility, inputs, outputs, lifecycle)
- **Domain Model** with stable entity IDs
- **State machine and orchestration, safety rules, integration contracts**
- **Observability & Operations** — structured logging, metrics, alerts
- **Streaming and audit guidance** — cross-cutting concerns live here, not in Frontend
- **Testing matrix** per component, with verification commands
- **Agent Execution Plan** — branch, hooks, delegatable research, subagent-per-component
- **Extensibility, non-goals, open questions**

### `guidelines/workflow-file-guidelines.md` *(new in v4.0.0)*

The in-repository policy file guideline, containing:
- **Purpose** — single source of truth for project-wide rules
- **What belongs in `WORKFLOW.md`** — test commands, branch policy, commit format, hooks, subagent defaults, archival protocol
- **What does not belong** — feature-specific requirements, architecture decisions that vary by PRD, secrets
- **Forward compatibility rule** — unknown keys are ignored so the convention can evolve
- **Integration notes** for each of the five other guidelines
- **Template**: `templates/workflow-template.md`

### `guidelines/implementation-tasks-creation-guidelines.md`

The task generation and archival guideline, containing:
- **Agent-Era Execution Model** (v4.0.0) — agent executes tasks directly
- **ARCHIVAL PROTOCOL** — hook-enforceable completion workflow
- **Task Granularity** — atomic, verifiable tasks
- **Domain-specific testing approaches** — backend (Node.js native) vs. frontend (Vitest + RTL)
- **New v4.0.0 task format** — branch, `WORKFLOW.md` reference, recon phase, `[parallel]` markers, per-task verification

### Example Specifications

See the `examples/` directory for two reference PRDs used to develop and validate the framework:

1. **[Budget Filtering](examples/feature-specification-for-budget-filtering.md)** — business-logic feature with explicit constraints
2. **[Persistent Display CSS Grid Solution](examples/feature-specification-persistent-display-css-grid-solution.md)** — UI/UX optimization using the exploratory approach

These are illustrative, not exhaustive — use them as structural references when drafting your own PRDs.

## The Case for Pseudocode in Specifications

This framework treats **pseudocode as a first-class tool for specification authors**, not as a stylistic flourish. v4.0.2 added reference pseudocode blocks to two guidelines — [system-specification-guidelines.md](guidelines/system-specification-guidelines.md) for state-machine semantics and [implementation-tasks-creation-guidelines.md](guidelines/implementation-tasks-creation-guidelines.md) for the agent's PRD-execution loop. This section explains why.

### What pseudocode is, in this framework

Pseudocode here means **language-neutral, ordered, named-step descriptions of control flow**. It is structurally close to real code — `if`, `for`, `assert`, function calls, return values — but it is not bound to a syntax. A specification author writes it the same way regardless of whether the implementer will reach for TypeScript, Python, Go, Rust, or a state-machine library.

It is **not** a flowchart, a UML sequence diagram, a sketch, or a "whatever feels right." Those are different tools for different jobs. Pseudocode lives in the gap between prose and real code: more rigorous than prose because it commits to ordering and error paths, more flexible than real code because it does not commit to types, libraries, or concurrency primitives.

### Why pseudocode beats prose for the hard parts of a specification

A natural-language sentence can hide an enormous amount of ambiguity behind verbs like "should," "handles," "ensures," and "before." Pseudocode forces those hedges out. Consider the difference between two specifications of the same audit-write rule:

**Prose version**

> "When a run attempt finishes, the audit writer should record the outcome before the workspace is released, and if the audit write fails the system handles the failure appropriately."

**Pseudocode version**

```
function on_run_finished(run, outcome, workspace):
    audit_writer.write(run, outcome.action)         // FAIL-CLOSED
        // if write throws after retries, function aborts here;
        // workspace is NOT released; run stays "active";
        // operator is alerted via /status endpoint.

    transition(run, "active" -> "finished")
    workspace_manager.release(workspace)
```

The prose version permits at least four different correct implementations and at least four different incorrect ones — and the implementer cannot tell which is which from the sentence alone. The pseudocode version closes every ambiguity the prose left open: the audit write happens *before* the state transition, the workspace release is *gated on* the transition completing, and the failure path is explicit ("function aborts here"). An engineer reading the pseudocode knows what to build. An engineer reading the prose has to guess.

### Pseudocode as a forcing function for the author

The most underappreciated value of pseudocode is what it does to the **author**, not the reader. Writing pseudocode is the cheapest possible test of "do I actually understand this design?" If you cannot write the pseudocode, you do not yet understand the system well enough to specify it. The hand reaches for the keyboard, the keyboard demands ordering, and the ordering demands answers to questions the prose was hiding:

- "When the audit write fails, does the workspace get released?"
- "Is the state transition before or after the audit write?"
- "Does the retry loop re-acquire the workspace, or reuse it?"
- "What invariant must hold while we are between states?"

Prose lets the author defer all of those questions. Pseudocode does not. A specification that goes through one round of "try to write the pseudocode" will be tighter than a specification that did not — every time, with no exceptions.

### Pseudocode as a contract, not a translation

Pseudocode in a specification is **not a translation hint** for the implementer. The implementer is not expected to type the pseudocode into a file and run it. The pseudocode is a *contract* — it pins down ordering, error paths, and invariants the implementer must preserve, while leaving the implementer free to choose the language, the data structures, the concurrency primitives, the test framework, and the deployment target.

This distinction matters because it answers the most common objection to pseudocode in specifications: "we already have real code, why write fake code?" The answer is that **real code commits to too much**. Real code in a specification picks a language, a runtime, a set of dependencies, and a style — and every one of those choices imposes constraints on the implementer that the specification did not actually intend. Pseudocode is the right level of detail because it commits to the things that matter (ordering, invariants, error paths) and stays silent about the things that do not (syntax, libraries, types).

### When to write pseudocode in your specifications

The framework recommends pseudocode for:

- **State machines** with non-trivial transitions, error paths, or concurrency rules. The system guideline's reference IssueState block is the canonical example.
- **Algorithms** whose correctness depends on ordering — audit-write-before-transition, lock-acquire-before-read, validate-before-commit.
- **Reconciliation logic** that runs on restart or recovery, where the failure modes are subtle and prose tends to gloss over them.
- **Multi-step transactions** with rollback or compensating actions.
- **Agent-execution loops** — how a tool-using agent consumes a PRD and turns it into committed code. The implementation-tasks guideline's reference loop is the canonical example.

The framework recommends **against** pseudocode for:

- **Simple CRUD endpoints** where the prose Functional Requirement is already unambiguous.
- **UI rendering** where the visual result is the contract and ordering is less load-bearing than visual fidelity.
- **Configuration shapes** — these are better expressed as schemas, not pseudocode.
- **Anything that would require more than ~30 lines of pseudocode** — at that point the design is too detailed for a specification and should move into the implementation itself.

### A reading order for the pseudocode in this repository

If you want to see the framework's pseudocode discipline in action:

1. **Start with the agent-execution loop** in [implementation-tasks-creation-guidelines.md](guidelines/implementation-tasks-creation-guidelines.md). It is short, concrete, and directly visible in every session of every adopting project — it is what the agent does when it consumes a PRD.
2. **Then read the IssueState machine** in [system-specification-guidelines.md](guidelines/system-specification-guidelines.md) under "Reference Pseudocode." It demonstrates how pseudocode resolves the audit-write ordering question that the prose §7.7 hedges around.
3. **Finally, look at how the worked example** [examples/system-specification-ticket-orchestrator-v4-example.md](examples/system-specification-ticket-orchestrator-v4-example.md) populates §5 and §7.7 *without* a pseudocode block — and ask yourself which questions the example leaves open that the guideline's pseudocode block would have closed. That gap is the answer to "should this real PRD have included pseudocode?"

The discipline here is the same as the framework's larger philosophy: **build the fence, then explore the playground**. Pseudocode is one of the strongest fencing materials available — strong enough to stop ambiguity, light enough not to constrain creativity inside the fence.

## What the Framework Aims to Produce

Teams using this framework aim for:
- **Architectural consistency** — clear frontend/backend separation
- **Fewer common AI mistakes** — business logic on the backend by default
- **Shorter specification cycles** — less back-and-forth clarification
- **Focused features** — less scope creep and feature bloat
- **Machine-verifiable acceptance criteria** — tests, not prose judgments
- **Cleaner implementation handoffs** — specifications a junior developer or a subagent can execute
- **Reliable completion** — archival protocol and hook enforcement prevent half-done features

## Why Open Source This?

Product managers, developers, and AI practitioners everywhere struggle with the same challenge: how to harness AI's creative power without losing control of scope and requirements.

This framework builds on open-source work by [Aaron Nichols](https://github.com/adnichols) and [Ryan Carson](https://github.com/snarktank), whose projects explored structured AI collaboration patterns.

By open-sourcing this approach, I hope to:

- **Standardize AI specification practices** across teams and organizations
- **Improve human–AI collaboration** in product development
- **Demonstrate the value of domain-specific patterns** in AI instruction
- **Reduce systematic archival errors** through integrated completion workflows

## Contributing

If you have improvements, variations, or results to share, contributions are welcome.

The goal is simple: make AI assistants better partners in building great software.

---

**Framework Versions:**
- **v4.0.0** — Agent-Era Update: tool-using agents, subagents, hooks, `WORKFLOW.md` convention, System guideline
- **v3.0.0** — Architectural Decision Framework: frontend/backend separation, 5-Question framework, Architectural Audit
- **v2.0.0** — Framework completion: Tasks guideline, ARCHIVAL PROTOCOL, consistent naming
- **v1.x**   — Initial framework, templates, and first examples

*"First, build the fence. Then, explore every inch of the playground. Read the workflow. Let the hooks enforce it."*
