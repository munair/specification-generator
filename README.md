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

### How It Works

The framework operates on a two-phase approach:

#### Phase 1: Build the Fence (Boundary Establishment)
The AI assistant **must** establish clear boundaries before any creative work begins:
- What should this feature *not* do?
- Can this be broken into phases?
- How does it integrate with existing systems?

#### Phase 2: Explore the Playground (Creative Abandon)
Once boundaries are locked down, the AI assistant is encouraged to be **maximally creative and comprehensive** within those constraints.

This approach leverages the AI's natural strengths (creativity, thoroughness, pattern recognition) while preventing its weaknesses (scope creep, assumption-making).

## Why This Framework Works

### The Power of Metaphor in AI Instruction

Traditional AI prompting often relies on rigid rules and lengthy instructions. But well-chosen metaphors can be far more effective because they:

- **Create immediate mental models** - The AI "gets it" intuitively
- **Are memorable** - The core concept stays consistent throughout long conversations
- **Capture intent, not just rules** - The AI follows the spirit rather than mechanically following steps

The playground metaphor immediately communicates the desired behavior: creative exploration within defined limits.

### Addressing the 80/20 Problem

Most users (80%) come to AI assistants with clear problems and goals already in mind. Traditional specification processes bog these users down with basic questions about problem definition and target users.

This framework flips the priority:
- **Essential questions** focus on boundaries and constraints
- **Scope control questions** handle the basics (only when needed)
- **Context-dependent questions** gather implementation details

### Creative Abundance vs. Creative Paralysis

Many specification frameworks attempt to control AI creativity through restrictions. This framework takes the opposite approach: it **unleashes** creativity by first establishing safe boundaries.

The result is specifications that are both:
- **Comprehensive** - Exploring every possibility within scope
- **Focused** - Never straying beyond defined boundaries

## The Framework in Action

Here's how a typical specification process unfolds:

1. **User provides initial request** - Often brief or high-level
2. **AI establishes boundaries first** - "What should this NOT do?"
3. **AI confirms scope and phasing** - "Can this be broken down?"
4. **Creative exploration begins** - Within the established constraints
5. **Comprehensive PRD generated** - Thorough but focused

### Sample Interaction Flow

```
User: "I need a user dashboard for our app"

AI: "Before I design this dashboard, let me establish some boundaries:
- What should this dashboard NOT include or do?
- Are there any existing features this shouldn't overlap with?
- Should this be built all at once, or can we phase it?"

User: "Don't include admin functions, don't duplicate the settings page, 
and let's start with just the core metrics."

AI: "Perfect! Now I can explore every possibility for a user dashboard 
focused on core metrics, avoiding admin functions and settings overlap. 
Let me create a comprehensive specification..."
```

## What You'll Find Here

### `guidelines-for-creatively-generating-feature-specifications.md`

The complete framework document containing:
- **Clarifying Questions Framework** - Prioritized question categories
- **PRD Structure** - Template for comprehensive specifications  
- **Guiding Principles** - The core philosophy including "Creative Abandon Within Scope"
- **Process Flow** - Step-by-step implementation guide
- **Testing Considerations** - Integrated testing requirements and scenarios

This isn't just documentation - it's a tested system that consistently produces high-quality specifications while preventing the most common AI pitfalls.

## Why Open Source This?

Product managers, developers, and AI practitioners everywhere struggle with the same challenge: how to harness AI's creative power without losing control of scope and requirements.

This framework represents dozens of iterations and real-world testing, building on inspiration from innovative work in the open-source community - particularly [Aaron Nichols](https://github.com/adnichols) and [Ryan Carson](https://github.com/snarktank), whose projects demonstrated the power of structured AI collaboration.

By open-sourcing this approach, I hope to:

- **Standardize AI specification practices** across teams and organizations
- **Enable better human-AI collaboration** in product development
- **Demonstrate the power of metaphor-driven AI instruction**

## Getting Started

1. **Copy the guidelines file** (`guidelines-for-creatively-generating-feature-specifications.md`) to your AI assistant context
2. **Use the activation prompt**: "Please follow the Feature Specification / Product Requirements Document (PRD) guidelines. Feature request: [YOUR REQUEST]"
3. **Let the AI establish boundaries first** before exploring solutions
4. **Watch it create comprehensive specs** that actually meet your needs

## Results You Can Expect

Teams using this framework report:
- **Faster specification cycles** - Less back-and-forth clarification
- **More focused features** - Reduced scope creep and feature bloat
- **Better AI collaboration** - Clearer expectations and outputs
- **Improved developer handoffs** - Specifications that junior developers can actually implement

## Contributing

This framework is the result of practical experimentation with AI-assisted product development. If you have improvements, variations, or real-world results to share, contributions are welcome.

The goal is simple: make AI assistants better partners in building great software.

---

*"The framework explicitly tells an AI Assistant: 'First, build the fence. Then, explore every inch of the playground.'"*