#!/bin/bash
# memory-cap-guard.sh — PreToolUse hook na Write/Edit pro MEMORY.md
#
# Blokuje Write/Edit operace na MEMORY.md, které by překročily 22KB.
# Důvod: 24KB hard cap (CC index loader), nad to se ořezává → Claude vidí jen část → opakuje se.
# Buffer 2KB pro auto-append a další turn.
#
# Override: COMPLETION_OVERRIDE=1 nebo MEMORY_CAP_OVERRIDE=1 (skip pro legitimate edge case).
# 2026-04-27 — Filip session: "memory bere moc usage, opakuje se"

set -uo pipefail

INPUT=$(cat)
HOOK_LOG="${HOME}/.claude/logs/memory-cap-guard.log"
mkdir -p "$(dirname "$HOOK_LOG")"

TOOL=$(printf '%s' "$INPUT" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('tool_name',''))" 2>/dev/null || echo "")
FILE_PATH=$(printf '%s' "$INPUT" | python3 -c "import json,sys; d=json.load(sys.stdin); ti=d.get('tool_input',{}); print(ti.get('file_path',''))" 2>/dev/null || echo "")

# Only guard MEMORY.md (not auto-index, not extra-index)
if [[ "$FILE_PATH" != *"/projects/<your-project-id>/memory/MEMORY.md" ]]; then
  exit 0
fi

# Override paths
if [[ "${COMPLETION_OVERRIDE:-0}" == "1" || "${MEMORY_CAP_OVERRIDE:-0}" == "1" ]]; then
  echo "[$(date +%FT%T)] OVERRIDE active for MEMORY.md edit" >> "$HOOK_LOG"
  exit 0
fi

# Check size if file exists
if [[ -f "$FILE_PATH" ]]; then
  CUR_SIZE=$(wc -c < "$FILE_PATH" | tr -d ' ')
  HARD_CAP=22528  # 22KB - safe margin under 24KB CC limit

  # For Write tool: check new content size
  if [[ "$TOOL" == "Write" ]]; then
    NEW_CONTENT=$(printf '%s' "$INPUT" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('content',''))" 2>/dev/null || echo "")
    NEW_SIZE=$(printf '%s' "$NEW_CONTENT" | wc -c | tr -d ' ')

    if (( NEW_SIZE > HARD_CAP )); then
      echo "[$(date +%FT%T)] BLOCKED Write MEMORY.md: new=${NEW_SIZE}B > cap=${HARD_CAP}B" >> "$HOOK_LOG"
      cat <<EOF >&2
MEMORY-CAP-GUARD: BLOCKED Write na MEMORY.md.
Nová velikost: ${NEW_SIZE}B
Hard cap: ${HARD_CAP}B (22KB; CC limit 24KB s buffer)
Stávající: ${CUR_SIZE}B

Důvod: MEMORY.md je auto-loaded každým turnem. Nad cap se ořezává → Claude vidí jen část → opakuje se.

Akce:
1. Zkrať obsah na <22KB
2. Move starší entries do MEMORY-INDEX-EXTRA.md
3. Auto entries patří do MEMORY-AUTO-INDEX.md
4. Override: MEMORY_CAP_OVERRIDE=1 (pro legitimate edge case)
EOF
      exit 2
    fi
  fi

  # For Edit tool: check if it would grow the file
  if [[ "$TOOL" == "Edit" ]]; then
    OLD=$(printf '%s' "$INPUT" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('old_string',''))" 2>/dev/null || echo "")
    NEW=$(printf '%s' "$INPUT" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('new_string',''))" 2>/dev/null || echo "")
    DELTA=$(( ${#NEW} - ${#OLD} ))
    PROJ_SIZE=$(( CUR_SIZE + DELTA ))

    if (( PROJ_SIZE > HARD_CAP )); then
      echo "[$(date +%FT%T)] BLOCKED Edit MEMORY.md: projected=${PROJ_SIZE}B > cap=${HARD_CAP}B" >> "$HOOK_LOG"
      cat <<EOF >&2
MEMORY-CAP-GUARD: BLOCKED Edit na MEMORY.md.
Projektovaná velikost: ${PROJ_SIZE}B (current ${CUR_SIZE}B + delta ${DELTA}B)
Hard cap: ${HARD_CAP}B

Akce: Move entries do MEMORY-INDEX-EXTRA.md místo growing MEMORY.md.
Override: MEMORY_CAP_OVERRIDE=1
EOF
      exit 2
    fi
  fi
fi

# Log successful pass-through
echo "[$(date +%FT%T)] OK ${TOOL} MEMORY.md current=${CUR_SIZE}B" >> "$HOOK_LOG"
exit 0
