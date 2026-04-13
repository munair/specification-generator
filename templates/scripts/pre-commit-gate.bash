#!/usr/bin/env bash
#
# pre-commit-gate.bash — reference PreToolUse hook for git commit gating.
#
# What it does
# ------------
# This script is the body of a Claude Code PreToolUse hook that matches
# tool name `Bash`. It reads the hook input JSON from stdin, inspects the
# Bash command the agent is about to run, and only runs the project's
# test / lint / type-check suite when the command actually contains
# `git commit`. On any failure it emits a deny decision so the commit is
# blocked. On success it emits nothing and exits 0 so the commit proceeds.
#
# How to wire it up
# -----------------
# 1. Copy this file into your project at `.claude/hooks/pre-commit-gate.bash`.
# 2. Register it in `.claude/settings.json` under `hooks.PreToolUse`:
#
#    {
#      "hooks": {
#        "PreToolUse": [
#          {
#            "matcher": "Bash",
#            "hooks": [
#              { "type": "command", "command": "bash .claude/hooks/pre-commit-gate.bash" }
#            ]
#          }
#        ]
#      }
#    }
#
# 3. Adapt the TEST_COMMANDS block below to your project. Delete what
#    does not apply. A pure backend repository probably does not run
#    `npm test`; a Python project has no `typecheck` in the Node.js
#    sense.
#
# Design notes
# ------------
# - Fail closed on parse errors. If `jq` is missing, if stdin cannot be
#   read, or if the input shape is unexpected, the hook denies rather
#   than silently allowing.
# - Short-circuit on non-commit Bash calls. Running the full test suite
#   for every `ls` or `grep` the agent issues would be absurd.
# - The deny JSON shape is the Claude Code schema for a PreToolUse
#   hookSpecificOutput with permissionDecision=deny. Other harnesses
#   (Codex, Cursor, etc.) may expect a different shape.

set -euo pipefail

# --- Adapt this block to your project ----------------------------------
TEST_COMMANDS=(
  "npm test"
  "npm run lint"
  "npm run typecheck"
)
# -----------------------------------------------------------------------

emit_deny() {
  local reason="$1"
  if command -v jq >/dev/null 2>&1; then
    jq -nc --arg reason "$reason" '{
      hookSpecificOutput: {
        hookEventName: "PreToolUse",
        permissionDecision: "deny",
        permissionDecisionReason: $reason
      }
    }'
  else
    printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s"}}\n' "$reason"
  fi
  exit 0
}

if ! command -v jq >/dev/null 2>&1; then
  emit_deny "pre-commit-gate.bash requires jq, which is not installed on this system."
fi

INPUT="$(cat || true)"
if [[ -z "${INPUT}" ]]; then
  emit_deny "pre-commit-gate.bash received empty stdin — hook input is malformed."
fi

COMMAND="$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null || true)"
if [[ -z "${COMMAND}" ]]; then
  # Not a Bash tool call with a command field, or jq failed to parse it.
  # Allow by default — this hook only cares about git commit gating.
  exit 0
fi

# Short-circuit: only run the test suite when the agent is about to commit.
if [[ "$COMMAND" != *"git commit"* ]]; then
  exit 0
fi

# Run the configured test / lint / typecheck commands in order.
# The first failure denies the commit.
for cmd in "${TEST_COMMANDS[@]}"; do
  if ! eval "$cmd" >/dev/null 2>&1; then
    emit_deny "pre-commit-gate.bash: '$cmd' failed — fix before committing."
  fi
done

exit 0
