#!/bin/bash
# Claude Code status line script
# Shows: [Model] Directory | Branch | Context% | Cost | Learning Progress

input=$(cat)

# Extract JSON values
MODEL=$(echo "$input" | jq -r '.model.display_name // "Claude"')
PROJECT_DIR=$(echo "$input" | jq -r '.workspace.project_dir // "."')
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // "0"')
CTX_PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)

# Get directory name
DIR_NAME=$(basename "$PROJECT_DIR" 2>/dev/null || echo "unknown")

# Get git branch if in repo
BRANCH=""
if [ -d "$PROJECT_DIR/.git" ] || git -C "$PROJECT_DIR" rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git -C "$PROJECT_DIR" branch --show-current 2>/dev/null)
    [ -z "$BRANCH" ] && BRANCH=$(git -C "$PROJECT_DIR" rev-parse --short HEAD 2>/dev/null)
fi

# Format cost
if [ "$COST" != "0" ] && [ -n "$COST" ]; then
    COST_FMT=$(printf "$%.2f" "$COST")
else
    COST_FMT=""
fi

# Format context usage
CTX_FMT=""
if [ "$CTX_PCT" != "0" ] && [ -n "$CTX_PCT" ]; then
    CTX_FMT="ctx:${CTX_PCT}%"
fi

# Learning progress from project's active plan
LEARN_FMT=""
PLAN_FILE=""
ACTIVE_PLAN_MARKER="$PROJECT_DIR/.claude/active-plan"
if [ -f "$ACTIVE_PLAN_MARKER" ]; then
    PLAN_NAME=$(cat "$ACTIVE_PLAN_MARKER" 2>/dev/null | tr -d '[:space:]')
    [ -n "$PLAN_NAME" ] && PLAN_FILE="$HOME/.claude/plans/$PLAN_NAME"
    [ ! -f "$PLAN_FILE" ] && PLAN_FILE=""
fi
if [ -n "$PLAN_FILE" ]; then
        DONE=$(grep -c '^\- \[x\]' "$PLAN_FILE" 2>/dev/null)
        [ -z "$DONE" ] && DONE=0
        TODO=$(grep -c '^\- \[ \]' "$PLAN_FILE" 2>/dev/null)
        [ -z "$TODO" ] && TODO=0
        TOTAL=$((DONE + TODO))
        if [ "$TOTAL" -gt 0 ]; then
            CURRENT=$(grep '^\- \[ \]' "$PLAN_FILE" 2>/dev/null | head -1 | sed 's/^- \[ \] \*\*//' | sed 's/\*\*.*//' | cut -c1-20)
            FILLED=$((DONE * 10 / TOTAL))
            BAR=""
            for i in $(seq 1 10); do
                [ "$i" -le "$FILLED" ] && BAR="${BAR}▓" || BAR="${BAR}░"
            done
            LEARN_FMT="[${DONE}/${TOTAL}] ${BAR} ▶ ${CURRENT}"
        fi
fi

# Build output
OUTPUT="[$MODEL] $DIR_NAME"
[ -n "$BRANCH" ] && OUTPUT="$OUTPUT | $BRANCH"
[ -n "$CTX_FMT" ] && OUTPUT="$OUTPUT | $CTX_FMT"
[ -n "$COST_FMT" ] && OUTPUT="$OUTPUT | $COST_FMT"
[ -n "$LEARN_FMT" ] && OUTPUT="$OUTPUT | $LEARN_FMT"

echo "$OUTPUT"
