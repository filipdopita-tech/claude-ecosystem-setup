#!/usr/bin/env bash
# audit-batch.sh — batch wrapper, runs audit-binary.sh on multiple targets
# Usage: audit-batch.sh <dir_with_binaries> [pattern]
#        audit-batch.sh --list <file_with_paths>
#
# Generates per-binary findings.md + INDEX.md aggregating risk scores across batch.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SINGLE="$SCRIPT_DIR/audit-binary.sh"
OUT_BASE="$HOME/Desktop/Codex/ghidra-runs"
BATCH_DIR="$OUT_BASE/_batch_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BATCH_DIR"
INDEX="$BATCH_DIR/INDEX.md"

declare -a TARGETS=()

if [[ "${1:-}" == "--list" ]]; then
  LIST="${2:?usage: audit-batch.sh --list <file>}"
  while IFS= read -r line; do
    [[ -z "$line" || "$line" =~ ^# ]] && continue
    TARGETS+=("$line")
  done < "$LIST"
else
  DIR="${1:?usage: audit-batch.sh <dir> [pattern] | --list <file>}"
  PATTERN="${2:-*}"
  while IFS= read -r f; do
    if file "$f" 2>/dev/null | grep -qE 'executable|shared object|Mach-O|PE32|ELF'; then
      TARGETS+=("$f")
    fi
  done < <(find "$DIR" -maxdepth 3 -type f -name "$PATTERN" 2>/dev/null)
fi

echo "[batch] targets: ${#TARGETS[@]}"
[[ ${#TARGETS[@]} -eq 0 ]] && { echo "[batch] no targets, exit"; exit 0; }

{
  echo "# Batch Binary Audit — $(date)"
  echo
  echo "Targets: ${#TARGETS[@]}"
  echo
  echo "| binary | risk | suspicious | network | crypto | findings |"
  echo "| --- | --- | --- | --- | --- | --- |"
} > "$INDEX"

for t in "${TARGETS[@]}"; do
  if [[ ! -f "$t" ]]; then
    echo "[batch] skip (missing): $t"
    continue
  fi
  label=$(basename "$t")
  echo "[batch] >>> $label"
  if "$SINGLE" "$t" "$label" > "$BATCH_DIR/${label}.log" 2>&1; then
    findings="$OUT_BASE/$(echo "$label" | tr -c 'A-Za-z0-9._-' '_')/findings.md"
    if [[ -f "$findings" ]]; then
      risk=$(grep -E '\*\*Heuristic risk score\*\*' "$findings" | head -1 | sed -E 's/.*\*\*([0-9]+)\*\*.*/\1/')
      band=$(grep -E '\*\*Heuristic risk score\*\*' "$findings" | head -1 | sed -E 's/.*\(([A-Z]+)\).*/\1/')
      susp=$(grep -E '^- \*\*Risk indicators' "$findings" | sed -E 's/.*suspicious=([0-9]+).*/\1/')
      net=$(grep -E '^- \*\*Risk indicators' "$findings" | sed -E 's/.*network=([0-9]+).*/\1/')
      crypto=$(grep -E '^- \*\*Risk indicators' "$findings" | sed -E 's/.*crypto=([0-9]+).*/\1/')
      echo "| \`$label\` | $risk ($band) | $susp | $net | $crypto | [findings.md]($findings) |" >> "$INDEX"
    else
      echo "| \`$label\` | ERR | — | — | — | (no findings) |" >> "$INDEX"
    fi
  else
    echo "| \`$label\` | FAIL | — | — | — | (see $BATCH_DIR/${label}.log) |" >> "$INDEX"
  fi
done

echo
echo "[batch] DONE"
echo "  index: $INDEX"
