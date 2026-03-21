# didmar's Claude Code Skills

A collection of [Claude Code](https://claude.ai/code) skills.

## Install

```
/plugin marketplace add didmar/skills
```

Skills are then available with the `didmar:` prefix, e.g. `/didmar:forked-repo-git-practices`.

## Skills

### `forked-repo-git-practices`

Best practices for maintaining a forked git repository in sync with its upstream original, and for contributing back via pull requests.

Covers: initial setup, syncing your fork, creating PR branches, keeping PRs updated during review, post-merge cleanup, local integration branches, and common pitfalls.

### `init-python`

Bootstrap a new Python project with the Astral toolchain (UV, Ruff, ty) and pre-commit hooks. Opinionated.

Supports both app and library layouts. Sets up linting, testing (pytest), pre-commit hooks, and optionally: Dockerfile + docker compose, GitHub Actions CI, VS Code settings, pytest-cov, PyPI packaging (library only), and CONTRIBUTING/AGENTS docs.

Usage: `/didmar:init-python` or `/didmar:init-python lib` for library layout.

### `setup-deploy-key`

Generate an SSH deploy key for the current project and configure git to use it. Idempotent.

Creates an ed25519 SSH key pair, adds an SSH config entry with a project-specific host alias, updates the git remote URL, and displays the public key with instructions for adding it to GitHub.

### `toulminify`

Extract and structure arguments from text or URLs using Toulmin's model of argumentation.

Accepts a URL, file path, or raw text as input and identifies every distinct argument, breaking each down into claim, grounds, warrant, backing, qualifier, and rebuttal.

Usage: `/didmar:toulminify <url|filepath|text>` or `/didmar:toulminify --json <url|filepath|text>` for JSON output.

### `recover-sessions`

Recover Claude Code sessions after moving a project to a new directory.

When a project is moved, Claude Code sessions become invisible because they are stored under a path-derived directory in `~/.claude/projects/`. This skill copies sessions from the old path's storage into the current path's storage.

Usage: `/didmar:recover-sessions ~/old-project-path` or `/didmar:recover-sessions --dry-run ~/old-project-path` to preview.
