#!/bin/bash
# Security Guard - PreToolUse hook for Write|Edit
# Detects and blocks credential leaks across all major API providers
# Hardened: 2026-04-09

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.filePath // empty' 2>/dev/null)
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content // .tool_input.new_string // empty' 2>/dev/null)

[ -z "$FILE_PATH" ] && exit 0

# BLOCK: Direct credential files (write requires explicit override via bash heredoc)
if echo "$FILE_PATH" | grep -qiE '(master\.env|\.env\.prod|credentials\.json|secrets\.yaml|\.pem$|\.key$|id_rsa|id_ed25519|mcp-keys\.env|keys\.env|wg0\.conf|authorized_keys)'; then
  echo "SECURITY: Credential file detected ($FILE_PATH). Verify this is intentional." >&2
  exit 2
fi

# WARN: General env/config files
if echo "$FILE_PATH" | grep -qiE '(\.env$|\.env\.|config.*secret|token|password|apikey)'; then
  echo '{"systemMessage":"WARNING: This file may contain secrets. Double-check no credentials are being hardcoded."}'
  exit 0
fi

# BLOCK: Content contains potential secrets - comprehensive patterns
if [ -n "$CONTENT" ]; then
  # GitHub
  if echo "$CONTENT" | grep -qE '(ghp_[a-zA-Z0-9]{36}|gho_[a-zA-Z0-9]{36}|ghu_[a-zA-Z0-9]{36}|ghs_[a-zA-Z0-9]{36}|ghr_[a-zA-Z0-9]{36}|github_pat_[a-zA-Z0-9_]{80,})'; then
    echo "SECURITY: GitHub token detected in content. Never hardcode tokens." >&2
    exit 2
  fi
  # OpenAI/Anthropic
  if echo "$CONTENT" | grep -qE '(sk-ant-api[0-9]{2}-[a-zA-Z0-9_-]{90,}|sk-proj-[a-zA-Z0-9]{48,}|sk-[a-zA-Z0-9]{48})'; then
    echo "SECURITY: OpenAI/Anthropic API key detected. Never hardcode." >&2
    exit 2
  fi
  # AWS
  if echo "$CONTENT" | grep -qE '(AKIA[A-Z0-9]{16}|aws_secret_access_key\s*=\s*[A-Za-z0-9/+=]{40})'; then
    echo "SECURITY: AWS credentials detected. Never hardcode." >&2
    exit 2
  fi
  # Google
  if echo "$CONTENT" | grep -qE 'AIza[0-9A-Za-z_-]{35}'; then
    echo "SECURITY: Google API key detected. Never hardcode." >&2
    exit 2
  fi
  # Slack
  if echo "$CONTENT" | grep -qE '(xox[baprs]-[0-9a-zA-Z-]{10,})'; then
    echo "SECURITY: Slack token detected. Never hardcode." >&2
    exit 2
  fi
  # Stripe
  if echo "$CONTENT" | grep -qE '(sk_live_[0-9a-zA-Z]{24,}|rk_live_[0-9a-zA-Z]{24,})'; then
    echo "SECURITY: Stripe live key detected. Never hardcode." >&2
    exit 2
  fi
  # OpenRouter
  if echo "$CONTENT" | grep -qE 'sk-or-v1-[a-f0-9]{60,}'; then
    echo "SECURITY: OpenRouter key detected. Never hardcode." >&2
    exit 2
  fi
  # Snyk
  if echo "$CONTENT" | grep -qE 'snyk_uat\.[a-f0-9]{8}\.[a-zA-Z0-9_-]+'; then
    echo "SECURITY: Snyk token detected. Never hardcode." >&2
    exit 2
  fi
  # Generic JWT in suspicious context
  if echo "$CONTENT" | grep -qE 'eyJhbGciOi[a-zA-Z0-9_-]{20,}\.[a-zA-Z0-9_-]{20,}\.[a-zA-Z0-9_-]{20,}'; then
    # Only warn for JWTs - they're common in legit contexts too
    echo '{"systemMessage":"WARNING: JWT token detected. If this is a credential, move to env file."}'
  fi
  # Private keys
  if echo "$CONTENT" | grep -qE 'BEGIN (RSA|EC|OPENSSH|DSA|PGP) PRIVATE KEY'; then
    echo "SECURITY: Private key detected in content. Never write keys to files via Edit/Write." >&2
    exit 2
  fi
fi

exit 0
