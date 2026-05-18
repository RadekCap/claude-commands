---
description: Quick daily priority check — shows your weekly priorities and today's planned actions (Tue–Thu)
---

# Daily Priority Check

Lightweight 5-minute check-in. Run at 9:00 before opening Slack or email.

## Usage

```
/daily-check
```

## Steps

### 1. Find and read the weekly plan

```bash
WEEK=$(date +%Y-W%V)
PLAN_FILE="$OBSIDIAN_VAULT/Diary/Weekly/${WEEK}-plan.md"
```

If the plan file doesn't exist:
```
⚠ No weekly plan found for $WEEK.
Run /weekly-review open to create one.
```

### 2. Determine today

```bash
DAY_NAME=$(date +%A)
```

If today is Monday or Friday, suggest the full review instead:
```
Today is $DAY_NAME — time for your full weekly review.
Run /weekly-review open (Monday) or /weekly-review close (Friday).
```

### 3. Morning CAPZ Status

Check the state of CAPZ CI/CD pipelines. Print:

```
━━━ Morning CAPZ Status ━━━━━━━━━━━━━━━━━━━━━━━
```

Provide links for manual check:
```
  - [ ] OpenShift CI:  https://prow.ci.openshift.org/?job=periodic-ci-stolostron-capi-tests-*
  - [ ] GHA Management cluster: https://github.com/stolostron/capi-tests/actions/workflows/management-cluster-aro.yml
  - [ ] GHA Workload cluster:   https://github.com/stolostron/capi-tests/actions/workflows/workload-cluster-aro.yml
  - [ ] ACM Jenkins:   https://jenkins-csb-rhacm-tests.dno.corp.redhat.com/job/CI-Jobs/job/capz_tests/
  - [ ] Stale Resources: https://github.com/stolostron/capi-tests/actions/workflows/stale-resources.yml
```

Also fetch the latest GHA workflow runs programmatically:
```bash
gh run list --repo stolostron/capi-tests --workflow "management-cluster-aro.yml" --limit 1 --json status,conclusion,createdAt
gh run list --repo stolostron/capi-tests --workflow "workload-cluster-aro.yml" --limit 1 --json status,conclusion,createdAt
gh run list --repo stolostron/capi-tests --workflow "stale-resources.yml" --limit 1 --json status,conclusion,createdAt
```

Print a summary: ✅ passing / ❌ failing / ⏳ running for each.

Ask: "Any red flags to address before starting your day?"

### 4. Show priorities

Print:
```
━━━ Weekly Priorities ━━━━━━━━━━━━━━━━━━━━━━━━━

📋 This week's priorities:
  1. ARO-XXXXX — <description>
  2. ARO-YYYYY — <description>
```

Read the priorities from the `## Priorities` section of the plan file.

### 5. Show today's actions

Read the `## Daily Plan` section and find today's subsection (### Tuesday, ### Wednesday, ### Thursday).

```
📌 Today ($DAY_NAME):
  - [ ] <action 1>
  - [ ] <action 2>
```

If today has no planned actions:
```
📌 No specific actions planned for $DAY_NAME.
    Focus on moving your priorities forward.
```

### 6. Ask for focus

Ask: "What will you focus on first?"

After the user responds, print:
```
━━━ ✔ Go. Priorities first, inbox later. ━━━━━━
```
