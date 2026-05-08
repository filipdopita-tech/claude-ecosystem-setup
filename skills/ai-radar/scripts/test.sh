#!/bin/bash
# ai-radar v3 unified test suite — verify skill end-to-end.
# Použití: bash test.sh
# Exit 0 = PASS, 1 = FAIL
#
# v3 additions: auto-implement.sh, prune-watchlist.sh, NEW_MCP_AVAILABLE cross-ref,
# source quality boost, learning loop, decisions.jsonl integrity.

set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCAN="$SCRIPT_DIR/scan.sh"
SCAN_INTERNAL="$SCRIPT_DIR/scan-internal.sh"
PARSE="$SCRIPT_DIR/parse_feeds.py"
CROSS_REF="$SCRIPT_DIR/cross-reference.py"
AUDIT="$SCRIPT_DIR/audit-engine.py"
ROUTER="$SCRIPT_DIR/unified-router.sh"
RUN="$SCRIPT_DIR/run-unified.sh"
AUTO_IMPL="$SCRIPT_DIR/auto-implement.sh"
PRUNE_WL="$SCRIPT_DIR/prune-watchlist.sh"
CACHE="$HOME/.claude/ai-radar/cache"
DECISIONS="$HOME/.claude/ai-radar/decisions.jsonl"

PASS=0
FAIL=0
WARN=0
FAILED_TESTS=()

test_case() {
  local name="$1"
  shift
  if "$@" >/dev/null 2>&1; then
    echo "  ✓ $name"
    PASS=$((PASS+1))
  else
    echo "  ✗ $name"
    FAIL=$((FAIL+1))
    FAILED_TESTS+=("$name")
  fi
}

warn_case() {
  local name="$1"
  shift
  if "$@" >/dev/null 2>&1; then
    echo "  ✓ $name"
    PASS=$((PASS+1))
  else
    echo "  ⚠ $name (warning, not fatal)"
    WARN=$((WARN+1))
  fi
}

echo "=== ai-radar v2 (unified) test suite ==="
echo ""

# ──────────────────────────────────────────────────────────────────
# 1. Dependencies
# ──────────────────────────────────────────────────────────────────
echo "[1/8] Dependencies"
test_case "gh CLI"           command -v gh
test_case "curl"             command -v curl
test_case "jq"               command -v jq
test_case "python3"          command -v python3
test_case "awk"              command -v awk
warn_case "gh authenticated" bash -c 'gh auth status -h github.com 2>&1 | grep -q "Logged in"'

# ──────────────────────────────────────────────────────────────────
# 2. File structure
# ──────────────────────────────────────────────────────────────────
echo ""
echo "[2/8] File structure"
test_case "SKILL.md exists"            test -f "$SCRIPT_DIR/../SKILL.md"
test_case "scan.sh executable"         test -x "$SCAN"
test_case "scan-internal.sh executable" test -x "$SCAN_INTERNAL"
test_case "parse_feeds.py exists"      test -f "$PARSE"
test_case "cross-reference.py exists"  test -f "$CROSS_REF"
test_case "audit-engine.py exists"     test -f "$AUDIT"
test_case "unified-router.sh executable" test -x "$ROUTER"
test_case "run-unified.sh executable"  test -x "$RUN"
test_case "cache dir exists"           test -d "$CACHE"
test_case "runs dir exists"            test -d "$HOME/.claude/ai-radar/runs"
test_case "watchlist.md exists"        test -f "$HOME/.claude/ai-radar/watchlist.md"

# Legacy ecosystem-radar scanners (used by scan-internal.sh)
warn_case "legacy 01-services.sh"      test -x "$HOME/.claude/ecosystem-radar/scan/01-services.sh"
warn_case "legacy 02-evals.sh"         test -x "$HOME/.claude/ecosystem-radar/scan/02-evals.sh"
warn_case "legacy 03-credentials.sh"   test -x "$HOME/.claude/ecosystem-radar/scan/03-credentials.sh"
warn_case "legacy 04-memory.sh"        test -x "$HOME/.claude/ecosystem-radar/scan/04-memory.sh"

# ──────────────────────────────────────────────────────────────────
# 3. Syntax checks
# ──────────────────────────────────────────────────────────────────
echo ""
echo "[3/8] Syntax"
test_case "scan.sh bash syntax"           bash -n "$SCAN"
test_case "scan-internal.sh bash syntax"  bash -n "$SCAN_INTERNAL"
test_case "unified-router.sh bash syntax" bash -n "$ROUTER"
test_case "run-unified.sh bash syntax"    bash -n "$RUN"
test_case "parse_feeds.py syntax"         python3 -c "import ast; ast.parse(open('$PARSE').read())"
test_case "cross-reference.py syntax"     python3 -c "import ast; ast.parse(open('$CROSS_REF').read())"
test_case "audit-engine.py syntax"        python3 -c "import ast; ast.parse(open('$AUDIT').read())"

