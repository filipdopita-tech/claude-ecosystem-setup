#!/bin/bash
# ai-radar test suite — verify skill end-to-end works.
# Použití: bash ~/.claude/skills/ai-radar/scripts/test.sh
# Exit 0 = všechny testy PASS, exit 1 = nějaký FAIL s error detail.

set -uo pipefail   # NE -e — chceme zachytit failures explicitně, ne crash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCAN="$SCRIPT_DIR/scan.sh"
PARSE="$SCRIPT_DIR/parse_feeds.py"
CACHE="$HOME/.claude/ai-radar/cache"

PASS=0
FAIL=0
FAILED_TESTS=()

test_case() {
  local name="$1"
  shift
  if "$@"; then
    echo "  ✓ $name"
    PASS=$((PASS+1))
  else
    echo "  ✗ $name"
    FAIL=$((FAIL+1))
    FAILED_TESTS+=("$name")
  fi
}

echo "=== ai-radar test suite ==="
echo ""

# 1. Dependency checks
echo "[1/6] Dependencies"
test_case "gh CLI installed"     command -v gh
test_case "curl installed"       command -v curl
test_case "jq installed"         command -v jq
test_case "python3 installed"    command -v python3
test_case "gh authenticated"     gh auth status -h github.com 2>&1 | grep -q "Logged in"

# 2. File structure
echo ""
echo "[2/6] File structure"
test_case "SKILL.md exists"      test -f "$SCRIPT_DIR/../SKILL.md"
test_case "scan.sh executable"   test -x "$SCAN"
test_case "parse_feeds.py exists" test -f "$PARSE"
test_case "cache dir exists"     test -d "$CACHE"
test_case "runs dir exists"      test -d "$HOME/.claude/ai-radar/runs"
test_case "watchlist.md exists"  test -f "$HOME/.claude/ai-radar/watchlist.md"

# 3. Syntax checks
echo ""
echo "[3/6] Syntax"
test_case "scan.sh bash syntax"     bash -n "$SCAN"
test_case "parse_feeds.py syntax"   python3 -c "import ast; ast.parse(open('$PARSE').read())"

# 4. Live end-to-end scan (2 days = fast)
echo ""
echo "[4/6] End-to-end scan (2-day window)"
COMBINED=$(bash "$SCAN" 2 2>/tmp/ai-radar-test.stderr | tail -1)
test_case "scan.sh returned path"   test -n "$COMBINED"
test_case "combined.json exists"    test -f "$COMBINED"
test_case "combined.json valid JSON" jq -e . "$COMBINED" >/dev/null
COUNT=$(jq 'length' "$COMBINED" 2>/dev/null || echo 0)
test_case "findings count > 10"     test "$COUNT" -gt 10

# health.json check
RUN_ID=$(basename "$COMBINED" | sed 's/-combined.json//')
HEALTH="$CACHE/${RUN_ID}-health.json"
test_case "health.json generated"   test -f "$HEALTH"
test_case "health.json valid"       jq -e '.sources' "$HEALTH" >/dev/null

# 5. Source coverage (per-source non-empty expectation)
echo ""
echo "[5/6] Source coverage"
if [ -f "$HEALTH" ]; then
  for src in anthropic-cc-changelog openai-blog google-ai-blog; do
    items=$(jq -r ".sources[\"$src\"].items // 0" "$HEALTH")
    if [ "$items" -gt 0 ]; then
      echo "  ✓ $src ($items items)"
      PASS=$((PASS+1))
    else
      echo "  ⚠ $src (0 items — possible network or endpoint drift)"
      # warn, not fail — může být legitimate (žádný nový content za 2 dny)
    fi
  done
fi

# 6. Cache hit test (2nd run should hit cache)
echo ""
echo "[6/6] Cache behavior (2nd run < 1h TTL)"
CACHE_OUT=$(bash "$SCAN" 2 2>&1 | grep -c "cache hit" || echo 0)
test_case "cache hits >= 3 on 2nd run"  test "$CACHE_OUT" -ge 3

# Summary
echo ""
echo "=== Results ==="
echo "PASS: $PASS | FAIL: $FAIL"
if [ "$FAIL" -gt 0 ]; then
  echo ""
  echo "Failed tests:"
  for t in "${FAILED_TESTS[@]}"; do
    echo "  - $t"
  done
  if [ -s /tmp/ai-radar-test.stderr ]; then
    echo ""
    echo "Last stderr:"
    tail -5 /tmp/ai-radar-test.stderr
  fi
  exit 1
fi
echo "All tests passed."
exit 0
