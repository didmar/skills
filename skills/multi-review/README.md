# /multi-review skill

Runs three independent code reviews in parallel — using Claude (`/review`), OpenCode (`/opencode-review`), and Codex (`/codex-review`) — then merges the results into a single deduplicated action plan.

## How it works

1. **Parallel reviews** — launches 3 agents concurrently, one per reviewer. Each agent invokes its respective review skill and returns findings. 180s timeout per agent; failures are noted but don't block the others.

2. **Merge & deduplicate** — same file + same issue from multiple reviewers is collapsed into one finding. Findings flagged by 2+ reviewers get higher confidence. Single-source findings are kept but marked as such.

3. **Plan mode** — enters plan mode with a merged plan:
   - Consensus summary at the top (e.g., "3/3 agree on X", "only Codex caught Y")
   - Findings grouped by severity (P0 - P3)
   - Each finding includes: file path, line, summary, what to change, which reviewer(s) flagged it

4. **User approval** — the plan is presented for review before any edits are made.

## Prerequisites

- [OpenAI Codex CLI](https://github.com/openai/codex) installed and configured (see [codex-review README](../codex-review/README.md))
- [OpenCode CLI](https://opencode.ai) installed and configured (see [opencode-review README](../opencode-review/README.md))

## Usage

```
/multi-review
```

Run it on any repo with uncommitted changes. All three reviewers analyze the same diff independently, giving you a broader perspective than any single tool alone.
