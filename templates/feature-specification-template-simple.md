# Feature Specification: [Feature Name]

---
**Domain**: [Backend | Frontend | Exploratory]
**Guideline**: Use `[backend|frontend|exploratory]-feature-specification-guidelines.md`
**Testing Approach**: [Node.js native | Vitest + RTL | TBD]
---

## Overview
[One paragraph describing what this feature does and why it's needed. Focus on the problem being solved, not the implementation details.]

## Goals
- [Primary objective - what key outcome will this achieve?]
- [Secondary objective]
- [Measurable goal with specific target]

## Functional Requirements
FR1: The system must [specific behavior or capability]
FR2: The system must [another specific requirement]
FR3: The system must [additional requirement]
FR4: The system must NOT [prohibited behavior or constraint]
FR5: The system must NOT [scope boundary]

## Non-Goals
- [Explicitly state what this feature will NOT do]
- [Common misconception about scope]
- [Future enhancement deferred to later phase]
- [Another explicit boundary]
- [Fifth NOT to prevent scope creep]

## Testing Considerations

### Test Scenarios
- [Critical user flow that must work]
- [Edge case or error condition to handle]
- [Performance or scale consideration]
- [Data validation scenario]

### Testing Approach
- **Backend**: Node.js native modules (`assert`, `fs`, `path`)
- **Frontend**: Vitest + React Testing Library
- **Location**: [Where tests will live based on domain]

## Success Metrics
- [Primary metric]: [Definition, target, measurement window]
- [User adoption metric]: [Expected usage within timeframe]
- [Quality metric]: [Error rate, performance target, etc.]

## Archival Cross-Reference

**IMPORTANT**: After implementation, follow the **ARCHIVAL PROTOCOL** in `guidelines-for-generating-tasks.md`:

1. Mark ALL tasks complete (`- [ ]` → `- [x]`)
2. Rename from `implementing-` to `implementation-log-`
3. Move to `/documentation/tasks/completed/`

---

## Quick Checklist
☐ Problem clearly defined
☐ Scope boundaries explicit (5+ NOTs)
☐ Testing approach specified
☐ Success metrics measurable
☐ Archival workflow understood