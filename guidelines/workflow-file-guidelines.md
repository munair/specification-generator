# Rule: The `WORKFLOW.md` / `CLAUDE.md` Convention (v4.0.0)

## Overview

Starting in v4.0.0, this framework formalizes an **in-repository policy file** that encodes project-level rules for tool-using agents. Depending on your harness, this file is named:
- `WORKFLOW.md` — framework-neutral name (recommended for portability)
- `CLAUDE.md` — Claude Code convention
- `.cursorrules` or `.cursor/rules/*` — Cursor convention
- `AGENTS.md` — some multi-agent harnesses
This framework treats them as interchangeable; you may symlink or duplicate as needed. For documentation purposes we use `WORKFLOW.md`.
**The reference template lives at `templates/workflow-template.md`.** Copy it to your project root and customize.

## Why This Exists

Before v4.0.0, this framework baked project conventions into PRDs ("the AI should use the existing test framework," "commit messages should follow Conventional Commits," etc.). That approach had three problems:
1. **Repetition**: Every PRD restated the same rules.
2. **Drift**: PRDs written at different times would contradict each other.
3. **Non-determinism**: Prose rules rely on the agent "remembering." Hooks and policy files do not.
`WORKFLOW.md` is the fix. Project-wide rules live in one file. PRDs reference it. Hooks enforce it. Agents read it.

## The Contract

A repository that follows this framework should have:
1. **A `WORKFLOW.md` at the repository root** (or equivalent). This file defines test commands, branch policy, commit style, subagent delegation defaults, archival protocol, and hook configuration.
2. **Hooks wired into `.claude/settings.json`** (or harness equivalent) that enforce the deterministic rules from `WORKFLOW.md`.
3. **PRDs that reference `WORKFLOW.md`** instead of restating its rules.
4. **Task lists that reference `WORKFLOW.md`** instead of restating its rules.

## What Belongs in `WORKFLOW.md`

Include rules that apply to **every feature in this project**:
- Test commands and their pass criteria
- Branch policy (feature branches, worktrees, main protection)
- Commit message format
- Hook configuration (or a reference to it)
- Subagent delegation defaults
- Archival protocol reference
- Project-specific conventions (directory layout, deployment target, secrets)

## What Does NOT Belong in `WORKFLOW.md`

- Feature-specific requirements → those go in PRDs
- One-off task instructions → those go in task lists
- Architectural decisions about a specific component → those go in system specs
- Personal user preferences → those go in user-level agent settings

## Forward Compatibility

**Unknown keys in `WORKFLOW.md` front matter must be ignored with a warning**, never rejected. This lets the file evolve without breaking older agent harnesses. When deprecating a rule, mark it `deprecated: true` for one release cycle before removing.

## How This Integrates with the Other Guidelines
- **Backend PRD**: The Agent Execution Plan section references `WORKFLOW.md` for test commands and branch policy.
- **Frontend PRD**: Same as backend.
- **Exploratory**: The recon subagent reads `WORKFLOW.md` as part of its initial survey.
- **System Specification**: Note that `system-specification-guidelines.md` §4 "Service Policy / Configuration File" is a **different file** — it specifies a service's own operational configuration (for example, `config/scheduler.yaml` or `config/poller.yaml`) that the service reads at startup, and it is **not** the project-level `WORKFLOW.md` that tells the coding agent how to operate on the repository. A project has one `WORKFLOW.md`; a service has its own configuration file. In a single-service repository the two may collapse into one file in practice; in a multi-service repository they stay separate and are named distinctly so each service owns its configuration and the project owns `WORKFLOW.md`. See the naming note at the top of §4 in `system-specification-guidelines.md`.
- **Implementation Tasks**: Task lists reference `WORKFLOW.md` for test commands and hook configuration. Deterministic rules go into hooks, not task descriptions.

## Getting Started

1. Copy `templates/workflow-template.md` to your project root as `WORKFLOW.md`.
2. Fill in the project-specific sections (test commands, directory layout, deployment target).
3. Wire up the reference hooks in `.claude/settings.json` (or your harness equivalent).
4. Audit your existing PRDs: anywhere they restate a rule that now lives in `WORKFLOW.md`, delete the duplication and add a reference.
5. From this point forward, new PRDs reference `WORKFLOW.md` rather than restating conventions.

## Example Reference from a PRD

Instead of this (v3.x style):
> "The AI assistant should run all tests using `node --test tests/` and verify they pass before committing. Commits should follow Conventional Commits format..."
Write this (v4.0.0 style):
> "See `WORKFLOW.md` for test commands, commit style, and hook configuration. The PreToolUse(git commit) hook will enforce test passage automatically."
Shorter. More accurate. Automatically updated when `WORKFLOW.md` changes.