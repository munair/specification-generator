#!/bin/bash
# PreToolUse hook: blocks access to .env files (but NOT .env.example).
#
# Attack surfaces covered:
#   1. File access via Read/Write/Edit                   (file_path)
#   2. Search via Grep/Glob                              (path)
#   3. Notebook access via NotebookEdit                  (notebook_path)
#   4. Bash exfiltration: cat, source, redirects, env-dump, /proc/environ,
#                         ps with env flags, tar/rsync/cp-r/zip of repository root
#   5. URL / prompt leakage via WebFetch/WebSearch/Task  (url, prompt)
#
# Design notes:
#   - Fails CLOSED on jq/parse errors, missing input, or any unexpected state.
#   - `.env.example` allowlist applies to path fields ONLY, not to commands
#     (so decoy strings like `cat .env # see .env.example` cannot bypass).
#   - Shell quote characters are stripped before matching so that
#     `bash -c 'printenv'` and `sh -c "cat .env"` are detected.
#   - Case-insensitive matching catches `.ENV` on case-insensitive filesystems.
#   - Denials are logged to ~/.claude/protect-env.log for audit.

LOG_FILE="${HOME}/.claude/protect-env.log"

log_deny() {
  mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null || true
  printf '[%s] deny tool=%s reason=%s\n' \
    "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    "${TOOL_NAME:-?}" \
    "$1" >> "$LOG_FILE" 2>/dev/null || true
}

emit_deny_json() {
  local msg="$1"
  if command -v jq >/dev/null 2>&1; then
    jq -nc --arg reason "$msg" '{
      hookSpecificOutput: {
        hookEventName: "PreToolUse",
        permissionDecision: "deny",
        permissionDecisionReason: $reason
      }
    }'
  else
    printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s"}}\n' "$msg"
  fi
}

deny() {
  local reason="${1:-.env access blocked}"
  log_deny "$reason"
  emit_deny_json "Blocked: ${reason}. Use .env.example for reference."
  exit 0
}

# Strip shell quote characters and backslashes. This is what makes
# `bash -c 'printenv'` match `printenv`.
strip_quotes() {
  local s="$1"
  s="${s//\'/ }"
  s="${s//\"/ }"
  s="${s//\\/ }"
  printf '%s' "$s"
}

# --- Read and validate input ------------------------------------------------

INPUT=$(cat 2>/dev/null)
if [[ -z "$INPUT" ]]; then
  deny "empty hook input"
fi

if ! command -v jq >/dev/null 2>&1; then
  deny "jq not available (cannot safely parse tool input)"
fi

if ! echo "$INPUT" | jq -e . >/dev/null 2>&1; then
  deny "unparseable hook input"
fi

TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
TOOL_PATH=$(echo "$INPUT" | jq -r '.tool_input.path // empty')
NOTEBOOK_PATH=$(echo "$INPUT" | jq -r '.tool_input.notebook_path // empty')
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
URL=$(echo "$INPUT" | jq -r '.tool_input.url // empty')
PROMPT=$(echo "$INPUT" | jq -r '.tool_input.prompt // empty')

# Case-insensitive matching (macOS HFS+ is CI by default; `.ENV` == `.env`)
shopt -s nocasematch

PATH_FIELDS=$(strip_quotes "$FILE_PATH $TOOL_PATH $NOTEBOOK_PATH")
OTHER_FIELDS=$(strip_quotes "$COMMAND $URL $PROMPT")
BASH_CMD=$(strip_quotes "$COMMAND")

# Path-segment boundary: start, slash, whitespace, redirect, pipe, semicolon,
# ampersand, paren, backtick, dollar-sign. Covers `cat .env`, `<.env`, `.env`,
# `./path/.env`, `|.env`, `$(cat .env)`, etc.
BOUNDARY='(^|[[:space:]/<>|&;()`$])'
ENV_RE="${BOUNDARY}\\.env"
EXAMPLE_RE="${BOUNDARY}\\.env\\.example([[:space:]/]|\$)"

