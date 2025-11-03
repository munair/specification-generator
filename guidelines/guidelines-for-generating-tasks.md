# Rule: Generating a Task List from a Feature Specification

## Goal

To guide an AI assistant in creating a detailed, step-by-step task list in Markdown format based on an existing Feature Specification (sometimes referred to as a PRD). The task list should be granular enough to guide a developer through implementation.

## Output

- **Format:** Markdown (`.md`)
- **Location:** `/documentation/tasks/active/`
- **Filename:** `implementing-[feature-name].md` (This file is renamed to `implementation-log-[feature-name].md` upon completion of all tasks).

## ⚠️ ARCHIVAL PROTOCOL ⚠️

**READ THIS FIRST** - If you're archiving a completed task list, follow this checklist EXACTLY:

### When All Implementation Tasks Are Complete:

```bash
# Step 1: Mark ALL tasks complete
# Open the file and change EVERY `- [ ]` to `- [x]`
# You can use this command to verify:
grep -c "- \[ \]" documentation/tasks/active/implementing-[feature-name].md
# ^ This MUST return 0 before proceeding

# Step 2: Rename with implementation-log- prefix
git mv documentation/tasks/active/implementing-[feature-name].md \
     documentation/tasks/active/implementation-log-[feature-name].md

# Step 3: Move to completed directory
git mv documentation/tasks/active/implementation-log-[feature-name].md \
     documentation/tasks/completed/implementation-log-[feature-name].md

# Step 4: Commit the archival
git add documentation/tasks/completed/implementation-log-[feature-name].md
git commit -m "docs(tasks): archive completed implementation log for [feature-name]

All tasks marked complete and archived per guidelines.
Implementation verified in [relevant files/commits]."
```

### Archival Checklist:

Before you commit archival, verify:
- [ ] **ALL** checkboxes changed from `- [ ]` to `- [x]`
- [ ] File renamed from `implementing-` to `implementation-log-`
- [ ] File moved to `documentation/tasks/completed/`
- [ ] Commit message explains what was implemented

### Common Archival Errors (DO NOT MAKE THESE):

❌ Archiving with `implementing-` prefix (WRONG)
✅ Archiving with `implementation-log-` prefix (CORRECT)

❌ Leaving tasks unchecked `- [ ]`
✅ ALL tasks checked `- [x]`

❌ Archiving before implementation complete
✅ Archiving ONLY after feature verified working

---

## Key Terminology

### What "Granular" and "Atomic" Mean

**Granular**: Breaking work into clear, specific steps that ensure **diligence and attention to detail**
- ✅ CORRECT: Identify the specific changes needed to deliver each PRD requirement
- ❌ INCORRECT: Create hundreds of infrastructure tasks beyond PRD scope

**Atomic**: Each task should be independently completable and testable
- ✅ CORRECT: "Add indicator arrows next to ticker symbols" (one focused change)
- ❌ INCORRECT: "Create caching infrastructure" (an entire system not in the PRD)

These terms emphasize **care and thoroughness**, not architectural complexity.

## Process

0.  **Consult Foundational Documents:** Before starting, consult `CLAUDE.md`, `DEVELOPMENT.md`, and `ARCHITECTURE.md` to understand the project's context, conventions, and architectural patterns. The test-driven development (TDD) approach should be pursued whenever possible when defining tasks.
1.  **Receive Feature Specification Reference:** The user will provide a reference to a specific Feature Specification file. Ideally, this document is the output of the process defined in `guidelines-for-clarifying-feature-specifications.md`.
2.  **Analyze Specification:** Read and analyze the functional requirements, user stories, and "Definition of Done" from the specified document.
3.  **Assess Current State:** Review the existing codebase to identify relevant files, components, and utilities that can be leveraged or will require modification.
4.  **Phase 1: Propose High-Level Plan (Interactive Check-in):** Based on the analysis, generate the main, high-level parent tasks required to implement the feature. Present these tasks to the user for validation. This is a critical check-in point to ensure alignment.
    -   **Prompt for User:** "I have generated the high-level tasks based on the Feature Specification. This plan reflects my understanding of the required phases. Please review. Ready to generate the detailed sub-tasks? Respond with 'Go' to proceed."
5.  **Wait for Confirmation:** Pause and wait for the user to respond with "Let's boogie!". This confirms the high-level plan is correct before proceeding.
6.  **Phase 2: Generate Granular Sub-Tasks:** Once the user confirms, break down each parent task into smaller, atomic, and actionable sub-tasks necessary for completion.
7.  **Identify Relevant Files:** Based on the tasks, identify all files that will likely need to be created or modified.
8.  **Save Implementation Plan:** Save the complete, granular task list in the `/documentation/tasks/active/` directory with the filename `implementing-[feature-name].md`.
9.  **Review, Approve, and Commit (CRITICAL CHECKPOINT):**
    - **Present the complete, granular task list (`implementing-[feature-name].md`) to the user for final review and approval.**
    - **Prompt the user:** "I have generated the detailed implementation plan. Please review this complete task list to ensure it accurately reflects the work required. Once you approve, I will commit this plan to the repository before we begin changing any code."
    - **Wait for explicit user approval.**
    - **Commit the approved `implementing-[feature-name].md` file to the repository.** No implementation should begin until this step is complete.

## Interaction Model

The process explicitly requires a pause after generating the high-level parent tasks. This interactive model is superior because it:
- **Ensures Alignment:** It confirms that the AI's high-level understanding matches the user's intent before investing effort in detailed planning.
- **Prevents Wasted Effort:** It allows for early course correction, preventing the generation of a detailed but incorrect plan.
- **Fosters Collaboration:** It makes the process a partnership, mirroring the iterative nature of software development.

