#!/bin/bash
# ai-radar v3 install / re-init helper.
# Idempotentní — bezpečné opakovaně spustit (post-clone, post-update, atd.)
# v3 additions: auto-implement.sh, prune-watchlist.sh, daily-lite launchd, README.
set -euo pipefail

ROOT="$HOME/.claude/ai-radar"
SKILL_DIR="$HOME/.claude/skills/ai-radar"
LEGACY_ECOSYSTEM="$HOME/.claude/ecosystem-radar"
HELPERS_DIR="$HOME/.claude/helpers"
LAUNCHD_DIR="$HOME/Library/LaunchAgents"

echo "[install] ai-radar v3 setup"

# 1. Storage dirs
mkdir -p "$ROOT/runs" "$ROOT/cache/latest" "$ROOT/archive" "$ROOT/baselines"
[ -f "$ROOT/watchlist.md" ] || echo "# AI Radar Watchlist (OneFlow)" > "$ROOT/watchlist.md"
[ -f "$ROOT/decisions.jsonl" ] || : > "$ROOT/decisions.jsonl"
echo "  ✓ storage: $ROOT"

# 2. Legacy ecosystem-radar (kept for scanner compat)
if [ -d "$LEGACY_ECOSYSTEM/scan" ]; then
  echo "  ✓ legacy ecosystem-radar scanners: $LEGACY_ECOSYSTEM/scan/"
  chmod +x "$LEGACY_ECOSYSTEM/scan/"*.sh 2>/dev/null || true
else
  echo "  ⚠ legacy ecosystem-radar/scan missing — internal scope will lose 4 dim (services/evals/credentials/memory)"
  echo "    expected at: $LEGACY_ECOSYSTEM/scan/{01-services,02-evals,03-credentials,04-memory}.sh"
fi

# 3. Optional Obsidian vault mirror
if [ -d "$HOME/Documents/OneFlow-Vault" ]; then
  mkdir -p "$HOME/Documents/OneFlow-Vault/02-Reference"
  [ -f "$HOME/Documents/OneFlow-Vault/02-Reference/ai-radar-watchlist.md" ] || \
    echo "# AI Radar Watchlist (Obsidian mirror)" > "$HOME/Documents/OneFlow-Vault/02-Reference/ai-radar-watchlist.md"
  echo "  ✓ Obsidian vault mirror: ~/Documents/OneFlow-Vault/02-Reference/"
else
  echo "  ⏸ Obsidian vault not found — primary watchlist v $ROOT/watchlist.md (OK)"
fi

# 4. Script permissions (all scripts)
chmod +x "$SKILL_DIR/scripts/"*.sh 2>/dev/null || true
chmod +x "$SKILL_DIR/scripts/"*.py 2>/dev/null || true
echo "  ✓ scripts executable"

# 5. Dependency check (warn, don't fail)
echo "  Dependencies:"
for bin in gh curl jq python3 awk; do
  if command -v "$bin" >/dev/null; then
    echo "    ✓ $bin"
  else
    echo "    ⚠ $bin MISSING — install via: brew install $bin"
  fi
done

# 6. gh auth check
if gh auth status -h github.com 2>&1 | grep -q "Logged in"; then
  echo "  ✓ gh authenticated"
else
  echo "  ⚠ gh NOT authenticated — run: gh auth login"
  echo "    (GitHub sources budou skipped — trending/MCP/CC releases)"
fi

# 7. ntfy URL detection
if [ -n "${ABTOP_NTFY_URL:-}" ]; then
  echo "  ✓ ntfy URL: $ABTOP_NTFY_URL"
else
  echo "  ⏸ ABTOP_NTFY_URL not set — using default https://ntfy.oneflow.cz/Filip"
fi

# 8. v3 — Launchd registration (weekly + daily-lite)
echo ""
echo "[install] v3 Launchd registration:"
WEEKLY_PLIST="$LAUNCHD_DIR/cz.oneflow.ai-radar-weekly.plist"
DAILY_PLIST="$LAUNCHD_DIR/cz.oneflow.ai-radar-daily.plist"

if [ -f "$WEEKLY_PLIST" ]; then
  if launchctl list | grep -q cz.oneflow.ai-radar-weekly; then
    echo "  ✓ weekly launchd already loaded (Mon 08:00)"
  else
    launchctl load "$WEEKLY_PLIST" && echo "  ✓ weekly launchd loaded"
  fi
else
  echo "  ⏸ weekly plist missing at $WEEKLY_PLIST"
fi

if [ -f "$DAILY_PLIST" ]; then
  if launchctl list | grep -q cz.oneflow.ai-radar-daily; then
    echo "  ✓ daily launchd already loaded (03:35)"
  else
    launchctl load "$DAILY_PLIST" && echo "  ✓ daily launchd loaded"
  fi
else
  echo "  ⏸ daily plist missing at $DAILY_PLIST (auto-skip)"
fi

# Helper script perms
[ -f "$HELPERS_DIR/ai-radar-weekly.sh" ] && chmod +x "$HELPERS_DIR/ai-radar-weekly.sh" && echo "  ✓ weekly helper exec"
[ -f "$HELPERS_DIR/ai-radar-daily-lite.sh" ] && chmod +x "$HELPERS_DIR/ai-radar-daily-lite.sh" && echo "  ✓ daily-lite helper exec"

# 9. v3 — Verify legacy crontab cleaned
if crontab -l 2>/dev/null | grep -q "ecosystem-radar/run-radar"; then
  echo "  ⚠ Legacy crontab still has ecosystem-radar entries — manual remove:"
  echo "    crontab -l | grep -v ecosystem-radar/run-radar | crontab -"
else
  echo "  ✓ Legacy crontab clean (no ecosystem-radar entries)"
fi

# 10. Sanity test (dry run)
echo ""
echo "[install] Sanity dry-run (--lite --dry, no writes):"
if bash "$SKILL_DIR/scripts/run-unified.sh" --scope=internal --lite --dry --no-ntfy >/dev/null 2>&1; then
  echo "  ✓ run-unified.sh syntactically valid"
else
  echo "  ⚠ run-unified.sh dry-run failed — check $ROOT/cache/*.err"
fi

# 11. v3 test suite quick run
echo ""
echo "[install] Quick test (full suite available via: bash $SKILL_DIR/scripts/test.sh):"
if bash "$SKILL_DIR/scripts/auto-implement.sh" </dev/null 2>&1 | grep -q '"error"'; then
  echo "  ✓ auto-implement.sh responsive (returns error when no plan, expected)"
fi
if bash "$SKILL_DIR/scripts/prune-watchlist.sh" --dry --max-days=60 >/dev/null 2>&1; then
  echo "  ✓ prune-watchlist.sh --dry returns 0"
fi

echo ""
echo "[install] Done."
echo ""
echo "Next steps:"
echo "  1. Full test suite:   bash $SKILL_DIR/scripts/test.sh"
echo "  2. First real run:    /ai-radar  (or bash $SKILL_DIR/scripts/run-unified.sh)"
echo "  3. Lite health check: /ai-radar --scope=internal --lite"
echo "  4. Weekly digest:     decisions analyzer → bash $SKILL_DIR/scripts/decisions-analyzer.py"
echo ""
echo "Migration od /ecosystem-radar (legacy):"
echo "  /ecosystem-radar          → /ai-radar --scope=internal"
echo "  /ecosystem-radar --mode=lite → /ai-radar --scope=internal --lite"
