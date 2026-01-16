#!/bin/bash
# Claude Code session resume hook
# Displays context when resuming a session

input=$(cat)
source=$(echo "$input" | jq -r '.source // "unknown"')

if [ "$source" = "resume" ]; then
    # Get current directory info
    DIR_NAME=$(basename "$PWD")

    # Get git branch
    BRANCH=$(git branch --show-current 2>/dev/null)

    # Build context message
    echo "=== Session Resumed ==="
    echo "Directory: $DIR_NAME"
    [ -n "$BRANCH" ] && echo "Branch:    $BRANCH"
    echo ""
    echo "Tip: Run /todos to see your task list"
    echo "     Run /context for full context"
    echo "========================"
fi
