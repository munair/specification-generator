#!/bin/bash
# PreToolUse hook: blocks access to .env files (but NOT .env.example).
#
# Covers three attack surfaces:
#   1. Direct file access via Read/Write/Edit (file_path field)
#   2. Search access via Grep/Glob (path field — different key than file_path)
#   3. Bash command exfiltration (command field: cat, source, env, printenv, etc.)

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
TOOL_PATH=$(echo "$INPUT" | jq -r '.tool_input.path // empty')   # Grep/Glob use "path", not "file_path"
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Combine all path-bearing fields for pattern matching
TARGET="$FILE_PATH $TOOL_PATH $COMMAND"

deny() {
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "Access to .env files is blocked — use .env.example for reference"
    }
  }'
  exit 0
}

# Allow .env.example explicitly (check before the broad block below)
if [[ "$TARGET" =~ \.env\.example ]]; then
  exit 0
fi

# Block any path that contains a .env file:
#   - Must be a path segment start (beginning of string, slash, or whitespace)
#   - Matches .env, .env.local, .env.production, .envrc, etc.
if [[ "$TARGET" =~ (^|[[:space:]/])\.env ]]; then
  deny
fi

# Block Bash commands that can dump environment variables without referencing .env by name
if [[ "$TOOL_NAME" == "Bash" ]]; then
  # Block: env, printenv, export (when used to dump all vars)
  if [[ "$COMMAND" =~ (^|[[:space:];|&])(env|printenv)([[:space:]]|$|;|&|\|) ]]; then
    deny
  fi
fi

exit 0
