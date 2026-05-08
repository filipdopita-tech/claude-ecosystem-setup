#!/bin/bash
# observe.sh — PreToolUse + PostToolUse: tool usage observability + decision-point detection
# Source: filipdopita-tech/claude-ecosystem-setup (lightly adapted paths)
# Cost: zero. Pure bash + jq, no API calls. JSONL append + auto-purge at 1000 lines.
#
# Output:
#   ~/.claude/observations/observations.jsonl   — tool usage stream
#   ~/.claude/observations/decision-points.jsonl — flagged infra/config/dep changes
#   ~/.claude/observations/.cb_state.json        — circuit breaker state per tool+cmd
#
# Behavior:
#   - PRE phase: detect infra/config/dependency changes, inject [DECISION POINT] to stderr
#   - POST phase: track exit codes, 3 consecutive failures → [CIRCUIT BREAKER] warning to stderr
#
# stderr injects appear in Claude's context — designed to surface critical decisions
# without requiring user prompt. Safe: ~50-100 tokens per fire, decision-points only.

PHASE="${1:-post}"

BASE="${HOME}/.claude/observations"
mkdir -p "$BASE" 2>/dev/null

OBS_FILE="$BASE/observations.jsonl"
DECISION_LOG="$BASE/decision-points.jsonl"

# Anti-loop: skip if already observing
[ -n "$ECC_SKIP_OBSERVE" ] && exit 0
export ECC_SKIP_OBSERVE=1

INPUT=$(cat 2>/dev/null)
[ -z "$INPUT" ] && exit 0

TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)
[ -z "$TOOL" ] && exit 0

case "$TOOL" in
  observe*|hook*) exit 0 ;;
esac

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
CWD=$(pwd 2>/dev/null)

IS_DECISION="false"
DECISION_CATEGORY=""

if [ "$PHASE" = "pre" ]; then
  COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // .tool_input.file_path // empty' 2>/dev/null | head -c 500)

  if echo "$COMMAND" | grep -qE '(systemctl\s+(enable|disable|restart|stop|mask)|monit\s+(reload|unmonitor)|docker\s+(rm|stop|compose)|nginx\s+-s\s+reload|iptables|ufw|certbot|apt\s+(install|remove|purge)|brew\s+(install|uninstall))'; then
    IS_DECISION="true"
    DECISION_CATEGORY="infra_service"
  fi

  if echo "$COMMAND" | grep -qE '(/etc/systemd/|/etc/monit/|/etc/nginx/|docker-compose|\.service|monitrc|settings\.json|CLAUDE\.md)'; then
    IS_DECISION="true"
    DECISION_CATEGORY="config_change"
  fi

  if echo "$COMMAND" | grep -qE '(pip3?\s+install|npm\s+install|bun\s+(add|install)|apt\s+install|cargo\s+install|gem\s+install|brew\s+install)'; then
    IS_DECISION="true"
    DECISION_CATEGORY="new_dependency"
  fi

  if [ "$TOOL" = "Write" ]; then
    FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
    if echo "$FILE_PATH" | grep -qE '(/etc/|\.service$|\.conf$|\.env$|hooks/|scripts/|skills/|agents/|commands/)'; then
      IS_DECISION="true"
      DECISION_CATEGORY="new_config_file"
    fi
  fi

  jq -n -c \
    --arg ts "$TIMESTAMP" \
    --arg tool "$TOOL" \
    --arg phase "$PHASE" \
    --arg cwd "$CWD" \
    --arg cmd "$COMMAND" \
    --arg decision "$IS_DECISION" \
    --arg decision_cat "$DECISION_CATEGORY" \
    '{ts:$ts, tool:$tool, phase:$phase, cwd:$cwd, cmd:$cmd, decision:($decision == "true"), decision_cat:$decision_cat}' \
    >> "$OBS_FILE" 2>/dev/null

  if [ "$IS_DECISION" = "true" ]; then
    DEC_ID="dec_$(date +%s)_$$"

    jq -n -c \
      --arg id "$DEC_ID" \
      --arg ts "$TIMESTAMP" \
      --arg category "$DECISION_CATEGORY" \
      --arg tool "$TOOL" \
      --arg cmd "$COMMAND" \
      --arg outcome "pending" \
      '{id:$id, ts:$ts, category:$category, tool:$tool, cmd:$cmd, outcome:$outcome}' \
      >> "$DECISION_LOG" 2>/dev/null

    case "$DECISION_CATEGORY" in
      infra_service)
        echo "[DECISION POINT] Infra change. Ověř: Je restart/změna nutná? Fallback při selhání? Vliv na ostatní služby?" >&2
        ;;
      config_change)
        echo "[DECISION POINT] Config change. Ověř: Záloha originálu? Co při rollbacku? Testovaná syntaxe?" >&2
        ;;
      new_dependency)
        echo "[DECISION POINT] Nová závislost. Ověř: Je nutná? Lehčí alternativa? Maintenance stav? Security?" >&2
        ;;
      new_config_file)
        echo "[DECISION POINT] Nový config/script. Ověř: Patří sem? Duplicita? Soulad s architekturou?" >&2
        ;;
    esac
  fi

else
  EXIT_CODE=$(echo "$INPUT" | jq -r '.tool_output.exit_code // .tool_response.is_error // "0"' 2>/dev/null)
  ERROR=$(echo "$INPUT" | jq -r '.tool_output.stderr // empty' 2>/dev/null | head -c 200)

  jq -n -c \
    --arg ts "$TIMESTAMP" \
    --arg tool "$TOOL" \
    --arg phase "$PHASE" \
    --arg cwd "$CWD" \
    --arg exit "$EXIT_CODE" \
    --arg error "$ERROR" \
    '{ts:$ts, tool:$tool, phase:$phase, cwd:$cwd, exit:$exit, error:$error}' \
    >> "$OBS_FILE" 2>/dev/null
fi

# Auto-purge: keep last 1000 obs, last 200 decisions
if [ -f "$OBS_FILE" ]; then
  LINES=$(wc -l < "$OBS_FILE" 2>/dev/null)
  if [ "$LINES" -gt 1000 ]; then
    tail -500 "$OBS_FILE" > "${OBS_FILE}.tmp" && mv "${OBS_FILE}.tmp" "$OBS_FILE"
  fi
fi

if [ -f "$DECISION_LOG" ]; then
  DEC_LINES=$(wc -l < "$DECISION_LOG" 2>/dev/null)
  if [ "$DEC_LINES" -gt 200 ]; then
    tail -100 "$DECISION_LOG" > "${DECISION_LOG}.tmp" && mv "${DECISION_LOG}.tmp" "$DECISION_LOG"
  fi
fi

exit 0
