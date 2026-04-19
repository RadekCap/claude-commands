---
description: Generate a weekly status report from GitHub and Jira activity, formatted for Slack
---

# Weekly Report

Generate a weekly status report by gathering activity from GitHub (PRs, issues) and Jira, then format it for pasting into Slack.

## Usage

```
/weekly-report
```

Optionally provide a date range:
```
/weekly-report 2026-03-24
```

If no start date is provided, default to 7 days ago.

## Data Sources

### GitHub

1. **Merged PRs** — PRs merged in the date range:
   ```bash
   gh pr list --state merged --search "merged:>=$START_DATE" --json number,title,url,mergedAt --limit 30
   ```

2. **Open PRs** — Currently open PRs:
   ```bash
   gh pr list --state open --json number,title,url --limit 20
   ```

3. **Closed Issues** — Issues closed in the date range:
   ```bash
   gh issue list --state closed --search "closed:>=$START_DATE" --json number,title,url --limit 20
   ```

4. **GHA Workflow Status** — Check deployment workflow results:
   ```bash
   gh run list --workflow "Full Cluster Deployment (ARO)" --limit 3 --json status,conclusion,createdAt
   gh run list --workflow "Full Cluster Deployment (ROSA)" --limit 3 --json status,conclusion,createdAt
   ```

### Jira

Read credentials from `credentials.json` in the project root:
```bash
EMAIL=$(python3 -c "import json; d=json.load(open('credentials.json')); print(d['jira']['email'])")
TOKEN=$(python3 -c "import json; d=json.load(open('credentials.json')); print(d['jira']['token'])")
```

**IMPORTANT**: Use the v3 search API — v2 search has been removed by Atlassian:

1. **Resolved JIRAs** — Issues resolved in the date range:
   ```bash
   curl -s -u "$EMAIL:$TOKEN" -H "Content-Type: application/json" \
     "https://redhat.atlassian.net/rest/api/3/search/jql?jql=project=ARO+AND+labels=CAPZ+AND+statusCategory=Done+AND+resolved+%3E%3D+%22$START_DATE%22+ORDER+BY+resolved+DESC&maxResults=30&fields=key,summary,status,resolution"
   ```

2. **Open/In-Progress JIRAs** — Active issues:
   ```bash
   curl -s -u "$EMAIL:$TOKEN" -H "Content-Type: application/json" \
     "https://redhat.atlassian.net/rest/api/3/search/jql?jql=project=ARO+AND+labels=CAPZ+AND+assignee=5fabb5fdecdae600685b01d6+AND+statusCategory+!=+Done+ORDER+BY+priority+DESC&maxResults=30&fields=key,summary,status"
   ```

Note: Individual issue GET still works on v2 (`/rest/api/2/issue/ARO-XXXXX`). Only JQL search requires v3.

### Weekly Notes (Manual Highlights)

Read `050 Inbox/weekly-notes.md` from the Obsidian vault. This file contains manually added notes — context, achievements, and items that don't appear in GitHub or Jira. These become the **Highlights** section at the top of the report.

After the report is confirmed by the user, clear the `## Notes` section of this file (keep the frontmatter and description intact).

### External PRs

Check for any notable PRs in related repos (e.g., openshift/release):
- Only include if there's a known PR to check (from conversation context or memory)
- Don't search speculatively

## Output Format

Format the output for **Slack copy-paste** — use Slack emoji syntax and full URLs (not markdown links, as those get lost when pasting):

```
*Highlights* :star:
- Item from weekly-notes (context not captured by GitHub/Jira)

*Done* :white_check_mark:

*<Headline achievement>* — brief description

*GHA Deployment Workflows* — Both passing on main
- Full Cluster Deployment (ARO) — :white_check_mark: success
- Full Cluster Deployment (ROSA) — :white_check_mark: success

*Merged PRs*
- https://github.com/org/repo/pull/NNN — title
- https://github.com/org/repo/pull/NNN — title

*Closed JIRAs*
- ARO-XXXXX — title
- ARO-XXXXX — title

*In progress* :soon:

*<Current focus area>* — brief description

*Open PRs*
- https://github.com/org/repo/pull/NNN — title
- https://github.com/org/repo/pull/NNN — title

*JIRAs In Progress*
- ARO-XXXXX — title
- ARO-XXXXX — title

*Next* :soon:

- Item 1
- Item 2

*Blockers* :warning:
- None currently
```

## Formatting Rules

1. **Use full URLs** for PRs — `https://github.com/org/repo/pull/NNN` not `[#NNN](url)`. Slack renders these as clickable links, and they survive copy-paste.
2. **Use Slack bold** — `*bold*` not `**bold**`
3. **Use Slack emoji** — `:white_check_mark:`, `:soon:`, `:warning:`
4. **Group dependabot/automated PRs** — list them on one line with all URLs comma-separated
5. **Separate manual PRs** — one per line with description
6. **Keep descriptions short** — one line per item
7. **Highlight key achievements** — lead with the most important accomplishment

## Steps

1. **Determine date range**
   - Use provided start date or default to 7 days ago
   - Calculate: `date -d '7 days ago' +%Y-%m-%d`

2. **Read weekly notes**
   - Read `050 Inbox/weekly-notes.md` from the Obsidian vault (path relative to the vault root)
   - Extract bullet points from the `## Notes` section
   - These become the *Highlights* section at the top of the report
   - If the file is empty or has no notes, skip the Highlights section

3. **Gather GitHub data**
   - Fetch merged PRs, open PRs, closed issues, workflow status (in parallel)

4. **Gather Jira data**
   - Read credentials from `credentials.json`
   - Fetch resolved and open issues via v3 search API

5. **Check previous status** (if available in memory)
   - Compare with previous "Next" items to track continuity
   - Carry forward items that are still in progress

6. **Compose the report**
   - Follow the output format above — lead with Highlights from weekly notes
   - Print the report to the terminal
   - Wait for user confirmation or edits before considering done

7. **Clear weekly notes**
   - After the user confirms the report, clear the `## Notes` section in `050 Inbox/weekly-notes.md`
   - Keep the frontmatter and description header intact

## Tips

- If Jira search returns 0 results unexpectedly, check if the API token needs regeneration
- The "Next" section often carries forward between weeks — check memory for previous status
- GHA workflows may show "cancelled" for no-change runs — note this as grey/cancelled, not failure
