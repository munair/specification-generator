# Specification Generator

*A framework for guiding AI assistants to create comprehensive feature specifications through structured creativity*

## The Problem with AI-Generated Specifications

AI assistants are incredibly powerful at generating detailed technical documentation, but they often suffer from two critical flaws when creating product specifications:

1. **Scope Creep** - They get excited and design elaborate solutions that far exceed what was actually requested
2. **Assumption-Making** - They fill in gaps with their own interpretations rather than asking clarifying questions

The result? Beautiful, comprehensive documents that solve the wrong problem entirely.

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

#### Phase 1.5: Architectural Decision Making (NEW in v3.0.0)
For full-stack applications, the framework now enforces **explicit architectural boundaries** between frontend and backend:
- **Smart Backend, Simple Frontend** - Business logic belongs on backend
- **5-Question Decision Framework** - Systematic placement of work
- **Architectural Audit** - Self-verification before PRD finalization

This approach leverages the AI's natural strengths (creativity, thoroughness, pattern recognition) while preventing its weaknesses (scope creep, assumption-making, architectural mistakes).

## Guideline Taxonomy: Domain-First Organization

The framework provides **three specialized guidelines** organized by domain and approach:

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

**Best for**: Innovative features, strategic initiatives, when systematic approaches aren't working, creative rescue scenarios

## When to Use Which Guideline

| Scenario                           | Recommended Guideline   | Why                                                                 |
|------------------------------------|-------------------------|---------------------------------------------------------------------|
| Lambda function development        | Backend                 | Specialized for serverless architecture and dependency-free testing |
| React component features           | Frontend                | Optimized for component architecture and state management           |
| API endpoint creation              | Backend                 | Focuses on service integration and data transformation              |
| Dashboard UI improvements          | Frontend                | Emphasizes UX, accessibility, and progressive disclosure            |
| Data processing pipelines          | Backend                 | Handles performance, error recovery, and scalability                |
| Trading interface features         | Frontend                | Component composition, real-time updates, user workflows            |
| Novel, unexplored solutions        | Exploratory → Domain    | Creative exploration, then migrate to domain-specific spec          |
| When systematic approach fails     | Exploratory             | Creative rescue when structured thinking isn't working              |
| Complex system integrations        | Backend or Frontend     | Choose based on primary implementation domain                       |
| Simple bug fixes                   | Backend or Frontend     | Use Quick Start variant for straightforward fixes                   |

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
- **v3.0.0**: Architectural Decision Framework - Frontend/backend separation
- Backend Guidelines: Optimized for serverless Lambda architecture
- Frontend Guidelines: Optimized for React/TypeScript with architectural boundaries
- Exploratory Guidelines: Constraint-free creative ideation

*"The framework explicitly tells an AI Assistant: 'First, build the fence. Then, explore every inch of the playground.'"*