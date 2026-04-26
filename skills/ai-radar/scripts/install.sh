#!/bin/bash
# ai-radar install / re-init helper.
# Idempotentní — bezpečné opakovaně spustit (na novém Macu, post-dotfiles-clone, atd.)
set -euo pipefail

ROOT="$HOME/.claude/ai-radar"
SKILL_DIR="$HOME/.claude/skills/ai-radar"

echo "[install] ai-radar setup"

# 1. Storage dirs
mkdir -p "$ROOT/runs" "$ROOT/cache/latest" "$ROOT/archive"
[ -f "$ROOT/watchlist.md" ] || echo "# AI Radar Watchlist ([YOUR_COMPANY])" > "$ROOT/watchlist.md"
echo "  ✓ storage: $ROOT"

# 2. Optional Obsidian vault mirror (jen pokud vault existuje)
if [ -d "$HOME/Documents/[YOUR_COMPANY]-Vault" ]; then
  mkdir -p "$HOME/Documents/[YOUR_COMPANY]-Vault/02-Reference"
  [ -f "$HOME/Documents/[YOUR_COMPANY]-Vault/02-Reference/ai-radar-watchlist.md" ] || \
    echo "# AI Radar Watchlist (Obsidian mirror)" > "$HOME/Documents/[YOUR_COMPANY]-Vault/02-Reference/ai-radar-watchlist.md"
  echo "  ✓ Obsidian vault mirror: ~/Documents/[YOUR_COMPANY]-Vault/02-Reference/"
else
  echo "  ⏸ Obsidian vault not found — primary watchlist v $ROOT/watchlist.md (OK)"
fi

# 3. Script permissions
chmod +x "$SKILL_DIR/scripts/"*.sh "$SKILL_DIR/scripts/"*.py 2>/dev/null || true
echo "  ✓ scripts executable"

# 4. Dependency check (warn, don't fail)
for bin in gh curl jq python3; do
  if command -v "$bin" >/dev/null; then
    echo "  ✓ $bin found"
  else
    echo "  ⚠ $bin MISSING — install via: brew install $bin"
  fi
done

# 5. gh auth check
if gh auth status -h github.com 2>&1 | grep -q "Logged in"; then
  echo "  ✓ gh authenticated"
else
  echo "  ⚠ gh NOT authenticated — run: gh auth login (GitHub sources budou skipped)"
fi

# 6. Gemini CLI (optional, pro batch >80K)
if command -v gemini >/dev/null; then
  echo "  ✓ gemini CLI found (free tier pro batch processing)"
else
  echo "  ⏸ gemini CLI missing (OK pro small scans, vyžadováno pro >80K batch)"
fi

echo ""
echo "[install] Done. Test: bash $SKILL_DIR/scripts/test.sh"
