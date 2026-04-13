---
# WORKFLOW.md front matter (optional but recommended)
# Unknown keys are ignored for forward compatibility.
project: example-project
version: 1
tracker: none            # none | linear | github | jira
branch_policy: feature   # main-only | feature | worktree
default_branch: main
---
# WORKFLOW.md — Project Automation Policy
This file encodes **project-level rules** that coding agents (Claude Code, Codex, subagents, etc.) must honor when working in this repository. It is the **single source of truth** for test commands, commit conventions, branch rules, and hook configuration.
> **Contract**: If a guideline (PRD, task list, system spec) says "follow project conventions," the agent reads this file rather than asking the human. If a rule is deterministic, it belongs here — or in a hook — not in a PRD narrative.
---
## 1. Test Commands
The agent must run these before any commit. If a `PreToolUse(Bash:git commit)` hook is configured in `settings.json`, it runs these automatically.
```bash
# Backend (Node.js native tests)
node --test tests/
# Frontend (Vitest)
npm test
# Linting
npm run lint
# Type-checking
npm run typecheck
```
**Rule**: All four must exit 0 before a commit is allowed.
---
## 2. Branch Policy
- **Never commit directly to `main`.**
- Feature work happens on `feature/[feature-name]`.
- System-level work happens on `system/[service-name]`.
- Experimental/exploration work happens in a git worktree under `.worktrees/`.
- Agents may create branches; agents may not delete branches without explicit user approval.
---
## 3. Commit Style
- Conventional Commits: `type(scope): description`
- Types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `perf`, `style`
- Subject line ≤ 72 characters
- Body explains the **why**, not the **what**
- No emoji unless the user requests it
**Example**: `feat(lambdas): add account numbers endpoint with DynamoDB-backed authorization`
---
## 4. Hook Configuration (Reference)
The following hooks should be present in `.claude/settings.json` (or your agent harness equivalent). If they are missing, the agent's first task for any new feature should be to wire them up.
```jsonc
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "pattern": "git commit",
        "command": "npm test && npm run lint && npm run typecheck"
      }
    ],
    "Stop": [
      {
        "command": "scripts/verify-archival.sh"
      }
    ],
    "SessionStart": [
      {
        "command": "scripts/session-bootstrap.sh"
      }
    ]
  }
}
```
Where `scripts/verify-archival.sh` is a small script that checks: *no active implementing-\*.md file has unchecked boxes at session end.*
---
## 5. Subagent Delegation Defaults
By default, delegate to subagents:
- Any codebase survey spanning > 5 files → `Explore` subagent
- Any architectural second opinion → `Plan` subagent
- Any parallelizable test suite run → independent subagent per suite
- Any independent component build (per system-specification-guidelines) → one subagent per component
The main agent should keep its context focused on the critical path.
---
## 6. Archival Protocol
Follow the **ARCHIVAL PROTOCOL** in `guidelines/implementation-tasks-creation-guidelines.md`. The `Stop` hook above enforces it automatically — but the protocol is the contract.
---
## 7. Project-Specific Conventions
*(Fill in per project.)*
- Directory layout: …
- Deployment target: …
- On-call / escalation: …
- Secret management: …
- Observability endpoints: …
---
## 8. Forward Compatibility
**Unknown keys in front matter are ignored with a warning.** Adding new rules to this file should not break older agent harnesses. When deprecating a rule, leave it in place for one release cycle with a `deprecated: true` marker.
---
## 9. What Does NOT Belong Here
- Feature-specific requirements → those go in a PRD
- One-off instructions for a single task → those go in the task list
- Architectural decisions about a specific component → those go in a system spec
- Personal preferences of a specific human user → those go in user-level agent settings
**Rule of thumb**: If a rule applies across *all* features in this project, it belongs here. Otherwise it belongs closer to the feature.