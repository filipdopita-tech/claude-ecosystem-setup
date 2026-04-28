#!/usr/bin/env bash
# pre-write-secrets-scan.sh — PreToolUse (Write): advisory warning when writing to sensitive filenames

# Never block (always exit 0); purely advisory

if ! command -v jq &>/dev/null; then
  exit 0
fi

INPUT=$(cat)
if [[ -z "$INPUT" ]]; then
  exit 0
fi

# Extract the file_path being written to
FILE_PATH=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // ""' 2>/dev/null) || exit 0

if [[ -z "$FILE_PATH" ]]; then
  exit 0
fi

# Normalize to lowercase basename for matching
BASENAME=$(basename "$FILE_PATH" | tr '[:upper:]' '[:lower:]')

# Exempt safe locations: ~/.claude/ and ~/Library/
NORM_PATH=$(printf '%s' "$FILE_PATH" | sed "s|^~|$HOME|")
if [[ "$NORM_PATH" == "$HOME/.claude/"* ]] || \
   [[ "$NORM_PATH" == "$HOME/Library/"* ]]; then
  exit 0
fi

# Sensitive filename patterns
MATCHED_REASON=""

case "$BASENAME" in
  .env|.env.*|env)
    MATCHED_REASON=".env file" ;;
  .mcp.json|mcp.json)
    MATCHED_REASON=".mcp.json config" ;;
  credentials.json|credentials)
    MATCHED_REASON="credentials file" ;;
  id_rsa|id_rsa.pub)
    MATCHED_REASON="RSA SSH key file" ;;
  id_ed25519|id_ed25519.pub)
    MATCHED_REASON="Ed25519 SSH key file" ;;
  *)
    # Check for keywords in filename
    if [[ "$BASENAME" == *secret* ]]; then
      MATCHED_REASON="filename contains 'secret'"
    elif [[ "$BASENAME" == *private* ]]; then
      MATCHED_REASON="filename contains 'private'"
    elif [[ "$BASENAME" == *token* ]]; then
      MATCHED_REASON="filename contains 'token'"
    fi
    ;;
esac

if [[ -n "$MATCHED_REASON" ]]; then
  printf '\n[pre-write-secrets-scan] ADVISORY: Writing to sensitive file (%s): %s\n' \
    "$MATCHED_REASON" "$FILE_PATH" >&2
  printf '  Ensure no secrets are committed to version control.\n\n' >&2
fi

# Always advisory — never block
exit 0
