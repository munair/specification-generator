# Guidelines Directory

This directory contains the complete framework for generating high-quality feature specifications, organized by domain and approach.

> **v4.0.0**: The framework now contains **six guidelines** plus the `WORKFLOW.md` convention. New additions: `system-specification-guidelines.md` (multi-component services) and `workflow-file-guidelines.md` (in-repository policy contract). All existing guidelines have been updated for the agent-era execution model.

## Domain-First Organization

Guidelines are now organized by **domain** (backend vs frontend) and **approach** (systematic vs exploratory) for maximum clarity and precision.

### Why Domain-First?

**Problem**: Generic guidelines try to serve all contexts, resulting in vague patterns that don't match real architectures.

**Solution**: Domain-specific guidelines provide:
- **Immediate Clarity** - Filename tells you exactly when to use it
- **Precise Patterns** - Backend uses Node.js native testing; Frontend uses Vitest
- **Better Sorting** - Related guidelines grouped alphabetically
- **Future-Proof** - Easy to add new domains (mobile, embedded, desktop, etc.)

## The Framework Guidelines

This directory contains **six essential guidelines** that form the complete feature development framework:

### PRD Generation Guidelines (4)
These four guidelines help you create comprehensive Product Requirements Documents:

#### `backend-feature-specification-guidelines.md`
**Domain**: Lambda functions, APIs, data processing, backend services

**For Use With**:
- AWS Lambda functions
- REST API endpoints
- Data transformation services
- Background job processors
- Serverless architectures

**Key Features**:
- Dependency-free testing patterns (Node.js `assert`, `fs`, `path` only)
- DynamoDB integration and authorization patterns
- API error handling and validation
- Performance optimization (concurrency, cold starts, caching)
- Service integration architecture
- Quick Start vs Full PRD structure
- Archival cross-reference to completion workflow

**Testing Approach**: Unit tests using Node.js native modules, integration tests with mocked dependencies, architectural tests for circular dependency detection.

**When to Use**: Any backend system, serverless function, API endpoint, or data pipeline development.

---

#### `frontend-feature-specification-guidelines.md`
**Domain**: React/TypeScript applications, UI components, user interfaces

**For Use With**:
- React web applications
- Trading dashboards and interfaces
- Component libraries
- User-facing features
- State-managed UIs

**Key Features**:
- **Architectural Boundaries Framework (NEW in v3.0.0)** - Frontend vs backend decision making
- **5-Question Decision Framework** - Systematic work placement
- **Common Anti-Patterns** - Concrete wrong vs correct examples
- **Architectural Audit Checklist** - Self-verification before finalization
- **Mandatory [Backend/Frontend] prefix** in functional requirements
- Component-based architecture patterns
- React Context API and reducer patterns
- Progressive disclosure principles
- WCAG AA accessibility compliance
- Vitest + React Testing Library patterns
- Performance optimization (bundle size, lazy loading, memoization)
- Quick Start vs Full PRD structure
- Archival cross-reference to completion workflow

**Testing Approach**: Component tests with React Testing Library, integration tests with context mocking, edge case coverage for UI states.

**When to Use**: Any React/TypeScript feature, UI component, dashboard improvement, or user-facing functionality requiring frontend/backend work separation.

---

#### `exploratory-feature-specification-guidelines.md`
**Domain**: Creative ideation, novel solutions, constraint-free thinking

**For Use With**:
- Brainstorming sessions
- Novel feature exploration
- Strategic initiatives requiring innovation
- When systematic approaches aren't producing results
- Creative rescue scenarios

**Key Features**:
- The Spark (unconstrained problem identification)
- Dream Scenario visualization
- Failure Mode analysis through speculation
- Metaphor development for conceptual frameworks
- Notes capture for migration to formal specs
- Migration path to domain-specific PRD
- Archival cross-reference to completion workflow

**Process**: Freeform exploration → capture insights → migrate to Backend or Frontend guidelines for formal PRD.

**When to Use**: When you need creative breakthrough, systematic thinking isn't working, or exploring truly novel solutions.

---

