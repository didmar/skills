#!/usr/bin/env bash
set -euo pipefail

# Usage: recover-sessions.sh [--dry-run] [old-project-path]
# Recovers Claude Code sessions after a project is moved to a new directory.

PROJECTS_DIR="$HOME/.claude/projects"

# --- helpers ---
mangle() { echo "-$(echo "$1" | sed 's|^/||; s|/|-|g')"; }

count_sessions() {
  local dir="$1"
  find "$dir" -maxdepth 1 \( -type d -name '????????-????-????-????-????????????' -o -name '*.jsonl' \) 2>/dev/null | grep -v '/memory$' | wc -l
}

# Returns: "none", "empty", or "present"
memory_status() {
  local dir="$1"
  if [[ ! -f "$dir/memory/MEMORY.md" ]]; then
    echo "none"
  elif [[ ! -s "$dir/memory/MEMORY.md" ]]; then
    echo "empty"
  else
    echo "present"
  fi
}

# --- parse args ---
DRY_RUN=false
OLD_PATH=""
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    *) OLD_PATH="$arg" ;;
  esac
done

# expand ~ if present
OLD_PATH="${OLD_PATH/#\~/$HOME}"

# --- current project ---
current_mangled="$(mangle "$PWD")"
current_dir="$PROJECTS_DIR/$current_mangled"

# --- resolve old project ---
if [[ -z "$OLD_PATH" ]]; then
  echo "Usage: /recover-sessions [--dry-run] <old-project-path>"
  echo ""
  echo "Example: /recover-sessions ~/old-project-path"
  echo "         /recover-sessions --dry-run ~/old-project-path"
  exit 1
else
  # resolve to absolute path
  OLD_PATH="$(cd "$OLD_PATH" 2>/dev/null && pwd || echo "$OLD_PATH")"
  old_mangled="$(mangle "$OLD_PATH")"
fi

old_dir="$PROJECTS_DIR/$old_mangled"

# --- validate ---
if [[ ! -d "$old_dir" ]]; then
  echo "ERROR: No session data found (looked in $old_dir)"
  exit 1
fi
mkdir -p "$current_dir"

# --- summary ---
old_count=$(count_sessions "$old_dir")
new_count=$(count_sessions "$current_dir")
old_memory=$(memory_status "$old_dir")
new_memory=$(memory_status "$current_dir")

echo "Source:      $old_dir"
echo "Destination: $current_dir"
echo ""
echo "Sessions in old location:     $old_count"
echo "Sessions in current location: $new_count"
echo "MEMORY.md in old: $old_memory | in current: $new_memory"

if $DRY_RUN; then
  echo ""
  echo "[dry-run] No files copied. Re-run without --dry-run to proceed."
  exit 0
fi

# --- copy ---
echo ""
cp -a --update=none "$old_dir"/* "$current_dir"/ 2>/dev/null || true

# --- memory conflict check ---
if [[ "$old_memory" != "none" && "$new_memory" != "none" ]]; then
  if ! diff -q "$old_dir/memory/MEMORY.md" "$current_dir/memory/MEMORY.md" >/dev/null 2>&1; then
    if [[ "$new_memory" == "empty" ]]; then
      cp -a "$old_dir/memory/MEMORY.md" "$current_dir/memory/MEMORY.md"
      echo "Copied old MEMORY.md (current one was empty)."
    else
      echo "WARNING: Both locations have a MEMORY.md and they differ."
      echo "  The old one was NOT copied (no-clobber). You may want to manually merge from:"
      echo "  $old_dir/memory/MEMORY.md"
      echo ""
    fi
  fi
fi

# --- results ---
final_count=$(count_sessions "$current_dir")
recovered=$((final_count - new_count))

echo "Done! $recovered sessions recovered ($final_count total now)."
echo "Use 'claude --resume' or 'claude --continue' to access old sessions."
echo "Old data left intact in $old_dir (not deleted)."
