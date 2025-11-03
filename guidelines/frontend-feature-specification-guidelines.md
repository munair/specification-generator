# Rule: Feature Specification / Product Requirements Document (PRD)

## Overview
The framework explicitly tells an AI Assistant: "First, build the fence. Then, explore every inch of the playground."

---

## 1. Application Process

1. **Receive Prompt** – User provides a feature request
2. **Determine Scope** – Assess if this needs Quick Start or Full Process (see below)
3. **Clarify Before Writing** – Ask clarifying questions *only for details not already provided*
   - Skip questions clearly addressed in the prompt
   - Always verify boundaries, testing approach, and failure handling
4. **Generate PRD** – Create a comprehensive Markdown PRD using the appropriate structure
5. **Save PRD** – Save as `feature-specification-[feature-name].md` in `/documentation/`
6. **Review & Approve (Critical Checkpoint)** 
   - Present draft for explicit user approval
   - Do not proceed until approved
7. **Commit** – Only after approval, commit the PRD
8. **Begin Implementation** – Do not generate tasks until PRD is committed
9. **Archive Completed PRD** – After successful implementation and deployment, move PRD to `/documentation/specifications/` to maintain clean project organization

### When to Use Quick Start vs Full Process
- **Quick Start:** Bug fixes, minor enhancements, single-purpose utilities, technical debt
- **Full Process:** New user-facing features, system integrations, data handling changes, anything with external dependencies

---

## 2. Clarifying Questions Framework

### Essential (Always Verify If Not Clear)
- **Boundaries:** What should this feature *not* do? Any explicit non-goals?
- **Phasing:** Should this be broken into phases or iterations?
- **Integration:** How does this fit with existing features or systems?
- **Failure & Recovery:** How should rollback, data migration failures, or partial deployments be handled?
- **Testing Requirements:** What critical behaviors, user flows, and edge cases must be tested?
- **Success Metrics:** How will we measure success (both quantitative and qualitative)?

**For Complex Features - Boundary Checklist:**
- ☐ Have we listed 3-5 explicit things this feature will NOT do?
- ☐ Have we defined Phase 1 (minimal viable) vs Phase 2+ (future enhancements)?
- ☐ Have we identified all system integrations and dependencies?
- ☐ Have we outlined clear acceptance criteria?
- ☐ Have we defined success metrics with failure thresholds?

### Scope Control (Ask When Needed)
- **Problem/Goal:** What specific problem does this solve for users?
- **Target User:** Who is the primary user of this feature?
- **Core Functionality:** What are the most important actions users should be able to perform?

### Context-Dependent (Ask Based on Feature Type)
- **User Stories:** For user-facing features
- **Data Requirements:** For data-processing features
- **Design/UX:** For UI components
- **Technical Constraints:** For system-level changes
- **Performance Requirements:** For high-traffic or resource-intensive features

### Creative Exploration (Use When Feature Has Strategic Impact)
**Skip for:** Bug fixes, technical debt, minor UI adjustments, internal tools
**Use for:** New user experiences, competitive differentiators, novel workflows

Consider these prompts:
- **Dream Scenario:** "If this wildly exceeded expectations, what would that look like?"
- **Bold Vision:** "What's the most ambitious version we could imagine?"
- **Failure Modes:** "What could go spectacularly wrong?"
- **Metaphor:** "What analogy captures the essence of this feature?"
- **Delight Factors:** "What unexpected touches could make this memorable?"

---

## 3. PRD Structure

### Quick Start PRD (Minimal)
1. **Overview** – One paragraph: what and why
2. **Goals** – Bullet list of objectives
3. **Functional Requirements** – Numbered list of must-haves
4. **Non-Goals** – What it won't do
5. **Testing Considerations** – Key test scenarios
6. **Success Metrics** – How we'll measure success

### Full PRD (Comprehensive)
1. **Introduction/Overview** – Feature description and problem it solves
2. **Goals** – Specific, measurable objectives
3. **Vision & Creative Considerations** *(Optional)* – Aspirational scenarios, metaphors, delight factors
4. **User Stories** – Narrative descriptions of feature usage
5. **Functional Requirements** – Numbered list (e.g., "FR1: The system must...")
6. **Non-Goals (Out of Scope)** – Explicit exclusions to manage scope
7. **Design Considerations** *(Optional)* – UI/UX requirements, mockups
8. **Technical Considerations** *(Optional)* – Architecture, dependencies, constraints
9. **Failure & Recovery Strategy** – Rollback plan, error handling, data recovery
10. **Testing Considerations** – Unit, integration, edge cases, critical user flows
11. **Success Metrics** – Quantitative and qualitative measures
12. **Open Questions** – Unresolved items needing future clarification

---

## 4. Guiding Principles

