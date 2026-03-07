#!/bin/bash
# Setup script for claude-commands
# Configures commands, hooks, statusline, and settings for Claude Code.
#
# Usage:
#   git clone git@github.com:RadekCap/claude-commands.git ~/git/claude-commands
#   cd ~/git/claude-commands
#   ./setup.sh
#
# What it does:
#   1. Symlinks commands to ~/.claude/commands/
#   2. Copies statusline.sh to ~/.claude/
#   3. Patches ~/.claude/settings.json with hooks and statusline config
#
# Safe to re-run: skips steps that are already done.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"

echo "=== Claude Commands Setup ==="
echo "Source: $SCRIPT_DIR"
echo "Target: $CLAUDE_DIR"
echo ""

# Step 1: Create ~/.claude if needed
mkdir -p "$CLAUDE_DIR"

# Step 2: Symlink commands
if [ -L "$CLAUDE_DIR/commands" ]; then
    CURRENT_TARGET="$(readlink "$CLAUDE_DIR/commands")"
    if [ "$CURRENT_TARGET" = "$SCRIPT_DIR" ]; then
        echo "[OK] Commands symlink already correct"
    else
        echo "[UPDATE] Commands symlink points to $CURRENT_TARGET, updating..."
        rm "$CLAUDE_DIR/commands"
        ln -s "$SCRIPT_DIR" "$CLAUDE_DIR/commands"
        echo "[OK] Commands symlink updated"
    fi
elif [ -d "$CLAUDE_DIR/commands" ]; then
    echo "[WARN] $CLAUDE_DIR/commands/ is a directory (not a symlink)"
    echo "       To use shared commands, remove it first:"
    echo "       rm -rf $CLAUDE_DIR/commands"
    echo "       Then re-run this script."
else
    ln -s "$SCRIPT_DIR" "$CLAUDE_DIR/commands"
    echo "[OK] Commands symlinked"
fi

# Step 3: Copy statusline
cp "$SCRIPT_DIR/statusline.sh" "$CLAUDE_DIR/statusline.sh"
chmod +x "$CLAUDE_DIR/statusline.sh"
echo "[OK] Statusline installed"

# Step 4: Ensure hooks are executable
chmod +x "$SCRIPT_DIR/hooks/"*.sh
echo "[OK] Hooks are executable"

# Step 5: Patch settings.json
# Uses jq to merge hook configuration without overwriting existing settings.
if ! command -v jq &> /dev/null; then
    echo ""
    echo "[ERROR] jq is required to patch settings.json"
    echo "        Install with: brew install jq (macOS) or sudo apt install jq (Linux)"
    echo ""
    echo "Alternatively, manually add this to $SETTINGS_FILE:"
    echo ""
    cat <<MANUAL
{
  "statusLine": {
    "type": "command",
    "command": "$CLAUDE_DIR/statusline.sh"
  },
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "$SCRIPT_DIR/hooks/require-confirmation-before-pr.sh"
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "matcher": "resume",
        "hooks": [
          {
            "type": "command",
            "command": "$SCRIPT_DIR/hooks/on-resume.sh"
          }
        ]
      }
    ]
  }
}
MANUAL
    exit 1
fi

# Build the hooks config using the actual script directory
HOOKS_CONFIG=$(jq -n \
    --arg statusline "$CLAUDE_DIR/statusline.sh" \
    --arg pr_hook "$SCRIPT_DIR/hooks/require-confirmation-before-pr.sh" \
    --arg resume_hook "$SCRIPT_DIR/hooks/on-resume.sh" \
    '{
        statusLine: {
            type: "command",
            command: $statusline
        },
        hooks: {
            PreToolUse: [
                {
                    matcher: "Bash",
                    hooks: [
                        {
                            type: "command",
                            command: $pr_hook
                        }
                    ]
                }
            ],
            SessionStart: [
                {
                    matcher: "resume",
                    hooks: [
                        {
                            type: "command",
                            command: $resume_hook
                        }
                    ]
                }
            ]
        }
    }')

if [ -f "$SETTINGS_FILE" ]; then
    # Merge with existing settings (existing values win for non-hook fields)
    MERGED=$(jq -s '.[0] * .[1]' "$SETTINGS_FILE" <(echo "$HOOKS_CONFIG"))
    echo "$MERGED" > "$SETTINGS_FILE"
    echo "[OK] Settings updated (merged with existing)"
else
    echo "$HOOKS_CONFIG" > "$SETTINGS_FILE"
    echo "[OK] Settings created"
fi

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Installed:"
echo "  - Commands:   $CLAUDE_DIR/commands -> $SCRIPT_DIR"
echo "  - Statusline: $CLAUDE_DIR/statusline.sh"
echo "  - Hooks:"
echo "    - PreToolUse:   Block gh pr create (require confirmation)"
echo "    - SessionStart: Show context on resume"
echo ""
echo "Restart Claude Code to apply changes."