# ──────────────────────────────────────────────────────────────────
# 4. Internal scan dry-run (lite)
# ──────────────────────────────────────────────────────────────────
echo ""
echo "[4/8] Internal scan (lite mode)"
INT_OUT="$CACHE/test-internal-$$.json"
if bash "$SCAN_INTERNAL" --lite --out="$INT_OUT" >/dev/null 2>&1; then
  test_case "scan-internal --lite produced JSON" test -s "$INT_OUT"
  test_case "internal JSON valid"                jq -e . "$INT_OUT"
  test_case "internal JSON has composite"        jq -e '.composite' "$INT_OUT"
  test_case "internal JSON has dimensions array" jq -e '.dimensions | type == "array"' "$INT_OUT"
  COMPOSITE=$(jq -r '.composite' "$INT_OUT" 2>/dev/null || echo "?")
  N_DIMS=$(jq '.dimensions | length' "$INT_OUT" 2>/dev/null || echo 0)
  echo "  ℹ composite=$COMPOSITE, dims=$N_DIMS"
else
  echo "  ✗ scan-internal --lite failed"
  FAIL=$((FAIL+1))
  FAILED_TESTS+=("scan-internal --lite")
fi

# ──────────────────────────────────────────────────────────────────
# 5. External scan (2-day window, fast)
# ──────────────────────────────────────────────────────────────────
echo ""
echo "[5/8] External scan (2-day window)"
COMBINED=$(bash "$SCAN" 2 2>/tmp/ai-radar-test.stderr | tail -1)
test_case "scan.sh returned path"     test -n "$COMBINED"
if [ -n "$COMBINED" ]; then
  test_case "combined.json exists"    test -f "$COMBINED"
  test_case "combined.json valid"     jq -e . "$COMBINED"
  COUNT=$(jq 'length' "$COMBINED" 2>/dev/null || echo 0)
  echo "  ℹ external findings: $COUNT"
fi

# ──────────────────────────────────────────────────────────────────
# 6. Cross-reference engine
# ──────────────────────────────────────────────────────────────────
echo ""
echo "[6/8] Cross-reference engine"
if [ -n "$COMBINED" ] && [ -f "$COMBINED" ] && [ -f "$INT_OUT" ]; then
  CR_OUT="$CACHE/test-cross-ref-$$.json"
  if python3 "$CROSS_REF" --external "$COMBINED" --internal "$INT_OUT" --out "$CR_OUT" 2>/tmp/ai-radar-cr.err; then
    test_case "cross-ref produced JSON"  test -s "$CR_OUT"
    test_case "cross-ref JSON valid"     jq -e '.cross_refs | type == "array"' "$CR_OUT"
    N_CR=$(jq '.cross_refs | length' "$CR_OUT" 2>/dev/null || echo 0)
    echo "  ℹ cross-references: $N_CR"
  else
    echo "  ✗ cross-reference.py crashed"
    FAIL=$((FAIL+1))
    FAILED_TESTS+=("cross-reference.py")
  fi
else
  echo "  ⏸ skip (missing inputs)"
fi

# ──────────────────────────────────────────────────────────────────
# 7. Audit engine
# ──────────────────────────────────────────────────────────────────
echo ""
echo "[7/8] Audit engine (mythos-grade)"
if [ -n "$COMBINED" ] && [ -f "$COMBINED" ]; then
  AUDIT_OUT="$CACHE/test-audited-$$.json"
  AUDIT_ARGS=(--findings "$COMBINED" --top-n 3 --out "$AUDIT_OUT")
  [ -n "${CR_OUT:-}" ] && [ -f "${CR_OUT:-}" ] && AUDIT_ARGS+=(--cross-ref "$CR_OUT")
  if python3 "$AUDIT" "${AUDIT_ARGS[@]}" 2>/tmp/ai-radar-audit.err; then
    test_case "audit produced JSON"   test -s "$AUDIT_OUT"
    test_case "audits is array"       jq -e '.audits | type == "array"' "$AUDIT_OUT"
    test_case "stats has routing breakdown" jq -e '.stats.routing_breakdown' "$AUDIT_OUT"
    # Check that top-3 has falsification
    test_case "top finding has falsification" bash -c 'jq -e ".audits[0].falsification // empty" "'"$AUDIT_OUT"'" | grep -q "."'
    test_case "top finding has ach"           bash -c 'jq -e ".audits[0].ach.winner_label // empty" "'"$AUDIT_OUT"'" | grep -q "."'
  else
    echo "  ✗ audit-engine.py crashed"
    FAIL=$((FAIL+1))
    FAILED_TESTS+=("audit-engine.py")
  fi
