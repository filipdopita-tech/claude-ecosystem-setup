---
name: dashboard
description: Open Active-Agents live Computer Panel (Manus ekvivalent). Use when Filip says "co dělají agenti", "stav pipeline", "live dashboard", "computer panel", "kde jsem", "/dashboard", "jaký je stav". Returns refreshed Active-Agents.md content + Hermes/Conductor/KARIMO/Codex/Cost overview.
last-updated: 2026-05-03
---

# /dashboard — Live Agent Cockpit

## When to invoke

- "/dashboard" / "/cockpit" / "stav agentů"
- "Co teď běží na Flash" / "co dělá Hermes" / "kde je conductor"
- "Live status" / "computer panel" / "pipeline stav"
- Před start dlouhého úkolu (situational awareness)
- Po návratu k práci (po /clear, po sleep, po denní pauze)

## What it does

1. Refreshes Active-Agents dashboard (forces immediate update)
2. Reads `~/Documents/OneFlow-Vault/00-Claude-Dashboard/Active-Agents.md`
3. Returns formatted view: Live Status + Today + Decisions + Alerts + Cost
4. Surfaces critical alerts (Hermes commits behind, disk pressure, gateway inactive)

## Implementation

```bash
# Force refresh
bash ~/scripts/automation/active-agents-refresh.sh

# Show dashboard
cat ~/Documents/OneFlow-Vault/00-Claude-Dashboard/Active-Agents.md
```

For replay of specific agent log:
```bash
bash ~/scripts/automation/active-agents-refresh.sh --replay {hermes|conductor|karimo|codex|events}
```

## Output format (return to Filip)

```
=== Live Status ===
[Service table: Hermes/Conductor/Flash/Mac with current status]

=== Today's Activity ===
[Counts: KARIMO/Codex/Hermes/Shannon/Events]

=== Last 24h Decisions ===
[ai-radar decisions.jsonl entries]

=== Alerts ===
[Hermes commits behind, gateway down, disk pressure]

=== Quick Actions ===
- Refresh: bash ~/scripts/automation/active-agents-refresh.sh
- Replay agent: ~/scripts/automation/active-agents-refresh.sh --replay <agent>
- Stop Hermes cron: ssh root@10.77.0.1 'systemctl stop hermes-cron'
```

## Chain partners

- **Pre-task**: chain s `/triad agent` if Filip wants to start something
- **Post-incident**: chain s `/postmortem` after agent failure
- **Telegram setup pending**: nabídni `bash ~/scripts/automation/hermes-telegram-setup.sh`
- **Cost tracking pending**: nabídni Codex handoff `~/Desktop/Codex/ai-control-plane/handoffs/2026-05-03-cost-tracking-wrapper.md`

## Auto-refresh

Cron `*/15 * * * *` (active 2026-05-03). Manuální refresh přes tento skill nebo přímo bash.

## Reference

- Dashboard MD: `~/Documents/OneFlow-Vault/00-Claude-Dashboard/Active-Agents.md`
- Refresh script: `~/scripts/automation/active-agents-refresh.sh`
- User dossier (related): `~/Documents/OneFlow-Vault/00-Claude-Dashboard/Filip-User-Dossier.md`
- Memory: `project_ecosystem_upgrade_manus_2026_05_03.md`
- Manus parity reference: `project_ecosystem_upgrade_manus_2026_05_03.md` § Manus capability gap analysis
