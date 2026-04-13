#!/usr/bin/env bash
#
# verify-archival.bash — reference Stop hook that refuses to let a
# session end cleanly if any active implementation log still has
# unchecked tasks.
#
# What it does
# ------------
# Claude Code's `Stop` event fires when the agent finishes its turn.
# This script scans `documentation/tasks/active/implementing-*.md` for
# any remaining `- [ ]` checkboxes. If any are found, it emits a deny
# decision so the session cannot archive without the ARCHIVAL PROTOCOL
# being followed end-to-end. If all boxes are checked (or no
# implementing files exist), it exits 0 silently and the session ends
# normally.
#
# How to wire it up
# -----------------
# 1. Copy this file into your project at `scripts/verify-archival.bash`.
# 2. Register it in `.claude/settings.json` under `hooks.Stop`:
#
#    {
#      "hooks": {
#        "Stop": [
#          {
#            "hooks": [
#              { "type": "command", "command": "bash scripts/verify-archival.bash" }
#            ]
#          }
#        ]
#      }
#    }
#
# Design notes
# ------------
# - Fail closed on error. A missing directory is not an error (nothing
#   to verify). A file that cannot be read IS an error — deny rather
#   than silently pass.
# - Report every offending file in the denial reason, so the user sees
#   exactly what still needs archival.
# - The hook itself never exits non-zero. A non-zero exit from a Stop
#   hook is surfaced as a harness error rather than a blocking decision,
#   which defeats the purpose. Always exit 0 and express the decision
#   in the emitted JSON.

set -euo pipefail

ACTIVE_DIR="documentation/tasks/active"

emit_deny() {
  local reason="$1"
  if command -v jq >/dev/null 2>&1; then
    jq -nc --arg reason "$reason" '{
      hookSpecificOutput: {
        hookEventName: "Stop",
        permissionDecision: "deny",
        permissionDecisionReason: $reason
      }
    }'
  else
    printf '{"hookSpecificOutput":{"hookEventName":"Stop","permissionDecision":"deny","permissionDecisionReason":"%s"}}\n' "$reason"
  fi
  exit 0
}

if [[ ! -d "$ACTIVE_DIR" ]]; then
  exit 0
fi

offenders=()
while IFS= read -r -d '' file; do
  if grep -q -- "- \[ \]" "$file" 2>/dev/null; then
    count="$(grep -c -- "- \[ \]" "$file" 2>/dev/null || printf '0')"
    offenders+=("$file ($count unchecked)")
  fi
done < <(find "$ACTIVE_DIR" -maxdepth 1 -type f -name 'implementing-*.md' -print0 2>/dev/null || true)

if [[ "${#offenders[@]}" -eq 0 ]]; then
  exit 0
fi

reason="ARCHIVAL PROTOCOL violation — the following implementation logs still have unchecked tasks and must be completed or archived before this session can end: ${offenders[*]}. See guidelines/implementation-tasks-creation-guidelines.md for the archival procedure."
emit_deny "$reason"
