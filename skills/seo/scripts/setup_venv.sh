#!/bin/bash
# SEO skill venv setup — idempotent, run on first use or after .venv deletion
# Usage: cd ~/.claude/skills/seo && bash scripts/setup_venv.sh

set -e

SKILL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$SKILL_DIR"

if [ -d ".venv" ]; then
  echo "[seo] .venv already exists — skip. Delete .venv and re-run to rebuild."
  exit 0
fi

PYTHON=${PYTHON:-python3}
if ! command -v "$PYTHON" >/dev/null 2>&1; then
  echo "[seo] ERROR: python3 not found. Install Python 3.11+."
  exit 1
fi

echo "[seo] Creating .venv..."
$PYTHON -m venv .venv

echo "[seo] Upgrading pip..."
./.venv/bin/pip install --quiet --upgrade pip

echo "[seo] Installing requirements.txt..."
./.venv/bin/pip install --quiet -r requirements.txt

echo "[seo] .venv ready: $(du -sh .venv | cut -f1)"
