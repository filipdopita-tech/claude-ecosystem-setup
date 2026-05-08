#!/usr/bin/env bash
# falsification-gate.sh — Stop hook
# Detects high-stakes outputs in the closing message and flags missing
# falsification / verification markers. Advisory (non-blocking, exit 0).
# Pairs with reasoning-depth.md § Falsification-First and evalopt skill.

set -uo pipefail
LOG_DIR="$HOME/.claude/logs"
LOG="$LOG_DIR/falsification-flags.jsonl"
mkdir -p "$LOG_DIR"

# Hook protocol: Claude Code passes JSON on stdin with the final message.
INPUT="$(cat 2>/dev/null || true)"
[[ -z "$INPUT" ]] && exit 0

# Try to extract last assistant message (best-effort: any text payload).
TXT="$(printf '%s' "$INPUT" | tr -d '\000' | tr '\n' ' ' | head -c 16000)"
[[ -z "$TXT" ]] && exit 0

# High-stakes signals (CZ + EN, OneFlow domain).
HIGH_STAKES_RE='(DSCR|LTV|emitent|prospekt|due diligence|investor memo|investment memo|investorský memo|cap table|equity|cnb|ecsp|aml |gdpr binding|prod(ukč|uction)|nasadit|deploy|systemctl (restart|stop|disable)|migrate|drop (table|database)|rm -rf|force[- ]push|rotate (key|secret)|nový klient|klientská smlouva|cena .* (kč|czk|usd|eur)|invoice|fakturac)'

# Missing-falsification markers (overconfident without verification flags).
OVERCONFIDENT_RE='(určitě|stoprocentně|naprosto|zaručeně|certainly|definitely|absolutely)'
HAS_VERIFY_RE='(\[VERIFIED\]|\[LIKELY|\[GUESS|\[UNCERTAIN\]|verify-claim|/factcheck|evalopt|3 alternativ|steelman|falsifikac|falsification)'

flagged=0
reason=""

if [[ "$TXT" =~ $HIGH_STAKES_RE ]]; then
  if ! [[ "$TXT" =~ $HAS_VERIFY_RE ]]; then
    flagged=1
    reason="high-stakes content without verification markers"
  fi
fi

# Independent overconfidence trigger.
if [[ "$TXT" =~ $OVERCONFIDENT_RE ]] && ! [[ "$TXT" =~ $HAS_VERIFY_RE ]]; then
  flagged=1
  reason="${reason:+$reason; }overconfident phrasing without [VERIFIED]/[LIKELY] markers"
fi

if (( flagged == 1 )); then
  TS="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  SIG="$(printf '%s' "$TXT" | head -c 400 | tr '"' '`' | tr -d '\000-\037')"
  printf '{"ts":"%s","reason":"%s","sig":"%s"}\n' "$TS" "$reason" "$SIG" >> "$LOG"

  # Best-effort ntfy nudge (advisory, never blocking).
  if command -v curl >/dev/null 2>&1; then
    curl -fsS -m 3 -d "Falsification gate: $reason" \
      -H "Title: Claude high-stakes output — verify" \
      -H "Priority: low" \
      -H "Tags: warning" \
      https://ntfy.oneflow.cz/Filip >/dev/null 2>&1 || true
  fi

  # Surface to user via stderr (Claude Code shows hook stderr in trace).
  echo "[falsification-gate] $reason — consider /evalopt or /verify-claim before shipping." 1>&2
fi

exit 0
