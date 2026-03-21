---
name: recover-sessions
description: Recover Claude Code sessions after moving a project to a new directory. Use when sessions are missing because the project path changed.
allowed-tools: Bash
user-invocable: true
---

# Recover Sessions from a Previous Project Path

When a project is moved to a new directory, Claude Code sessions become invisible because they are stored under a path-mangled directory in `~/.claude/projects/`. This skill copies sessions from the old path's storage into the current path's storage.

## Execution

Run the script next to this file in a single Bash call, passing `$ARGUMENTS` through:

```bash
bash ~/.claude/skills/recover-sessions/recover-sessions.sh $ARGUMENTS
```

Relay its output to the user verbatim — do not add extra commentary unless there is a warning or error.

## Options

- `/recover-sessions ~/old-project-path` — recover sessions from the old path
- `/recover-sessions --dry-run ~/old-project-path` — preview what would be copied without copying