## Implementation Discipline

### Complexity Reality Check

Before generating tasks, verify the implementation complexity matches the PRD requirements:

1. **Is the task count proportional to user value?**
   - Simple UI additions (arrows, badges): 5-15 tasks
   - New data integrations: 15-30 tasks
   - Complex multi-component features: 30-50 tasks
   - System refactors: 50+ tasks (requires justification)

2. **Are we solving the PRD problem or building infrastructure?**
   - If PRD doesn't mention performance → No performance monitoring tasks
   - If PRD doesn't mention scale → No batch processing tasks
   - If PRD doesn't mention caching → No cache infrastructure tasks

3. **Task Red Flags (Signs of Over-Engineering):**
   - More infrastructure tasks than feature tasks
   - Tasks for "future-proofing" not in the PRD
   - Generic system building when PRD asks for specific solution
   - Optimization tasks without PRD performance requirements

### The PRD as Implementation Guide

Remember: **The PRD defines both necessary complexity and scope boundaries**
- Tasks MUST cover everything in the PRD
- Tasks MUST NOT add infrastructure beyond the PRD
- When in doubt, prefer modifying existing code over creating new files
- Start with inline implementation; extract only when PRD goals require it

### Implementation Principles to Enforce

When generating tasks, ensure they follow these principles:

1. **Start with the simplest solution that could work**
   - First task should be the most direct implementation
   - Only add complexity tasks if the simple solution fails PRD requirements

2. **No abstraction without concrete need**
   - Don't create generic services for single-use features
   - Don't build "reusable" components unless PRD specifies multiple uses

3. **Inline first, extract later**
   - Initial tasks should add code directly where it's needed
   - Only create separate files/services when code needs reuse

4. **The Three-File Rule**
   - Most features should modify 3-5 existing files maximum
   - Creating more than 3 new files requires PRD justification

Example task evolution:
- ✅ "Add arrow indicators to MarketComparisonDashboard rows"
- ❌ "Create MovingAverageIndicatorService with caching infrastructure"

## Testing Approach

All implementation tasks should be accompanied by comprehensive tests. The testing approach varies by project type:

### **Frontend Testing (React Applications)**

Frontend tests should use the established testing framework and follow these principles:

-   **Testing Framework:** Use Vitest with React Testing Library for component testing
-   **Test Isolation:** Mock external dependencies (APIs, contexts) and focus on component behavior
-   **Comprehensive Test Types:**
    -   **Unit Tests:** Test individual functions, hooks, and utility modules in isolation
    -   **Component Tests:** Test React components with proper context mocking
    -   **Integration Tests:** Test component interactions and context integration
    -   **Edge Case Tests:** Test error states, loading states, and boundary conditions

**Frontend Test Structure:**
```
src/
├── components/ComponentName.tsx
├── components/ComponentName.test.tsx
├── utilities/utilityName.ts
├── utilities/utilityName.test.ts
├── hooks/useCustomHook.ts
└── hooks/useCustomHook.test.ts
```

### **Backend Testing (Lambda Functions)**

Backend tests should be dependency-free and follow these principles:

-   **Dependency-Free:** Tests must rely only on Node.js native modules (`assert`, `fs`, `path`). No external frameworks like Jest or Mocha should be used.
-   **Test Isolation:** Code being tested must be completely isolated from dependencies. Use `require.cache` manipulation to inject mocks *before* the module-under-test is loaded.
-   **Comprehensive Test Types:**
    -   **Unit Tests (`tests/utilities/`, `tests/services/`):** Each utility or service module should have a corresponding unit test file that verifies all functions in isolation. All dependencies must be mocked.
    -   **Integration Tests (`tests/integration/`):** Verify successful orchestration of multiple modules, particularly the main `index.cjs` handler. External system dependencies (APIs) must be mocked.
    -   **Architectural Tests (`tests/architecture/`):** Enforce high-level rules and conventions for the entire codebase, such as circular dependency detection.

## Task Format Example

```markdown
# Implementation Log: [Feature Name]

This document provides a granular, atomic checklist for implementing the new feature as outlined in the `feature-specification-[feature-name].md`.

---

### Phase 1: [First High-Level Task Title]

- [ ] 1.1 [Sub-task description 1.1]
- [ ] 1.2 [Sub-task description 1.2]

### Phase 2: [Second High-Level Task Title]

- [ ] 2.1 [Sub-task description 2.1]
- [ ] 2.2 [Sub-task description 2.2]

---

### Relevant Files

- `index.cjs`
- `utilities/new-utility.cjs`
- `tests/utilities/new-utility.test.cjs`
```

### Phase 3: Feature Completion and Release

Once all tasks in the implementation log are complete and the feature has been deployed and verified:

1. **Final Implementation Commit** - Commit all code changes with comprehensive, educational message summarizing the changes. The commit hash will be used in the completion summary.

2. **Version Update** - Run `npm version <major|minor|patch>` to create version commit and git tag linking the completed work to a specific release.

3. **Archive Task List** - Follow the **ARCHIVAL PROTOCOL** at the top of this document to properly rename, mark complete, and move the implementation log.

4. **Archive Feature Specification** - Move the original `feature-specification-[feature-name].md` to `documentation/specifications/completed/` to keep the primary documentation folder focused on active work.

5. **Completion Summary** (Optional) - Add a `### Completion Summary` section to the bottom of the archived implementation log with:
   - Status confirmation that all tasks were completed
   - Completion date
   - Final commit hash
   - Version tag created by `npm version`
   - Brief one-paragraph summary of the outcome

**For archival details, see the ARCHIVAL PROTOCOL section at the top of this document.**
