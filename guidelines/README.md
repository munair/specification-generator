# Guidelines Directory

This directory contains the complete framework for generating high-quality feature specifications, organized by domain and approach.

## Domain-First Organization

Guidelines are now organized by **domain** (backend vs frontend) and **approach** (systematic vs exploratory) for maximum clarity and precision.

### Why Domain-First?

**Problem**: Generic guidelines try to serve all contexts, resulting in vague patterns that don't match real architectures.

**Solution**: Domain-specific guidelines provide:
- **Immediate Clarity** - Filename tells you exactly when to use it
- **Precise Patterns** - Backend uses Node.js native testing; Frontend uses Vitest
- **Better Sorting** - Related guidelines grouped alphabetically
- **Future-Proof** - Easy to add new domains (mobile, embedded, desktop, etc.)

## The Three Guidelines

### `backend-feature-specification-guidelines.md`
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

### `frontend-feature-specification-guidelines.md`
**Domain**: React/TypeScript applications, UI components, user interfaces

**For Use With**:
- React web applications
- Trading dashboards and interfaces
- Component libraries
- User-facing features
- State-managed UIs

**Key Features**:
- Component-based architecture patterns
- React Context API and reducer patterns
- Progressive disclosure principles
- WCAG AA accessibility compliance
- Vitest + React Testing Library patterns
- Performance optimization (bundle size, lazy loading, memoization)
- Quick Start vs Full PRD structure
- Archival cross-reference to completion workflow

**Testing Approach**: Component tests with React Testing Library, integration tests with context mocking, edge case coverage for UI states.

**When to Use**: Any React/TypeScript feature, UI component, dashboard improvement, or user-facing functionality.

---

### `exploratory-feature-specification-guidelines.md`
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

## Decision Matrix: Which Guideline to Use?

| Your Need                              | Use This Guideline | Then                                    |
|----------------------------------------|--------------------|-----------------------------------------|
| Lambda function feature                | Backend            | Generate PRD → implement                |
| React component feature                | Frontend           | Generate PRD → implement                |
| API endpoint creation                  | Backend            | Generate PRD → implement                |
| Dashboard UI improvement               | Frontend           | Generate PRD → implement                |
| Creative brainstorming                 | Exploratory        | Explore → migrate to Backend/Frontend   |
| Systematic approach isn't working      | Exploratory        | Creative rescue → formalize             |
| Novel feature, unclear domain          | Exploratory        | Define → choose Backend/Frontend        |
| Bug fix (backend)                      | Backend            | Use Quick Start variant                 |
| Bug fix (frontend)                     | Frontend           | Use Quick Start variant                 |
| Complex system integration             | Backend or Frontend| Choose based on primary implementation  |

## Complete Specification Lifecycle

### 1. PRD Generation
Choose appropriate guideline → AI establishes boundaries → generates comprehensive PRD

**Critical Checkpoint**: Review, approve, and commit PRD before implementation

### 2. Task Breakdown
Use `guidelines-for-generating-tasks.md` to break PRD into atomic tasks

**Output**: `/documentation/tasks/active/implementing-[feature-name].md`

### 3. Implementation
Execute tasks with full test coverage and documentation

### 4. Archival
Follow **ARCHIVAL PROTOCOL** (see below)

## The Archival Protocol

**All three PRD guidelines** now include cross-references to the **ARCHIVAL PROTOCOL** in `guidelines-for-generating-tasks.md` (lines 13-61).

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

See `guidelines-for-generating-tasks.md` lines 13-61 for complete executable archival commands.

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

All three guidelines now include:
- ✅ Archival cross-reference section
- ✅ Domain-first naming convention
- ✅ Quick Start vs Full Process variants (Backend/Frontend)
- ✅ Testing approach specific to domain
- ✅ Integration with task generation workflow
- ✅ Feature tagging strategy for implementation tracking

**Last Updated**: November 2, 2025
**Framework Version**: Domain-First Organization (v2.0)

---

**Quick Reference Commands**:

```bash
# Backend PRD activation
"Follow backend-feature-specification-guidelines.md for Lambda function: [REQUEST]"

# Frontend PRD activation
"Follow frontend-feature-specification-guidelines.md for React component: [REQUEST]"

# Exploratory PRD activation
"Follow exploratory-feature-specification-guidelines.md to explore: [REQUEST]"

# Archival verification
grep -c "- \[ \]" documentation/tasks/active/implementing-[feature-name].md
```