fi

# ──────────────────────────────────────────────────────────────────
# 8. Unified router (dry-run)
# ──────────────────────────────────────────────────────────────────
echo ""
echo "[8/8] Unified router (dry-run)"
ROUTER_ARGS=(--run-id "test-$$" --dry)
[ -n "${AUDIT_OUT:-}" ] && [ -f "${AUDIT_OUT:-}" ] && ROUTER_ARGS+=(--audited "$AUDIT_OUT")
[ -f "$INT_OUT" ] && ROUTER_ARGS+=(--internal "$INT_OUT")
[ -n "${CR_OUT:-}" ] && [ -f "${CR_OUT:-}" ] && ROUTER_ARGS+=(--cross-ref "$CR_OUT")
test_case "unified-router --dry returns 0" bash "$ROUTER" "${ROUTER_ARGS[@]}"

# ──────────────────────────────────────────────────────────────────
# v3 — auto-implement engine
# ──────────────────────────────────────────────────────────────────
echo ""
echo "[v3-A] Auto-implement engine"

test_case "auto-implement.sh exists + exec"   test -x "$AUTO_IMPL"
test_case "prune-watchlist.sh exists + exec"  test -x "$PRUNE_WL"

# Dry-run plan with all 6 action types (lite check)
PLAN_TMP=$(mktemp)
cat > "$PLAN_TMP" <<'JSON'
{
  "max_actions": 5,
  "dry": true,
  "actions": [
    {"id":"t1","type":"APPEND_TOOL_WATCHLIST","title":"v3-test","url":"https://example.com/v3-test","score":40,"confidence":"VERIFIED","evidence":"test"},
    {"id":"t2","type":"CREATE_REFERENCE_MEMORY","title":"v3-test-memref","url":"https://example.com/memref","score":42,"confidence":"VERIFIED","evidence":"test","source":"anthropic-cookbook"},
    {"id":"t3","type":"PRUNE_WATCHLIST"}
  ]
}
JSON

OUT_FILE=$(mktemp)
bash "$AUTO_IMPL" --plan "$PLAN_TMP" > "$OUT_FILE" 2>/dev/null
test_case "auto-implement processes 3 dry actions" jq -e '.count_executed >= 3' "$OUT_FILE"
test_case "auto-implement returns valid JSON"      jq -e '.executed | length' "$OUT_FILE"
rm -f "$PLAN_TMP" "$OUT_FILE"

# Self-eval gate test (UNCERTAIN should be rejected)
PLAN_TMP=$(mktemp)
cat > "$PLAN_TMP" <<'JSON'
{
  "max_actions": 5,
  "dry": true,
  "actions": [
    {"id":"reject1","type":"APPEND_TOOL_WATCHLIST","title":"x","url":"https://example.com/r1","score":40,"confidence":"UNCERTAIN"}
  ]
}
JSON
OUT_FILE=$(mktemp)
bash "$AUTO_IMPL" --plan "$PLAN_TMP" > "$OUT_FILE" 2>/dev/null
test_case "auto-implement rejects UNCERTAIN" jq -e '.skipped | length >= 1' "$OUT_FILE"
rm -f "$PLAN_TMP" "$OUT_FILE"

# Per-run cap respected
PLAN_TMP=$(mktemp)
ACTIONS=""
for i in 1 2 3 4 5 6 7; do
  [ -n "$ACTIONS" ] && ACTIONS+=","
  ACTIONS+="{\"id\":\"cap-$i\",\"type\":\"APPEND_TOOL_WATCHLIST\",\"title\":\"cap-$i\",\"url\":\"https://example.com/cap-$i\",\"score\":40,\"confidence\":\"VERIFIED\"}"
done
echo "{\"max_actions\":3,\"dry\":true,\"actions\":[$ACTIONS]}" > "$PLAN_TMP"
OUT_FILE=$(mktemp)
bash "$AUTO_IMPL" --plan "$PLAN_TMP" > "$OUT_FILE" 2>/dev/null
test_case "per-run cap respected (3/7)" jq -e '.count_executed == 3' "$OUT_FILE"
rm -f "$PLAN_TMP" "$OUT_FILE"

