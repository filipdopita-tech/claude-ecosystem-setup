# Ecosystem Quick Reference

## SSH
- Flash (Contabo): `ssh root@10.77.0.1` (WG only) | 12GB/6vCPU/200GB
- Mac: `ssh mac` (10.77.0.2) nebo /mac/ (SSHFS)
- WG: 10.77.0.0/24 (Flash=.1, Mac=.2)
- Alfa (Wedos): DISCONTINUED 2026-04-12 — nepoužívat

## Klíčové služby (vše na Flash)
- kb-api, killswitch, conductor, caddy, openspace-mcp(18860), openspace-dashboard(7788), fluent-bit, monit
- postfix+dovecot+opendkim (email, 5 domén), ntfy(2586), oneflow-wa-bridge(18810), imessage-bridge
- dashboard(3000), sse-dashboard(8099), mariadb(3306)
- ghl-watcher, unsub-server(8089), oneflow-bot, social-terminal(8878)

## Credentials
- Flash: /root/.credentials/master.env NEBO /home/claude/.credentials/master.env

## MCP
github, flywheel-memory, openspace, playwright | Remote: Canva, Figma, Gmail, GCal, Notion, Webflow, context7, notebooklm

## Známé problémy
- Flash IP (91.231.30.250) ověřen proti Spamhaus/Barracuda/Spamcop = CLEAN (2026-04-17)

## Deprecated
- Agent Cards MCP — JWT renewal neřešíme (dle rozhodnutí 2026-04-17, Filip)

Pro kompletní service/port tabulky viz `~/.claude/knowledge/ecosystem-detail.md`
