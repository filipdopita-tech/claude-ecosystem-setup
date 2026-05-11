---
name: agent-lifecycle-ops
description: Unified start/stop/status/check/logs/tail/strategy interface for any systemd-managed OneFlow agent. Auto-heals stagnant services. Auto-limits restart storms. Single bash script handles all VPS agents.
origin: pattern extracted from EvoMap/evolver (src/ops/lifecycle.js) — bash reimplementation at ~/scripts/evolver-patterns/agent_lifecycle.sh
allowed-tools:
  - Bash
  - Read
  - Grep
  - Glob
---

# Agent Lifecycle Ops

Jeden bash skript pro ovládání všech autonomous agentů na Flash (Conductor, Paseo, Dubai outreach, cold-email daemon, Social publisher, GHL watcher, Telegram bot, atd.). Konzistentní interface napříč všemi.

## Kdy použít

- Chceš jednotný health-check v cronu: `agent_lifecycle.sh conductor check`
- Debugging — tail logy jakéhokoli agentu bez pamatování systemd jmen
- Switch strategy za běhu: `agent_lifecycle.sh dubai-outreach strategy repair-only`
- Manual restart po deploy: `agent_lifecycle.sh paseo restart`

## Instalace na Flash

```bash
rtk scp ~/scripts/evolver-patterns/agent_lifecycle.sh root@10.77.0.1:/usr/local/bin/agent
rtk ssh root@10.77.0.1 'chmod +x /usr/local/bin/agent'
```

Pak `agent <service> <action>` funguje odkudkoli.

## Actions

| Action | Co dělá |
|---|---|
| `start` | systemctl start |
| `stop` | graceful SIGTERM s 10s grace |
| `restart` | full restart + log |
| `status` | systemctl status + restarts-last-hour + last log age |
| `check` | **auto-heal**: failed → restart; stagnant (>10min žádný log) → restart; >3 restarts/h → bail + ntfy alert |
| `logs` | last 100 řádků |
| `tail` | follow logs |
| `strategy <preset>` | nastaví `AGENT_STRATEGY` přes systemd drop-in override |

## Cron setup

Přidej na Flash do cronu health check pro všechny agenty:

```cron
*/5 * * * * /usr/local/bin/agent conductor check
*/5 * * * * /usr/local/bin/agent paseo check
*/5 * * * * /usr/local/bin/agent dubai-outreach check
*/5 * * * * /usr/local/bin/agent cold-email-daemon check
```

Všechno tiše dokud se něco nestane. Pak ntfy na `oneflow-alerts`.

## Restart storm protection

Skript trackuje restarty v `/var/lib/oneflow/lifecycle/<agent>.restarts`. Pokud víc než 3 restarty za hodinu → `check` přestane restartovat a pošle high-priority ntfy alert. Filip pak ručně rozhodne.

## Strategy switching

```bash
# Po deployi Conductoru → harden mode
agent conductor strategy harden

# Incident: Dubai outreach dostala Proofpoint block
agent dubai-outreach strategy repair-only

# Zpátky na normál
agent dubai-outreach strategy balanced
```

Skript zapíše systemd drop-in override do `/etc/systemd/system/<agent>.service.d/strategy.conf`, `daemon-reload`, a restart. Přežije reboot.

Hromadný switch všech agentů najednou: `strategy_mode.sh` ve stejném adresáři.

## Integrace s monit

Místo monit `exec` direktiv použij `agent <name> check`. Konzistentní chování + ntfy + restart storm protection zadarmo.

## Related

- Strategy presets: `/agent-strategy-mode`
- Stagnation detection: `/agent-stagnation-guard`
- Audit trail: `/evolution-event-log`
