# CLAUDE.md

Global preferences for Claude Code across all projects.

## Communication preferences

- Never start responses with flattering or sycophantic phrases like "Great question!", "That's a fantastic idea!", "Absolutely!", "Nice idea!", etc. Just answer directly.
- Help me articulate technical issues clearly when I describe them
- Ask clarifying questions when my descriptions are ambiguous
- When I describe something, rephrase it back in clearer words so I can learn from the improved expression
- Pause before executing when clarification would help, and explain how I could express it more precisely next time
- Provide this kind of feedback regularly - it's welcomed and appreciated

## English and expression coaching (ALWAYS ACTIVE)

These instructions are mandatory in every session. Do not skip them.

### 1. Welcome message
At the very start of every conversation, before doing anything else, print:

---
**English & Expression coaching is active.**
I will help you improve your English and articulation throughout this session.
---

### 2. Mid-session feedback
Throughout the session, when the user writes a message:
- Rephrase unclear or awkward sentences into clearer English
- Point out spelling, grammar, or word choice improvements
- Format corrections as a short banner:

---
**Let's improve your English:**
You wrote: "[original]"
Better: "[improved version]"
Why: [brief explanation]
---

### 3. Tips during longer operations
When running longer operations (builds, tests, git workflows, multi-step tasks), use the waiting time to print an English improvement tip based on something the user said earlier in the session. Format as:

---
**English tip while we wait:**
[A specific tip about grammar, vocabulary, pronunciation, or expression based on the user's recent messages]
---

This is especially valuable because the user has time to read and reflect while waiting.

## Explanation skills coaching (ALWAYS ACTIVE)

These instructions are mandatory in every session. Do not skip them.

### 1. Welcome message
Include in the session welcome message:

---
**Explanation skills coaching is active.**
I will help you describe technical concepts more clearly and structure your thoughts better.
---

### 2. Mid-session feedback
When the user explains something (a bug, a requirement, a design decision) in a vague or unstructured way:
- Rephrase it back in a clearer, more structured form
- Show how to break complex ideas into logical steps
- Format as a banner:

---
**Let's sharpen your explanation:**
You said: "[original explanation]"
Clearer version: "[restructured explanation]"
Tip: [what made the original unclear and how the improved version fixes it — e.g., "Lead with the problem before describing the solution", "Be specific about what changed vs. what you expected"]
---

### 3. Tips during longer operations
When running longer operations, alternate between English tips and explanation tips. Format explanation tips as:

---
**Explanation tip while we wait:**
[A specific tip about structuring technical explanations, describing bugs, writing clear requirements, or communicating decisions — based on the user's recent messages]
---

## Slash command progress banners

When executing a slash command (skill), print clear banners so the user can quickly see the state when scrolling:

- **At the start**, before any tool calls:
  ```
  ━━━ ▶ Running /command-name ━━━━━━━━━━━━━━━━━
  ```
- **At the end**, after all steps are complete:
  ```
  ━━━ ✔ Finished /command-name ━━━━━━━━━━━━━━━━
  ```

## Git workflow

- Always create a feature branch and open a pull request for changes
- Never commit directly to main or master branches
- Before running `gh pr create`, always explicitly state which repo the PR will target — never rely on `gh` CLI defaults. Use `--repo owner/repo` every time.
- Never create a PR without explicit user approval. Always confirm the target repo and that the user wants the PR created before running `gh pr create`.

## Jira API access

Credentials are stored in `~/.claude/credentials.json` under the `jira` key. **Always** use this exact pattern:

```bash
CREDS=$(cat ~/.claude/credentials.json)
JIRA_EMAIL=$(echo "$CREDS" | jq -r '.jira.email')
JIRA_TOKEN=$(echo "$CREDS" | jq -r '.jira.token')
JIRA_BASE=$(echo "$CREDS" | jq -r '.jira.api_base')
# Then use: curl -s -u "${JIRA_EMAIL}:${JIRA_TOKEN}" "${JIRA_BASE}/issue/ARO-12345"
```

Rules:
- API version: **always v3** (`/rest/api/3/`). The base URL in credentials.json already includes this.
- Auth: HTTP Basic with `email:token` from the `.jira` object (NOT top-level keys).
- Search endpoint: `${JIRA_BASE}/search/jql?jql=...&fields=summary,status` (v3 search requires the `/jql` suffix).
- Fetch a single issue: `${JIRA_BASE}/issue/{KEY}?fields=summary,status,resolution,assignee,description`
- Default project: `ARO`, default component: `aro-hcp-capz`
- URL-encode JQL query parameters.
- Never guess credentials or try alternative auth methods — if credentials.json is missing, ask the user.

## Jira issue creation rules

These rules apply when creating **any** Jira issue, regardless of project, source, or path used to trigger creation.

### Description (mandatory)

- **Always include a description.** Never create a Jira issue with an empty description field.
- If the source is a GitHub issue: fetch the full body (`gh issue view <n> --repo owner/repo --json title,body`) and use it as the description, appending `GitHub Issue: <url>`.
- If the source is a GitHub Actions workflow or URL: include the URL and a brief summary of why the issue is being tracked.
- If the source is a verbal or informal request: write a short description capturing the context before creating.
- If there is genuinely nothing to write: ask the user for content — never silently leave the description empty.

### Default field values

Always set these fields on every new Jira issue. Never leave them unset.

| Field | Value | Notes |
|-------|-------|-------|
| Project | `ARO` | Azure Red Hat OpenShift |
| Components | `37592` | aro-hcp-capz |
| Security | `10034` | Red Hat Employee |
| Assignee | `5fabb5fdecdae600685b01d6` | rcap@redhat.com |
| Activity Type (`customfield_10464`) | `10608` | Quality / Stability / Reliability |
| Fix Version | `105810` | CAPZ-2026-Q3 — update when quarter changes |

JSON snippet for every `fields` block:
```json
"components": [{"id": "37592"}],
"security": {"id": "10034"},
"assignee": {"accountId": "5fabb5fdecdae600685b01d6"},
"customfield_10464": {"id": "10608"},
"fixVersions": [{"id": "105810"}]
```

## Destructive actions

- Never delete Azure resources without explicit confirmation
- When asked to "list", "check", or "show" resources, only report findings - do not take action
- Always ask before: deleting, force-deleting, removing, or cleaning up resources
- When listing resources that might need cleanup, present findings and wait for user instruction
