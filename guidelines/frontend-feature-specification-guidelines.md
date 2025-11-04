# Rule: Feature Specification / Product Requirements Document (PRD)

## Overview
The framework explicitly tells an AI Assistant: "First, build the fence. Then, explore every inch of the playground."

**NEW**: This framework now includes explicit architectural guidance to prevent frontend/backend responsibility misplacement.

---

## 1. Application Process

1. **Receive Prompt** – User provides a feature request
2. **Determine Scope** – Assess if this needs Quick Start or Full Process (see below)
3. **Clarify Before Writing** – Ask clarifying questions *only for details not already provided*
   - Skip questions clearly addressed in the prompt
   - Always verify boundaries, testing approach, and failure handling
   - **NEW**: Always verify architectural placement (frontend vs backend)
4. **Generate PRD** – Create a comprehensive Markdown PRD using the appropriate structure
5. **Save PRD** – Save as `feature-specification-[feature-name].md` in `/documentation/specifications/active/`
6. **Review & Approve (Critical Checkpoint)** 
   - Present draft for explicit user approval
   - Do not proceed until approved
7. **Commit** – Only after approval, commit the PRD
8. **Begin Implementation** – Do not generate tasks until PRD is committed
9. **Archive Completed PRD** – After successful implementation and deployment, move PRD to `/documentation/specifications/completed/` to maintain clean project organization

### When to Use Quick Start vs Full Process
- **Quick Start:** Bug fixes, minor enhancements, single-purpose utilities, technical debt
- **Full Process:** New user-facing features, system integrations, data handling changes, anything with external dependencies

---

## 2. Architectural Boundaries: Frontend vs Backend Decision Framework

**CRITICAL**: Before writing functional requirements, determine where each piece of work belongs.

### Backend Responsibilities (AWS Lambda)
The backend should handle:
- ✅ **Business Logic**: Calculations, algorithms, data transformations
- ✅ **Data Aggregations**: Combining multiple data sources, statistical calculations
- ✅ **Heavy Computations**: Greeks calculations, P/C ratios, volatility metrics, moving averages
- ✅ **Multi-Symbol Operations**: Comparisons requiring multiple API calls
- ✅ **Data Normalization**: Standardizing formats, cleaning raw data
- ✅ **Security-Sensitive Operations**: Authentication, authorization, rate limiting
- ✅ **Caching & Optimization**: Response caching, data pre-processing
- ✅ **External API Integration**: Schwab API calls, data fetching

### Frontend Responsibilities (React)
The frontend should handle:
- ✅ **UI State Management**: Component state, user interactions
- ✅ **Presentation Logic**: Formatting for display, sorting, filtering for UX
- ✅ **Progressive Disclosure**: Showing/hiding UI elements
- ✅ **Client-Side Validation**: Input validation, real-time feedback
- ✅ **Visual Calculations**: Chart rendering, table pagination
- ✅ **User Preferences**: UI settings, theme, layout preferences

### Decision Framework: Where Should This Work Happen?

**Ask these questions for EVERY functional requirement:**

1. **"Does this require data from multiple sources?"**
   - YES → Backend aggregation
   - NO → Consider other factors

2. **"Is this a calculation or transformation?"**
   - Simple formatting for display → Frontend
   - Statistical calculation, aggregation, or complex math → Backend

3. **"Will multiple clients (future mobile app, API consumers) need this?"**
   - YES → Backend (DRY principle)
   - NO → Consider other factors

4. **"Does this affect performance?"**
   - Heavy computation → Backend
   - UI responsiveness → Frontend optimization

5. **"Is this security-sensitive or rate-limited?"**
   - YES → Always backend
   - NO → Consider other factors

### Common Anti-Patterns to Avoid

❌ **DON'T**: Write PRD that says "Frontend calculates P/C ratio from options data"
✅ **DO**: Write PRD that says "Backend includes P/C ratio in response payload"

❌ **DON'T**: "Frontend fetches multiple symbols and compares Greeks"
✅ **DO**: "Backend multi-symbol comparison endpoint returns normalized comparison data"

❌ **DON'T**: "Frontend aggregates volume data across expirations"
✅ **DO**: "Backend includes aggregated volume metrics in expiration summary"

❌ **DON'T**: "Frontend calculates moving averages from price history"
✅ **DO**: "Backend includes SMA-20/50/200 in market data response"

