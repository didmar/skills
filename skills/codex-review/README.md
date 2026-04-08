# /codex-review skill

Runs the [OpenAI Codex CLI](https://github.com/openai/codex) to review uncommitted changes, then enters plan mode so Claude can act on the findings.

> **WARNING: Codex runs unsandboxed.** This skill uses `--dangerously-bypass-approvals-and-sandbox`, which means Codex executes shell commands with no approval prompts and no effective sandbox. It can read, write, and delete any file your user account can access. The Landlock backend provides some filesystem restrictions, but approval checks are fully disabled. Only run this in environments you trust (isolated VMs, containers, throwaway workspaces) — never on a machine with sensitive data or credentials that Codex shouldn't touch.

## Sandbox issues in VMs and containers

Codex uses [bubblewrap](https://github.com/containers/bubblewrap) (`bwrap`) to sandbox command execution on Linux. Even when `--dangerously-bypass-approvals-and-sandbox` is passed, bwrap is still used — that flag only skips *approval prompts*, not the sandbox itself.

bwrap creates a network namespace and assigns `127.0.0.1/8` to a loopback interface inside it. This requires the `RTM_NEWADDR` netlink operation, which needs `CAP_NET_ADMIN`. In restricted environments (VMs without full capabilities, unprivileged containers, Ubuntu 24.04+ with AppArmor user namespace restrictions), this fails with:

```
bwrap: loopback: Failed RTM_NEWADDR: Operation not permitted
```

Every shell command codex tries to run (even `git status` or `pwd`) fails, making the tool unusable.

### The fix: legacy Landlock backend

Codex ships an alternative sandbox backend based on [Landlock LSM](https://docs.kernel.org/security/landlock.html), a Linux security module that enforces filesystem access restrictions without needing network namespaces or elevated capabilities.

Enable it with:

```bash
codex -c 'features.use_legacy_landlock=true' --dangerously-bypass-approvals-and-sandbox review --uncommitted
```

This is what the skill uses. Landlock is available on Linux 5.13+ and doesn't require `CAP_NET_ADMIN`.

### Alternative: piping the diff via stdin

If Landlock also fails (e.g., on older kernels), you can bypass codex's need to run git entirely by piping the diff on stdin:

```bash
git diff HEAD | codex --dangerously-bypass-approvals-and-sandbox review - 2>&1
```

The `-` argument tells codex to read the diff from stdin instead of running `git` itself. The downside is that codex can't inspect files beyond the diff or run follow-up commands.

### References

- [openai/codex#14919](https://github.com/openai/codex/issues/14919) — bwrap RTM_NEWADDR failure
- [openai/codex#12572](https://github.com/openai/codex/issues/12572) — subagents can't execute commands
- [openai/codex#15057](https://github.com/openai/codex/issues/15057) — AppArmor userns restrictions on Ubuntu
- [openai/codex linux-sandbox README](https://github.com/openai/codex/blob/main/codex-rs/linux-sandbox/README.md) — Landlock fallback docs
