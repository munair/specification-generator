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

This repository contains a battle-tested framework that solves both problems through a simple but powerful metaphor:

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
The new guideline uses a section spine adapted from OpenAI's Symphony `SPEC.md`:
1. Problem & Goals
2. System Architecture (component table)
3. Domain Model (with stable IDs)
4. Workflow / Policy File
5. State Machine & Orchestration
6. Safety & Integration
7. Observability & Operations
8. Testing Matrix (per component, with verification commands)
9. Agent Execution Plan
10. Extensibility
11. Non-Goals
12. Open Questions
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

The framework now provides **five specialized guidelines** plus the `WORKFLOW.md` convention:

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

The complete backend framework document containing:
- **Lambda-Specific Patterns** - Serverless architecture best practices
- **Dependency-Free Testing** - Node.js native module testing approach
- **API Design** - REST endpoint patterns and error handling
- **Data Validation** - Input sanitization and transformation
- **DynamoDB Integration** - Authorization and data access patterns
- **Performance Optimization** - Concurrency, caching, cold start mitigation
- **Archival Cross-Reference** - Links to task completion workflow

### `guidelines/frontend-feature-specification-guidelines.md`

The complete frontend framework document containing:
- **Architectural Boundaries Framework (NEW)** - Frontend vs backend decision making
- **5-Question Decision Framework** - Where should work happen?
- **Common Anti-Patterns** - Concrete wrong vs correct examples
- **Architectural Audit Checklist** - Self-verification before finalization
- **Component Architecture** - React/TypeScript patterns
- **State Management** - Context API and reducer patterns
- **Progressive Disclosure** - Complexity management in UIs
- **Accessibility Standards** - WCAG AA compliance requirements
- **Testing Patterns** - Vitest and React Testing Library
- **Performance Optimization** - Bundle size, lazy loading, memoization
- **Archival Cross-Reference** - Links to task completion workflow

### `guidelines/exploratory-feature-specification-guidelines.md`

The creative exploration framework containing:
- **The Spark** - Problem identification without constraints
- **Dream Scenario** - Visualizing ideal outcomes
- **Failure Mode Analysis** - Identifying risks through speculation
- **Metaphor Development** - Finding conceptual frameworks
- **Notes Capture** - Preserving insights for formal specifications
- **Migration Path** - Moving from freeform to systematic PRD
- **Archival Cross-Reference** - Links to task completion workflow

### `implementation-tasks-creation-guidelines.md`

The task generation and archival framework containing:
- **ARCHIVAL PROTOCOL** - Step-by-step completion workflow (lines 13-61)
- **Task Granularity** - Breaking PRDs into atomic tasks
- **Testing Requirements** - Backend vs Frontend testing approaches
- **Phase Planning** - Interactive high-level task approval
- **Completion Workflow** - Marking tasks, renaming files, archiving

### Real-World Validation

See the `examples/` directory for **battle-tested PRDs** that led to successful implementations:

1. **[Budget Filtering](examples/feature-specification-for-budget-filtering.md)** - Complex business logic feature with 5 explicit constraints, delivered in record time
2. **[Persistent Display CSS Grid Solution](examples/feature-specification-persistent-display-css-grid-solution.md)** - UI/UX optimization using creative exploration approach

These examples demonstrate the framework's evolution from theoretical guidelines to **proven methodology** with measurable results.

## Getting Started

### For Backend Features (Lambda Functions, APIs):
1. **Copy the backend guidelines** (`guidelines/backend-feature-specification-guidelines.md`) to your AI assistant context
2. **Use the activation prompt**: "Please follow the Backend Feature Specification guidelines. Feature request: [YOUR REQUEST]"
3. **Let the AI establish boundaries first** before exploring solutions
4. **Watch it create backend-optimized specs** with proper Lambda patterns

### For Frontend Features (React/TypeScript):
1. **Copy the frontend guidelines** (`guidelines/frontend-feature-specification-guidelines.md`) to your AI assistant context
2. **Use the activation prompt**: "Please follow the Frontend Feature Specification guidelines. Feature request: [YOUR REQUEST]"
3. **Let the AI establish boundaries first** before exploring solutions
4. **Watch it create component-focused specs** with proper state management patterns

### For Creative Exploration:
1. **Copy the exploratory guidelines** (`guidelines/exploratory-feature-specification-guidelines.md`) to your AI assistant context
2. **Use when**: Systematic approaches aren't working OR you need innovative solutions
3. **Process**: Freeform exploration → migrate essentials to domain-specific formal spec
4. **Result**: Creative insights captured, then structured for implementation

### Using Manual Templates:
1. **Choose your template**:
   - Simple: For bug fixes, minor enhancements, single features
   - Full: For major features, integrations, strategic initiatives
2. **Fill out sections in order** - Don't skip the boundaries!
3. **Use the quality checklist** before finalizing
4. **Keep for reference** during implementation

## Results You Can Expect

Teams using this framework report:
- **Architectural Consistency (NEW)** - Clear frontend/backend separation
- **Prevention of Common AI Mistakes** - No more frontend calculations
- **Faster specification cycles** - Less back-and-forth clarification
- **More focused features** - Reduced scope creep and feature bloat
- **Better AI collaboration** - Clearer expectations and outputs
- **Improved developer handoffs** - Specifications that junior developers can actually implement
- **Proper Completion Workflow** - Archival protocol prevents incomplete implementations

## Why Open Source This?

Product managers, developers, and AI practitioners everywhere struggle with the same challenge: how to harness AI's creative power without losing control of scope and requirements.

This framework represents dozens of iterations and real-world testing, building on inspiration from innovative work in the open-source community - particularly [Aaron Nichols](https://github.com/adnichols) and [Ryan Carson](https://github.com/snarktank), whose projects demonstrated the power of structured AI collaboration.

By open-sourcing this approach, I hope to:

- **Standardize AI specification practices** across teams and organizations
- **Enable better human-AI collaboration** in product development
- **Demonstrate the power of domain-specific patterns** in AI instruction
- **Prevent systematic archival errors** through integrated completion workflows

## Contributing

This framework is the result of practical experimentation with AI-assisted product development. If you have improvements, variations, or real-world results to share, contributions are welcome.

The goal is simple: make AI assistants better partners in building great software.

---

**Framework Versions:**
- **v4.0.0**: Agent-Era Update — tool-using agents, subagents, hooks, `WORKFLOW.md` convention, system-level guideline
- **v3.0.0**: Architectural Decision Framework — frontend/backend separation
- Backend Guidelines: Optimized for serverless Lambda architecture
- Frontend Guidelines: Optimized for React/TypeScript with architectural boundaries
- Exploratory Guidelines: Constraint-free creative ideation
- System Guidelines (v4.0.0): Multi-component services with state machines and observability

*"First, build the fence. Then, explore every inch of the playground."*
*"Read the workflow. Let the hooks enforce it. Delegate the recon. Keep the context clean."* (v4.0.0)
