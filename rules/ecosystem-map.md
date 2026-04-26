# Ecosystem Quick Reference

## SSH
- VPS-PRIMARY: `ssh root@REDACTED_VPN_IP` (WG only) | 12GB/6vCPU/200GB
- Mac: `ssh $YOUR_HOST` (REDACTED_VPN_IP) nebo $VPS_MOUNT/ (SSHFS)
- WG: REDACTED_VPN_IP/24 (PRIMARY=.1, SECONDARY=.2)
- Alfa (Wedos): DISCONTINUED 2026-04-12 — nepoužívat

## Klíčové služby (vše na Flash)
- kb-api, killswitch, conductor, caddy, openspace-mcp(18860), openspace-dashboard(7788), fluent-bit, monit
- postfix+dovecot+opendkim (email, 5 domén), ntfy(2586), [your_company]-wa-bridge(18810), imessage-bridge
- dashboard(3000), sse-dashboard(8099), mariadb(3306)
- ghl-watcher, unsub-server(8089), [your_company]-bot, social-terminal(8878)

## Credentials
- Flash: /root/.credentials/master.env NEBO /home/claude/.credentials/master.env

## MCP
github, flywheel-memory, openspace, playwright | Remote: Canva, Figma, Gmail, GCal, Notion, Webflow, context7, notebooklm

## Známé problémy
- Flash IP (REDACTED_IP) ověřen proti Spamhaus/Barracuda/Spamcop = CLEAN (2026-04-17)

## Deprecated
- Agent Cards MCP — JWT renewal neřešíme (dle rozhodnutí 2026-04-17, [YOUR_NAME])

Pro kompletní service/port tabulky viz `~/.claude/knowledge/ecosystem-detail.md`
