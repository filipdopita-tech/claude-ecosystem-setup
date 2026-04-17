---
name: evolution-event-log
description: Append-only JSONL audit trail for autonomous agent decisions. Every strategy switch, signal, bail-out, and human override becomes a structured, grep-able event. Optional temporal KG sink.
origin: reusable pattern — dependency-free Python module (~200 řádků)
---

# Evolution Event Log

Když chceš vědět **proč** agent udělal rozhodnutí ve 3:17 ráno — a do pár sekund to najít. Každé významné rozhodnutí agenta (strategy switch, signal observation, bail-out, human override) se stane strukturovaným JSONL záznamem.

## Proč

- **Debug time**: místo scrollování logu grepuješ JSONL. `jq 'select(.type=="bail_out")'` a máš všechny bailouty.
- **Compliance**: regulatory audit vyžaduje append-only trail. Tohle to je.
- **KG feed**: každý event jde volitelně do temporal knowledge graph → temporal queries ("co dělal agent X v den Y").
- **Span bookends**: automatické start/end + duration_ms pro batche, tasky, API volání.

## Kdy použít

Integruj do každého agenta, který už má nějaký log output. Nahrazuje nestrukturované `print()` / `logger.info()` ve **chvílích rozhodnutí** (ne každém řádku).

Dobří kandidáti:
- Orchestrator daemon — každý task pick, task result, strategy switch
- Outbound pipeline — každý send attempt, bounce, throttle, batch summary
- Scraper — každý domain fetch, enrichment result, rate-limit hit
- Email daemon — každý send, unsubscribe, bounce, warmup state change
- Media analyzer — každý post fetch, transcript, creator added to pool

## Instalace

Modul: `<YOUR_TOOLS_DIR>/evolution_event.py` (vlastní ~200 řádků Python, viz reference níže)

```bash
scp evolution_event.py <YOUR_USER>@<YOUR_VPS>:/opt/<company>/lib/
```

Pak v agentu:

```python
import sys; sys.path.insert(0, "/opt/<company>/lib")
from evolution_event import EventLog

log = EventLog(agent="orchestrator")
log.strategy_switch("balanced", "harden", reason="post_deploy")

with log.span("task_batch", size=50):
    for task in tasks:
        # ... work ...
        log.signal_observed(signal={"type": "success"}, action="applied")
```

## Output

Soubor: `/var/log/<company>/events/<agent>.jsonl` (override: `<COMPANY>_EVENTS_DIR` env var)

Každý řádek = validní JSON s: `id`, `ts` (UTC ISO8601 s ms), `agent`, `host`, `type`, `span` (nullable) + user fields.

## Query recipes

```bash
# Všechny bailouty posledních 24h
jq 'select(.type=="bail_out" and .ts > "2026-04-15")' /var/log/<company>/events/*.jsonl

# Průměrná doba batche
jq 'select(.type | endswith(".span_end")) | .duration_ms' /var/log/<company>/events/orchestrator.jsonl | \
    awk '{s+=$1;n++} END {print s/n}'

# Strategy timeline
jq -r 'select(.type=="strategy_switch") | "\(.ts) \(.agent) \(.from_state)→\(.to_state): \(.reason)"' \
    /var/log/<company>/events/*.jsonl
```

## Temporal KG sink (volitelný)

Pokud chceš každý event zároveň do knowledge graph (např. Graphiti):

```python
from kg_client import add_node  # tvůj existující wrapper

def to_kg(event):
    add_node(
        type="EvolutionEvent",
        id=event["id"],
        agent=event["agent"],
        event_type=event["type"],
        timestamp=event["ts"],
        properties=event,
    )

log = EventLog(agent="orchestrator", kg_sink=to_kg)
```

Sink failure nikdy nezastaví agenta — disk write je primární, graph je secondary.

## Rotace

`logrotate` drop-in:

```
/var/log/<company>/events/*.jsonl {
    daily
    rotate 30
    compress
    missingok
    notifempty
    copytruncate
}
```

Nebo Fluent Bit → S3/GCS pro long-term.

## Reference implementace

Python modul `evolution_event.py` obsahuje:

- `EventLog(agent, host=None, kg_sink=None)` — konstruktor
- `log.log(type, **fields)` — generic event
- `log.strategy_switch(from_, to, reason=...)` — strategy change
- `log.signal_observed(signal, action)` — repair/adapt signal
- `log.bail_out(reason, **ctx)` — stagnation bail
- `log.human_override(decision, **ctx)` — human-in-loop
- `log.span(name, **fields)` — context manager s auto `{name}.span_start` + `{name}.span_end` + `duration_ms`

Každé volání append-only zapíše řádek do JSONL, volitelně zároveň pošle na KG sink.

## Related

- Strategy presets: `/agent-strategy-mode`
- Stagnation detection: `/agent-stagnation-guard`
- Lifecycle ops: `/agent-lifecycle-ops`
