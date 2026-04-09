---
name: codex-review
description: "Use OpenAI Codex CLI specifically to get a second opinion. Trigger only when the user explicitly asks for a Codex review."
allowed-tools: Bash, Read, Edit, Write
user-invocable: true
---

# Codex Review

Run OpenAI Codex CLI to review all uncommitted changes in the current repo, then synthesize the findings into an actionable plan.

## Arguments

This skill accepts an optional argument: custom review instructions. If provided, these instructions are appended to the default Codex review prompt to focus the review on specific concerns (e.g., `/codex-review focus on error handling and thread safety`).

## Steps

1. **Run Codex review** — use the legacy Landlock sandbox to avoid bwrap failures in VMs/containers. If the user provided custom instructions via the skill argument, append them to the review command using `--instructions`:

   Without custom instructions:
   ```bash
   codex -c 'features.use_legacy_landlock=true' --dangerously-bypass-approvals-and-sandbox review --uncommitted 2>&1 \
     | sed -n '/^codex$/,$ { /^codex$/d; p }' | awk '!seen[$0]++'
   ```

   With custom instructions (where `$INSTRUCTIONS` is the user-provided argument):
   ```bash
   codex -c 'features.use_legacy_landlock=true' --dangerously-bypass-approvals-and-sandbox review "$INSTRUCTIONS" 2>&1 \
     | sed -n '/^codex$/,$ { /^codex$/d; p }' | awk '!seen[$0]++'
   ```

   This extracts only the final review from Codex's output. The full output includes a header, the diff, exec traces, and then the review after a bare `codex` line (duplicated) — the `sed` + `awk` pipeline strips everything except the deduplicated final answer.

   If the command fails (e.g. `codex` not found), tell the user and stop.

2. **Parse all findings** — read through the Codex review output. Identify all the recommendations it made.

3. **Enter plan mode** — call `EnterPlanMode` and build a plan that:
   - Lists every actionable finding from Codex, grouped by severity (critical → minor)
   - For each finding, include the file path, a one-line summary, and what change is needed
   - Omits findings that are purely informational with no action required
   - Ends with a verification section (how to confirm fixes)

4. **Present the plan** — let the user review and approve before making any edits.