#### `system-specification-guidelines.md` (NEW in v4.0.0)
**Domain**: Multi-component services, orchestrators, daemons, long-running systems
**For Use With**:
- Agent orchestration services (Symphony-style)
- Polling daemons and schedulers
- Cross-Lambda coordination layers
- Any system with ≥ 3 communicating components
- Services with non-trivial state machines
**Key Features**:
- Symphony-inspired section spine (Problem → Architecture → Domain Model → State Machine → Safety → Observability → Testing Matrix)
- Explicit component table with responsibility, inputs, outputs, lifecycle
- Stable identifier discipline (internal IDs vs. display IDs)
- Forward-compatible schema (unknown keys ignored with a warning)
- Per-component testing matrix with verification commands
- Designed for subagent-per-component parallel implementation
- Explicit "Extensibility" section as first-class requirement
**Testing Approach**: Per-component unit tests + integration tests + real-system smoke test, all enforced by hooks on the full testing matrix.
**When to Use**: Whenever the Backend or Frontend guideline feels too small for what you're building — specifically, when you're specifying a service rather than a feature.
**When NOT to Use**: Single Lambda, single React component, or any feature that fits in one file. Use Backend or Frontend instead.
---

### Task Generation Guideline (1)

This guideline transforms approved PRDs into actionable implementation task lists:

#### `implementation-tasks-creation-guidelines.md`
**Purpose**: Convert feature specifications into granular, atomic task lists for implementation

**For Use With**:
- Approved feature specifications (any domain)
- Implementation planning
- Task tracking and completion
- Archival workflow management

**Key Features**:
- ⚠️ **ARCHIVAL PROTOCOL** (lines 13-61) - Critical completion workflow
- Granular task breakdown methodology
- Interactive check-in process (high-level plan approval before detailed tasks)
- Implementation discipline (complexity reality checks, over-engineering prevention)
- Domain-specific testing approaches (Backend vs Frontend)
- Three-File Rule and inline-first principles
- Executable bash commands for archival verification
- Task format examples and completion workflow

**Testing Standards**:
- **Backend**: Node.js native modules only (`assert`, `fs`, `path`)
- **Frontend**: Vitest + React Testing Library with component mocking

**Critical Protocol**: Contains the **ARCHIVAL PROTOCOL** that all three PRD guidelines reference for proper task completion, renaming, and archival.

**When to Use**: After PRD approval and before implementation begins. This guideline ensures systematic, well-documented implementation tracking.

**Output**: `/documentation/tasks/active/implementing-[feature-name].md`

---

### Convention Guideline (1) — NEW in v4.0.0
#### `workflow-file-guidelines.md`
**Purpose**: Define and integrate the `WORKFLOW.md` in-repository policy file.
**For Use With**: Any project where a coding agent will operate across multiple features.
**Key Features**:
- Defines what belongs in `WORKFLOW.md` (test commands, branch policy, commit style, hook configuration, subagent delegation defaults, archival reference)
- Defines what does NOT belong in `WORKFLOW.md` (feature-specific requirements, one-off instructions)
- Forward compatibility rule: unknown keys ignored with a warning
- Reference template at `templates/workflow-template.md`
**When to Use**: Once per project, at repository setup time. Then reference from every PRD.

---

### Validation Vocabulary (1) — NEW in v4.0.2

#### `specification-validation-vocabulary.md`

**Purpose**: A named failure taxonomy for specification reviews. Every failure mode a reviewer (human or subagent) can flag when auditing a PRD, system specification, task list, or `WORKFLOW.md` has a stable identifier here, a one-line description, the guideline and section it belongs to, an example of the failure, and an example of the fix. Adapted from OpenAI's Symphony `SPEC.md` §5.5 error-taxonomy pattern.

**For Use With**: Any specification review. The Final Audit section in each PRD guideline now references vocabulary codes in parentheses after each red-flag bullet.

**Key Features**:
- Cross-guideline codes (apply to any PRD): `missing_non_goals`, `fr_not_verifiable`, `workflow_content_restated`, `acceptance_criteria_not_measurable`, etc.
- Backend-specific codes: `missing_error_envelope`, `unspecified_idempotency`, `iam_overreach`, `streaming_in_backend_prd`, `audit_in_backend_prd`, etc.
- Frontend-specific codes: `frontend_calculates`, `sequential_hydration`, `frontend_streaming_spec`, `spanning_requirement_not_split`, etc.
- System-specific codes: `missing_component_table`, `missing_state_machine`, `audit_semantics_not_chosen`, `missing_test_matrix_row`, `streaming_no_backpressure_policy`, etc.
- Tasks and Workflow-file codes: `task_no_verification_step`, `missing_parallel_markers`, `missing_workflow_file`, etc.
- Conformance profiles (Core / Extension / Integration) for tiering audits by specification type
- Forward-compatibility rule: unknown codes in audit output are ignored with a warning, never rejected