# --- 1) Path fields: allow .env.example, block other .env* ------------------

if [[ -n "${PATH_FIELDS// }" ]]; then
  if [[ "$PATH_FIELDS" =~ $EXAMPLE_RE ]]; then
    : # path-field allowlist hit — skip .env block for this field set
  elif [[ "$PATH_FIELDS" =~ $ENV_RE ]]; then
    deny "path field references .env"
  fi
fi

# --- 2) Command / URL / prompt: NO allowlist (decoy bypass risk) ------------

if [[ -n "${OTHER_FIELDS// }" ]] && [[ "$OTHER_FIELDS" =~ $ENV_RE ]]; then
  deny "command/url/prompt references .env"
fi

# --- 3) Bash-specific dump and exfiltration patterns ------------------------

if [[ "$TOOL_NAME" == "Bash" ]]; then
  CMD_BOUNDARY='(^|[[:space:];|&()`$/<>])'

  DUMP_RE="${CMD_BOUNDARY}(env|printenv)([[:space:]]|\$|\||;|&|\))"
  if [[ "$BASH_CMD" =~ $DUMP_RE ]]; then
    deny "env/printenv command"
  fi

  EXPORT_RE="${CMD_BOUNDARY}export[[:space:]]+-p"
  if [[ "$BASH_CMD" =~ $EXPORT_RE ]]; then
    deny "export -p dumps environment"
  fi

  DECLARE_RE="${CMD_BOUNDARY}declare[[:space:]]+-x"
  if [[ "$BASH_CMD" =~ $DECLARE_RE ]]; then
    deny "declare -x dumps environment"
  fi

  if [[ "$BASH_CMD" =~ /proc/[^[:space:]]*/environ ]]; then
    deny "/proc/*/environ access"
  fi

  # ps with env-exposing flags:
  #   `ps -E`       (macOS env flag)
  #   `ps e`, `ps eww`, `ps eaw`, `ps eaww`  (BSD-style standalone `e` arg)
  #   `ps ax e`     (BSD flags then standalone `e`)
  PS_DASH_E_RE='(^|[[:space:];|&(])ps[[:space:]]+[^|;&]*-E([[:space:]]|$|\|)'
  PS_STANDALONE_E_RE='(^|[[:space:];|&(])ps[[:space:]]+([^|;&]*[[:space:]])?e(ww|aww|aw)?([[:space:]]|$|\|)'
  if [[ "$BASH_CMD" =~ $PS_DASH_E_RE ]] || [[ "$BASH_CMD" =~ $PS_STANDALONE_E_RE ]]; then
    deny "ps with env-exposing flags"
  fi

  # Archive/backup tools sourced from repository root (.env copied under a different name)
  ARCHIVE_TOOL_RE='(^|[[:space:];|&(])(tar|rsync|cpio)[[:space:]]'
  REPO_ROOT_SOURCE_RE='([[:space:]=])(\.|\./|\$PWD|\$\(pwd\)|`pwd`)([[:space:]]|$)'
  if [[ "$BASH_CMD" =~ $ARCHIVE_TOOL_RE ]] && [[ "$BASH_CMD" =~ $REPO_ROOT_SOURCE_RE ]]; then
    deny "archive tool reads repository root (may include .env)"
  fi

  # zip -r / zip -9r / zip -rq etc.
  ZIP_RE='(^|[[:space:];|&(])zip[[:space:]]+-[^[:space:]]*r'
  if [[ "$BASH_CMD" =~ $ZIP_RE ]]; then
    deny "zip -r may include .env"
  fi

  # cp -r . / cp -r ./ / cp -r $PWD
  CP_RE='(^|[[:space:];|&(])cp[[:space:]]+-[^[:space:]]*r[^[:space:]]*[[:space:]]+(\.|\./|\$PWD|\$\(pwd\)|`pwd`)([[:space:]]|$)'
  if [[ "$BASH_CMD" =~ $CP_RE ]]; then
    deny "cp -r from repository root"
  fi
fi

exit 0
