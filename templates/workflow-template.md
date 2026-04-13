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

The agent must run these before any commit. When the reference hook in §4 is configured, a `PreToolUse` event on `git commit` runs them automatically.

> **Delete what does not apply to your project.** This section is an example, not a mandate. A pure backend repo has no `npm test`; a Python project has no `typecheck` in the Node sense. Keep the commands you actually run.

```bash
# Backend (Node.js native tests)
node --test tests/

# Frontend (Vitest)
npm test

# Linting
npm run lint

# Type-checking (TypeScript projects only)
npm run typecheck
```

**Rule**: Every command you keep must exit 0 before a commit is allowed.

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

> **Schema note.** The Claude Code `PreToolUse` hook shape is:
> ```
> { "matcher": "<tool-name-regex>", "hooks": [ { "type": "command", "command": "<shell>" } ] }
> ```
> `matcher` is a **regex against the tool name only**. There is no top-level `pattern` key for filtering by command content — filtering by command content is the hook script's job. Always validate against your harness's schema; other harnesses (Codex, Cursor, etc.) may differ.

```jsonc
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/pre-commit-gate.sh"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash scripts/verify-archival.sh"
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash scripts/session-bootstrap.sh"
          }
        ]
      }
    ]
  }
}
```

Supporting scripts:

- `.claude/hooks/pre-commit-gate.sh` — reads the tool input from stdin, inspects the Bash command, runs tests/lint/typecheck only when the command contains `git commit`, and denies the tool use on failure. Minimal reference implementation:

    ```bash
    #!/bin/bash
    INPUT=$(cat)
    COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
    [[ "$COMMAND" != *"git commit"* ]] && exit 0

    if ! (npm test && npm run lint && npm run typecheck); then
      jq -nc '{
        hookSpecificOutput: {
          hookEventName: "PreToolUse",
          permissionDecision: "deny",
          permissionDecisionReason: "Tests, lint, or typecheck failed — fix before committing."
        }
      }'
      exit 0
    fi
    exit 0
    ```

- `scripts/verify-archival.sh` — at `Stop`, refuses to let the session end cleanly if any `documentation/tasks/active/implementing-*.md` file has unchecked boxes.

- `scripts/session-bootstrap.sh` — at `SessionStart`, prints a one-line summary of the current branch, active PRD, and unresolved tasks (optional but useful).
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