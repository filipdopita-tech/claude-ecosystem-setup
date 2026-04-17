---
name: agent-stagnation-guard
description: Drop-in stagnation detection for any autonomous agent. Prevents repair loops (SMTP bounce loops, API 429 spirals, dependency timeouts). Bails + escalates after N identical signals. Auto-notifies via push alert.
origin: reusable pattern — dependency-free Python module (~80 řádků)
---

# Agent Stagnation Guard

Když autonomous agent (scraper, email daemon, outbound pipeline, media analyzer) začne opravovat ten samý signál pořád dokola, zastaví se po N identických signálech, alertne, a čeká na human review.

## Kdy použít

- Scraper dostává 3x po sobě stejný SMTP bounce → bail, ne retry
- API vrací 3x identický 429 → bail + čekej na throttle clearance
- Whisper/ML OOM loop na stejném audio souboru → bail, skip souboru
- Email systém 3x identická rejection od stejného gatewaye → bail, čekej na delisting
- Orchestrator 3x stejný dependency timeout → bail, eskaluj

## Instalace

Modul: `<YOUR_TOOLS_DIR>/stagnation_detector.py` (dependency-free Python, ~80 řádků)

Deploy:

```bash
scp stagnation_detector.py <YOUR_USER>@<YOUR_VPS>:/opt/<company>/lib/
```

Pak v každém agentu:

```python
import sys; sys.path.insert(0, "/opt/<company>/lib")
from stagnation_detector import StagnationDetector

detector = StagnationDetector(agent="<agent-name>", threshold=3)

signal = {"type": "smtp_bounce", "target": email, "error": smtp_code}
if detector.observe_and_should_bail(signal):
    detector.escalate(reason="SMTP loop")
    sys.exit(1)
```

## Reference API

```python
class StagnationDetector:
    def __init__(self, agent: str, threshold: int = 3, hash_fn=None, state_dir="/var/lib/<company>/stagnation/"):
        ...

    def observe_and_should_bail(self, signal: dict) -> bool:
        """Observe signal, return True if N identical signals in a row."""
        ...

    def escalate(self, reason: str, **ctx):
        """Send push alert + log + mark state."""
        ...

    def reset(self):
        """Clear state (after human review)."""
        ...
```

## Signal hash function — customize pro unusual payloads

Default hashuje `type|target|error`. Pokud tvůj agent má jiné klíče, podej custom fn:

```python
import hashlib

def my_hash(sig):
    return hashlib.sha256(f"{sig['campaign_id']}:{sig['step']}".encode()).hexdigest()[:12]

detector = StagnationDetector(agent="<agent>", hash_fn=my_hash)
```

## Tuning threshold

- Default 3 — dobré pro většinu agentů
- Pomalé APIs s občasnými flaps: zvedni na 5
- Kritické (finance, payments): sniž na 2 — bail rychleji

## State

Stav je persistentní v `/var/lib/<company>/stagnation/<agent>.json` (override přes `<COMPANY>_STAGNATION_DIR` env var). Přežije restart. Clear: `detector.reset()` nebo `rm` state soubor.

## Related

- Strategy mode (přepínání režimů): `/agent-strategy-mode`
- Event log (audit trail): `/evolution-event-log`
- Lifecycle ops (auto-restart + health): `/agent-lifecycle-ops`
