#!/usr/bin/env bash
# stop-code-verify.sh — deterministická verifikace po každém tasku (bcherny pattern)
# Stop hook: spustí se při každém Stop eventu
# Výstup: PASS/WARN do stderr, nepřerušuje workflow

set -euo pipefail

PASS=0
WARN=0

# Najdi changed files z git (pokud jsme v git repo)
CHANGED_FILES=""
if git rev-parse --git-dir &>/dev/null 2>&1; then
  CHANGED_FILES=$(git diff --name-only HEAD 2>/dev/null || true)
fi

# 1. Python syntax check
PY_FILES=$(echo "$CHANGED_FILES" | grep '\.py$' || true)
if [ -n "$PY_FILES" ]; then
  PY_ERRORS=0
  while IFS= read -r f; do
    [ -f "$f" ] || continue
    if ! python3 -m py_compile "$f" 2>/dev/null; then
      echo "WARN: Python syntax error in $f" >&2
      PY_ERRORS=$((PY_ERRORS + 1))
    fi
  done <<< "$PY_FILES"
  if [ $PY_ERRORS -eq 0 ]; then
    echo "PASS: Python syntax OK ($(echo "$PY_FILES" | wc -l | tr -d ' ') files)" >&2
    PASS=$((PASS + 1))
  else
    WARN=$((WARN + 1))
  fi
fi

# 2. JS/TS lint (jen pokud package.json existuje)
if [ -f "package.json" ]; then
  if npm run lint --if-present 2>/dev/null; then
    echo "PASS: npm lint OK" >&2
    PASS=$((PASS + 1))
  else
    echo "WARN: npm lint failed or not configured" >&2
    WARN=$((WARN + 1))
  fi
fi

# 3. Shell script syntax check
SH_FILES=$(echo "$CHANGED_FILES" | grep '\.sh$' || true)
if [ -n "$SH_FILES" ]; then
  SH_ERRORS=0
  while IFS= read -r f; do
    [ -f "$f" ] || continue
    if ! bash -n "$f" 2>/dev/null; then
      echo "WARN: Shell syntax error in $f" >&2
      SH_ERRORS=$((SH_ERRORS + 1))
    fi
  done <<< "$SH_FILES"
  if [ $SH_ERRORS -eq 0 ]; then
    echo "PASS: Shell syntax OK ($(echo "$SH_FILES" | wc -l | tr -d ' ') files)" >&2
    PASS=$((PASS + 1))
  else
    WARN=$((WARN + 1))
  fi
fi

# Pokud žádné changed files, tiché PASS
if [ -z "$CHANGED_FILES" ] && [ ! -f "package.json" ]; then
  echo "PASS: no changed files to verify" >&2
fi

# Vždy exit 0 — nepřerušovat workflow
exit 0
