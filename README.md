# Claude Commands

Shared Claude Code commands, hooks, and settings that work across all repositories and machines.

## TL;DR

### A. New computer

```bash
git clone git@github.com:RadekCap/claude-commands.git ~/git/claude-commands
cd ~/git/claude-commands
./setup.sh
```

### B. Already set up, just need to update

Nothing to do — updates are pulled automatically at the start of every Claude Code session.

---

## What you get

| What | How it works |
|---|---|
| Slash commands (`/cleanup`, `/sync-main`, etc.) | `~/.claude/commands/` symlinked to this repo |
| Global instructions (coaching, git rules) | `~/.claude/CLAUDE.md` symlinked to this repo |
| Hooks (PR confirmation, session resume, auto-sync) | Paths in `~/.claude/settings.json` |
| Status line (model, dir, branch, cost) | `~/.claude/statusline.sh` |

## Included commands

| Command | What it does |
|---|---|
| `/sync-main` | Sync main with remote, optionally create feature branch |
| `/cleanup` | Update main, delete all other local branches |
| `/implement-issue <number>` | Analyze a GitHub issue and create a PR |
| `/prepare-worktree <number>` | Create isolated git worktree for an issue |
| `/close-worktree <number>` | Clean up worktree after PR merge |
| `/copilot-review <pr>` | Process GitHub Copilot review findings |
| `/context` | Show current directory, branch, and todos |

## Included hooks

| Hook | Trigger | What it does |
|---|---|---|
| `require-confirmation-before-pr.sh` | Before `gh pr create` | Forces Claude to show PR description and ask for approval |
| `on-resume.sh` | Session resume | Shows directory and branch context |
| `sync-shared-commands.sh` | Every session start | Auto-pulls this repo from GitHub |

## Adding a new command

1. Create `your-command.md` in this repo
2. Commit and push
3. It's automatically available everywhere (directory symlink + auto-sync)

## How auto-sync works

Every Claude Code session runs `git pull --ff-only` on this repo. If you pushed changes from another machine, they're picked up automatically. If offline, it silently skips.
