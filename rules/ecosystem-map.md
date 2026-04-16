# Ecosystem Quick Reference
# CUSTOMIZE: Doplň podle svého infrastruktura setupu

## SSH
# CUSTOMIZE: Přidej své VPS a Mac adresy
- VPS-PRIMARY: `ssh root@YOUR_VPS_IP` (WG only) | specs
- Mac: `ssh mac` (YOUR_MAC_WG_IP) nebo /mac/ (SSHFS)
- WG: YOUR_WG_SUBNET (VPS=.1, Mac=.2)

## Klíčové služby (vše na VPS)
# CUSTOMIZE: Nahraď svými službami
# Příklady standardních služeb:
- caddy (reverse proxy), mariadb/postgres (databáze), ntfy (push notifikace)
- postfix+dovecot+opendkim (email stack), claude-code daemon

## Credentials
# CUSTOMIZE: Cesty ke credentials na tvém systému
- VPS: /root/.credentials/master.env NEBO /home/YOUR_USER/.credentials/master.env
- Mac: ~/.claude/mcp-keys.env

## MCP
# CUSTOMIZE: Doplň své aktivní MCP servery
# Standardní: github, playwright, context7
# Volitelné: gmail, gcal, notion, figma, canva, webflow, notebooklm

## Zdraví systému
- Zkontroluj: `~/.claude/hooks/stop-code-verify.sh`
- Monit dashboard: http://YOUR_VPS_IP:2812

Pro kompletní service/port tabulky viz `~/.claude/knowledge/ecosystem-detail.md`
# CUSTOMIZE: Vytvoř ecosystem-detail.md se svými službami
