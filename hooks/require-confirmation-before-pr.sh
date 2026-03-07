#!/bin/bash
# PreToolUse hook: Block 'gh pr create' commands
# Forces Claude to show the PR description and wait for user confirmation.
#
# How it works:
# - Intercepts Bash tool calls containing 'gh pr create'
# - Returns a deny decision with the full command shown
# - Claude must print the PR description and ask for explicit approval
#
# Install: Add to ~/.claude/settings.json hooks section
# See: https://code.claude.com/docs/en/hooks

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

# Only block when 'gh pr create' is an actual command being executed,
# not when it appears inside commit messages, heredocs, or string arguments.
#
# Strategy: strip everything inside quotes and heredocs, then check what remains.
# Simpler approach: check if any line starts with 'gh pr create' (possibly after
# whitespace or shell operators like && || ;), which covers real invocations.
# Lines where it appears mid-argument (e.g., git commit -m "...gh pr create...")
# won't match because 'gh' won't be at a command position.
if echo "$COMMAND" | grep -qE '^\s*gh\s+pr\s+create' || \
   echo "$COMMAND" | grep -qE '(&&|\|\||;)\s*gh\s+pr\s+create'; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "BLOCKED: Print the full PR description to the terminal and get explicit user approval before creating the PR."
    }
  }'
else
  exit 0
fi
