---
name: forked-repo-git-practices
description: >
  Best practices for maintaining a forked git repository in sync with the upstream original,
  and for creating branches to submit pull requests. Use when the user asks about: keeping a
  fork up to date, syncing with upstream, contributing to an open source project via fork,
  creating PR branches from a fork, fork workflow, "my fork is behind upstream", "how do I
  contribute to a repo I forked", any question about fork/upstream/PR git workflow, or how to
  run all local feature branches together while some are still pending merge upstream.
---

# Forked Repo Git Practices

## Core Principles

- **Never commit directly to your fork's default branch** (e.g. `main`, `master`, `develop`) — keep it a clean mirror of upstream
- **Always branch from fresh upstream HEAD** — not from your fork's potentially-stale default branch
- **One branch per PR** — keep concerns separate for easy review and revert

## Initial Setup

```bash
git clone https://github.com/YOUR_USER/REPO.git
cd REPO
git remote add upstream https://github.com/ORIGINAL_OWNER/REPO.git
git remote -v   # verify: origin (your fork) + upstream (original)
```

## Determine the Default Branch

After cloning, the default branch is automatically checked out. To confirm the default branch name for a remote:

```bash
git remote show upstream | grep 'HEAD branch'
```

Throughout this guide, `<default>` is used as a placeholder for the upstream default branch name (typically `main`, `master`, or `develop`). Replace it with the actual branch name in your commands.

## Syncing Your Fork with Upstream

Run this before starting any new branch:

```bash
git fetch upstream
git checkout <default>
git merge upstream/<default>    # fast-forward only; conflicts here mean your default branch diverged
git push origin <default>       # keep fork's default branch in sync on GitHub
```

> **Tip:** Never rebase your fork's default branch onto upstream — always merge. Rebasing rewrites
> history and causes divergence between your local and remote default branch.

## Creating a Branch for a PR

Always create feature branches **from upstream HEAD**, not from your (potentially stale) local default branch:

```bash
git fetch upstream
git checkout -b feat/my-feature upstream/<default>
```

This guarantees the branch starts at the exact same commit as upstream, even if you forgot to sync your local default branch first.

### Branch Naming Conventions

| Type | Pattern | Example |
|---|---|---|
| Feature | `feat/<short-description>` | `feat/add-dark-mode` |
| Bug fix | `fix/<issue-or-description>` | `fix/login-redirect-loop` |
| Docs | `docs/<description>` | `docs/update-contributing` |
| Chore/refactor | `chore/<description>` | `chore/upgrade-deps` |
| Hotfix | `hotfix/<description>` | `hotfix/null-pointer-crash` |

Use `kebab-case`, keep names short but descriptive. Include the issue number when relevant:
`fix/123-broken-auth`.

## PR Submission Workflow

```bash
# 1. Branch from upstream (never from your local default branch)
git fetch upstream
git checkout -b feat/my-feature upstream/<default>

# 2. Make commits with clear, atomic messages
git add -p                          # prefer staging hunks over `git add .`
git commit -m "feat: concise description of change"

# 3. Before opening PR, rebase onto latest upstream to avoid conflicts
git fetch upstream
git rebase upstream/<default>

# 4. Push to your fork
git push origin feat/my-feature

# 5. Open PR on GitHub: base = upstream/<default>  ←  compare = your-fork/feat/my-feature
```

## Keeping a PR Branch Updated During Review

If upstream advances while your PR is under review:

```bash
git fetch upstream
git rebase upstream/<default>            # replay your commits on top of latest upstream
git push origin feat/my-feature --force-with-lease   # safe force-push
```

Use `--force-with-lease` instead of `--force` — it refuses to push if someone else pushed to
the branch since your last fetch, preventing accidental overwrites.

## After Your PR is Merged

```bash
# Sync fork's default branch with upstream (your commits are now in upstream/<default>)
git checkout <default>
git fetch upstream
git merge upstream/<default>
git push origin <default>

# Clean up the feature branch
git branch -d feat/my-feature
git push origin --delete feat/my-feature
```

## Local Integration Branch (Using All Features Together)

When you have multiple feature branches — some merged upstream, some still pending — and you
want to use the repo locally with **all of them active**, maintain a dedicated local integration
branch. **Never push this as a PR.**

```bash
# Build the integration branch from scratch
git fetch upstream
git checkout -b local/dev upstream/<default>   # or rebuild: git checkout local/dev && git reset --hard upstream/<default>

# Merge each unmerged feature branch into it
git merge feat/feature-a
git merge feat/feature-b
git merge feat/feature-c
# Resolve any conflicts as you go
```

The branch diagram looks like this:

```
upstream/<default>  ──A──B──C──────────────────
                        \
feat/feature-a           ──a1──a2
feat/feature-b           ──b1
feat/feature-c           ──c1──c2──c3

local/dev      ──A──B──C──a1──a2──b1──c1──c2──c3  (merge commits)
```

### When Upstream Merges One of Your PRs

Say `feat/feature-a` gets merged upstream. Now `upstream/<default>` contains it.
Rebuild `local/dev` — the merged feature comes in automatically via `upstream/<default>`,
and you only re-merge the remaining unmerged branches:

```bash
git fetch upstream
git checkout local/dev
git reset --hard upstream/<default>   # discard old integration branch, start fresh from upstream
git merge feat/feature-b             # feature-a already in upstream/<default>, skip it
git merge feat/feature-c
```

Then clean up the merged branch:

```bash
git branch -d feat/feature-a
git push origin --delete feat/feature-a
```

### Checking Which Branches Are Already Merged Upstream

```bash
# Shows commits in feat/X that are NOT yet in upstream/<default> (empty = already merged)
git log upstream/<default>..feat/feature-a --oneline

# List all local branches not yet merged into upstream/<default>
git branch --no-merged upstream/<default>
```

### Key Rules for the Integration Branch

- Treat `local/dev` as **throwaway** — it's always rebuildable from the feature branches
- Use **merge** (not rebase) into `local/dev` — you want to preserve each branch's history
- Never commit work directly to `local/dev` — all real work belongs in the feature branches
- Rebuild rather than update when upstream merges one of your PRs — it's cleaner than trying
  to surgically remove a branch's commits

## Common Pitfalls

| Pitfall | Why it's a problem | Fix |
|---|---|---|
| Committing to fork's default branch | Causes divergence; future syncs become painful | Keep the default branch pristine; always use feature branches |
| Branching from stale local default branch | Your branch silently misses upstream changes | Always `git fetch upstream` before branching |
| Using `--force` on a shared branch | Can destroy collaborators' work | Use `--force-with-lease` |
| Merging upstream into a PR branch | Creates noisy merge commits in PR history | Use `git rebase upstream/<default>` instead |
| Opening a PR from the default branch | Blocks you from working on other things while PR is open | Always use a dedicated feature branch |
| Forgetting to delete merged branches | Accumulates stale branches, confusing state | Delete both local and remote after merge |
