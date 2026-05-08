#!/usr/bin/env bash
# algorithm-recall mirror updater
# Pulls latest from upstream TheAlgorithms repos (shallow).

set -euo pipefail

ROOT="$HOME/Documents/research-cache/algorithms-the-algorithms"
LANGS=(Python JavaScript TypeScript Rust Go Solidity)

if [ ! -d "$ROOT" ]; then
  echo "Creating mirror at $ROOT"
  mkdir -p "$ROOT"
fi

cd "$ROOT"

for lang in "${LANGS[@]}"; do
  if [ -d "$lang/.git" ]; then
    echo "=== Updating $lang ==="
    cd "$lang"
    # Shallow pull (avoids history bloat)
    git fetch --depth=1 origin 2>&1 | tail -3 || echo "  fetch failed"
    git reset --hard origin/$(git symbolic-ref --short HEAD 2>/dev/null || echo "main") 2>&1 | tail -2 || \
      git reset --hard origin/master 2>&1 | tail -2 || echo "  reset failed"
    cd ..
  else
    echo "=== Cloning $lang (missing) ==="
    git clone --depth=1 --quiet "https://github.com/TheAlgorithms/$lang.git" 2>&1 | tail -3 || echo "  clone failed"
  fi
done

echo
echo "=== Mirror sizes ==="
du -sh */ 2>/dev/null
echo
echo "=== Last commits ==="
for lang in "${LANGS[@]}"; do
  if [ -d "$lang/.git" ]; then
    cd "$lang"
    last=$(git log -1 --format="%h %ar — %s" 2>/dev/null | head -1)
    cd ..
    printf "  %-15s %s\n" "$lang" "$last"
  fi
done
