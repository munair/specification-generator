#!/bin/bash
# PreToolUse hook: blocks Read/Bash access to .env files (but NOT .env.example)
# This catches Bash-based access (cat .env, source .env) that permission deny rules miss.

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Combine file_path and command for pattern matching
TARGET="$FILE_PATH $COMMAND"

# Allow .env.example explicitly
if [[ "$TARGET" =~ \.env\.example ]]; then
  exit 0
fi

# Block .env, .env.local, .env.production, .env.*, etc.
if [[ "$TARGET" =~ \.env($|[[:space:]]|\.| ) ]]; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "Access to .env files is blocked — use .env.example for reference"
    }
  }'
  exit 0
fi

exit 0
