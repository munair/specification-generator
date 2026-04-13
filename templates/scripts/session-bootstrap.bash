#!/usr/bin/env bash
#
# session-bootstrap.bash — reference SessionStart hook that prints a
# one-line situational summary at the top of every agent session.
#
# What it does
# ------------
# Prints a single line summarizing the current workspace state so the
# agent (and the human watching) can orient quickly:
#
#   [branch] feature/account-summary | PRD: feature-specification-foo.md | 3 unchecked tasks
#
# It is strictly read-only and has no side effects. It does not block
# the session — any failure exits 0 silently.
#
# How to wire it up
# -----------------
# 1. Copy this file into your project at `scripts/session-bootstrap.bash`.
# 2. Register it in `.claude/settings.json` under `hooks.SessionStart`:
#
#    {
#      "hooks": {
#        "SessionStart": [
#          {
#            "hooks": [
#              { "type": "command", "command": "bash scripts/session-bootstrap.bash" }
#            ]
#          }
#        ]
#      }
#    }

set -u
set +e

branch="$(git branch --show-current 2>/dev/null || printf 'unknown')"

active_prd="none"
if [[ -d documentation/specifications/active ]]; then
  newest_prd="$(find documentation/specifications/active -maxdepth 1 -type f -name 'feature-specification-*.md' -print 2>/dev/null | sort | tail -n 1)"
  if [[ -n "$newest_prd" ]]; then
    active_prd="$(basename "$newest_prd")"
  fi
fi

unchecked_total=0
if [[ -d documentation/tasks/active ]]; then
  while IFS= read -r -d '' file; do
    count="$(grep -c -- "- \[ \]" "$file" 2>/dev/null || printf '0')"
    unchecked_total=$((unchecked_total + count))
  done < <(find documentation/tasks/active -maxdepth 1 -type f -name 'implementing-*.md' -print0 2>/dev/null)
fi

printf '[branch] %s | PRD: %s | %d unchecked tasks\n' "$branch" "$active_prd" "$unchecked_total"
exit 0