### Options Trading Context Examples

**Scenario: Add expiration-specific P/C ratios**

❌ **Wrong PRD**:
```
FR1: Frontend calculates P/C ratio from callExpDateMap and putExpDateMap
FR2: Frontend displays ratio in PersistentOrderDisplay component
```

✅ **Correct PRD**:
```
FR1: Backend: Calculate expiration-specific P/C ratios during options chain processing
FR2: Backend: Include putCallRatio field in each expiration's summary data
FR3: Frontend: Display pre-calculated putCallRatio from backend response
```

**Scenario: Multi-symbol comparison dashboard**

❌ **Wrong PRD**:
```
FR1: Frontend makes separate API calls for each symbol
FR2: Frontend normalizes and compares Greeks data
FR3: Frontend calculates relative strength metrics
```

✅ **Correct PRD**:
```
FR1: Backend: Provide multi-symbol comparison endpoint accepting array of symbols
FR2: Backend: Return normalized comparison data with relative metrics pre-calculated
FR3: Frontend: Display comparison data from single API response
```

### When Frontend Work is Appropriate

**Client-side filtering for UX**:
```
✅ FR1: Frontend: Filter strike table based on user's delta preference
✅ FR2: Frontend: Implement progressive disclosure for unaffordable strikes
✅ FR3: Frontend: Sort table by user-selected column
```

**User preference management**:
```
✅ FR1: Frontend: Persist user's preferred liquidity threshold in localStorage
✅ FR2: Frontend: Remember last selected account between sessions
✅ FR3: Frontend: Save user's dashboard tab preference
```

---

## 3. Clarifying Questions Framework

### Essential (Always Verify If Not Clear)
- **Boundaries:** What should this feature *not* do? Any explicit non-goals?
- **Phasing:** Should this be broken into phases or iterations?
- **Integration:** How does this fit with existing features or systems?
- **Architectural Placement:** What work belongs on backend vs frontend? (See Architectural Boundaries section)
- **API Design:** Does this require new backend endpoints or modifications to existing ones?
- **Data Flow:** Where does data transformation happen? Where does calculation happen?
- **Performance:** Are there heavy computations that should be backend-optimized?
- **Failure & Recovery:** How should rollback, data migration failures, or partial deployments be handled?
- **Testing Requirements:** What critical behaviors, user flows, and edge cases must be tested?
- **Success Metrics:** How will we measure success (both quantitative and qualitative)?

**For Complex Features - Boundary Checklist:**
- ☐ Have we listed 3-5 explicit things this feature will NOT do?
- ☐ Have we defined Phase 1 (minimal viable) vs Phase 2+ (future enhancements)?
- ☐ Have we identified all system integrations and dependencies?
- ☐ **NEW**: Have we explicitly assigned work to backend vs frontend with justification?
- ☐ **NEW**: Have we verified no frontend data aggregation or heavy computation?
- ☐ Have we outlined clear acceptance criteria?
- ☐ Have we defined success metrics with failure thresholds?

### Scope Control (Ask When Needed)
- **Problem/Goal:** What specific problem does this solve for users?
- **Target User:** Who is the primary user of this feature?
- **Core Functionality:** What are the most important actions users should be able to perform?

### Context-Dependent (Ask Based on Feature Type)
- **User Stories:** For user-facing features
- **Data Requirements:** For data-processing features
  - **For data features, always ask:**
    - What calculations or transformations are needed?
    - Should these happen on backend or frontend? (Apply Decision Framework)
    - Do we need new API endpoints or can we extend existing ones?
    - What's the expected data volume and performance requirements?
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

## 4. PRD Structure

### Quick Start PRD (Minimal)
1. **Overview** – One paragraph: what and why
2. **Goals** – Bullet list of objectives
3. **Architectural Decisions** – Brief backend vs frontend breakdown
4. **Functional Requirements** – Numbered list with [Backend/Frontend] prefix
5. **Non-Goals** – What it won't do
6. **Testing Considerations** – Key test scenarios
7. **Success Metrics** – How we'll measure success

### Full PRD (Comprehensive)
1. **Introduction/Overview** – Feature description and problem it solves
2. **Goals** – Specific, measurable objectives
3. **Vision & Creative Considerations** *(Optional)* – Aspirational scenarios, metaphors, delight factors
4. **Architectural Decisions** – Explicit frontend vs backend responsibility breakdown
   - Backend work: Endpoints, calculations, data transformations
   - Frontend work: UI state, presentation, user interactions
   - Justification for placement decisions
