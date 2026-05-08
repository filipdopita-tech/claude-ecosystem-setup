#!/usr/bin/env bash
# audit-remote.sh — Mac wrapper for Flash VPS Ghidra pipeline
# Usage: audit-remote.sh <binary_path> [label]
#        audit-remote.sh --batch <dir> [pattern]
#        audit-remote.sh --pull <label>     # rsync findings back to Mac
#
# Compute + storage on Flash VPS (10.77.0.1):
#   - Ghidra:  /opt/binary-analysis/ghidra
#   - Output:  /opt/binary-analysis/runs/<label>/
#
# Source binary resolution:
#   1. /mac/... path (Flash SSHFS view of Mac) → no upload needed
#   2. Mac local path under $HOME → translated to /mac/...
#   3. Other Mac path → scp to Flash /tmp/audit-uploads/<sha>/
#
# Pull mode: rsync /opt/binary-analysis/runs/<label>/ → ~/Desktop/Codex/ghidra-runs/<label>/

set -euo pipefail

FLASH="${FLASH_HOST:-root@10.77.0.1}"
FLASH_RUNS="/opt/binary-analysis/runs"
LOCAL_PULL_BASE="${LOCAL_PULL_BASE:-$HOME/Desktop/Codex/ghidra-runs}"

usage() {
  cat <<EOF
Usage:
  $(basename "$0") <binary> [label]              # single audit on Flash
  $(basename "$0") --batch <flash_dir> [pattern] # batch on Flash dir
  $(basename "$0") --pull <label>                # rsync findings to Mac
  $(basename "$0") --ls                          # list runs on Flash
  $(basename "$0") --tail <label>                # tail Flash ghidra.log

Env:
  FLASH_HOST       (default root@10.77.0.1)
  LOCAL_PULL_BASE  (default ~/Desktop/Codex/ghidra-runs)
EOF
}

[[ $# -eq 0 ]] && { usage; exit 1; }

case "${1:-}" in
  --help|-h) usage; exit 0 ;;
  --ls)
    ssh "$FLASH" "ls -la $FLASH_RUNS 2>/dev/null"
    exit 0
    ;;
  --tail)
    LABEL="${2:?--tail <label>}"
    LABEL_SAFE=$(printf '%s' "$LABEL" | tr -c 'A-Za-z0-9._-' '_')
    ssh "$FLASH" "tail -50 $FLASH_RUNS/$LABEL_SAFE/ghidra.log"
    exit 0
    ;;
  --pull)
    LABEL="${2:?--pull <label>}"
    LABEL_SAFE=$(printf '%s' "$LABEL" | tr -c 'A-Za-z0-9._-' '_')
    mkdir -p "$LOCAL_PULL_BASE/$LABEL_SAFE"
    rsync -avz --exclude 'ghidra_project' "$FLASH:$FLASH_RUNS/$LABEL_SAFE/" "$LOCAL_PULL_BASE/$LABEL_SAFE/"
    echo "[pull] → $LOCAL_PULL_BASE/$LABEL_SAFE/"
    echo "  open $LOCAL_PULL_BASE/$LABEL_SAFE/findings.md"
    exit 0
    ;;
  --batch)
    DIR="${2:?--batch <flash_dir>}"
    PATTERN="${3:-*}"
    ssh "$FLASH" "/opt/binary-analysis/scripts/audit-batch.sh '$DIR' '$PATTERN'"
    exit 0
    ;;
esac

# === Single audit mode ===
BIN="$1"
LABEL="${2:-$(basename "$BIN")}"

if [[ ! -f "$BIN" ]]; then
  echo "[audit-remote] ERROR: binary not found locally: $BIN" >&2
  exit 1
fi

# Resolve target path on Flash
ABS_BIN=$(cd "$(dirname "$BIN")" && pwd)/$(basename "$BIN")
case "$ABS_BIN" in
  /mac/*)
    # Already a Flash-side /mac path (rare on Mac, but support)
    FLASH_BIN="$ABS_BIN"
    MODE="mac-mount"
    ;;
  "$HOME"/*)
    # Mac home — translate to /mac mount on Flash
    REL="${ABS_BIN#$HOME/}"
    FLASH_BIN="/mac/$(whoami)/$REL"
    MODE="mac-mount-translate"
    # But /mac might be /mac/Users/<whoami>/ — check below
    ;;
  /Users/*)
    # Absolute Mac user path — Flash sees /mac/Users/<user>/...
    FLASH_BIN="/mac${ABS_BIN}"
    MODE="mac-mount-absolute"
    ;;
  *)
    # Other Mac path — scp upload
    SHA=$(shasum -a 256 "$BIN" | cut -c1-12)
    FLASH_DIR="/tmp/audit-uploads/$SHA"
    ssh "$FLASH" "mkdir -p '$FLASH_DIR'"
    scp -q "$BIN" "$FLASH:$FLASH_DIR/"
    FLASH_BIN="$FLASH_DIR/$(basename "$BIN")"
    MODE="scp-upload"
    ;;
esac

echo "[audit-remote] mode:        $MODE"
echo "[audit-remote] mac path:    $ABS_BIN"
echo "[audit-remote] flash path:  $FLASH_BIN"
echo "[audit-remote] label:       $LABEL"

# Verify Flash sees the binary (handles /mac translate edge cases)
if ! ssh "$FLASH" "test -f '$FLASH_BIN'"; then
  echo "[audit-remote] WARN: Flash cannot see $FLASH_BIN — falling back to scp upload"
  SHA=$(shasum -a 256 "$BIN" | cut -c1-12)
  FLASH_DIR="/tmp/audit-uploads/$SHA"
  ssh "$FLASH" "mkdir -p '$FLASH_DIR'"
  scp -q "$BIN" "$FLASH:$FLASH_DIR/"
  FLASH_BIN="$FLASH_DIR/$(basename "$BIN")"
  MODE="scp-upload-fallback"
  echo "[audit-remote] mode (fb):   $MODE → $FLASH_BIN"
fi

# Run on Flash
ssh "$FLASH" "/opt/binary-analysis/scripts/audit-binary.sh '$FLASH_BIN' '$LABEL'"

echo
echo "[audit-remote] To view findings on Mac:"
echo "  $0 --pull '$LABEL'"
echo "  open '$LOCAL_PULL_BASE/$(printf '%s' "$LABEL" | tr -c 'A-Za-z0-9._-' '_')/findings.md'"
