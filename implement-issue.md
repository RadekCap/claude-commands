---
description: Analyze a GitHub issue and create a pull request that implements the fix
---

# Implement Issue

Automatically analyze a GitHub issue, implement the required changes, and create a pull request with the fix.

## Usage

```
/implement-issue <issue-number>
```

**Example**: `/implement-issue 72`

## Workflow

1. **Validate issue number argument**
   - If no issue number provided, prompt user: "Please provide an issue number: /implement-issue <number>"
   - If issue number is not a valid integer, show error and exit

2. **Fetch issue details from GitHub**
   ```bash
   gh issue view <issue-number>
   ```
   - If issue doesn't exist, show error and exit
   - If issue is closed, ask user if they still want to proceed
   - Display issue title, description, and labels for context

3. **Analyze the issue**
   - Read the issue description carefully
   - Identify what type of change is needed:
     - Bug fix
     - New feature
     - Test addition
     - Documentation update
     - Workflow/CI fix
     - Refactoring
   - Determine affected files by:
     - Reading issue description for file/path mentions
     - Searching codebase for relevant code patterns
     - Using Grep/Glob tools to find related files
   - Check CLAUDE.md for repository-specific patterns and guidelines
   - Create a mental implementation plan

4. **Check current git status**
   ```bash
   git status
   ```
   - If there are uncommitted changes, ask user:
     - "You have uncommitted changes. What would you like to do?"
       - Option 1: Stash changes and continue
       - Option 2: Commit changes first
       - Option 3: Cancel operation
   - Handle user's choice before proceeding

5. **Ensure main branch is up to date**
   ```bash
   git checkout main
   git pull origin main
   ```
   - If pull fails, explain error and exit

6. **Create feature branch**
   - Generate branch name from issue:
     - Format: `fix-issue-<number>-<brief-description>`
     - Example: `fix-issue-72-add-logging-function`
     - Keep description under 50 chars, use kebab-case
   - Create and checkout branch:
     ```bash
     git checkout -b <branch-name>
     ```

7. **Use TodoWrite tool to create implementation plan**
   - Break down the implementation into specific tasks
   - Examples:
     - "Read current implementation of X"
     - "Create new function Y in file Z"
     - "Add tests for feature X"
     - "Update documentation"
     - "Run tests to verify changes"
     - "Commit changes"
     - "Create pull request"
   - Mark first task as in_progress

8. **Implement the fix**
   - Follow repository patterns from CLAUDE.md
   - Read existing code before making changes
   - Implement changes step-by-step, updating TodoWrite as you progress
   - For code changes:
     - Use Read tool to understand existing code
     - Use Edit/Write tools to make changes
     - Follow existing code style and patterns
     - Add comments where logic isn't self-evident

9. **Run relevant tests**
   - Determine which tests to run based on the project:
     - Check CLAUDE.md for test commands
     - Check package.json scripts, Makefile targets, or equivalent
     - Run project-specific test/lint/build commands
   - If tests fail:
     - Analyze failure
     - Fix implementation
     - Re-run tests
     - Repeat until tests pass

10. **Format code**
    - Run project-specific formatting command if available
    - Check CLAUDE.md for formatting guidelines

11. **Commit changes**
    - Create descriptive commit message following this format:
      ```
      <Brief summary> (fixes #<issue-number>)

      <Detailed description of what changed and why>

      Fixes #<issue-number>

      Generated with [Claude Code](https://claude.com/claude-code)

      Co-Authored-By: Claude <noreply@anthropic.com>
      ```
    - Commit using:
      ```bash
      git add .
      git commit -m "$(cat <<'EOF'
      <commit message here>
      EOF
      )"
      ```

12. **Push branch to remote**
    ```bash
    git push -u origin <branch-name>
    ```

