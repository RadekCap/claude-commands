Run when STOPPING work on Prow CI branches before switching computers. Check if any branches have unpushed commits.

Check these branches across two repositories:

1. **capi-tests** repo (find it - check `~/git/capi-tests` or `~/git/github/stolostron/capi-tests`):
   - `configure-prow`
   - `configure-prow-mgmt`

2. **openshift/release** repo (find it - check `~/git/release` or `~/git/github/openshift/release`):
   - `stolostron-capi-tests-ci`
   - `stolostron-capi-tests-ci-mgmt`

For each repo that exists, run `git fetch origin` first. Then for each branch that exists locally:
- Compare local vs `origin/<branch>` using `git rev-list --count origin/<branch>..<branch>`
- If the local branch is AHEAD of remote: report it as a problem - "X unpushed commit(s)!"
- If no remote tracking branch exists: report as a problem - "no remote tracking"
- If they match: report OK

At the end:
- If any branches have unpushed commits, warn: "Push your changes before switching computers!"
- If all OK: "All branches pushed. Safe to stop."

Skip any repos or branches that don't exist on this machine.
