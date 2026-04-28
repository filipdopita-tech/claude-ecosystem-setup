---
name: evolution-event-log
description: Append-only JSONL audit trail for autonomous agent decisions. Every strategy switch, signal, bail-out, and human override becomes a structured, grep-able event. Optional Graphiti sink for temporal KG ingestion.
origin: pattern extracted from EvoMap/evolver (GEP "EvolutionEvent") — Python module at ~/scripts/evolver-patterns/evolution_event.py
allowed-tools:
  - Bash
  - Read
---

# Evolution Event Log

Když chceš vědět **proč** agent udělal rozhodnutí ve 3:17 ráno — a do pár sekund to najít. Každé významné rozhodnutí agenta (strategy switch, signal observation, bail-out, human override) se stane strukturovaným JSONL záznamem.

## Proč

- **Debug time**: místo scrollování logu grepuješ JSONL. `jq 'select(.type=="bail_out")'` a máš všechny bailouty.
- **Compliance**: CNB/AML audit vyžaduje append-only trail. Tohle to je.
- **Graphiti feed**: každý event jde volitelně do Graphiti → temporal queries ("co dělal Conductor v den X").
- **Span bookends**: automatické start/end + duration_ms pro batche, tasky, API volání.

## Kdy použít

Integruj do každého agenta, který už má nějaký log output. Nahrazuje nestrukturované `print()` / `logger.info()` ve **chvílích rozhodnutí** (ne každém řádku).

Dobří kandidáti:
- Conductor — každý task pick, task result, strategy switch
- Dubai outreach — každý send attempt, bounce, throttle, batch summary
- Scraper — každý domain fetch, enrichment result, rate-limit hit
- Cold email daemon — každý send, unsubscribe, bounce, warmup state change
- IG Analyzer — každý post fetch, Whisper transcript, creator added to pool

## Instalace

Modul: `~/scripts/evolver-patterns/evolution_event.py`

```bash
rtk scp ~/scripts/evolver-patterns/evolution_event.py root@<vps-private-ip>:/opt/oneflow/lib/
```

Pak v agentu:

```python
import sys; sys.path.insert(0, "/opt/oneflow/lib")
from evolution_event import EventLog

log = EventLog(agent="conductor")
log.strategy_switch("balanced", "harden", reason="post_deploy")

with log.span("task_batch", size=50):
    for task in tasks:
        # ... work ...
        log.signal_observed(signal={"type": "success"}, action="applied")
```

## Output

Soubor: `/var/log/oneflow/events/<agent>.jsonl` (override: `ONEFLOW_EVENTS_DIR`)

Každý řádek = validní JSON s: `id`, `ts` (UTC ISO8601 s ms), `agent`, `host`, `type`, `span` (nullable) + user fields.

## Query recipes

```bash
# Všechny bailouty posledních 24h
jq 'select(.type=="bail_out" and .ts > "2026-04-15")' /var/log/oneflow/events/*.jsonl

# Průměrná doba batche
jq 'select(.type | endswith(".span_end")) | .duration_ms' /var/log/oneflow/events/conductor.jsonl | \
    awk '{s+=$1;n++} END {print s/n}'

# Strategy timeline
jq -r 'select(.type=="strategy_switch") | "\(.ts) \(.agent) \(.from_state)→\(.to_state): \(.reason)"' \
    /var/log/oneflow/events/*.jsonl
```

## Graphiti sink (volitelný)

Pokud chceš každý event zároveň do Graphiti KG:

```python
from graphiti_client import add_node  # tvůj existující wrapper

def to_graphiti(event):
    add_node(
        type="EvolutionEvent",
        id=event["id"],
        agent=event["agent"],
        event_type=event["type"],
        timestamp=event["ts"],
        properties=event,
    )

log = EventLog(agent="conductor", graphiti_sink=to_graphiti)
```

Sink failure nikdy nezastaví agenta — disk write je primární, graph je secondary.

## Rotace

`logrotate` drop-in:

```
/var/log/oneflow/events/*.jsonl {
    daily
    rotate 30
    compress
    missingok
    notifempty
    copytruncate
}
```

Nebo Fluent Bit → S3/GCS pro long-term. Filipův stack má `fluent-bit` nainstalovaný.

## Related

- Strategy presets: `/agent-strategy-mode`
- Stagnation detection: `/agent-stagnation-guard`
- Lifecycle ops: `/agent-lifecycle-ops`
