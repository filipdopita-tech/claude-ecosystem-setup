#!/usr/bin/env bash
# regex-checks.sh — Mechanical/regex scorer for binary rubric items
# Usage: ./evals/scorers/regex-checks.sh --input <text> --rubric-json <json-array> [--output <text>]
#
# Handles rubric items expressible as pattern checks:
#   - word count constraints ("≤N words", "at least N words")
#   - presence of strings/keywords ("contains X")
#   - structural counts ("N variants", "N scenes")
#   - CTA presence, headline detection
#
# Returns: JSON object { checks: { "criterion": true|false }, skipped: [...] }
# Items not handled by regex are returned in the 'skipped' array for LLM judge.

set -euo pipefail

INPUT=""
RUBRIC_JSON=""
OUTPUT_TEXT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --input)      INPUT="$2";       shift 2 ;;
    --rubric-json) RUBRIC_JSON="$2"; shift 2 ;;
    --output)     OUTPUT_TEXT="$2"; shift 2 ;;
    *)            echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$RUBRIC_JSON" ]]; then
  echo "ERROR: --rubric-json is required" >&2
  exit 1
fi

# Helper: count words in a string
word_count() {
  echo "$1" | wc -w | tr -d ' '
}

# Helper: count occurrences of pattern in text
count_matches() {
  local text="$1" pattern="$2"
  echo "$text" | grep -oi "$pattern" | wc -l | tr -d ' '
}

# Helper: check if text contains a string (case-insensitive)
contains_string() {
  local text="$1" needle="$2"
  echo "$text" | grep -qi "$needle" && echo "true" || echo "false"
}

# Process results accumulator
CHECKS="{}"
SKIPPED="[]"

