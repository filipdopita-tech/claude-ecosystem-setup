#!/bin/bash
# Observation Hook v2 — records tool usage + detects decision points
# Runs on PreToolUse and PostToolUse
# Writes to ~/.claude/homunculus/observations.jsonl
# Tags critical infrastructure changes as decision-points

PHASE="${1:-post}"  # pre or post

# Detect environment: Mac vs VPS
if [ -d "/Users/filipdopita/.claude/homunculus" ]; then
  BASE="/Users/filipdopita/.claude/homunculus"
elif [ -d "/root/.claude/homunculus" ]; then
  BASE="/root/.claude/homunculus"
else
  BASE="${HOME}/.claude/homunculus"
  mkdir -p "$BASE" 2>/dev/null
fi

OBS_FILE="$BASE/observations.jsonl"
DECISION_LOG="$BASE/decision-points.jsonl"

# Anti-loop: skip if already observing
[ -n "$ECC_SKIP_OBSERVE" ] && exit 0
export ECC_SKIP_OBSERVE=1

# Read hook input from stdin
INPUT=$(cat 2>/dev/null)
[ -z "$INPUT" ] && exit 0

# Extract key fields
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)
[ -z "$TOOL" ] && exit 0

# Skip observation of observation hooks
case "$TOOL" in
  observe*|hook*) exit 0 ;;
esac

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
CWD=$(pwd 2>/dev/null)

# ===========================================================================
# Decision Point Detection — tag critical infrastructure changes
# ===========================================================================
IS_DECISION="false"
DECISION_CATEGORY=""

if [ "$PHASE" = "pre" ]; then
  COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // .tool_input.file_path // empty' 2>/dev/null | head -c 500)

  # Detect infra-critical commands via SSH
  if echo "$COMMAND" | grep -qE '(systemctl\s+(enable|disable|restart|stop|mask)|monit\s+(reload|unmonitor)|docker\s+(rm|stop|compose)|nginx\s+-s\s+reload|iptables|ufw|certbot|apt\s+(install|remove|purge))'; then
    IS_DECISION="true"
    DECISION_CATEGORY="infra_service"
  fi

  # Detect critical config file changes
  if echo "$COMMAND" | grep -qE '(/etc/systemd/|/etc/monit/|/etc/nginx/|/etc/fluent-bit/|docker-compose|\.service|monitrc|settings\.json|CLAUDE\.md)'; then
    IS_DECISION="true"
    DECISION_CATEGORY="config_change"
  fi

  # Detect new dependency installation
  if echo "$COMMAND" | grep -qE '(pip3?\s+install|npm\s+install|apt\s+install|cargo\s+install|gem\s+install)'; then
    IS_DECISION="true"
    DECISION_CATEGORY="new_dependency"
  fi

  # Detect architecture decisions (new files in critical dirs)
  if [ "$TOOL" = "Write" ]; then
    FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
    if echo "$FILE_PATH" | grep -qE '(/etc/|\.service$|\.conf$|\.env$|hooks/|scripts/|skills/)'; then
      IS_DECISION="true"
      DECISION_CATEGORY="new_config_file"
    fi
  fi

  # Write observation with decision metadata
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

  # If decision point: log it + output challenge to stderr (shows in Claude context)
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

    # Challenge prompt — injected into Claude's context via stderr
    case "$DECISION_CATEGORY" in
      infra_service)
        echo "[DECISION POINT] Infra change. Ověř: Je restart/změna služby nutná? Jaký je fallback pokud to selže? Vliv na ostatní služby?" >&2
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
  # Post phase
  EXIT_CODE=$(echo "$INPUT" | jq -r '.tool_output.exit_code // "0"' 2>/dev/null)
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

  # ===========================================================================
  # Circuit Breaker — 3 consecutive failures → warning injection
  # State: $BASE/.cb_state.json — {key: {count, ts}}
  # ===========================================================================
  CB_STATE="$BASE/.cb_state.json"
  [ ! -f "$CB_STATE" ] && echo '{}' > "$CB_STATE"

  # Key = tool + first 2 words of last command (for grouping)
  LAST_CMD=$(tail -20 "$OBS_FILE" 2>/dev/null | jq -r "select(.phase==\"pre\" and .tool==\"$TOOL\") | .cmd" 2>/dev/null | tail -1 | awk '{print $1" "$2}' | head -c 30)
  CB_KEY="${TOOL}_$(echo "$LAST_CMD" | tr ' /.@' '____' | head -c 20)"

  if [ "$EXIT_CODE" != "0" ] && [ -n "$EXIT_CODE" ] && [ "$EXIT_CODE" != "null" ]; then
    NOW_TS=$(date +%s)
    OLD_COUNT=$(jq -r --arg k "$CB_KEY" '.[$k].count // 0' "$CB_STATE" 2>/dev/null || echo 0)
    OLD_TS=$(jq -r --arg k "$CB_KEY" '.[$k].ts // 0' "$CB_STATE" 2>/dev/null || echo 0)
    # Reset after 1 hour
    [ $((NOW_TS - OLD_TS)) -gt 3600 ] && OLD_COUNT=0
    NEW_COUNT=$((OLD_COUNT + 1))
    # Atomic write
    jq --arg k "$CB_KEY" --argjson n "$NEW_COUNT" --argjson ts "$NOW_TS" \
       '.[$k] = {"count":$n,"ts":$ts}' "$CB_STATE" > "${CB_STATE}.tmp" 2>/dev/null \
       && mv "${CB_STATE}.tmp" "$CB_STATE"
    # Threshold: inject warning after 3 consecutive failures
    if [ "$NEW_COUNT" -ge 3 ]; then
      echo "[CIRCUIT BREAKER] $TOOL selhal ${NEW_COUNT}x po sobe (${LAST_CMD}). Zastav, analyzuj pricinu." >&2
    fi
  else
    # Success — reset counter for this key
    if [ -s "$CB_STATE" ] && [ "$(cat "$CB_STATE" 2>/dev/null)" != "{}" ]; then
      jq --arg k "$CB_KEY" 'del(.[$k])' "$CB_STATE" > "${CB_STATE}.tmp" 2>/dev/null \
         && mv "${CB_STATE}.tmp" "$CB_STATE"
    fi
  fi
fi

# Auto-purge: keep only last 1000 lines
if [ -f "$OBS_FILE" ]; then
  LINES=$(wc -l < "$OBS_FILE" 2>/dev/null)
  if [ "$LINES" -gt 1000 ]; then
    tail -500 "$OBS_FILE" > "${OBS_FILE}.tmp" && mv "${OBS_FILE}.tmp" "$OBS_FILE"
  fi
fi

# Auto-purge decision log: keep last 200
if [ -f "$DECISION_LOG" ]; then
  DEC_LINES=$(wc -l < "$DECISION_LOG" 2>/dev/null)
  if [ "$DEC_LINES" -gt 200 ]; then
    tail -100 "$DECISION_LOG" > "${DECISION_LOG}.tmp" && mv "${DECISION_LOG}.tmp" "$DECISION_LOG"
  fi
fi

exit 0
