#!/bin/bash
# PostToolUse hook: auto-format written files
# Reads stdin JSON, extracts file_path, applies formatting rules.
# Supports: .md (whitespace), .json (validation).
# Logs changes to ~/.claude/logs/auto-formatter.log
# Always exits 0 (non-blocking).

set -o pipefail

LOG_FILE="$HOME/.claude/logs/auto-formatter.log"
mkdir -p "$(dirname "$LOG_FILE")"

log_change() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Read stdin JSON
input=$(cat)
if [ -z "$input" ]; then
  exit 0
fi

# Extract file_path from tool_input
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
if [ -z "$file_path" ]; then
  exit 0
fi

# Check if file exists
if [ ! -f "$file_path" ]; then
  exit 0
fi

ext="${file_path##*.}"

case "$ext" in
  md)
    # Markdown: trim trailing whitespace, ensure single trailing newline, collapse 3+ blank lines to 2
    if sed -i '' -e 's/[[:space:]]*$//' "$file_path"; then
      log_change "✓ Trimmed trailing whitespace: $file_path"
    fi

    if sed -i '' -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$file_path"; then
      log_change "✓ Ensured single trailing newline: $file_path"
    fi

    # Collapse 3+ blank lines to 2
    if sed -i '' -e '/^$/N;/^\n$/!P;D' "$file_path"; then
      log_change "✓ Collapsed blank lines (3+ to 2): $file_path"
    fi
    ;;
  json)
    # JSON: validate and pretty-print (silent fail)
    if jq . "$file_path" > "$file_path.tmp" 2>/dev/null; then
      mv "$file_path.tmp" "$file_path"
      log_change "✓ Formatted JSON: $file_path"
    else
      rm -f "$file_path.tmp"
    fi
    ;;
esac

exit 0
