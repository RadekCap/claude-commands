#!/bin/bash
# Auto-approve tool calls targeting the Obsidian vault.
# Used by /obsidian-summarize-session and similar commands so they
# run without interactive prompts.
#
# Requires: $OBSIDIAN_VAULT environment variable set to the vault root path.
# Install: add a PreToolUse hook in ~/.claude/settings.json pointing here.

if [[ -z "$OBSIDIAN_VAULT" ]]; then
  exit 0
fi

# Resolve to absolute path (no trailing slash)
VAULT=$(realpath "$OBSIDIAN_VAULT" 2>/dev/null) || exit 0
INPUT=$(cat)

TOOL=$(echo "$INPUT" | jq -r '.tool_name')

approve() {
  jq -n --arg reason "$1" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "allow",
      permissionDecisionReason: $reason
    }
  }'
  exit 0
}

# Allowed Bash commands scoped to the vault directory.
# Only auto-approve git/gh/mkdir commands that start with "cd <vault> &&".
VAULT_PREFIX="cd $VAULT && "

case "$TOOL" in
  Bash)
    CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
    if [[ "$CMD" == "$VAULT_PREFIX"git\ * ]] || \
       [[ "$CMD" == "$VAULT_PREFIX"gh\ * ]] || \
       [[ "$CMD" == "mkdir -p \"$VAULT"* ]] || \
       [[ "$CMD" == "mkdir -p $VAULT"* ]]; then
      approve "Obsidian vault operation: ${CMD%%&&*}"
    fi
    ;;
  Write|Edit)
    FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
    RESOLVED=$(realpath -m "$FILE" 2>/dev/null) || exit 0
    if [[ "$RESOLVED" == "$VAULT/"* ]]; then
      approve "Obsidian vault file: $FILE"
    fi
    ;;
esac

# Default: normal permission flow
exit 0
