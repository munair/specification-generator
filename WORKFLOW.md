---
# WORKFLOW.md front matter — forward-compatible; unknown keys ignored.
project: specification-generator
version: 1
default_branch: main
branch_policy: feature
---

# WORKFLOW.md — Project Automation Policy

This file is the single source of truth for project-wide rules that a coding agent must honor when working in the specification-generator repository. It is the authoritative home for test commands, branch policy, commit conventions, hook configuration, subagent delegation defaults, and project-specific conventions. It exists in addition to being described in the framework — **this project eats its own dog food**: every guideline, template, and example authored here is itself produced under the v4.0.0 shape, and every adopting project is expected to have a file like this one at its own repository root.

> **Contract.** If any guideline, template, PRD, or task list in this repository says "follow project conventions," the agent reads this file rather than asking the human. If a rule is deterministic, it belongs here — or in a hook — not in a PRD narrative.

---

## 1. Test Commands

**This repository ships no code.** It is a documentation-only framework: markdown guidelines, markdown templates, markdown example specifications, and three reference hook scripts under [`templates/scripts/`](templates/scripts/) that are copied into adopting projects rather than executed here.

Because there is no code, there is nothing to test. The `test` script in [`package.json`](package.json) is intentionally a no-op that prints a message and exits 0:

```json
"scripts": {
  "test": "echo \"specification-generator is a docs-only package; no tests to run.\" && exit 0"
}
```

**Consequently**: there is no lint command, no type-check command, and no `PreToolUse(Bash:git commit)` hook wired to run tests. An agent working in this repository should **not** invent tests to run — there is no test harness to validate markdown content. If a test harness is introduced in a future release (for example, a markdown-lint or a schema validator for front matter blocks), this section will describe the commands and a pre-commit gate will be wired up.

---

## 2. Branch Policy

- **Never commit directly to `main`.** Every change goes through a feature branch.
- **Feature branches** use the pattern `feature/[short-slug]` (for example `feature/v4-polish-pass`).
- **System-level work** (if introduced) uses `system/[service-name]`.
- **Never force-push `main`.** Force-pushing a feature branch is acceptable only on a branch that has no reviewers and no open pull request.
- **No pull request** is opened unless the user explicitly requests one. A merged commit history with no upstream PR is the expected local state; the user decides when and how to publish.
- **Branches created by an agent** may not be deleted by the agent without explicit user approval. An abandoned branch is safer than an irrecoverable one.

---

## 3. Commit Style

- **Conventional Commits**: `type(scope): description`.
- **Types** in use in this repository's history: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `perf`, `style`.
- **Subject line** is at most 72 characters.
- **Body** explains the *why*, not the *what*. The diff already says what changed; the commit message says why that change was worth making.
- **No emoji** in commit messages unless the user explicitly requests them.
- **Every commit** that affects user-visible content — a guideline, a template, an example, a README, this file — must also update [`CHANGELOG.md`](CHANGELOG.md), either immediately or in a follow-up commit in the same branch. The changelog is the release notes; a content change that is not in the changelog is effectively invisible.

**Example**: `docs(guidelines): add PRD Review Checkpoint to backend guideline (Gap 9)`

---

## 4. Hook Configuration (Reference)

This repository has two hook-related assets:

- **[`.claude/settings.json`](.claude/settings.json)** — permission rules and hook wiring for agents operating in this repository.
- **[`.claude/hooks/protect-env.sh`](.claude/hooks/protect-env.sh)** — a defense-in-depth guard that denies access to `.env` and similar files even though this repository contains none. Shipped as a safety net because the same agent may work across repositories that do contain secrets.

**What is intentionally NOT wired up here**:

- **No `PreToolUse(Bash:git commit)` hook running tests.** There are no tests to run (see §1). Wiring one up would add latency to every commit for no benefit.
- **No `Stop` hook running `verify-archival.bash`.** There is no `documentation/tasks/active/implementing-*.md` file in this repository because this repository is not a product project with feature-tracked tasks. The archival protocol applies to projects that adopt this framework, not to the framework itself.
- **No `SessionStart` hook.** Unnecessary.

