---
description: Summarize the current Claude Code session and export it as an Obsidian note
---

# Obsidian Summarize Session

Summarize everything done in the current Claude Code session and save as an Obsidian note.

## Usage

```
/obsidian-summarize-session
```

## Configuration

- **Inbox path**: Use the `$OBSIDIAN_INBOX` environment variable (required)

## Steps

1. **Resolve the Inbox path**
   ```bash
   echo "$OBSIDIAN_INBOX"
   ```
   - If `$OBSIDIAN_INBOX` is not set, stop and tell the user to set it
   - Verify the directory exists

2. **Review the session**
   - Go through the entire conversation history
   - Identify: topics covered, PRs created/merged, decisions made, key learnings, files created/modified

3. **Write the note**
   - Filename: `<YYYY-MM-DD> Session - <short description>.md` in the `Claude Code Sessions/` subfolder of the Inbox path
   - Derive the short description from the main theme of the session
   - Use this structure:

   ```markdown
   # <YYYY-MM-DD> Session — <Short Description>

   ## Topics Covered
   ### 1. <Topic>
   - <key points>

   ## PRs Merged
   | PR | Repo | Description |
   |---|---|---|
   | [#N](url) | repo-name | what it did |

   ## Decisions Made
   - <decision with brief reasoning>

   ## Key Learnings
   - <anything new learned during the session>
   ```

   - Use Obsidian-flavored markdown
   - Be concise but complete — this is a reference for future you

4. **Auto-commit and push to the Obsidian repo**
   After writing the file, run the following git workflow in the Obsidian repo directory:
   - `git checkout -b feature/obsidian-session-<date>`
   - `git add` the new file
   - `git commit -m "Add session summary: <date>"` with `Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>`
   - `git push -u origin <branch>`
   - `gh pr create --title "Add session summary: <date>" --body "## Summary\n- Session summary exported from Claude Code"`
   - `gh pr merge --squash`
   - `git checkout main && git pull && git branch -d <branch>`

5. **Confirm completion**
   - Print the file path
   - Print the merged PR URL
