#!/usr/bin/env bash
# skill-feedback.sh — PostToolUse hook: logs Skill invocations to skill-feedback.jsonl
# Receives JSON on stdin: {"session_id":"...","tool_name":"Skill","tool_input":{"skill":"...","args":"..."},"tool_response":{...}}

FEEDBACK_FILE="$HOME/.claude/skill-feedback.jsonl"
INPUT=$(cat)

TOOL_NAME=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_name',''))" 2>/dev/null)
if [ "$TOOL_NAME" != "Skill" ]; then
  exit 0
fi

SKILL=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('skill','unknown'))" 2>/dev/null)
ARGS=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('args',''))" 2>/dev/null)
SESSION=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('session_id',''))" 2>/dev/null)

# Infer task_type from skill name
case "$SKILL" in
  ig-content-creator|content-repurpose|competitor-intel) TASK_TYPE="content" ;;
  dd-emitent) TASK_TYPE="due_diligence" ;;
  deploy-service) TASK_TYPE="infrastructure" ;;
  seo-audit) TASK_TYPE="seo" ;;
  security-self-audit|cso) TASK_TYPE="security" ;;
  graphify) TASK_TYPE="knowledge_graph" ;;
  mythos) TASK_TYPE="investigative" ;;
  deset|challenge|flip|redteam) TASK_TYPE="quality_loop" ;;
  *) TASK_TYPE="misc" ;;
esac

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

python3 - <<PYEOF >> "$FEEDBACK_FILE" 2>/dev/null
import json, os
record = {
    "timestamp": "$TIMESTAMP",
    "session_id": "$SESSION",
    "skill": "$SKILL",
    "task_type": "$TASK_TYPE",
    "args_hint": "$ARGS"[:80] if "$ARGS" else "",
    "outcome": "invoked",
}
print(json.dumps(record, ensure_ascii=False))
PYEOF

exit 0
