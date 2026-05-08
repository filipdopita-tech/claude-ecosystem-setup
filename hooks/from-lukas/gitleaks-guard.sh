#!/usr/bin/env bash
# gitleaks-guard.sh — PreToolUse: scans for secrets before git commit/push or file Write
# Fires on: Bash (matching git commit|git push) and Write tool calls.
# Exit 0 = pass, 1 = block (high+ severity finding), 2 = warn but allow.
# Requires gitleaks binary; if absent, prints install hint and exits 0.
# GITLEAKS_MODE=block|warn|off  (default: block)
# Logs all findings to ~/.claude/logs/gitleaks-guard.jsonl

set -euo pipefail

LOG_DIR="$HOME/.claude/logs"
LOG_FILE="$LOG_DIR/gitleaks-guard.jsonl"
mkdir -p "$LOG_DIR"

# Respect HOOK_PROFILE
PROFILE="$(cat "$HOME/.claude/.hook-profile-current" 2>/dev/null || echo standard)"
[[ "$PROFILE" == "off" ]] && exit 0

MODE="${GITLEAKS_MODE:-block}"
[[ "$MODE" == "off" ]] && exit 0

# Require jq
if ! command -v jq &>/dev/null; then
  exit 0
fi

# Read stdin
INPUT="$(cat)"
[[ -z "$INPUT" ]] && exit 0

TOOL_NAME="$(printf '%s' "$INPUT" | jq -r '.tool_name // ""' 2>/dev/null)" || exit 0
TIMESTAMP="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"

# Require gitleaks
if ! command -v gitleaks &>/dev/null; then
  printf '\n[gitleaks-guard] gitleaks not found — install via: brew install gitleaks\n' >&2
  exit 0
fi

run_scan_on_content() {
  local tmpfile
  tmpfile="$(mktemp /tmp/gitleaks-guard-XXXXXX)"
  printf '%s' "$1" > "$tmpfile"
  local report
  report="$(gitleaks detect --source="$tmpfile" --report-format=json --report-path=/dev/stdout --no-git 2>/dev/null || true)"
  rm -f "$tmpfile"
  emit_findings "$report" "$2"
}

run_scan_on_staged() {
  local diff tmpdir
  diff="$(git diff --cached 2>/dev/null || true)"
  [[ -z "$diff" ]] && return 0
  tmpdir="$(mktemp -d /tmp/gitleaks-staged-XXXXXX)"
  printf '%s' "$diff" > "$tmpdir/staged.diff"
  local report
  report="$(gitleaks detect --source="$tmpdir" --report-format=json --report-path=/dev/stdout --no-git 2>/dev/null || true)"
  rm -rf "$tmpdir"
  emit_findings "$report" "git-staged"
}

FOUND_HIGH=0
emit_findings() {
  local report="$1" source="$2"
  [[ -z "$report" || "$report" == "null" || "$report" == "[]" ]] && return 0
  local count
  count="$(printf '%s' "$report" | jq 'length' 2>/dev/null || echo 0)"
  [[ "$count" -eq 0 ]] && return 0
  while IFS= read -r finding; do
    local rule secret_snippet file line log_entry
    rule="$(printf '%s' "$finding" | jq -r '.RuleID // "unknown"')"
    secret_snippet="$(printf '%s' "$finding" | jq -r '.Secret // "" | .[0:12]')..."
    file="$(printf '%s' "$finding" | jq -r '.File // "unknown"')"
    line="$(printf '%s' "$finding" | jq -r '.StartLine // 0')"
    log_entry="$(jq -cn --arg ts "$TIMESTAMP" --arg tool "$TOOL_NAME" --arg src "$source" \
      --arg rule "$rule" --arg snip "$secret_snippet" --arg f "$file" --argjson l "$line" \
      '{timestamp:$ts,tool:$tool,source:$src,rule:$rule,secret_snippet:$snip,file:$f,line:$l}')"
    printf '%s\n' "$log_entry" >> "$LOG_FILE"
    FOUND_HIGH=1
    printf '\n[gitleaks-guard] SECRET DETECTED | rule=%s | file=%s:%s | snippet=%s\n' \
      "$rule" "$file" "$line" "$secret_snippet" >&2
  done < <(printf '%s' "$report" | jq -c '.[]' 2>/dev/null)
}

# Dispatch based on tool
case "$TOOL_NAME" in
  Bash)
    CMD="$(printf '%s' "$INPUT" | jq -r '.tool_input.command // ""' 2>/dev/null)"
    if printf '%s' "$CMD" | grep -qE 'git (commit|push)'; then
      run_scan_on_staged
    fi
    ;;
  Write)
    CONTENT="$(printf '%s' "$INPUT" | jq -r '.tool_input.content // ""' 2>/dev/null)"
    FILE_PATH="$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // "unknown"' 2>/dev/null)"
    run_scan_on_content "$CONTENT" "write:$FILE_PATH"
    ;;
  *)
    exit 0
    ;;
esac

if [[ "$FOUND_HIGH" -eq 1 ]]; then
  if [[ "$MODE" == "warn" ]]; then
    printf '[gitleaks-guard] WARNING mode — proceeding despite finding. Log: %s\n' "$LOG_FILE" >&2
    exit 0
  else
    printf '[gitleaks-guard] BLOCKED: secret(s) detected. Review log: %s\n  Override: GITLEAKS_MODE=warn\n' "$LOG_FILE" >&2
    exit 1
  fi
fi

exit 0