# Iterate rubric items
while IFS= read -r criterion; do
  [[ -z "$criterion" ]] && continue
  CRITERION_LOWER="$(echo "$criterion" | tr '[:upper:]' '[:lower:]')"
  HANDLED=false
  RESULT=false

  # --- Word count: "headline ≤N words" or "headline <= N words" ---
  if echo "$CRITERION_LOWER" | grep -qE '(headline|title).*(≤|<=|at most|under|no more than) *([0-9]+) *word'; then
    LIMIT="$(echo "$CRITERION_LOWER" | grep -oE '[0-9]+' | head -1)"
    # Extract first line that looks like a headline (short, often caps or bold)
    HEADLINE="$(echo "$OUTPUT_TEXT" | grep -m1 -E '^[A-Z*#]' | head -c 200 || echo "")"
    if [[ -z "$HEADLINE" ]]; then
      HEADLINE="$(echo "$OUTPUT_TEXT" | head -1)"
    fi
    WC="$(word_count "$HEADLINE")"
    if [[ -n "$LIMIT" && "$WC" -le "$LIMIT" ]]; then
      RESULT=true
    fi
    HANDLED=true
  fi

  # --- Variant/scene count: "N variants", "at least N variants", "N scenes" ---
  if [[ "$HANDLED" == false ]] && echo "$CRITERION_LOWER" | grep -qE '([0-9]+) (variant|version|option|scene|shot)'; then
    COUNT="$(echo "$CRITERION_LOWER" | grep -oE '[0-9]+' | head -1)"
    KEYWORD="$(echo "$CRITERION_LOWER" | grep -oE '(variant|version|option|scene|shot)' | head -1)"
    # Count labeled items: "Variant 1", "Scene 2", numbered lists, or bold headers
    FOUND="$(echo "$OUTPUT_TEXT" | grep -ciE "(${KEYWORD}|^[0-9]+[.)]|^#{1,3} [0-9])" || echo 0)"
    if [[ "$FOUND" -ge "$COUNT" ]]; then
      RESULT=true
    fi
    HANDLED=true
  fi

  # --- Minimum count: "≥N" or "at least N" ---
  if [[ "$HANDLED" == false ]] && echo "$CRITERION_LOWER" | grep -qE '(≥|>=|at least|minimum) *([0-9]+)'; then
    MIN="$(echo "$CRITERION_LOWER" | grep -oE '[0-9]+' | head -1)"
    # Try to find what is being counted
    SUBJECT="$(echo "$CRITERION_LOWER" | grep -oE 'find|identif|issue|opportunit|task|criterion' | head -1 || echo "")"
    if [[ -n "$SUBJECT" ]]; then
      FOUND="$(count_matches "$OUTPUT_TEXT" "$SUBJECT")"
      if [[ "$FOUND" -ge "$MIN" ]]; then
        RESULT=true
      fi
      HANDLED=true
    fi
  fi

  # --- CTA presence ---
  if [[ "$HANDLED" == false ]] && echo "$CRITERION_LOWER" | grep -qE '\bcta\b|call.to.action|call to action'; then
    # Check if output contains common CTA patterns
    CTA_FOUND="$(contains_string "$OUTPUT_TEXT" "\(get started\|sign up\|try\|buy\|order now\|download\|schedule\|book\|start\|join\|learn more\|contact\|cta\|call to action\)")"
    RESULT="$CTA_FOUND"
    HANDLED=true
  fi

  # --- Hook in first scene/section ---
  if [[ "$HANDLED" == false ]] && echo "$CRITERION_LOWER" | grep -qE 'hook.*(scene 1|first scene|opening|first)'; then
    FIRST_SECTION="$(echo "$OUTPUT_TEXT" | head -5)"
    HOOK_FOUND="$(contains_string "$FIRST_SECTION" "hook\|grab\|attention\|open\|question\|stat\|bold")"
    RESULT="$HOOK_FOUND"
    HANDLED=true
  fi

  # --- Duration check: "duration sums correctly" ---
  if [[ "$HANDLED" == false ]] && echo "$CRITERION_LOWER" | grep -qE 'duration.*(sum|correct|total|add)'; then
    # Extract all numbers followed by "second" or "s" — check they sum to a plausible total
    DURATIONS="$(echo "$OUTPUT_TEXT" | grep -oE '[0-9]+ *(sec|second|s\b)' | grep -oE '[0-9]+' | paste -sd+ | bc 2>/dev/null || echo 0)"
    if [[ "$DURATIONS" -gt 0 ]]; then
      RESULT=true
    fi
    HANDLED=true
  fi

  # --- Captions present ---
  if [[ "$HANDLED" == false ]] && echo "$CRITERION_LOWER" | grep -qE '\bcaption'; then
    CAPTION_FOUND="$(contains_string "$OUTPUT_TEXT" "caption\|subtitle\|text overlay\|on.screen text")"
    RESULT="$CAPTION_FOUND"
    HANDLED=true
  fi

  # --- No fabrication (heuristic: check if output invents specific URLs, stats not in input) ---
  if [[ "$HANDLED" == false ]] && echo "$CRITERION_LOWER" | grep -qE 'no fabricat|no invention|no hallucin'; then
    # Simple heuristic: if output contains URLs not in input, flag as potential fabrication
    OUTPUT_URLS="$(echo "$OUTPUT_TEXT" | grep -oE 'https?://[^ ]+' | wc -l | tr -d ' ')"
    INPUT_URLS="$(echo "$INPUT" | grep -oE 'https?://[^ ]+' | wc -l | tr -d ' ')"
    if [[ "$OUTPUT_URLS" -le "$INPUT_URLS" ]]; then
      RESULT=true
    fi
    HANDLED=true
  fi

  # --- String presence: "contains X" or "includes X" ---
  if [[ "$HANDLED" == false ]] && echo "$CRITERION_LOWER" | grep -qE '^(contains|includes|mentions|has|must include)'; then
    NEEDLE="$(echo "$CRITERION_LOWER" | sed 's/^contains //;s/^includes //;s/^mentions //;s/^has //;s/^must include //')"
    RESULT="$(contains_string "$OUTPUT_TEXT" "$NEEDLE")"
    HANDLED=true
  fi

  # Add to results
  if [[ "$HANDLED" == true ]]; then
    CHECKS="$(echo "$CHECKS" | jq --arg k "$criterion" --argjson v "$RESULT" '. + {($k): $v}')"
  else
    SKIPPED="$(echo "$SKIPPED" | jq --arg item "$criterion" '. + [$item]')"
  fi

done < <(echo "$RUBRIC_JSON" | jq -r '.[]')

# Output result
jq -n \
  --argjson checks "$CHECKS" \
  --argjson skipped "$SKIPPED" \
  '{ checks: $checks, skipped: $skipped }'