- **Boundaries First, Creativity Second** – Define the fence before exploring the playground
- **Right-Size the Effort** – Match PRD depth to feature complexity
- **Skip Redundant Questions** – Don't re-ask what's already clearly stated
- **Every Requirement Traces to a Need** – No features without clear user benefit
- **Write for Junior Developers** – Explicit, unambiguous, jargon-free
- **Surface All Assumptions** – Document or question them, never hide them
- **Testing is Mandatory** – Every feature must define test scenarios

### Supporting Documentation Guidelines
- **User Guides** – Create for all user-facing features to ensure adoption and proper usage
- **Testing Procedures** – Document specialized testing approaches (accessibility, performance, etc.)
- **Rollback Plans** – Required for complex features that could impact production stability
- **Lessons Learned** – Capture insights from challenging implementations for knowledge transfer
- **Implementation Logs** – Archive detailed task completion records using `implementation-log-[feature].md` naming convention

### PRD Lifecycle Management
- **Active Development** – PRDs remain in `/documentation/` during feature development
- **Completed Features** – Successfully implemented PRDs are archived to `/documentation/specifications/`
- **Supporting Documentation** – Feature-related documents organized in semantic folders:
  - `/documentation/information/` – User guides and end-user documentation
  - `/documentation/testing/` – Testing methodologies and procedures
  - `/documentation/rollbacks/` – Emergency rollback procedures and plans
  - `/documentation/lessons/` – Educational materials and lessons learned
  - `/documentation/tasks/completed/` – Implementation logs (using `implementation-log-[feature].md` naming)
- **Organizational Benefits** – Semantic folder structure improves discoverability, separates content by audience and purpose, maintains project documentation standards across the complete development lifecycle

---

## 5. Archival Cross-Reference

**IMPORTANT**: When archiving implementation logs, follow the **ARCHIVAL PROTOCOL** in `implementation-tasks-creation-guidelines.md`.

Key requirements:
1. Mark ALL tasks complete (`- [ ]` → `- [x]`)
2. Rename from `implementing-` to `implementation-log-`
3. Move to `documentation/tasks/completed/`

**DO NOT** attempt to archive without following the protocol checklist.

---

## 6. Output Requirements

- **Format:** Markdown (`.md`)
- **PRD Location:** `/documentation/` (during development), `/documentation/specifications/` (after completion)
- **PRD Filename:** `feature-specification-[feature-name].md`
- **Supporting Documentation Structure:**
  - **User Guides:** `/documentation/information/user-guide-[feature-name].md`
  - **Testing Procedures:** `/documentation/testing/[test-type]-testing-[feature-name].md`
  - **Rollback Plans:** `/documentation/rollbacks/rollback-plan-[feature-name].md`
  - **Lessons Learned:** `/documentation/lessons/[feature-name]-lessons-learned.md`
  - **Implementation Logs:** `/documentation/tasks/completed/implementation-log-[feature-name].md`
- **Archival Process:** Move completed PRDs and organize all supporting documentation in semantic folders to maintain clean project structure and optimize discoverability by document type and target audience

---

## 7. Examples

### Quick Start Example:
```markdown
# Feature Specification: Add CSV Export to Reports

## Overview
Users need to export report data for use in Excel and other tools. This feature adds a "Download CSV" button to all report pages.

## Goals
- Enable data export from any report view
- Maintain current filtering/sorting in exported data
- Support reports up to 10,000 rows

## Functional Requirements
FR1: System must add "Download CSV" button to report toolbar
FR2: CSV must include all visible columns in current order
FR3: Export must respect current filters and sorting
FR4: System must show progress indicator for exports over 1000 rows

## Non-Goals
- Custom column selection for export
- Other formats (Excel, PDF)
- Scheduled/automated exports

## Testing Considerations
- Export with various filter combinations
- Large dataset performance (10k rows)
- Special characters in data
- Empty report states

## Success Metrics
- 80% of users who view reports use export within first month
- Export completes in <5 seconds for typical reports (<1000 rows)
```

### Full PRD Structure Example:
*(Show just the headers for space)*
```markdown
# Feature Specification: Customer Portal Dashboard

## Introduction/Overview
## Goals
## Vision & Creative Considerations
## User Stories
## Functional Requirements
## Non-Goals (Out of Scope)
## Design Considerations
## Technical Considerations
## Failure & Recovery Strategy
## Testing Considerations
## Success Metrics
## Open Questions
```

---

## 8. Feature Tagging Strategy

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

### Benefits:
- **Searchability**: Easy to find specific feature implementations
- **Documentation**: Tags serve as implementation markers
- **Technical History**: Preserves solution approaches over time
- **Team Communication**: Clear feature identification
- **Version Management**: Proper separation of concerns

### Implementation Journey Best Practices:
- **Freeform → Formal → Implementation Flow**: Start with creative exploration, migrate to structured requirements, implement with iterative refinement
- **Testing Alignment Strategy**: Update tests to match new component structures, mock context data with complete objects
- **Documentation Evolution**: Keep freeform exploration for creative history, archive formal specifications after completion