**For adopters.** Copy-ready hook scripts for the usual three events ship in [`templates/scripts/`](templates/scripts/): `pre-commit-gate.bash`, `verify-archival.bash`, and `session-bootstrap.bash`. Invoke them via `bash <path>.bash`. See [`templates/workflow-template.md`](templates/workflow-template.md) §4 for the full wiring guide.

---

## 5. Subagent Delegation Defaults

By default, delegate to subagents:

- Any codebase survey spanning more than roughly five files → `Explore` subagent.
- Any architectural or content second opinion on a non-trivial change → `Plan` subagent.
- Any parallelizable set of independent edits → independent subagent per edit when the context budget justifies it.

The main agent keeps its context focused on the user-facing narrative and the critical-path edits. Broad surveys, cross-file audits, and research that would otherwise pollute the main context go to subagents that return short summaries.

---

## 6. Archival Protocol

The framework's **ARCHIVAL PROTOCOL** is defined in [`guidelines/implementation-tasks-creation-guidelines.md`](guidelines/implementation-tasks-creation-guidelines.md) and is the contract every adopting project follows. In this repository, the protocol applies to **meta-work**: if this repository's own development ever produces an `implementing-[feature-name].md` file under a hypothetical `documentation/tasks/active/` directory, that file must follow the archival protocol end to end. As of this writing, no such directory exists.

The protocol in two lines:
1. All tasks in an implementation log must be checked (`- [ ]` → `- [x]`) before archival.
2. The file is renamed from `implementing-` to `implementation-log-` and moved to `documentation/tasks/completed/`.

---

## 7. Project-Specific Conventions

- **Documentation-only repository.** Every change is a documentation change. There is no runtime code, no build output, no test suite, no deployment pipeline, and no package-install step for end users. Adopters read the markdown and copy the templates; they do not `npm install` the framework.
- **Changelog discipline.** Every user-visible change must be reflected in [`CHANGELOG.md`](CHANGELOG.md). The changelog is the product.
- **Version bumps follow the Major/Minor/Patch rules in the CHANGELOG header.** Major: new expectations adopters must meet (a new required section, a new required file at the project root, a new taxonomy entry). Minor: additive improvements within the existing expectations (new optional section, new guideline, new template). Patch: corrections, clarifications, and editorial polish that do not change expectations. A polish pass like the one that produced 4.0.1 is a patch release.
- **Directory layout:**
  - [`guidelines/`](guidelines/) — authoritative long-form guideline text, one file per PRD type plus the convention guideline.
  - [`templates/`](templates/) — starting-point documents that adopters copy into their own projects. Includes [`templates/scripts/`](templates/scripts/) for the reference hook scripts.
  - [`examples/`](examples/) — worked example specifications illustrating each guideline in use. Divided between v4.0.0 reference examples and v1.x legacy examples.
  - [`.claude/`](.claude/) — agent harness configuration for this repository.
- **Dog food rule.** Every PRD, template, or example authored in this repository uses the v4.0.0 shape itself. If a new example is added, it must demonstrate the Agent Execution Plan section, `[Backend]` / `[Frontend]` prefixes where applicable, Delegatable Research (if the feature warrants it), and references to `WORKFLOW.md` (this file) rather than restated rules.
- **No abbreviations in authored content.** Write "repository," "configuration," "documentation," and so on in full rather than "repo," "config," "docs" (except where an abbreviation is canonical — file names, CLI flags, package names, Conventional Commits type labels like `feat` / `docs` / `chore`).
- **Bash scripts use `.bash` suffix and are invoked via `bash <path>.bash`** — not `chmod +x` followed by direct execution.

---

## 8. Forward Compatibility

**Unknown keys in the front matter above are ignored with a warning.** Adding new rules to this file should never break older agent harnesses. When deprecating a rule, leave it in place for one release cycle with a `deprecated: true` marker before removing.

---

## 9. What Does NOT Belong Here

- Feature-specific requirements → those go in a PRD under [`examples/`](examples/) if illustrative or in a downstream project if real.
- One-off instructions for a single task → those go in an implementation task list.
- Architectural decisions about a specific guideline — those go in the guideline itself.
- Personal preferences of a specific human user → those go in user-level agent settings outside this repository.

**Rule of thumb**: if a rule applies across *every* change in this project, it belongs here. Otherwise it belongs closer to the change.
