---
name: init-python
description: Bootstrap a new Python project with the Astral toolchain (UV, Ruff, ty), flake8-stepdown, and pre-commit hooks. Opinionated.
disable-model-invocation: true
model: haiku
---

Argument: $ARGUMENTS

- We assume `uv` is installed.
- **Convention**: Always Read existing files before overwriting them (tool requirement). Create parent directories as needed for all file writes.

1. If `pyproject.toml` already exists, warn the user and stop.

2. Parse the argument. If it contains "lib" or "library", use library layout. Otherwise, use app layout (default). Note: the project name is determined by the directory name (UV's default behavior), not parsed from the argument. The argument is only used to determine app vs library layout.

3. Initialize the project:

- App layout:
  1. `uv init --python ">=3.13"`
  2. Determine `<package>` from the project name in `pyproject.toml` (UV converts e.g. `dummy-app` → `dummy_app`)
  3. `mkdir <package>`, move `main.py` to `<package>/main.py`, create `<package>/__init__.py` with content `"""<package> application."""`
- Library layout:
  1. `uv init --lib --build-backend hatch --python ">=3.13"`
  2. Determine `<package>` by listing `src/`
  3. Move `src/<package>/` to `./<package>/` and `rmdir src`
  4. Append to `pyproject.toml`:
     ```toml
     [tool.hatch.build.targets.wheel]
     packages = ["<package>"]
     ```

Note: UV converts names like `dummy-library` → `dummy_library`. Use the actual directory name as `<package>` in all subsequent substitutions.

4. Append [references/pyproject-tool-config.toml](references/pyproject-tool-config.toml) verbatim to `pyproject.toml`. Note: keep `[dependency-groups]` as the last section in pyproject.toml (step 5 appends it).

5. Install dev dependencies:

uv add --dev pytest ruff ty pre-commit flake8-stepdown

**Note**: `uv init` generates `.gitignore` and `README.md` (plus `main.py` for app layout, or `src/<package>/__init__.py` and `py.typed` for library layout).

**Steps 6-9 are independent — run them in parallel where possible.**

6. Write [references/lint.sh](references/lint.sh) to `lint.sh` and `chmod +x` it.

7. Write [references/pre-commit-config.yaml](references/pre-commit-config.yaml) to `.pre-commit-config.yaml`. Then run `uv run pre-commit autoupdate --repo https://github.com/astral-sh/ruff-pre-commit` to sync the ruff hook version.

8. Fix up UV-generated files to pass strict linting:

- App layout: write [references/main.py](references/main.py) to `<package>/main.py`.
- Library layout: write [references/lib_init.py](references/lib_init.py) to `<package>/__init__.py`.

9. Create test scaffolding:

- `tests/__init__.py` with content: `"""Test suite."""`
- Write [references/test_placeholder.py](references/test_placeholder.py) to `tests/test_placeholder.py`.
  - Library layout: replace `<package>` with the actual package directory name (needed for coverage).
  - App layout: remove the import line, replace the test body with `assert True`.

10. If `.git` doesn't exist, run `git init`. Overwrite `.gitignore` with [references/gitignore](references/gitignore).

11. Install pre-commit hooks:

uv run pre-commit install

12. Run `uv run pytest` to verify setup works.

13. Stage all files first: `git add -A` (including `.python-version`). This is needed so that pre-commit hooks can actually check the files.

14. Run `uv run pre-commit run --all-files` to verify all hooks pass. If ruff auto-fixes anything, re-stage with `git add -A`.

15. Create initial commit with message "Initial project setup with UV, Ruff, ty, flake8-stepdown, and pre-commit".

16. Use the AskUserQuestion tool to ask the user which optional extras they want. Present options using AskUserQuestion (use multiSelect, split across up to two questions if needed since the tool supports max 4 options per question). The user can pick multiple, all, or none:

- **Dockerfile + docker compose** - Multi-stage Dockerfile with `dev` and `prod` targets, `compose.yaml`, and `.dockerignore`
- **GitHub Actions CI** - `.github/workflows/ci.yml` running ruff, ty, and pytest on push and PR
- **VS Code settings** - `.vscode/settings.json` with ruff extension as formatter, format-on-save, organize imports on save
- **pytest-cov** - Add `pytest-cov` dev dependency and configure `[tool.pytest.ini_options]` with `--cov` and a minimum coverage threshold
- **PyPI packaging** *(library layout only)* - GitHub Actions publish workflow, classifiers, license, and project URLs in pyproject.toml
- **CONTRIBUTING.md + AGENTS.md** - Code style guide and conventions for humans and AI agents, with `CLAUDE.md` symlink

Only include the PyPI packaging option when using library layout (omit it entirely for app layout). Include a "None of the above" option in each question so the user can skip extras without deselecting items manually.

**Ordering**: Apply extras in this order: Dockerfile + docker compose, GitHub Actions CI, VS Code settings, pytest-cov, PyPI packaging, CONTRIBUTING.md + AGENTS.md. Then implement whichever extras the user selected. Details for each:

### Dockerfile + docker compose

- App layout: write [references/Dockerfile](references/Dockerfile) to `Dockerfile`, replacing `<package>` with the actual package name.
- Library layout: write [references/Dockerfile-lib](references/Dockerfile-lib) to `Dockerfile`.
- Write [references/compose.yaml](references/compose.yaml) to `compose.yaml`.
- Write [references/dockerignore](references/dockerignore) to `.dockerignore`.

### GitHub Actions CI

Write [references/ci.yml](references/ci.yml) to `.github/workflows/ci.yml`.

### VS Code settings

Write [references/vscode-settings.json](references/vscode-settings.json) to `.vscode/settings.json`.

### pytest-cov

Run `uv add --dev pytest-cov`, then add to `pyproject.toml`:

```toml
[tool.pytest.ini_options]
addopts = "--cov=<package> --cov-report=term-missing --cov-fail-under=80"
```

### PyPI packaging *(library layout only)*

1. Add PyPI metadata to `pyproject.toml`:
   - Append `license` and `classifiers` to the existing `[project]` section (after `dependencies`):
     ```toml
     license = "MIT"
     classifiers = [
         "Development Status :: 3 - Alpha",
         "Programming Language :: Python :: 3",
         "Programming Language :: Python :: 3.13",
     ]
     ```
   - Add `[project.urls]` immediately after `[project]` (before `[build-system]`):
     ```toml
     [project.urls]
     Homepage = "https://github.com/<owner>/<project-name>"
     Repository = "https://github.com/<owner>/<project-name>"
     Issues = "https://github.com/<owner>/<project-name>/issues"
     ```
   - Replace `<owner>`/`<project-name>` from `git remote get-url origin` if available, otherwise use placeholders. Note any placeholders in the final summary.

2. Write [references/publish.yml](references/publish.yml) to `.github/workflows/publish.yml`.

### CONTRIBUTING.md + AGENTS.md

- Write [references/CONTRIBUTING.md](references/CONTRIBUTING.md) to `CONTRIBUTING.md`.
- Write [references/AGENTS.md](references/AGENTS.md) to `AGENTS.md`.
- Create `CLAUDE.md` as a symlink: `ln -s AGENTS.md CLAUDE.md`

17. **Always generate README.md** after all extras (its content depends on them):

Start from [references/readme-base.md](references/readme-base.md) (replace `<project-name>` and `<package>` with actual values). For library layout, omit the "Running" subsection. Then conditionally append based on selected extras:

- Docker selected → append [references/readme-docker.md](references/readme-docker.md)
- CI selected → append [references/readme-ci.md](references/readme-ci.md)
- PyPI selected → append [references/readme-pypi.md](references/readme-pypi.md)
- CONTRIBUTING selected → append [references/readme-contributing.md](references/readme-contributing.md)

18. Stage all changes and validate all hooks pass: `git add -A && uv run pre-commit run --all-files`. If ruff auto-fixes anything, re-stage with `git add -A`.

19. Create a new commit with message "Add optional extras: <list of what was added>".
