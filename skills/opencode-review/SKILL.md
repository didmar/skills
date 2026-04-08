---
name: opencode-review
description: Run OpenCode to review uncommitted changes, then build an action plan from its findings.
allowed-tools: Bash, Read, Edit, Write
user-invocable: true
---

# OpenCode Review

Run OpenCode CLI to review all uncommitted changes in the current repo, then synthesize the findings into an actionable plan.

## Steps

1. **Run OpenCode review** — use `opencode run` with a review prompt and auto-approved permissions:

   ```bash
   opencode run --dangerously-skip-permissions \
     "Run git diff HEAD to see all uncommitted changes. Review the diff for bugs, correctness issues, security problems, style violations, and improvements. For each finding list: file path, line number, severity (P0-P3), one-line summary, and what should change. If there are no issues, say so." \
     2>&1
   ```

   If the command fails (e.g. `opencode` not found), tell the user and stop.

2. **Parse all findings** — read through the OpenCode output. Identify all the recommendations it made.

3. **Enter plan mode** — call `EnterPlanMode` and build a plan that:
   - Lists every actionable finding from OpenCode, grouped by severity (critical → minor)
   - For each finding, include the file path, a one-line summary, and what change is needed
   - Omits findings that are purely informational with no action required
   - Ends with a verification section (how to confirm fixes)

4. **Present the plan** — let the user review and approve before making any edits.
