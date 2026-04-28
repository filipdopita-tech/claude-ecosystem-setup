#!/usr/bin/env bash
# hook-profile-loader.sh — SessionStart hook
# Reads HOOK_PROFILE env var (minimal|standard|strict|off) and writes to
# ~/.claude/.hook-profile-current for other hooks to consume.
# Default: standard

set -euo pipefail

LOG_DIR="$HOME/.claude/logs"
LOG_FILE="$LOG_DIR/hook-profile-loader.log"
MAX_LOG_LINES=1000
PROFILE_FILE="$HOME/.claude/.hook-profile-current"

mkdir -p "$LOG_DIR"
mkdir -p "$HOME/.claude"

VALID_PROFILES="minimal standard strict off"

# Determine profile
PROFILE="${HOOK_PROFILE:-standard}"

# Validate; fall back to standard on unknown value
VALID=0
for P in $VALID_PROFILES; do
  [[ "$PROFILE" == "$P" ]] && VALID=1 && break
done

if [[ "$VALID" -eq 0 ]]; then
  printf 'hook-profile-loader: unknown HOOK_PROFILE=%s, falling back to standard\n' "$PROFILE" >&2
  PROFILE="standard"
fi

# Write resolved profile
printf '%s' "$PROFILE" > "$PROFILE_FILE"

TIMESTAMP="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
printf '%s profile=%s\n' "$TIMESTAMP" "$PROFILE" >> "$LOG_FILE"

# Advisory to stderr (visible in Claude session start output)
printf '[hooks] Profile: %s\n' "$PROFILE" >&2

# Explain each level on first mention per session
case "$PROFILE" in
  off)      printf '[hooks] All advisory hooks suppressed (off)\n' >&2 ;;
  minimal)  printf '[hooks] Minimal: only hard-block hooks active\n' >&2 ;;
  standard) printf '[hooks] Standard: advisories + hard blocks active\n' >&2 ;;
  strict)   printf '[hooks] Strict: all enforcement hooks maximally active\n' >&2 ;;
esac

# Log rotation
if [[ -f "$LOG_FILE" ]]; then
  LINE_COUNT="$(wc -l < "$LOG_FILE")"
  if (( LINE_COUNT > MAX_LOG_LINES )); then
    TMP="$(mktemp)"
    tail -n "$MAX_LOG_LINES" "$LOG_FILE" > "$TMP" && mv "$TMP" "$LOG_FILE"
  fi
fi

exit 0
