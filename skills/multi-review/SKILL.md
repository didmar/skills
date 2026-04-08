---
name: multi-review
description: Run parallel code reviews using Claude, OpenCode, and Codex, then merge findings into a single plan.
allowed-tools: Bash, Read, Edit, Write, Agent
user-invocable: true
---

# Multi-Review

Run three independent code reviews in parallel using different AI tools, then merge the results into a single deduplicated action plan.

## Steps

1. **Launch 3 review agents in parallel** — use a single message with 3 `Agent` tool calls so they execute concurrently. Each agent runs one reviewer:

   - **Agent 1 — Claude:** Invoke the `/review` skill and return the findings.
   - **Agent 2 — OpenCode:** Invoke the `/opencode-review` skill and return the findings.
   - **Agent 3 — Codex:** Invoke the `/codex-review` skill and return the findings.

   Use a 180s timeout per agent. If a reviewer times out or fails, note it but proceed with the others.

2. **Merge findings** — once all agents return:
   - Deduplicate: same file + same issue → merge into one, note which reviewers agreed
   - Consensus: findings flagged by 2+ reviewers get higher confidence
   - Unique finds: keep single-source findings but mark them as such
   - Discard purely informational notes with no action

3. **Enter plan mode** — call `EnterPlanMode` and build a merged plan:
   - Consensus summary at the top (e.g., "3/3 agree on X", "only Codex caught Y")
   - Findings grouped by severity (P0 → P3)
   - Each finding: file path, line, summary, what to change, which reviewer(s) flagged it
   - Verification section at the end

4. **Present the plan** — let the user review and approve before making any edits.
