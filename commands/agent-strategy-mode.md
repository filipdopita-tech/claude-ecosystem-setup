---
name: agent-strategy-mode
description: Adaptive agent behavior via strategy presets + stagnation detection. Prevents repair loops. Tune innovate/harden/repair balance per deployment state. Apply to Conductor, Paseo, scraper, Dubai outreach, IG analyzer.
origin: pattern extracted from EvoMap/evolver (GEP) — NOT a dependency; source is obfuscated + GPL-3.0
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Grep
  - Glob
---

# Agent Strategy Mode

Reusable pattern pro libovolný autonomní agent v OneFlow ekosystému. Dvě mechaniky, oboje implementovatelné <50 řádků.

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
# /etc/systemd/system/conductor.service
[Service]
Environment=AGENT_STRATEGY=balanced
# Override for incident: systemctl edit conductor → AGENT_STRATEGY=repair-only
ExecStart=/usr/bin/python3 /opt/conductor/daemon.py
```

## 2. Stagnation Detection — break repair loops

Problem: agent 3x po sobě loguje stejný signal a "opravuje" ho bez progresu. Klasický repair loop (scraper SMTP bounce, cold email block, Whisper OOM retry).

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
1. `ntfy.sh` alert Filipovi s posledním signálem
2. Switch ENV → `AGENT_STRATEGY=repair-only` (systemd-reload + restart)
3. Halt auto-apply, čekej na human review
4. Log do Graphiti (`graphiti_add` EvolutionEvent-style node)

## OneFlow aplikace

| Agent | Default strategy | Escalation trigger |
|---|---|---|
| Conductor | `balanced` | Ntfy fire → `repair-only` |
| Paseo | `balanced` | >2 agent spawn fails → `harden` |
| Dubai outreach | `harden` | Throttle file → `repair-only` |
| Cold email warmup | `harden` (během PP blocku) | Po clearance → `balanced` |
| Scraper v4 | `balanced` | SMTP dedup 3x same → bail |
| IG Analyzer | `innovate` (explore) / `repair-only` (rate-limited) | API 429 3x → bail |

## Pre-deploy checklist

Před integrací do existujícího agentu:
- [ ] ENV var dokumentován v `ecosystem-map.md`
- [ ] Default = `balanced` (nezhorší current behavior)
- [ ] Bail-out posílá ntfy (ne jen log)
- [ ] Signal hash pokrývá skutečnou unique identitu (ne jen timestamp)
- [ ] Threshold otestovaný — nefire na první legitimní retry

## Monitoring

Indicators že to funguje:
- Repair loop MTBF stoupá (méně wake-upů na stejný signál)
- Deploy-phase failures klesají po `harden` pre-deploy
- Ntfy signal-to-noise ratio se zlepšuje (bail nahrazuje spam)

Indicators že je rozbité:
- Bail-out fire na první legit retry → zvyš threshold ze 3 na 5
- Stagnation nikdy nedetekován přes zjevné loopy → signal_hash coverage chybí
- `repair-only` uvízl → timeout + auto-switch zpět na `balanced` po 2h

## Proč ne použít EvoMap/evolver přímo

- Source obfuskovaný (`javascript-obfuscator` v devDeps, 783KB mangled `src/evolve.js`)
- GPL-3.0 viral pro komerční integraci
- Centralizovaný "Hub" vyžaduje node ID, data flow opaque
- Historie force-pushed (67 releases, 2 commity v main)
- Vezmi pattern, nech package.

## Reference

- EvoMap/evolver (inspirace): https://github.com/EvoMap/evolver — `EVOLVE_STRATEGY` env var, "Signal De-duplication"
- Související skill: `continuous-learning-v2` (feedback loop)
- Memory: `project_conductor.md`, `project_paseo.md`