13. **Create pull request**
    - Use `gh pr create` with detailed PR description
    - PR title: `<Brief summary> (fixes #<issue-number>)`
    - PR body should include:
      - ## Summary
      - ## Problem (reference original issue)
      - ## Solution
      - ## Changes
      - ## Testing
      - Fixes #<issue-number>
      - Generated with Claude Code
    - Example:
      ```bash
      gh pr create --title "Add logging function (fixes #72)" --body "$(cat <<'EOF'
      ## Summary
      Implements logging function as requested in #72

      ## Problem
      <Describe the problem from the issue>

      ## Solution
      <Describe how you fixed it>

      ## Changes
      - <Change 1>
      - <Change 2>

      ## Testing
      - [x] Tests pass
      - [x] Code formatted

      Fixes #72

      Generated with [Claude Code](https://claude.com/claude-code)
      EOF
      )"
      ```

14. **Post comment on the issue explaining the implementation**
    - After creating the PR, post a comment on the original issue
    - The comment should explain what was implemented, not just link to the PR
    - Use `gh issue comment <issue-number>` with a comprehensive explanation
    - Format:
      ```bash
      gh issue comment <issue-number> --body "$(cat <<'EOF'
      ## Implementation Complete

      I've implemented a fix for this issue. Here's what was done:

      ### Solution
      <Brief explanation of the approach taken>

      ### Key Changes
      - <Important change 1>
      - <Important change 2>

      ### Files Modified
      - `<file1>` - <what changed>
      - `<file2>` - <what changed>

      ### Testing
      - <Test result 1>
      - <Test result 2>

      ### Pull Request
      The full implementation details are available in PR #<pr-number>

      Automated implementation via [Claude Code](https://claude.com/claude-code)
      EOF
      )"
      ```

15. **Provide summary to user**
    - Display PR URL
    - Display issue comment confirmation
    - List files changed
    - Show test results
    - Remind user that CI will run automatically

## Important Guidelines

### Code Quality
- **Read before writing**: Always use Read tool to understand existing code before making changes
- **Follow patterns**: Adhere to CLAUDE.md guidelines and existing code patterns
- **Test coverage**: Add tests for new functionality when appropriate
- **No over-engineering**: Only implement what's requested in the issue
- **Security**: Check for common vulnerabilities (SQL injection, XSS, command injection, etc.)

### Git Best Practices
- **Branch naming**: `fix-issue-<number>-<brief-description>` or `feature-issue-<number>-<brief-description>`
- **Commit messages**: Descriptive, reference issue number
- **One issue per PR**: Don't mix multiple unrelated changes

### Testing Requirements
- Run tests before committing (use project-specific commands)
- Ensure all existing tests still pass
- Add new tests for new functionality when appropriate

## Error Handling

### Issue Not Found
```
Error: Issue #<number> not found
Please check the issue number and try again
```

### Tests Fail
- Show test output
- Ask user: "Tests are failing. Would you like to:"
  - Option 1: Let me fix the issue
  - Option 2: Skip tests and commit anyway (not recommended)
  - Option 3: Cancel operation

### Git Conflicts
- Explain conflict
- Provide resolution commands
- Ask user how to proceed

### Uncommitted Changes
- Detect uncommitted changes before starting
- Offer to stash, commit, or cancel
- Never proceed without handling changes

## Post-Implementation Checklist

After completing implementation, verify:
- [ ] Issue requirements fully addressed
- [ ] Code follows repository patterns (CLAUDE.md)
- [ ] Tests pass (or explanation if no tests needed)
- [ ] Code formatted per project conventions
- [ ] Commit message references issue number
- [ ] PR description includes "Fixes #<issue-number>"
- [ ] Branch pushed to remote
- [ ] PR created successfully
- [ ] Issue comment posted explaining the implementation

## Tips for Success

1. **Read the issue carefully**: Understand exactly what's being asked before starting
2. **Check CLAUDE.md**: Follow project-specific patterns and conventions
3. **Follow existing patterns**: Consistency is key
4. **Test thoroughly**: Don't skip tests
5. **Ask for clarification**: If issue is ambiguous, use AskUserQuestion to clarify with user
6. **Keep it focused**: Only implement what the issue requests, nothing more
