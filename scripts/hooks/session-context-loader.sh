#!/bin/bash
# Session Context Loader — proactive memory + instinct loading at session start

MEMORY_DIR="$HOME/.claude/projects/$(whoami)/memory"
HOMUNCULUS="$HOME/.claude/homunculus"
CONTEXT=""

# 1. Session handoff (capped at 2KB to save tokens)
if [ -f "$MEMORY_DIR/session_handoff.md" ]; then
    HANDOFF=$(head -c 2048 "$MEMORY_DIR/session_handoff.md")
    if [ -n "$HANDOFF" ]; then
        CONTEXT="${CONTEXT}## Previous Session Handoff\n${HANDOFF}\n\n"
    fi
fi

# 2. Credential expiry warnings
if [ -f "$MEMORY_DIR/credential_expiry.md" ]; then
    EXPIRING=$(grep -E "\| .*(EXPIRING|EXPIRED|WARNING)" "$MEMORY_DIR/credential_expiry.md" 2>/dev/null)
    if [ -n "$EXPIRING" ]; then
        CONTEXT="${CONTEXT}## Credential Warnings\n${EXPIRING}\n\n"
    fi
fi

# 3. Active instincts (high confidence only)
INSTINCTS=""
for f in "$HOMUNCULUS/instincts/"*.jsonl; do
    [ -f "$f" ] || continue
    # Extract high-confidence instincts (>= 0.7)
    # Seed instincts: show >= 0.7, auto-learned: show >= 0.5
    HIGH=$(jq -r 'select((.confidence >= 0.7 and .source != "observer") or (.confidence >= 0.5 and .source == "observer")) | "- [\(.type)] \(.pattern) → \(.action)"' "$f" 2>/dev/null)
    [ -n "$HIGH" ] && INSTINCTS="${INSTINCTS}${HIGH}\n"
done

if [ -n "$INSTINCTS" ]; then
    COUNT=$(echo -e "$INSTINCTS" | grep -c "^-")
    CONTEXT="${CONTEXT}## Active Instincts ($COUNT high-confidence rules)\n${INSTINCTS}\n"
fi

# 4. Observation stats (quick summary)
OBS_FILE="$HOMUNCULUS/observations.jsonl"
if [ -f "$OBS_FILE" ]; then
    OBS_COUNT=$(wc -l < "$OBS_FILE" 2>/dev/null | tr -d ' ')
    ERROR_COUNT=$(jq -r 'select(.exit != "0" and .exit != "" and .phase == "post") | .exit' "$OBS_FILE" 2>/dev/null | wc -l | tr -d ' ')
    if [ "$OBS_COUNT" -gt 0 ]; then
        CONTEXT="${CONTEXT}## Learning: ${OBS_COUNT} observations, ${ERROR_COUNT} errors tracked\n"
    fi
fi

# 4b. Active loop detections (Pattern Interruption warnings)
LOOP_LOG="$HOMUNCULUS/loop-detections.jsonl"
if [ -f "$LOOP_LOG" ]; then
    UNRESOLVED=$(jq -r 'select(.resolved == false) | "- [\(.type)] \(.file // .cmd) (\(.count)x)"' "$LOOP_LOG" 2>/dev/null | tail -5)
    if [ -n "$UNRESOLVED" ]; then
        CONTEXT="${CONTEXT}## Active Loop Warnings (pattern interruption)\n${UNRESOLVED}\nTyto vzorce byly detekovány v minulých sessions. Pokud se opakují, změň přístup.\n\n"
    fi
fi

# 4c. Recent decision points (Devil's Advocate tracking)
DECISION_LOG="$HOMUNCULUS/decision-points.jsonl"
if [ -f "$DECISION_LOG" ]; then
    BAD_DECISIONS=$(jq -r 'select(.outcome == "errors_followed") | "- [\(.category)] \(.cmd | .[0:80]) → \(.error_count) errors"' "$DECISION_LOG" 2>/dev/null | tail -3)
    if [ -n "$BAD_DECISIONS" ]; then
        CONTEXT="${CONTEXT}## Decision Points With Issues (review needed)\n${BAD_DECISIONS}\n\n"
    fi
    PENDING=$(jq -r 'select(.outcome == "pending")' "$DECISION_LOG" 2>/dev/null | wc -l | tr -d ' ')
    if [ "$PENDING" -gt 0 ]; then
        CONTEXT="${CONTEXT}## $PENDING pending decision points tracked\n"
    fi
fi

# 5. Run observer processor if enough new data (background, don't block)
LAST=$(cat "$HOMUNCULUS/.last_processed" 2>/dev/null || echo 0)
if [ -f "$OBS_FILE" ]; then
    TOTAL=$(wc -l < "$OBS_FILE" 2>/dev/null | tr -d ' ')
    NEW=$((TOTAL - LAST))
    if [ "$NEW" -ge 20 ]; then
        bash $HOME/.claude/scripts/observer-processor.sh > /dev/null 2>&1 &
    fi
fi

# 6. AutoDream — memory consolidation gate check (background-safe)
DREAM_OUTPUT=$(bash $HOME/.claude/scripts/auto-dream.sh 2>/dev/null)
if [ $? -eq 0 ] && [ -n "$DREAM_OUTPUT" ]; then
    CONTEXT="${CONTEXT}\n${DREAM_OUTPUT}\n"
fi

# 6b. Last dream result (if exists)
DREAM_RESULT="$HOMUNCULUS/.dream_result.json"
if [ -f "$DREAM_RESULT" ]; then
    DREAM_TS=$(jq -r '.ts // empty' "$DREAM_RESULT" 2>/dev/null)
    DREAM_MERGED=$(jq -r '.merged // 0' "$DREAM_RESULT" 2>/dev/null)
    DREAM_PRUNED=$(jq -r '.pruned // 0' "$DREAM_RESULT" 2>/dev/null)
    if [ -n "$DREAM_TS" ] && [ "$DREAM_MERGED" != "0" ] || [ "$DREAM_PRUNED" != "0" ]; then
        CONTEXT="${CONTEXT}## Last AutoDream (${DREAM_TS}): ${DREAM_MERGED} merged, ${DREAM_PRUNED} pruned\n"
    fi
fi

# Output
if [ -n "$CONTEXT" ]; then
    echo -e "$CONTEXT"
fi