5. **User Stories** – Narrative descriptions of feature usage
6. **Functional Requirements** – Numbered list with architectural prefix
   - **Format**: `FR1: [Backend/Frontend]: Specific requirement`
   - **Example**: `FR1: Backend: Calculate expiration-specific P/C ratios during options chain processing`
7. **Non-Goals (Out of Scope)** – Explicit exclusions to manage scope
8. **Design Considerations** *(Optional)* – UI/UX requirements, mockups
9. **Technical Considerations** *(Optional)* – Architecture, dependencies, constraints
10. **Failure & Recovery Strategy** – Rollback plan, error handling, data recovery
11. **Testing Considerations** – Unit, integration, edge cases, critical user flows
12. **Success Metrics** – Quantitative and qualitative measures
13. **Open Questions** – Unresolved items needing future clarification

---

## 5. Guiding Principles

- **Boundaries First, Creativity Second** – Define the fence before exploring the playground
- **Smart Backend, Simple Frontend** – Business logic and calculations belong on backend; frontend focuses on presentation and UX
- **Backend-First Thinking** – For data features, start by designing the ideal API response, then build frontend to consume it
- **Single Source of Truth** – Data transformations happen once on backend, not repeatedly on each client
- **Right-Size the Effort** – Match PRD depth to feature complexity
- **Skip Redundant Questions** – Don't re-ask what's already clearly stated
- **Every Requirement Traces to a Need** – No features without clear user benefit
- **Write for Junior Developers** – Explicit, unambiguous, jargon-free
- **Surface All Assumptions** – Document or question them, never hide them
- **Testing is Mandatory** – Every feature must define test scenarios

### PRD Review Checkpoint: Architectural Audit

**Before finalizing PRD, audit each functional requirement:**

☐ Have we justified why work is on frontend vs backend?
☐ Are we avoiding frontend data aggregation?
☐ Are calculations happening on the backend?
☐ Will the backend API support future clients (mobile, etc.)?
☐ Are we following the "smart backend, simple frontend" principle?

**Red Flags**:
- PRD mentions "frontend calculates" or "frontend aggregates"
- Multiple API calls from frontend to achieve one feature
- Frontend doing data normalization or transformation
- Complex business logic in React components

### Supporting Documentation Guidelines
- **User Guides** – Create for all user-facing features to ensure adoption and proper usage
- **Testing Procedures** – Document specialized testing approaches (accessibility, performance, etc.)
- **Rollback Plans** – Required for complex features that could impact production stability
- **Lessons Learned** – Capture insights from challenging implementations for knowledge transfer
- **Implementation Logs** – Archive detailed task completion records using `implementation-log-[feature].md` naming convention

### PRD Lifecycle Management
- **Active Development** – PRDs remain in `/documentation/specifications/active/` during feature development
- **Completed Features** – Successfully implemented PRDs are archived to `/documentation/specifications/completed/`
- **Supporting Documentation** – Feature-related documents organized in semantic folders:
  - `/documentation/information/` – User guides and end-user documentation
  - `/documentation/testing/` – Testing methodologies and procedures
  - `/documentation/rollbacks/` – Emergency rollback procedures and plans
  - `/documentation/lessons/` – Educational materials and lessons learned
  - `/documentation/tasks/completed/` – Implementation logs (using `implementation-log-[feature].md` naming)
- **Organizational Benefits** – Semantic folder structure improves discoverability, separates content by audience and purpose, maintains project documentation standards across the complete development lifecycle

---

## 6. Archival Cross-Reference

**IMPORTANT**: When archiving implementation logs, follow the **ARCHIVAL PROTOCOL** in `implementation-tasks-creation-guidelines.md`.

Key requirements:
1. Mark ALL tasks complete (`- [ ]` → `- [x]`)
2. Rename from `implementing-` to `implementation-log-`
3. Move to `documentation/tasks/completed/`

**DO NOT** attempt to archive without following the protocol checklist.

---

## 7. Output Requirements

