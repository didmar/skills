# /opencode-review skill

Runs [OpenCode CLI](https://opencode.ai) to review all uncommitted changes, then enters plan mode so Claude can act on the findings.

> **WARNING: OpenCode runs with auto-approved permissions.** This skill uses `--dangerously-skip-permissions`, which means OpenCode executes tool calls (shell commands, file reads/writes) without asking for approval. Only run this in environments you trust.

## How it works

OpenCode doesn't have a built-in `/review` command — the skill uses `opencode run` with a review prompt. OpenCode's agent reads the diff via `git diff HEAD`, analyzes it, and returns findings.

The command:

```bash
opencode run --dangerously-skip-permissions "Run git diff HEAD to see all uncommitted changes. Review the diff for bugs..." 2>&1
```

### Output format

Unlike Codex (which has a structured output with a header, exec traces, and a duplicated final answer), OpenCode's `run` output interleaves tool calls and text in a streaming format with ANSI escape codes. The skill reads the full output and extracts findings from the agent's final response.

### Model configuration

OpenCode uses whatever model is configured in your `opencode.json` or environment. The default model affects both review quality and speed. If reviews time out, consider using a faster model:

```bash
opencode run -m provider/model --dangerously-skip-permissions "..."
```

### Comparison with /codex-review

| | codex-review | opencode-review |
|---|---|---|
| Tool | OpenAI Codex CLI | OpenCode CLI |
| Review mode | Built-in `review --uncommitted` | Prompt-based via `opencode run` |
| Sandbox | bwrap/Landlock | None (relies on `--dangerously-skip-permissions`) |
| Model | gpt-5.3-codex (fixed) | Configurable via `-m` or config |
| Output | Structured (header + exec + final answer) | Streaming agent output |
