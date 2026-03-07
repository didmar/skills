---
name: setup-deploy-key
description: Generate an SSH deploy key for the current project and configure git to use it. Use when the user needs to set up GitHub deploy key SSH access for a repository.
---

# Setup Deploy Key

Configure SSH deploy key access for the current project's GitHub repository. This is idempotent.

## Instructions

Execute the following steps in order. For each step, check if the configuration already exists before making changes.

### Step 1: Derive project slug and repo info

Run this to extract the remote origin URL and derive identifiers:

```bash
REMOTE_URL=$(git remote get-url origin 2>/dev/null)
echo "Remote URL: $REMOTE_URL"
```

If there is no git remote origin, stop and tell the user this must be run from a git repo with a configured origin remote.

Parse the remote URL to extract:
- **owner** and **repo** (e.g., from `git@github.com:didmar/Auto-Claude.git` or `https://github.com/didmar/Auto-Claude.git`)
- **slug**: the repo name converted to lowercase snake_case (e.g., `Auto-Claude` → `auto_claude`)

### Step 2: Generate SSH key pair

- **Key path:** `~/.ssh/<slug>_deploy` (e.g., `~/.ssh/auto_claude_deploy`)
- If the key already exists, report "SSH key already exists at ~/.ssh/<slug>_deploy" and skip to Step 3
- Otherwise, generate it:

```bash
ssh-keygen -t ed25519 -f ~/.ssh/<slug>_deploy -N "" -C "deploy-key-<slug>"
```

### Step 3: Add SSH config entry

- **Host alias:** `github.com-<slug>` (using hyphens, e.g., `github.com-auto-claude`)
- Check if `~/.ssh/config` already contains a `Host github.com-<slug>` entry
- If it exists, report "SSH config entry already exists for github.com-<slug>" and skip to Step 4
- Otherwise, append to `~/.ssh/config`:

```
Host github.com-<slug>
    HostName github.com
    IdentityFile ~/.ssh/<slug>_deploy
    IdentitiesOnly yes
```

Make sure there is a blank line before the new entry if the file is non-empty.

### Step 4: Update git remote URL

- The expected remote URL format is: `git@github.com-<slug>:<owner>/<repo>.git`
- Check if the current origin URL already matches this format
- If it already matches, report "Git remote already configured correctly" and skip to Step 5
- Otherwise, update it:

```bash
git remote set-url origin git@github.com-<slug>:<owner>/<repo>.git
```

### Step 5: Display the public key

Show the contents of `~/.ssh/<slug>_deploy.pub` and instruct the user:

1. Copy the public key shown below
2. Go to the GitHub repository → Settings → Deploy keys → Add deploy key
3. Paste the key, give it a title (e.g., "agent deploy key"), and check **Allow write access** if relevant
4. Click "Add key"

Display the public key contents clearly so the user can copy it.

### Summary

After all steps, print a summary showing what was done vs. what was already configured:
- SSH key: created / already existed
- SSH config: added / already existed
- Git remote: updated / already correct
- Public key: displayed (if newly created) or location reminded
