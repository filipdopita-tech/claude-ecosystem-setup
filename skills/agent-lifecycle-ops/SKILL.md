---
name: agent-lifecycle-ops
description: Unified start/stop/status/check/logs/tail/strategy interface for any systemd-managed autonomous agent. Auto-heals stagnant services. Auto-limits restart storms. Single bash script handles all VPS agents.
origin: reusable pattern — bash script (~100 řádků)
---

# Agent Lifecycle Ops

Jeden bash skript pro ovládání všech autonomous agentů (orchestrator, schedulers, outbound pipeline, email daemon, social publisher, bot daemony, atd.). Konzistentní interface napříč všemi.

## Kdy použít

- Chceš jednotný health-check v cronu: `agent_lifecycle.sh <agent> check`
- Debugging — tail logy jakéhokoli agentu bez pamatování systemd jmen
- Switch strategy za běhu: `agent_lifecycle.sh <agent> strategy repair-only`
- Manual restart po deploy: `agent_lifecycle.sh <agent> restart`

## Instalace

```bash
scp agent_lifecycle.sh <YOUR_USER>@<YOUR_VPS>:/usr/local/bin/agent
ssh <YOUR_VPS> 'chmod +x /usr/local/bin/agent'
```

Pak `agent <service> <action>` funguje odkudkoli.

## Actions

| Action | Co dělá |
|---|---|
| `start` | systemctl start |
| `stop` | graceful SIGTERM s 10s grace |
| `restart` | full restart + log |
| `status` | systemctl status + restarts-last-hour + last log age |
| `check` | **auto-heal**: failed → restart; stagnant (>10min žádný log) → restart; >3 restarts/h → bail + alert |
| `logs` | last 100 řádků |
| `tail` | follow logs |
| `strategy <preset>` | nastaví `AGENT_STRATEGY` přes systemd drop-in override |

## Cron setup

Health check pro všechny agenty:

```cron
*/5 * * * * /usr/local/bin/agent <agent-1> check
*/5 * * * * /usr/local/bin/agent <agent-2> check
*/5 * * * * /usr/local/bin/agent <agent-3> check
*/5 * * * * /usr/local/bin/agent <agent-4> check
```

Všechno tiše dokud se něco nestane. Pak push notifikace (ntfy, PagerDuty, Slack).

## Restart storm protection

Skript trackuje restarty v `/var/lib/<company>/lifecycle/<agent>.restarts`. Pokud víc než 3 restarty za hodinu → `check` přestane restartovat a pošle high-priority alert. Human pak ručně rozhodne.

## Strategy switching

```bash
# Po deployi → harden mode
agent <agent-1> strategy harden

# Incident: outbound pipeline dostala block
agent <agent-2> strategy repair-only

# Zpátky na normál
agent <agent-2> strategy balanced
```

Skript zapíše systemd drop-in override do `/etc/systemd/system/<agent>.service.d/strategy.conf`, `daemon-reload`, a restart. Přežije reboot.

Hromadný switch všech agentů najednou: wrapper script `strategy_mode.sh` ve stejném adresáři.

## Integrace s monit

Místo monit `exec` direktiv použij `agent <name> check`. Konzistentní chování + alerty + restart storm protection zadarmo.

## Reference implementace

Bash skript typicky ~100 řádků:

```bash
#!/bin/bash
# agent_lifecycle.sh <service> <action> [args...]

SERVICE="$1"
ACTION="$2"
STATE_DIR="/var/lib/<company>/lifecycle"
MAX_RESTARTS_PER_HOUR=3
STAGNANT_THRESHOLD_MIN=10

case "$ACTION" in
  check)
    # Check if failed
    if ! systemctl is-active --quiet "$SERVICE"; then
        restart_with_storm_protection "$SERVICE"
    fi
    # Check stagnant (last log age)
    last_log_age=$(check_last_log_age "$SERVICE")
    if [ "$last_log_age" -gt "$((STAGNANT_THRESHOLD_MIN * 60))" ]; then
        restart_with_storm_protection "$SERVICE"
    fi
    ;;
  strategy)
    PRESET="$3"
    mkdir -p "/etc/systemd/system/${SERVICE}.service.d"
    echo -e "[Service]\nEnvironment=AGENT_STRATEGY=${PRESET}" \
        > "/etc/systemd/system/${SERVICE}.service.d/strategy.conf"
    systemctl daemon-reload && systemctl restart "$SERVICE"
    ;;
  # ... start, stop, restart, status, logs, tail ...
esac
```

Full implementace: viz related skills pro stagnation detection a strategy presets.

## Related

- Strategy presets: `/agent-strategy-mode`
- Stagnation detection: `/agent-stagnation-guard`
- Audit trail: `/evolution-event-log`
