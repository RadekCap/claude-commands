# Claude Commands

Shared Claude Code slash commands that work across all repositories.

## Included Commands

| Command | Description |
|---------|-------------|
| `/sync-main` | Sync local main branch with remote and optionally create a new feature branch |
| `/cleanup` | Cleanup local git repository by updating main and removing all other branches |
| `/implement-issue <number>` | Analyze a GitHub issue and create a pull request that implements the fix |
| `/copilot-review <pr-number>` | Process GitHub Copilot code review findings for a PR |

## Setup

### Option 1: Fresh Setup (no existing commands)

Use this if your repo doesn't have `.claude/commands/` yet.

**Claude Prompt** (copy and paste to Claude):

```
Add shared Claude commands to this repository as a git submodule.

Steps:
1. Create .claude directory if it doesn't exist: mkdir -p .claude
2. Add submodule: git submodule add https://github.com/RadekCap/claude-commands.git .claude/commands
3. Commit: git commit -m "Add shared Claude commands as submodule"
4. Push: git push

After completion, verify the commands work by typing /sync-main
```

**Manual Steps**:

```bash
mkdir -p .claude
git submodule add https://github.com/RadekCap/claude-commands.git .claude/commands
git commit -m "Add shared Claude commands as submodule"
git push
```

---

### Option 2: Replace Existing Local Commands

Use this if you already have `.claude/commands/` with manually copied command files.

**Claude Prompt** (copy and paste to Claude):

```
Replace local Claude commands with the shared submodule repository.

Steps:
1. Check for any local customizations in .claude/commands/ that should be preserved
2. Remove the existing commands directory: rm -rf .claude/commands
3. Stage the removal: git add .claude/commands
4. Add the shared repo as submodule: git submodule add https://github.com/RadekCap/claude-commands.git .claude/commands
5. Commit: git commit -m "Replace local Claude commands with shared submodule"
6. Push: git push

After completion, verify the commands work by typing /sync-main
```

**Manual Steps**:

```bash
# Remove existing commands
rm -rf .claude/commands
git add .claude/commands

# Add submodule
git submodule add https://github.com/RadekCap/claude-commands.git .claude/commands

# Commit and push
git commit -m "Replace local Claude commands with shared submodule"
git push
```

---

## Cloning Repositories with Submodules

When cloning a repo that uses this submodule:

```bash
# Clone with submodules in one command
git clone --recurse-submodules https://github.com/USER/REPO.git

# Or if already cloned without submodules
git submodule update --init --recursive
```

---

## Updating Commands

When commands are updated in this repository, pull the changes into your projects:

**Claude Prompt**:

```
Update the shared Claude commands submodule to the latest version.

Steps:
1. Update submodule: git submodule update --remote .claude/commands
2. Commit: git commit -am "Update shared Claude commands"
3. Push: git push
```

**Manual Steps**:

```bash
git submodule update --remote .claude/commands
git commit -am "Update shared Claude commands"
git push
```

---

## Adding New Commands

To add a new command to the shared repository:

1. Clone this repo: `git clone https://github.com/RadekCap/claude-commands.git`
2. Create new command file: `your-command.md`
3. Commit and push
4. Update submodule in each project (see "Updating Commands" above)

---

## Project-Specific Commands

If you need commands specific to one project, you have two options:

1. **Override in project**: Create a command with the same name in a different location (project commands take precedence)
2. **Keep separate**: Store project-specific commands in a different directory

---

## Global CLAUDE.md (Communication Preferences)

This repo includes a `CLAUDE.md` file with personal preferences that apply across all Claude Code sessions.

### Setup on Each Computer

```bash
# In any project with the submodule, update it:
git submodule update --remote

# Then create the symlink (one-time per computer):
ln -sf /path/to/any-project/.claude/commands/CLAUDE.md ~/.claude/CLAUDE.md
```

### How It Works

- Your communication preferences are now in the shared `claude-commands` repo
- The symlink makes them global for all Claude Code sessions on this computer
- When you `git submodule update --remote` in any project, you get the latest preferences

---

## Troubleshooting

### Commands not showing up after clone

```bash
git submodule update --init --recursive
```

### Submodule shows as empty directory

```bash
git submodule init
git submodule update
```

### Detached HEAD in submodule

This is normal for submodules. The parent repo tracks a specific commit, not a branch.
