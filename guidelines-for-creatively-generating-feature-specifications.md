# Rule: Feature Specification / Product Requirements Document (PRD)

## Overview

The framework explicitly tells an AI Assistant: "First, build the fence. Then, explore every inch of the playground."

## Goal

To guide an AI assistant in creating a detailed Feature Specification / Product Requirements Document (PRD) in Markdown format, based on an initial user prompt. The PRD should be thorough, actionable, and suitable for a junior developer to understand and implement the feature.

## Process

1. **Receive Initial Prompt:** The user provides a brief description or request for a new feature or functionality.
2. **Clarify Before Creating:** Before writing the PRD, the AI assistant *must* ask clarifying questions to gather sufficient detail and establish clear boundaries. The goal is to understand user needs deeply while preventing scope creep.
3. **Generate PRD:** Based on the initial prompt and the user's answers, generate a comprehensive PRD using the structure outlined below.
4. **Save PRD:** Save the generated document as `feature-specification-[feature-name].md` inside the `/documentation` directory.
5. **Review, Approve, and Commit (CRITICAL CHECKPOINT):**
    - **Present the specification to the user for final review and approval.**
    - **Prompt the user:** "I have drafted the Feature Specification. Please review it to ensure it aligns with your goals. Once you approve, I will commit it to the repository to formalize our plan."
    - **Wait for explicit user approval.**
    - **Commit the approved specification to the repository.** Do not proceed to task generation until the specification is committed.

## Clarifying Questions Framework

The AI assistant should adapt its questions based on the prompt, prioritizing understanding over assumptions. Focus on these key areas:

### Essential (Always Ask)
- **Boundaries:** "What should this feature *not* do? Any explicit non-goals?"
- **Phase Consideration:** "Is this something that could be broken into phases or iterations?"
- **Integration Constraints:** "How should this fit with existing features or systems?"

### Scope Control (Ask When Needed)
- **Problem/Goal:** "What specific problem does this feature solve for users?"
- **Target User:** "Who is the primary user of this feature?"
- **Core Functionality:** "What are the 3-5 most important actions users should be able to perform?"
- **Success Definition:** "How will we know this feature is working well?"

### Context-Dependent (Ask Based on Prompt)
- **User Stories:** "Could you provide 2-3 user stories describing typical usage?"
- **Data Requirements:** "What information does this feature need to work with?"
- **Design/UX:** "Are there any UI/UX requirements or existing patterns to follow?"
- **Technical Constraints:** "Are there any known technical limitations or requirements?"
- **Edge Cases:** "What could go wrong? Any special scenarios to consider?"
- **Testing Requirements:** "What specific behaviors or edge cases must be tested? Are there critical user flows that need test coverage?"

## PRD Structure

The generated PRD should include the following sections:

1. **Introduction/Overview:** Briefly describe the feature and the problem it solves. State the primary goal.
2. **Goals:** List specific, measurable objectives for this feature.
3. **User Stories:** Detail user narratives describing feature usage and benefits.
4. **Functional Requirements:** List specific functionalities the feature must have. Use clear, numbered requirements (e.g., "The system must allow users to upload a profile picture").
5. **Non-Goals (Out of Scope):** Clearly state what this feature will *not* include to manage scope.
6. **Design Considerations (Optional):** Link to mockups, describe UI/UX requirements, or mention relevant components/styles if applicable.
7. **Technical Considerations (Optional):** Mention any known technical constraints, dependencies, or integration requirements.
8. **Testing Considerations:** Define what types of testing are required (unit, integration, edge cases) and any specific testing scenarios that must be covered.
9. **Success Metrics:** How will the success of this feature be measured? Include both quantitative and qualitative indicators.
10. **Open Questions:** List any remaining questions or areas needing further clarification.

## Guiding Principles

- **Establish Boundaries First:** Lock down scope, non-goals, and constraints before exploring possibilities
- **Creative Abandon Within Scope:** Once boundaries are clear, be maximally creative and comprehensive within those constraints
- **Stay Tethered:** Every requirement should trace back to a stated user need
- **Target Junior Developers:** Requirements should be explicit, unambiguous, and avoid unnecessary jargon
- **Question Assumptions:** When in doubt, ask rather than assume

## Output Requirements

- **Format:** Markdown (`.md`)
- **Location:** `/documentation/`
- **Filename:** `feature-specification-[feature-name].md`

## Final Instructions

1. **Do NOT start generating tasks until after the PRD is formally approved and committed**
2. **Ask clarifying questions that enhance understanding while preventing scope creep**
3. **Use the user's answers to create a comprehensive yet focused PRD**
4. **If the scope seems too large, suggest breaking the feature into phases**