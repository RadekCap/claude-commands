Run when STARTING work on Prow CI branches from a new computer. Fetch remotes and check if local branches are behind remote.

Check these branches across two repositories:

1. **capi-tests** repo (find it - check `~/git/capi-tests` or `~/git/github/stolostron/capi-tests`):
   - `configure-prow`
   - `configure-prow-mgmt`

2. **openshift/release** repo (find it - check `~/git/release` or `~/git/github/openshift/release`):
   - `stolostron-capi-tests-ci`
   - `stolostron-capi-tests-ci-mgmt`

For each repo that exists, run `git fetch origin` first. Then for each branch that exists locally:
- Compare local vs `origin/<branch>` using `git rev-list --count <branch>..origin/<branch>`
- If the local branch is BEHIND remote: report it as a problem - "X commits behind, pull first!"
- If the local branch is ahead of remote: that's fine, just note it
- If they match: report OK

At the end:
- If any branches are behind remote, warn: "Pull stale branches before making changes!"
- If all OK: "All branches up to date. Safe to start."

Skip any repos or branches that don't exist on this machine.
