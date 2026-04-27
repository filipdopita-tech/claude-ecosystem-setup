# Ecosystem Detail (moved from rules/ to save per-message tokens)

## Flash Services
| Služba | Port | Účel |
|---|---|---|
| kb-api | 18830 (local) | Knowledge Base API (SQLite FTS5) |
| killswitch | 18900 (public) | Emergency kill switch |
| oneflow-affiliate | 18800 (public) | Partner dashboard |
| imessage-bridge | 8100 (local) | iMessage API |
| multi-ai-chat | 8090 (local) | Multi-AI chat |
| social-terminal | 8878 (local) | Social API |
| sms-receiver | 8446 (local) | SMS webhook |
| lead-scoring | 18840 (local+WG) | OneFlow Lead Scoring API |
| systems-api | 18850 (local+WG) | Systems Status API |
| conductor | pidfile | Claude Code orchestrator |
| oneflow-bot | - | Telegram bot |
| beskyd-form | - | Form handler |
| fluent-bit | - | Log collector -> ntfy |
| caddy | 80/443 | Reverse proxy |
| openspace-mcp | 18860 (WG) | Self-evolving skills engine |

Crony: orphan-cleaner (*/5), mount-mac (*/5), mac-guardian (*/15), nightly-sync (2:00), config-backup (4:00), ai-brain-sync (*/30), ai-brain-daily (1:00)
Monit: kb-api, killswitch, affiliate, conductor, sshd, fluent-bit, perms-watcher, mac-mount, research-engine, caddy, fail2ban, alfa-vpn, mac-vpn, openspace-mcp + 7 screen processes
Docker: autoheal container

## Alfa Services
| Služba | Port | Účel |
|---|---|---|
| postfix+dovecot | 25/143/993 | Email (mail.oneflow-team.cz) |
| nginx | 80/443/++ | Reverse proxy *.oneflow.cz |
| ntfy | 2586 | Push notifikace |
| wa-bridge (Go) | 18810 | WhatsApp Bridge |
| whatsapp-bridge | 8085 | WA Baileys bridge (fallback) |
| oneflow-dashboard | 3000 | Dashboard (PM2, Next.js) |
| mariadb | 3306 (local) | Database |
| beszel-agent | 45876 | System monitor |
| ghl-watcher | - | GHL event watcher |
| unsub-server | - | Unsubscribe handler |

Crony: 43 entries (cold email 16x, dashboard 8x, scraping 8x, backup 5x, security 3x, social 1x)
Screen: social-terminal, wa-bridge, sms-receiver, oneflow-bot, beskyd_form, httpserv

## Mac CLI Tools
gh, ffmpeg, vercel, playwright, stripe (1.40.3)

## Klíčové cesty
- /mac/Documents/ = Mac Documents (source of truth)
- /home/claude/knowledge-base/ = KB API data (Flash)
- /home/claude/dubai-scraper/ = UAE lead scraper (Flash)

## Resolved Issues (2026-04-08)
Caddy active, GEMINI_API_KEY in .env, backup cron 4:00, SSHFS fixed, li-ghl-sync disabled+masked, WG 10.77.0.0/24, Alfa disk 53%, Postfix LE cert (exp 2026-07-07), SN expired+disabled, Cloudflare token saved, WEDOS WAPI fixed, DMARC quarantine+SPF -all
