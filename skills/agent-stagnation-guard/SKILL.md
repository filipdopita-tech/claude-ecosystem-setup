---
name: agent-stagnation-guard
description: Drop-in stagnation detection for any OneFlow agent. Prevents repair loops (SMTP bounce loops, API 429 spirals, dependency timeouts). Bails + escalates after 3 identical signals. Auto-notifies via ntfy.
origin: pattern extracted from EvoMap/evolver — dependency-free Python module at ~/scripts/evolver-patterns/stagnation_detector.py
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Grep
  - Glob
---

# Agent Stagnation Guard

Když autonomous agent (Conductor, Paseo, Dubai outreach, scraper, cold-email daemon, IG analyzer) začne opravovat ten samý signál pořád dokola, zastaví se po 3 identických signálech, alertne na ntfy, a čeká na human review.

## Kdy použít

- Scraper dostává 3x po sobě stejný SMTP bounce → bail, ne retry
- LinkedIn Voyager API vrací 3x identický 429 → bail + čekej na throttle clearance
- Whisper OOM loop na stejném audio souboru → bail, skip souboru
- Cold email systém 3x identická Proofpoint rejection → bail, čekej na delisting
- Conductor 3x stejný dependency timeout → bail, eskaluj

## Instalace

Modul už je napsaný: `~/scripts/evolver-patterns/stagnation_detector.py`

Deploy na Flash:

```bash
rtk scp ~/scripts/evolver-patterns/stagnation_detector.py root@10.77.0.1:/opt/oneflow/lib/
```

Pak v každém agentu:

```python
import sys; sys.path.insert(0, "/opt/oneflow/lib")
from stagnation_detector import StagnationDetector

detector = StagnationDetector(agent="dubai-outreach", threshold=3)

signal = {"type": "smtp_bounce", "target": email, "error": smtp_code}
if detector.observe_and_should_bail(signal):
    detector.escalate(reason="SMTP loop")
    sys.exit(1)
```

## Integration examples (ready to drop)

- `~/scripts/evolver-patterns/examples/dubai_outreach_integration.py` — full batch wrapper
- `~/scripts/evolver-patterns/examples/conductor_integration.py` — main loop with strategy picker

Oba soubory mají smoke testy na konci (`python3 file.py` → pass/fail).

## Signal hash function — customize pro unusual payloads

Default hashuje `type|target|error`. Pokud tvůj agent má jiné klíče, podej custom fn:

```python
def my_hash(sig):
    return hashlib.sha256(f"{sig['campaign_id']}:{sig['step']}".encode()).hexdigest()[:12]

detector = StagnationDetector(agent="cold-email", hash_fn=my_hash)
```

## Tuning threshold

- Default 3 — dobré pro většinu agentů
- Pomalé APIs s občasnými flaps: zvedni na 5
- Kritické (finance, payments): sniž na 2 — bail rychleji

## State

Stav je persistentní v `/var/lib/oneflow/stagnation/<agent>.json` (override přes `ONEFLOW_STAGNATION_DIR`). Přežije restart. Clear: `detector.reset()` nebo `rm` file.

## Related

- Strategy mode (přepínání režimů): `/agent-strategy-mode`
- Event log (audit trail): `/evolution-event-log`
- Lifecycle ops (auto-restart + health): `/agent-lifecycle-ops`