- **Format:** Markdown (`.md`)
- **PRD Location:** `/documentation/specifications/active/` (during development), `/documentation/specifications/completed/` (after completion)
- **PRD Filename:** `feature-specification-[feature-name].md`
- **Supporting Documentation Structure:**
  - **User Guides:** `/documentation/information/user-guide-[feature-name].md`
  - **Testing Procedures:** `/documentation/testing/[test-type]-testing-[feature-name].md`
  - **Rollback Plans:** `/documentation/rollbacks/rollback-plan-[feature-name].md`
  - **Lessons Learned:** `/documentation/lessons/[feature-name]-lessons-learned.md`
  - **Implementation Logs:** `/documentation/tasks/completed/implementation-log-[feature-name].md`
- **Archival Process:** Move completed PRDs and organize all supporting documentation in semantic folders to maintain clean project structure and optimize discoverability by document type and target audience

---

## 8. Examples

### Quick Start Example (Updated):
```markdown
# Feature Specification: Add CSV Export to Reports

## Overview
Users need to export report data for use in Excel and other tools. This feature adds a "Download CSV" button to all report pages.

## Goals
- Enable data export from any report view
- Maintain current filtering/sorting in exported data
- Support reports up to 10,000 rows

## Architectural Decisions
**Backend Work:**
- Generate CSV file from database query results
- Apply current filters and sorting server-side
- Stream response for large datasets

**Frontend Work:**
- Add "Download CSV" button to report toolbar
- Trigger download with current filter state
- Show progress indicator during export

## Functional Requirements
FR1: Backend: Generate CSV from filtered query results with proper escaping
FR2: Backend: Stream response for datasets over 1000 rows
FR3: Frontend: Add "Download CSV" button to report toolbar
FR4: Frontend: Send current filter/sort state to backend endpoint
FR5: Frontend: Show progress indicator during export

## Non-Goals
- Custom column selection for export (Phase 2)
- Other formats (Excel, PDF)
- Scheduled/automated exports

## Testing Considerations
- Export with various filter combinations
- Large dataset performance (10k rows)
- Special characters in data (quotes, commas)
- Empty report states

## Success Metrics
- 80% of users who view reports use export within first month
- Export completes in <5 seconds for typical reports (<1000 rows)
```

### Architectural Boundary Example (Full):

**BAD PRD (Frontend doing backend work):**
```markdown
# Feature Specification: Add Moving Average Indicators

## Functional Requirements
FR1: Frontend fetches price history for symbol
FR2: Frontend calculates SMA-20/50/200 from price data
FR3: Frontend determines price relationship to each MA
FR4: Frontend displays calculated indicators
```

**GOOD PRD (Proper separation):**
```markdown
# Feature Specification: Add Moving Average Indicators

## Architectural Decisions

### Backend Work (Lambda Function Enhancement)
- Calculate SMA-20/50/200 from underlying price history
- Determine current price relationship to each MA (above/below)
- Include moving average data in options chain response
- Cache calculated values to reduce API calls

### Frontend Work (React Component)
- Display pre-calculated MA indicators from backend response
- Implement visual indicators (color coding, arrows)
- Persist user's MA visibility preference in localStorage
- Progressive disclosure: hide/show detailed MA breakdown

## Functional Requirements
FR1: Backend: Calculate SMA-20, SMA-50, SMA-200 from underlying price history
FR2: Backend: Determine price relationship to each MA (above/below, percentage distance)
FR3: Backend: Include movingAverages object in options chain response payload
FR4: Backend: Cache MA calculations for 5 minutes to reduce computation
FR5: Frontend: Display movingAverages data from backend response
FR6: Frontend: Show visual indicators (green ↑ when above MA, red ↓ when below)
FR7: Frontend: Persist user's MA visibility toggle in localStorage
FR8: Frontend: Progressive disclosure for detailed percentage distances

## Non-Goals
- Custom MA period configuration (fixed to 20/50/200 for Phase 1)
- Multiple underlying symbols in single view (Phase 2)
- Historical MA crossover detection

## Testing Considerations
- Verify SMA calculations match expected values
- Test caching behavior and invalidation
- Test visual indicators for various price/MA relationships
- Test localStorage persistence across sessions
```

### Full PRD Structure Example:
*(Show just the headers for space)*
```markdown
# Feature Specification: Customer Portal Dashboard

## Introduction/Overview
## Goals
## Vision & Creative Considerations
## Architectural Decisions
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

## 9. Feature Tagging Strategy

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