#!/usr/bin/env bash
# auto-formatter.sh — automatické formátování po Write/Edit/MultiEdit (bcherny pattern)
# PostToolUse async hook: tichý výstup, nepřerušuje workflow

set -uo pipefail

# Načti filepath z CLAUDE_TOOL_INPUT (JSON env var)
FILE=""
if [ -n "${CLAUDE_TOOL_INPUT:-}" ]; then
  # Write tool: {"file_path": "..."}
  FILE=$(echo "$CLAUDE_TOOL_INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('file_path', d.get('path', '')))" 2>/dev/null || true)
fi

# Fallback: zkus CLAUDE_TOOL_RESULT
if [ -z "$FILE" ] && [ -n "${CLAUDE_TOOL_RESULT:-}" ]; then
  FILE=$(echo "$CLAUDE_TOOL_RESULT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('file_path', ''))" 2>/dev/null || true)
fi

# Pokud stále nemáme file, exit tiše
[ -z "$FILE" ] && exit 0
[ -f "$FILE" ] || exit 0

EXT="${FILE##*.}"

case "$EXT" in
  py)
    # Python: zkus black, fallback ruff
    black "$FILE" 2>/dev/null \
      || ruff format "$FILE" 2>/dev/null \
      || true
    ;;
  js|jsx|ts|tsx|json|css|scss|md)
    # JS/TS: prettier (tiché)
    npx --yes prettier --write "$FILE" 2>/dev/null || true
    ;;
  sh|bash)
    # Shell: jen chmod +x pokud shebang
    FIRST_LINE=$(head -1 "$FILE" 2>/dev/null || true)
    if [[ "$FIRST_LINE" == "#!/"* ]]; then
      chmod +x "$FILE" 2>/dev/null || true
    fi
    ;;
  *)
    # Ostatní typy: nic
    ;;
esac

exit 0
