---
name: agent-strategy-mode
description: Adaptive agent behavior via strategy presets + stagnation detection. Prevents repair loops. Tune innovate/harden/repair balance per deployment state. Apply to orchestrator, scheduler, scraper, outbound pipeline, media analyzer.
origin: reusable pattern — strategy env var + Python/bash reference implementace (~50 řádků)
---

# Agent Strategy Mode

Reusable pattern pro libovolný autonomní agent. Dvě mechaniky, oboje implementovatelné <50 řádků.

## 1. Strategy Presets — řídí intent balance přes env var

```bash
AGENT_STRATEGY={balanced|innovate|harden|repair-only}
```

| Preset | Innovate | Optimize | Repair | Kdy použít |
|---|---|---|---|---|
| `balanced` (default) | 50% | 30% | 20% | Daily steady-state |
| `innovate` | 80% | 15% | 5% | Stable system, ship features |
| `harden` | 20% | 40% | 40% | Po deployi, stability focus |
| `repair-only` | 0% | 20% | 80% | Incident mode, broken pipeline |

**Python reference implementace:**

```python
import os, random

STRATEGY = os.getenv("AGENT_STRATEGY", "balanced")
WEIGHTS = {
    "balanced":    (0.50, 0.30, 0.20),
    "innovate":    (0.80, 0.15, 0.05),
    "harden":      (0.20, 0.40, 0.40),
    "repair-only": (0.00, 0.20, 0.80),
}[STRATEGY]

def pick_action():
    return random.choices(
        ["new_feature", "optimize_existing", "repair_signal"],
        weights=WEIGHTS
    )[0]
```

**Bash / systemd service pattern:**

```ini
# /etc/systemd/system/<agent>.service
[Service]
Environment=AGENT_STRATEGY=balanced
# Override for incident: systemctl edit <agent> → AGENT_STRATEGY=repair-only
ExecStart=/usr/bin/python3 /opt/<company>/daemon.py
```

## 2. Stagnation Detection — break repair loops

Problem: agent 3x po sobě loguje stejný signal a "opravuje" ho bez progresu. Klasický repair loop (scraper SMTP bounce, email block, OOM retry).

**Rule:** 3 identické signal hashes za sebou → bail out + escalate.

```python
from hashlib import sha256
from collections import deque

signal_history = deque(maxlen=3)

def signal_hash(sig: dict) -> str:
    payload = f"{sig['type']}:{sig.get('target','')}:{sig.get('error','')}"
    return sha256(payload.encode()).hexdigest()[:12]

def should_bail(signal: dict) -> bool:
    signal_history.append(signal_hash(signal))
    return len(signal_history) == 3 and len(set(signal_history)) == 1
```

**On bail action:**
1. Push alert (ntfy, PagerDuty, Slack) s posledním signálem
2. Switch ENV → `AGENT_STRATEGY=repair-only` (systemd-reload + restart)
3. Halt auto-apply, čekej na human review
4. Log do event store (`/evolution-event-log` pattern)

## Aplikace na typické agenty

| Agent | Default strategy | Escalation trigger |
|---|---|---|
| Orchestrator daemon | `balanced` | Alert fire → `repair-only` |
| Scheduler/batcher | `balanced` | >2 spawn fails → `harden` |
| Outbound pipeline | `harden` | Throttle file → `repair-only` |
| Email warmup | `harden` (během block) | Po clearance → `balanced` |
| Scraper | `balanced` | SMTP dedup 3x same → bail |
| Media analyzer | `innovate` (explore) / `repair-only` (rate-limited) | API 429 3x → bail |

## Pre-deploy checklist

Před integrací do existujícího agentu:
- [ ] ENV var dokumentován (ecosystem-map nebo README)
- [ ] Default = `balanced` (nezhorší current behavior)
- [ ] Bail-out posílá push alert (ne jen log)
- [ ] Signal hash pokrývá skutečnou unique identitu (ne jen timestamp)
- [ ] Threshold otestovaný — nefire na první legitimní retry

## Monitoring

Indicators že to funguje:
- Repair loop MTBF stoupá (méně wake-upů na stejný signál)
- Deploy-phase failures klesají po `harden` pre-deploy
- Alert signal-to-noise ratio se zlepšuje (bail nahrazuje spam)

Indicators že je rozbité:
- Bail-out fire na první legit retry → zvyš threshold ze 3 na 5
- Stagnation nikdy nedetekován přes zjevné loopy → signal_hash coverage chybí
- `repair-only` uvízl → timeout + auto-switch zpět na `balanced` po 2h

## Inspirace

Pattern je evolutionary-computing idiom (GEP — "Signal De-duplication", "innovate vs repair"). Implementace je vždy malá (< 50 řádků), hlavní hodnota je v disciplíně — nemoci "jen dál zkoušet" bez eskalace.

## Related

- Stagnation guard (detekce): `/agent-stagnation-guard`
- Lifecycle ops (runtime control): `/agent-lifecycle-ops`
- Event log (audit): `/evolution-event-log`
