#!/usr/bin/env bash
# llm-judge.sh — LLM-as-judge scorer using claude -p (headless)
# Usage: ./evals/scorers/llm-judge.sh --input <text> --rubric-json <json-array> --output <text> [--model haiku]
#
# Returns: JSON object { score, pass_fail, reasoning, summary }

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
JUDGE_PROMPT_FILE="$REPO_ROOT/evals/runner/judge-prompt.md"

INPUT=""
RUBRIC_JSON=""
OUTPUT=""
MODEL="haiku"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --input)      INPUT="$2";      shift 2 ;;
    --rubric-json) RUBRIC_JSON="$2"; shift 2 ;;
    --output)     OUTPUT="$2";     shift 2 ;;
    --model)      MODEL="$2";      shift 2 ;;
    *)            echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$INPUT" || -z "$RUBRIC_JSON" || -z "$OUTPUT" ]]; then
  echo "ERROR: --input, --rubric-json, and --output are all required" >&2
  exit 1
fi

if [[ ! -f "$JUDGE_PROMPT_FILE" ]]; then
  echo "ERROR: judge-prompt.md not found at $JUDGE_PROMPT_FILE" >&2
  exit 1
fi

# Resolve model string to claude model ID
case "$MODEL" in
  haiku)   CLAUDE_MODEL="claude-haiku-4-5-20251001" ;;
  sonnet)  CLAUDE_MODEL="claude-sonnet-4-6" ;;
  opus)    CLAUDE_MODEL="claude-opus-4-7" ;;
  opus1m)  CLAUDE_MODEL="claude-opus-4-7[1m]" ;;
  *)       CLAUDE_MODEL="$MODEL" ;;
esac

# Format rubric as readable list
RUBRIC_LIST="$(echo "$RUBRIC_JSON" | jq -r '.[] | "- " + .')"

# Build the full judge prompt by substituting into template
JUDGE_SYSTEM="$(cat "$JUDGE_PROMPT_FILE")"

USER_MESSAGE="INPUT:
${INPUT}

RUBRIC:
${RUBRIC_LIST}

OUTPUT:
${OUTPUT}

Return ONLY valid JSON. No markdown fences. No explanation outside the JSON object."

# Build combined prompt for claude -p (headless, non-interactive)
FULL_PROMPT="SYSTEM (judge instructions):
${JUDGE_SYSTEM}

---

USER REQUEST:
${USER_MESSAGE}"

# Call claude
RAW_RESPONSE="$(echo "$FULL_PROMPT" | claude -p --model "$CLAUDE_MODEL" 2>/dev/null)"

# Strip markdown code fences if present (claude sometimes wraps in ```json)
CLEAN_RESPONSE="$(echo "$RAW_RESPONSE" | sed 's/^```json//;s/^```//;s/```$//' | sed '/^[[:space:]]*$/d')"

# Validate JSON
if ! echo "$CLEAN_RESPONSE" | jq empty 2>/dev/null; then
  # Attempt recovery: extract first {...} block
  EXTRACTED="$(echo "$CLEAN_RESPONSE" | grep -o '{.*}' | head -1 || echo '')"
  if echo "$EXTRACTED" | jq empty 2>/dev/null; then
    CLEAN_RESPONSE="$EXTRACTED"
  else
    # Return safe fallback
    RUBRIC_KEYS="$(echo "$RUBRIC_JSON" | jq -r 'map({key: ., value: false}) | from_entries')"
    CLEAN_RESPONSE="$(jq -n \
      --argjson pf "$RUBRIC_KEYS" \
      --arg raw "$RAW_RESPONSE" \
      '{"score": 0, "pass_fail": $pf, "reasoning": {"error": ("Judge returned invalid JSON. Raw: " + $raw[0:200])}, "summary": "Scoring error — judge output was not valid JSON."}')"
  fi
fi

# Ensure required fields exist
FINAL="$(echo "$CLEAN_RESPONSE" | jq '
  . as $orig |
  {
    score: (.score // 0 | if type == "number" then . else 0 end),
    pass_fail: (.pass_fail // {}),
    reasoning: (.reasoning // {}),
    summary: (.summary // "no summary")
  }
')"

echo "$FINAL"