# ──────────────────────────────────────────────────────────────────
# v3 — Prune watchlist
# ──────────────────────────────────────────────────────────────────
echo ""
echo "[v3-B] Watchlist prune"
test_case "prune-watchlist --dry returns 0"  bash "$PRUNE_WL" --dry --max-days=60
test_case "prune-watchlist --dry --max-days=7 returns 0" bash "$PRUNE_WL" --dry --max-days=7

# ──────────────────────────────────────────────────────────────────
# v3 — Cross-reference NEW_MCP_AVAILABLE
# ──────────────────────────────────────────────────────────────────
echo ""
echo "[v3-C] NEW_MCP_AVAILABLE category"
EXT_TMP=$(mktemp)
cat > "$EXT_TMP" <<'JSON'
[
  {"title":"obsidian-mcp","url":"https://github.com/test/obsidian-mcp","desc":"MCP server pro Obsidian vault search","source":"mcp-new"},
  {"title":"random-tool","url":"https://github.com/test/random","desc":"Some random thing","source":"github-trending-llm"}
]
JSON
INT_TMP=$(mktemp)
echo '{"composite":100,"dimensions":[]}' > "$INT_TMP"
CR_TMP=$(mktemp)
python3 "$CROSS_REF" --external "$EXT_TMP" --internal "$INT_TMP" --out "$CR_TMP" 2>/dev/null
test_case "cross-ref produces JSON"   test -s "$CR_TMP"
test_case "cross-ref valid JSON"      bash -c "jq -e . '$CR_TMP'"
warn_case "NEW_MCP_AVAILABLE detected for obsidian" bash -c "jq -e '.cross_refs[]? | select(.type == \"NEW_MCP_AVAILABLE\")' '$CR_TMP'"
rm -f "$EXT_TMP" "$INT_TMP" "$CR_TMP"

# ──────────────────────────────────────────────────────────────────
# v3 — Audit engine source quality boost
# ──────────────────────────────────────────────────────────────────
echo ""
echo "[v3-D] Audit engine v3 features"
test_case "source_quality_modifier exists"  bash -c "grep -q 'def source_quality_modifier' '$AUDIT'"
test_case "learning_loop_boost exists"      bash -c "grep -q 'def learning_loop_boost' '$AUDIT'"
test_case "load_decisions_log exists"       bash -c "grep -q 'def load_decisions_log' '$AUDIT'"

# ──────────────────────────────────────────────────────────────────
# v3 — Decisions log integrity
# ──────────────────────────────────────────────────────────────────
echo ""
echo "[v3-E] Decisions log"
warn_case "decisions.jsonl exists"  test -f "$DECISIONS"
if [ -f "$DECISIONS" ] && [ -s "$DECISIONS" ]; then
  test_case "decisions.jsonl valid NDJSON" bash -c "while IFS= read -r line; do [ -z \"\$line\" ] || echo \"\$line\" | jq -e . >/dev/null || exit 1; done < '$DECISIONS'"
fi

# ──────────────────────────────────────────────────────────────────
# v3 — Cron / launchd integration
# ──────────────────────────────────────────────────────────────────
echo ""
echo "[v3-F] Launchd integration"
warn_case "weekly launchd loaded"   bash -c "launchctl list | grep -q cz.oneflow.ai-radar-weekly"
warn_case "daily launchd loaded"    bash -c "launchctl list | grep -q cz.oneflow.ai-radar-daily"
warn_case "daily helper exists"     test -x "$HOME/.claude/helpers/ai-radar-daily-lite.sh"
warn_case "no legacy crontab"       bash -c "! crontab -l 2>/dev/null | grep -q 'ecosystem-radar/run-radar'"

# ──────────────────────────────────────────────────────────────────
# Cleanup tmp test files
# ──────────────────────────────────────────────────────────────────
rm -f "$INT_OUT" "${CR_OUT:-/dev/null}" "${AUDIT_OUT:-/dev/null}" 2>/dev/null

# ──────────────────────────────────────────────────────────────────
# Summary
# ──────────────────────────────────────────────────────────────────
echo ""
echo "=== Results ==="
echo "PASS: $PASS | FAIL: $FAIL | WARN: $WARN"
if [ "$FAIL" -gt 0 ]; then
  echo ""
  echo "Failed tests:"
  for t in "${FAILED_TESTS[@]}"; do
    echo "  - $t"
  done
  if [ -s /tmp/ai-radar-test.stderr ]; then
    echo ""
    echo "Last stderr:"
    tail -10 /tmp/ai-radar-test.stderr
  fi
  exit 1
fi
echo ""
echo "All tests passed. ai-radar v3 ready."
exit 0
