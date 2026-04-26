# Security Hard Rules

- Credentials NIKDY hardcoded -> `~/.credentials/` (chmod 600) nebo `/root/.credentials/master.env`
- Services bind: localhost > WG (REDACTED_VPN_IP/x) > public. I s UFW deny, bind localhost
- SSH: prohibit-password, no PasswordAuth, MaxAuthTries 3, fail2ban, ed25519
- systemd: EnvironmentFile pro secrets, Restart=always, NoNewPrivileges=true
- MCP: pinovat verze, klíče z env, audit před přidáním
- Hooks (security-guard.sh, vps-safety-check.sh): NIKDY nesmazat/obejít
- HTTPS only, TLS 1.2+, HSTS. No secrets v git diff
- GDPR: žádná osobní data v plain text logech. AML: append-only 10 let
- Anti-patterns: `curl|bash`, `chmod 777`, `ufw disable`, `rm -rf /`, `eval $(external)`
- Incident: STOP -> ISOLATE -> PRESERVE -> INVESTIGATE -> ROTATE -> REBUILD -> POSTMORTEM
