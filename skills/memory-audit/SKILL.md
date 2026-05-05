---
name: memory-audit
description: "Audit staleness memory entries v ~/.claude/projects/-Users-filipdopita/memory/. Najde entries bez last_verified, starší 30/60 dní, bez frontmatteru. Nenavrhuje mazat automaticky — Filip rozhoduje. Aktivuj: /memory-audit nebo 'audit memory', 'stale memory', 'zkontroluj paměť'."
allowed-tools:
  - Bash
  - Read
  - Grep
  - Glob
---

# /memory-audit

Memory entries mohou stárnout. Co bylo pravda před 3 měsíci (API key, server status, projekt aktivní) dnes nemusí platit. Tento skill najde kandidáty k re-verifikaci nebo archivaci.

## Co dělá

Spustí `~/.claude/scripts/memory-staleness-audit.py` a prezentuje:
- Entries bez `last_verified` timestamp
- Entries starší 30 dní (kandidáti k re-verifikaci)
- Project entries starší 60 dní (kandidáti k archivaci)
- Entries bez frontmatteru (formát fix)

## Konvence: last_verified metadata

Všechny nové memory entries by měly mít:

```yaml
---
name: Název entry
description: Krátký popis
type: project|user|feedback|reference
last_verified: 2026-04-19  # den kdy jsem naposledy ověřil že fakta platí
---
```

Když Claude načte memory entry a obsah se zdá stále platný → update `last_verified`.
Když zjistí že fakta se změnila → update obsah + `last_verified`.

## Použití

```bash
# Rychlý souhrn
python3 ~/.claude/scripts/memory-staleness-audit.py

# Full list stale entries
python3 ~/.claude/scripts/memory-staleness-audit.py --full

# JSON (pro agenty)
python3 ~/.claude/scripts/memory-staleness-audit.py --json
```

## Workflow

### Rutina (weekly)
1. `/memory-audit` → zobrazí seznam
2. Pro každý archive candidate: rozhodnout "ARCHIVE" nebo "STILL RELEVANT"
3. Pro stale: otevřít, ověřit, přidat `last_verified: YYYY-MM-DD`

### Po velkém eventu (migrace, project completion, incident)
1. Spusť `/memory-audit`
2. Prohledej entries souvisejícími s eventem
3. Archivuj completed projekty, update changed facts

## Thresholds (konfigurovatelné v scriptu)

| Threshold | Default | Co to znamená |
|---|---|---|
| STALE_THRESHOLD_DAYS | 30 | Re-verify candidate |
| ARCHIVE_THRESHOLD_DAYS | 60 | Archive candidate (pokud type=project) |

## Kdy NEarchivovat

- `type: user` entries (user profile neexpiruje)
- `type: feedback` entries (behaviorální pravidla nemají expiraci)
- `type: reference` entries (OSINT engines, API katalogy — dlouhodobé)
- Credentials entries (aktivní credentials)

Automaticky se archivují jen `type: project` po 60 dnech nepoužívání.

## Integrace

- `/status` — memory stats
- `/handoff` — před koncem session doporuč audit pokud >14 dní
- `compile-wiki` — po auditu promítni archive do Obsidian raw→wiki
