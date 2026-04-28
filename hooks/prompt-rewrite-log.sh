#!/bin/bash
# prompt-rewrite-log.sh - UserPromptSubmit: Stage A passive logging of user prompt classification.
# No rewrite, no modification. Just classifies intent + logs to ~/.claude/logs/prompt-rewrites.jsonl.
# Provides data for later decision whether Stage B (actual rewrite) makes sense.

source "${HOME}/.claude/hooks/hooks-common.sh"

JQ=$(command -v jq 2>/dev/null || echo "${HOME}/.claude/bin/jq.exe")
INPUT=$(cat 2>/dev/null)
[ -z "$INPUT" ] && exit 0

PROMPT=$(echo "$INPUT" | "$JQ" -r '.prompt // ""' 2>/dev/null)
SESSION_ID=$(echo "$INPUT" | "$JQ" -r '.session_id // ""' 2>/dev/null)
[ -z "$PROMPT" ] && exit 0

PLEN=${#PROMPT}

# Lightweight heuristic classifier (bash-grade).
# Directive: imperative verbs up front (udelej, implementuj, oprav, make, do, run, add, fix, change, create, delete)
# Inquiry: question words / ends with "?"
# Ambiguous: neither strong signal
KIND="ambiguous"

case "$PROMPT" in
  \?*|*\?)
    KIND="inquiry"
    ;;
  [Jj]ak\ *|[Cc]o\ *|[Pp]roc\ *|[Kk]dy\ *|[Kk]do\ *|[Ww]hat\ *|[Hh]ow\ *|[Ww]hy\ *|[Ww]hen\ *|[Ww]ho\ *)
    KIND="inquiry"
    ;;
  [Uu]dela*|[Ii]mplement*|[Oo]prav*|[Nn]apis*|[Vv]ytvor*|[Zz]meni*|[Ss]maz*|[Pp]ridej*|[Pp]rid\ *|[Aa]dd\ *|[Ff]ix\ *|[Mm]ake\ *|[Dd]o\ *|[Rr]un\ *|[Cc]reate\ *|[Dd]elete\ *|[Cc]hange\ *)
    KIND="directive"
    ;;
esac

# Length bucket
if [ "$PLEN" -lt 40 ]; then
  LBUCKET="short"
elif [ "$PLEN" -lt 200 ]; then
  LBUCKET="medium"
else
  LBUCKET="long"
fi

LOG_DIR="${HOME}/.claude/logs"
mkdir -p "$LOG_DIR"
TS=$(date -u +"%Y-%m-%d %H:%M UTC")

"$JQ" -nc \
  --arg ts "$TS" \
  --arg sid "$SESSION_ID" \
  --arg kind "$KIND" \
  --arg lb "$LBUCKET" \
  --argjson plen "$PLEN" \
  '{ts:$ts, session_id:$sid, kind:$kind, length_bucket:$lb, prompt_len:$plen}' \
  >> "$LOG_DIR/prompt-rewrites.jsonl" 2>/dev/null

exit 0
