#!/bin/bash
# VPS Safety Check - PreToolUse hook for Bash
# Blocks destructive operations and security-sensitive commands
# Hardened: 2026-04-09

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)

[ -z "$COMMAND" ] && exit 0

# BLOCK: Catastrophic destruction
if echo "$COMMAND" | grep -qE '(rm\s+-rf\s+/$|rm\s+-rf\s+/\*|rm\s+-rf\s+/root$|rm\s+-rf\s+/root/$|rm\s+-rf\s+/home$|rm\s+-rf\s+/etc|rm\s+-rf\s+/var|rm\s+-rf\s+/usr|mkfs\.|dd\s+if=.*of=/dev/(sd|nvme|hd)|>\s*/dev/(sd|nvme|hd)|shutdown|reboot|init\s+0|init\s+6|halt\s|poweroff)'; then
  echo '{"decision":"block","reason":"BLOCKED: Destructive system command. Requires explicit user approval."}'
  exit 0
fi

# BLOCK: Security-sensitive bypass attempts
if echo "$COMMAND" | grep -qE '(curl\s+.*\|\s*(bash|sh|zsh)|wget\s+.*\|\s*(bash|sh|zsh)|nc\s+-e|bash\s+-i\s+>&\s*/dev/tcp|/dev/tcp/[0-9])'; then
  echo '{"decision":"block","reason":"BLOCKED: Pipe-to-shell or reverse shell pattern detected."}'
  exit 0
fi

# BLOCK: Disabling security
if echo "$COMMAND" | grep -qE '(ufw\s+disable|systemctl\s+stop\s+(fail2ban|ufw|firewalld|monit)|systemctl\s+disable\s+(fail2ban|ufw|firewalld|sshd)|iptables\s+-F|setenforce\s+0|spctl\s+--master-disable)'; then
  echo '{"decision":"block","reason":"BLOCKED: Disabling security service. Requires explicit approval."}'
  exit 0
fi

# WARN: Service-affecting commands
if echo "$COMMAND" | grep -qE '(systemctl\s+stop|service\s+.*\s+stop|docker\s+rm\s+-f|docker\s+system\s+prune|iptables\s+-D)'; then
  echo '{"decision":"warn","reason":"WARNING: Service-affecting command. Verify this is intentional."}'
  exit 0
fi

# WARN: Git destructive operations
if echo "$COMMAND" | grep -qE 'git\s+push\s+.*(-f\b|--force)'; then
  echo '{"decision":"warn","reason":"WARNING: git force-push rewrites remote history."}'
  exit 0
fi

if echo "$COMMAND" | grep -qE 'git\s+reset\s+--hard'; then
  echo '{"decision":"warn","reason":"WARNING: git reset --hard discards all uncommitted changes."}'
  exit 0
fi

if echo "$COMMAND" | grep -qE 'git\s+(checkout|restore)\s+\.'; then
  echo '{"decision":"warn","reason":"WARNING: discards all uncommitted changes in working tree."}'
  exit 0
fi

# WARN: Recursive delete on non-standard targets
if echo "$COMMAND" | grep -qE 'rm\s+(-[a-zA-Z]*r[a-zA-Z]*\s+|--recursive\s+)'; then
  SAFE_ONLY=true
  RM_TARGETS=$(echo "$COMMAND" | sed -E 's/.*rm\s+(-[a-zA-Z]+\s+)*//;s/--recursive\s*//')
  for target in $RM_TARGETS; do
    case "$target" in
      */node_modules|node_modules|*/.next|.next|*/dist|dist|*/__pycache__|__pycache__|*/.cache|.cache|*/build|build|*/.turbo|.turbo|*/coverage|coverage|/tmp/*|/var/tmp/*)
        ;; # safe target
      -*)
        ;; # flag, skip
      *)
        SAFE_ONLY=false
        break
        ;;
    esac
  done
  if [ "$SAFE_ONLY" = false ]; then
    echo '{"decision":"warn","reason":"WARNING: Recursive delete on non-standard target. Verify paths."}'
    exit 0
  fi
fi

# BLOCK: Database destruction
if echo "$COMMAND" | grep -qiE '(DROP\s+TABLE|DROP\s+DATABASE|TRUNCATE\s+|DELETE\s+FROM\s+.*\s+WHERE\s+1)'; then
  echo '{"decision":"block","reason":"BLOCKED: Destructive database command."}'
  exit 0
fi

# WARN: Mass network ops
if echo "$COMMAND" | grep -qE '(nmap\s+.*-p\s*-|masscan|hydra|sqlmap)'; then
  echo '{"decision":"warn","reason":"WARNING: Network scanning tool. Ensure target is authorized (own systems only)."}'
  exit 0
fi

exit 0