**When to Use**: Every time a reviewer (human or subagent) flags a finding. Cite the code; the code links to the guideline section that owns it.

---

## Decision Matrix: Which Guideline to Use?

| Your Need                                  | Use This Guideline     | Then                                                 |
|--------------------------------------------|------------------------|------------------------------------------------------|
| Lambda function feature                    | Backend                | Generate PRD → implement                             |
| React component feature                    | Frontend               | Generate PRD → implement                             |
| API endpoint creation                      | Backend                | Generate PRD → implement                             |
| Dashboard UI improvement                   | Frontend               | Generate PRD → implement                             |
| Creative brainstorming                     | Exploratory            | Explore → migrate to Backend/Frontend/System         |
| Systematic approach isn't working          | Exploratory            | Creative rescue → formalize                          |
| Novel feature, unclear domain              | Exploratory            | Define → choose Backend/Frontend/System              |
| Bug fix (backend)                          | Backend                | Use Quick Start variant                              |
| Bug fix (frontend)                         | Frontend               | Use Quick Start variant                              |
| **Multi-component service / daemon**       | **System (v4.0.0)**    | **State machine, concurrency, observability first** |
| **Agent orchestrator / poller**            | **System (v4.0.0)**    | **Workflow file, subagent-per-component, matrix**    |
| **Cross-Lambda coordination layer**        | **System (v4.0.0)**    | **≥ 3 components; isolation over coordination**      |
| **Streaming / real-time service**          | **System (v4.0.0)**    | **Owns SSE/WS, backpressure, audit**                 |
| **Audit-sensitive or compliance feature**  | **System (v4.0.0)**    | **Owns log schema, retention, redaction**            |
| **New repository setup** (one-time)        | **Workflow File (v4.0.0)** | **Author `WORKFLOW.md` and wire reference hooks** |
| Complex system integration                 | Backend, Frontend, or System | Choose by scope: one component → B/F; multi → S |

## Complete Specification Lifecycle

### 1. PRD Generation (Use PRD Guidelines)
Choose appropriate guideline (Backend, Frontend, or Exploratory) → AI establishes boundaries → generates comprehensive PRD

**Critical Checkpoint**: Review, approve, and commit PRD before implementation

**Guidelines**: `backend-feature-specification-guidelines.md`, `frontend-feature-specification-guidelines.md`, or `exploratory-feature-specification-guidelines.md`

### 2. Task Breakdown (Use Task Generation Guideline)
Use `implementation-tasks-creation-guidelines.md` to transform approved PRD into granular, atomic implementation tasks

**Process**: High-level plan approval → detailed sub-task generation → implementation tracking

**Output**: `/documentation/tasks/active/implementing-[feature-name].md`

### 3. Implementation
Execute tasks with full test coverage and documentation

### 4. Archival
Follow **ARCHIVAL PROTOCOL** (see below)

## The Archival Protocol

**All three PRD guidelines** now include cross-references to the **ARCHIVAL PROTOCOL** in `implementation-tasks-creation-guidelines.md` (lines 13-61).

### Why This Matters

**Problem**: Systematic archival errors occurred because the completion workflow was disconnected from PRD creation.

**Solution**: Every PRD guideline now references the archival protocol, creating a closed loop from planning to completion.

### Archival Requirements

When implementation is complete:
1. **Mark ALL tasks** complete (`- [ ]` → `- [x]`)
2. **Rename file** from `implementing-` to `implementation-log-`
3. **Move to** `documentation/tasks/completed/`
4. **Commit** with descriptive message explaining what was implemented

**Verification Command**:
```bash
grep -c "- \[ \]" documentation/tasks/active/implementing-[feature-name].md
# ^ Must return 0 before proceeding
```

See `implementation-tasks-creation-guidelines.md` lines 13-61 for complete executable archival commands.

## How to Use These Guidelines

### For AI-Assisted PRD Generation:

1. **Identify domain** (Backend, Frontend, or Exploratory)
2. **Copy guideline** to AI assistant context
3. **Use activation prompt**: "Please follow the [Backend/Frontend/Exploratory] Feature Specification guidelines. Feature request: [YOUR REQUEST]"
4. **Let AI establish boundaries** before exploring solutions
5. **Review generated PRD** for completeness
6. **Approve and commit** before implementation begins

