---
name: memory-decay
description: "Mercury-style evidence-scored memory lifecycle (cosmicstack-labs/mercury-agent eval, 2026-05-07). Multi-axis scoring (confidence/importance/durability/scope/evidence_kind/evidence_count) + time-based decay (active+inferred 21d, active+direct 42d, durable+inferred 120d -0.15) + auto-promotion (active + evidence_count>=3 + direct/manual → durable). Doplňuje /memory-audit (binary 30/60d → multi-axis decay). Trigger: /memory-decay, 'decay memory', 'evidence scoring memory', 'pruni durable entries', 'promote memory active to durable'."
allowed-tools:
  - Bash
  - Read
  - Grep
---

# /memory-decay

Mercury-style memory lifecycle audit + apply. Augments `/memory-audit` (binary 30/60d) with multi-axis evidence scoring + time-based decay + auto-promotion.

## Pattern source

Adapted from [`cosmicstack-labs/mercury-agent`](https://github.com/cosmicstack-labs/mercury-agent) `src/memory/second-brain-db.ts` (MIT). Mercury's SQLite schema treats memories as rows with `confidence`/`importance`/`durability`/`evidence_count`/`evidence_kind`/`scope` fields. We apply the same scoring to Filipova file-based memory (`~/.claude/projects/-Users-filipdopita/memory/*.md`) via optional frontmatter fields with backward-compat defaults inferred from `type:`.

## Scoring fields (frontmatter)

```yaml
---
name: ...
description: ...
type: project|feedback|user|reference
# Mercury-style scoring (all optional, defaults inferred from type:)
scope: active|durable                      # active = volatile, durable = long-term
evidence_kind: direct|inferred|manual      # direct = Filip said it; inferred = LLM derived; manual = behavioral rule
confidence: 0.0-1.0                         # default 0.7
importance: 0.0-1.0                         # default 0.5 (varies by type)
durability: 0.0-1.0                         # default 0.5 (varies by type)
evidence_count: 1+                          # incremented when same fact reaffirmed
last_verified: YYYY-MM-DD                  # existing convention from /memory-audit
---
```

## Default inference from `type:`

| type | scope | evidence_kind | importance | durability |
|---|---|---|---|---|
| user | durable | direct | 0.9 | 0.95 |
| feedback | durable | manual | 0.95 | 0.95 |
| project | active | direct | 0.6 | 0.5 |
| reference | durable | direct | 0.7 | 0.8 |
| (missing) | active | inferred | 0.5 | 0.5 |

Tj. existující entries fungují bez migrace — defaults aplikují Mercury rules na základě `type:` field.

## Decay rules (per Mercury)

| Scope | Evidence kind | Trigger | Action |
|---|---|---|---|
| active | inferred | age > 21d | ARCHIVE (move to `_archive/`) |
| active | direct | age > 42d | ARCHIVE |
| durable | inferred | age > 120d | DECAY: `confidence -= 0.15` |
| durable | * | confidence < 0.3 + age > 120d | ARCHIVE |
| any | manual | * | KEEP (behavioral rule, no auto-expire) |

## Promotion rule

`active` → `durable` when:
- `evidence_count >= 3` AND
- `evidence_kind in (direct, manual)`

Tj. fakt potvrzený 3× direct nebo manual = upgrade na durable scope (přežije 21d/42d archive).

## Použití

```bash
# Dry-run report (default — nezasahuje)
python3 ~/.claude/scripts/memory-decay.py

# JSON output (pro agenty)
python3 ~/.claude/scripts/memory-decay.py --json

# Apply archive + decay actions (vytvoří .bak files)
python3 ~/.claude/scripts/memory-decay.py --apply

# Apply promotion (active → durable)
python3 ~/.claude/scripts/memory-decay.py --promote

# Backfill scoring fields do existing entries (one-time migration)
python3 ~/.claude/scripts/memory-decay.py --backfill
```

## Workflow

### Týdenní rutina (Sunday s ai-radar)
1. `/memory-decay` → zobrazí report
2. Pokud archive_candidates > 0: zhlédnout list, případně `--apply`
3. Pokud promotion_candidates > 0: `--promote`
4. Update `evidence_count` ručně když Filip reaffirmuje fakt 3× v různých sessions

### Po major eventu (project completion, infrastructure change)
1. Spusť `/memory-decay --json` → identifikuj archive candidates
2. Project completed → zvyš `evidence_count` na 1 (deactivate) nebo archivuj přímo
3. New durable fact established → manually set `scope: durable` + `evidence_count: 3`

### Backfill (one-time migration)
```bash
python3 ~/.claude/scripts/memory-decay.py --backfill
# Vytvoří .bak.backfill.YYYYMMDD pro každý změněný soubor
# Přidá scope/evidence_kind/confidence/importance/durability/evidence_count
# Jen pokud chybí — nepřepisuje existující hodnoty
```

## Vztah k `/memory-audit`

| Aspekt | `/memory-audit` (existing) | `/memory-decay` (Mercury-style) |
|---|---|---|
| Granularita | Binary (stale/archive) | Multi-axis (scope × kind × confidence × age) |
| Threshold | 30d / 60d days_modified | 21d/42d/120d per scope+kind combo |
| Decay | Hard archive cutoff | Soft confidence decay PŘED archive |
| Promotion | n/a | active → durable po 3× evidence |
| Apply | Manual decision per entry | `--apply` batch (s .bak safety) |
| Coexistence | Run both — `/memory-audit` flags missing frontmatter, `/memory-decay` applies decay rules |

## Cost

0 Kč — pure local Python, žádné API calls. Standalone (žádné deps mimo Python 3.8+).

## Source

Mercury cosmicstack-labs evaluation: `~/.claude/projects/-Users-filipdopita/memory/reference_mercury_agent_eval_2026_05_07.md`.
Mirror: `~/Desktop/Codex/external-mirrors/mercury-agent-eval/mercury-agent/`.

## Reference frontmatter check (sanity)

```bash
# Najdi entries s explicit Mercury scoring
grep -l "^scope:" ~/.claude/projects/-Users-filipdopita/memory/*.md

# Najdi durable entries s nízkou confidence (kandidáty na re-validation)
python3 ~/.claude/scripts/memory-decay.py --json | jq '.decay_list[] | select(.scoring.confidence < 0.5)'
```
