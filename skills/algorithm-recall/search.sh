#!/usr/bin/env bash
# algorithm-recall search helper
# Usage: search.sh <pattern> [language]
# Examples:
#   search.sh "dijkstra"           # all languages
#   search.sh "rsa" Python          # Python only
#   search.sh "binary_search" Rust

set -euo pipefail

ROOT="$HOME/Documents/research-cache/algorithms-the-algorithms"

if [ ! -d "$ROOT" ]; then
  echo "ERROR: TheAlgorithms mirror not found at $ROOT" >&2
  echo "Run: cd ~/Documents/research-cache && git clone --depth=1 https://github.com/TheAlgorithms/Python.git algorithms-the-algorithms/Python" >&2
  exit 1
fi

PATTERN="${1:-}"
LANG="${2:-}"

if [ -z "$PATTERN" ]; then
  echo "Usage: $0 <pattern> [language]"
  echo "Languages: Python JavaScript TypeScript Rust Go Solidity"
  echo "Available repos:"
  ls -d "$ROOT"/*/ 2>/dev/null | xargs -n1 basename | sed 's/^/  - /'
  exit 1
fi

# Normalize pattern (lowercase, allow spaces or underscores)
PAT_LC="$(echo "$PATTERN" | tr '[:upper:]' '[:lower:]')"
PAT_RX="$(echo "$PAT_LC" | sed 's/[[:space:]]/[_-]/g')"

# Determine search scope
if [ -n "$LANG" ]; then
  SCOPE="$ROOT/$LANG"
  if [ ! -d "$SCOPE" ]; then
    echo "ERROR: language dir $SCOPE not found" >&2
    echo "Available: $(ls -d "$ROOT"/*/ 2>/dev/null | xargs -n1 basename | tr '\n' ' ')" >&2
    exit 1
  fi
else
  SCOPE="$ROOT"
fi

echo "=== Filename matches (pattern: '$PAT_RX') ==="
find "$SCOPE" -type f \( -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.rs" -o -name "*.go" -o -name "*.sol" \) \
  -not -path "*/node_modules/*" -not -path "*/.git/*" \
  2>/dev/null | grep -iE "$PAT_RX" | head -30 | while read -r f; do
    rel="${f#$ROOT/}"
    lines=$(wc -l < "$f" 2>/dev/null || echo "?")
    printf "  %-90s  (%s lines)\n" "$rel" "$lines"
  done

echo
echo "=== Content matches (top 15, with line numbers) ==="
grep -ril -E "$PAT_RX" "$SCOPE" --include="*.py" --include="*.js" --include="*.ts" --include="*.rs" --include="*.go" --include="*.sol" \
  2>/dev/null | head -15 | while read -r f; do
    rel="${f#$ROOT/}"
    # Get first matching line for context
    first_match=$(grep -nE -m1 -i "$PAT_RX" "$f" 2>/dev/null | head -1)
    printf "  %s\n" "$rel"
    [ -n "$first_match" ] && printf "    └─ L%s\n" "$first_match"
  done

echo
echo "=== Tip ==="
echo "Read top match: cat $SCOPE/<path-from-above>"
echo "Open in editor: code $SCOPE/<path>"