### For Manual PRD Creation:

1. **Choose guideline** based on domain
2. **Read through structure** to understand required sections
3. **Fill sections in order** (don't skip boundaries!)
4. **Use archival cross-reference** to understand completion workflow
5. **Keep PRD as implementation reference**

## Testing Standards by Domain

### Backend Testing (Node.js Native)
- **Unit Tests**: Use `assert`, `fs`, `path` only
- **Integration Tests**: Mock external dependencies via `require.cache`
- **Architectural Tests**: Detect circular dependencies
- **Location**: `tests/utilities/`, `tests/services/`, `tests/integration/`, `tests/architecture/`

### Frontend Testing (Vitest + RTL)
- **Component Tests**: React Testing Library with context mocking
- **Integration Tests**: Multi-component interaction testing
- **Edge Cases**: Loading states, error states, boundary conditions
- **Location**: Co-located with components (`ComponentName.test.tsx`)

### Exploratory (No Specific Tests)
- Exploratory phase doesn't produce implementation
- Tests are defined when migrating to Backend/Frontend PRD

## Framework Philosophy

All guidelines follow the core metaphor:

> **"First, build the fence. Then, explore every inch of the playground."**

**Phase 1: Boundaries** (The Fence)
- Establish explicit non-goals
- Define phasing and constraints
- Identify integration points

**Phase 2: Creativity** (The Playground)
- Maximize thoroughness within boundaries
- Explore all possibilities in scope
- Generate comprehensive requirements

This approach prevents scope creep while enabling creative, complete solutions.

## Guidelines Maintenance

All six guidelines now include:
- Agent-Era Execution Model section (v4.0.0)
- Domain-first naming convention
- Quick Start vs Full Process variants where applicable (Backend, Frontend, System)
- Testing approach specific to domain
- Integration with task generation workflow
- Cross-references to the ARCHIVAL PROTOCOL in the Tasks guideline

**Framework Structure**:
- **4 PRD Generation Guidelines**: Backend, Frontend, Exploratory, System (v4.0.0)
- **1 Task Generation Guideline**: Transforms PRDs into implementation tasks
- **1 Convention Guideline**: `workflow-file-guidelines.md` — in-repository policy contract (v4.0.0)
- **Cross-References**: All PRD guidelines reference the ARCHIVAL PROTOCOL

**Last Updated**: Monday, April 13, 2026
**Framework Version**: v4.0.0 — Agent-Era Update

---

### Quick Reference Commands (v4.0.0)

```bash
# Backend PRD activation — references WORKFLOW.md, uses subagents
"Follow guidelines/backend-feature-specification-guidelines.md for a Lambda function.
Read WORKFLOW.md at the repository root first. Use Explore subagents for codebase-wide research.
Feature request: [REQUEST]"

# Frontend PRD activation
"Follow guidelines/frontend-feature-specification-guidelines.md for a React component.
Read WORKFLOW.md at the repository root first. Use Explore subagents for component-tree audits.
Feature request: [REQUEST]"

# System-level spec activation (NEW in v4.0.0)
"Follow guidelines/system-specification-guidelines.md for a multi-component service.
Read WORKFLOW.md at the repository root first. Use a Plan subagent to review the draft
architecture before finalizing. System description: [DESCRIPTION]"

# Exploratory PRD activation — with recon subagents
"Follow guidelines/exploratory-feature-specification-guidelines.md. Spawn an Explore
subagent first to survey the codebase for adjacent prior art. Topic: [REQUEST]"

# Task generation from approved PRD
"Follow guidelines/implementation-tasks-creation-guidelines.md for PRD at [PRD FILE].
Spawn recon subagents for the PRD's Delegatable Research before proposing the plan."

# Repository setup (NEW in v4.0.0 — one-time per project)
"Follow guidelines/workflow-file-guidelines.md. Copy templates/workflow-template.md
to the repository root as WORKFLOW.md and customize for this project. Then wire up the
reference hooks in .claude/settings.json."

# Archival verification (hook-enforced in v4.0.0)
grep -c "- \[ \]" documentation/tasks/active/implementing-[feature-name].md
# ^ Must return 0 before archiving. The Stop hook enforces this automatically
#   if wired up per templates/workflow-template.md.
```
