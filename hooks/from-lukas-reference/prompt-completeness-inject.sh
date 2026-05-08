#!/usr/bin/env bash
# prompt-completeness-inject.sh — UserPromptSubmit: detects multi-point prompts and injects advisory
# Fires on: UserPromptSubmit (every user message).
# Exit 0 always — advisory only, never blocks.
# Detects: numbered lists, bullet items, multi-line bullets, EN+CZ connectors (and/then/plus/also/a také/pak/navíc/plus).
# Advisory threshold: ≥2 distinct asks detected.
# Env vars: none (always active unless HOOK_PROFILE=off).

set -euo pipefail

# Respect HOOK_PROFILE
PROFILE="$(cat "$HOME/.claude/.hook-profile-current" 2>/dev/null || echo standard)"
[[ "$PROFILE" == "off" ]] && exit 0

# Require jq
if ! command -v jq &>/dev/null; then
  exit 0
fi

# Read stdin
INPUT="$(cat)"
[[ -z "$INPUT" ]] && exit 0

PROMPT="$(printf '%s' "$INPUT" | jq -r '.prompt // ""' 2>/dev/null)" || exit 0
[[ -z "$PROMPT" ]] && exit 0

detect_points() {
  local text="$1"
  local count=0

  # Count numbered list items: lines starting with "1." "2." etc.
  local numbered
  numbered="$(printf '%s' "$text" | grep -cE '^\s*[0-9]+\.' || true)"
  # Each numbered item is a distinct ask
  if [[ "$numbered" -ge 2 ]]; then
    count=$(( count + numbered ))
  fi

  # Count markdown bullet items (lines starting with - or * or •)
  local bullets
  bullets="$(printf '%s' "$text" | grep -cE '^\s*[-*•]' || true)"
  if [[ "$bullets" -ge 2 ]]; then
    count=$(( count + bullets ))
  fi

  # Count EN connectors as additional asks: "and", "then", "plus", "also"
  # Only when NOT already caught by list structures (to avoid double-counting big lists)
  if [[ "$numbered" -lt 2 && "$bullets" -lt 2 ]]; then
    local connectors
    connectors="$(printf '%s' "$text" | grep -ioE '\b(and|then|plus|also)\b' | wc -l | tr -d '[:space:]' || true)"
    # CZ connectors: a, také, pak, navíc, potom, plus, a také
    local cz_connectors
    cz_connectors="$(printf '%s' "$text" | grep -ioE '\b(také|pak|navíc|potom)\b|(\ba\b)' | wc -l | tr -d '[:space:]' || true)"
    count=$(( count + connectors + cz_connectors ))
  fi

  printf '%d' "$count"
}

POINT_COUNT="$(detect_points "$PROMPT")"

if [[ "$POINT_COUNT" -ge 2 ]]; then
  printf '\n[prompt-completeness] Multi-point prompt detected (%d points). Reminder: use TodoWrite to track + verify all %d before claiming done.\n\n' \
    "$POINT_COUNT" "$POINT_COUNT" >&2
fi

exit 0
