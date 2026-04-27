#!/usr/bin/env bash
# Auto-patch Claude Code "done" logo to green after extension updates
# Triggered by SessionStart hook - checks and patches if needed
# Original: #D97757 (orange) -> Patched: #22C55E (green)

patch_svg() {
  local svg="$1"
  [ -f "$svg" ] || return 0
  if grep -q '#22C55E' "$svg" 2>/dev/null; then
    return 0  # already patched
  fi
  [ ! -f "$svg.backup" ] && cp "$svg" "$svg.backup"
  sed -i 's/fill="#D97757"/fill="#22C55E"/g' "$svg"
}

# VPS (Remote SSH server)
for dir in "$HOME"/.vscode-server/extensions/anthropic.claude-code-*/resources; do
  [ -d "$dir" ] && patch_svg "$dir/claude-logo-done.svg"
done

# Mac (via SSHFS mount)
for dir in /mac/.vscode/extensions/anthropic.claude-code-*/resources; do
  [ -d "$dir" ] && patch_svg "$dir/claude-logo-done.svg"
done

exit 0
