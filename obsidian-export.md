---
description: Export a topic analysis or brainstorm from the current conversation into an Obsidian note
---

# Obsidian Export

Export the current topic, brainstorm, or analysis from this conversation into an Obsidian note.

## Usage

```
/obsidian-export <title>
```

The title argument becomes the filename: `<Title>.md`

## Configuration

- **Inbox path**: Use the `$OBSIDIAN_INBOX` environment variable
- **Default**: `/Users/radoslavcap/git/obsidian-rh-acm/050 Inbox` if `$OBSIDIAN_INBOX` is not set

## Steps

1. **Resolve the Inbox path**
   ```bash
   echo "${OBSIDIAN_INBOX:-/Users/radoslavcap/git/obsidian-rh-acm/050 Inbox}"
   ```
   - Verify the directory exists
   - If it doesn't exist, stop and tell the user

2. **Gather content from the conversation**
   - Look at the recent discussion context in this session
   - Identify the topic, key points, decisions, and conclusions
   - If the conversation has multiple topics, focus on the most recent one unless the title suggests otherwise

3. **Write the note**
   - Filename: `<Title>.md` in the Inbox path
   - Use Obsidian-flavored markdown:
     - `# Heading` for the title
     - `[[wikilinks]]` for references to other notes when relevant
     - Standard markdown for everything else
   - Structure the note with clear headings and bullet points
   - Keep it concise — capture the essence, not the entire conversation

4. **Auto-commit and push to the Obsidian repo**
   After writing the file, run the following git workflow in the Obsidian repo directory (parent of the Inbox):
   ```bash
   # Navigate to the repo root
   cd "$(dirname "$OBSIDIAN_INBOX")"
   # Or use the resolved path
   ```
   - `git checkout -b feature/obsidian-export-<short-slug>`
   - `git add` the new file
   - `git commit -m "Add note: <Title>"`  with `Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>`
   - `git push -u origin <branch>`
   - `gh pr create --title "Add note: <Title>" --body "## Summary\n- Exported from Claude Code session"`
   - `gh pr merge --merge`
   - `git checkout main && git pull && git branch -d <branch>`

5. **Confirm completion**
   - Print the file path
   - Print the merged PR URL
