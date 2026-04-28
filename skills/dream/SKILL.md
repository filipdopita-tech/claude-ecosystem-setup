---
name: dream
description: Memory konsolidace podle Anthropic AutoDream specifikace (ccVersion 2.1.98). Multi-fázová reflexe nad memory soubory — sloučí nové signály, odstraní stale, zkrátí index. Spouštěj /dream (full), /dream prune (lehký), /dream nightly (cron), /dream status (info). Auto-trigger přes ~/.claude/scripts/auto-dream.sh (3 gates).
allowed-tools:
  - Bash
  - Grep
  - Read
---

# Dream — Memory Consolidation

Reflektivní průchod nad memory soubory. Syntetizuj naučené do trvalých, organizovaných pamětí, aby budoucí session mohla rychle orientovat.

**Konvence:**
- Memory dir: `~/.claude/projects/<your-project-id>/memory/`
- Index: `MEMORY.md` (max 200 řádků, max ~25KB, entries ≤150 znaků)
- Transcripts: `~/.claude/projects/<your-project-id>/*.jsonl` (velké, grep narrow)
- Observations: `~/.claude/homunculus/observations.jsonl`
- State: `~/.claude/homunculus/.last_dream_run`, `.last_dream_sessions`

**Safety rails (NIKDY neporušit):**
- Nikdy needituj v místě — memory soubory jsou immutable. Sloučení = smaž staré, napiš nový.
- Nikdy nesmaž `feedback_*.md` bez ověření, že fakt je opravdu contradicted codebasem.
- Nikdy nesmaž credential soubory (`*_api.md`, `credential_*`, `*_access.md`).
- Nikdy nemodifikuj `CLAUDE.md`, `rules/`, `hooks/`, `settings.json`.
- YAML frontmatter (`name`, `description`, `type`, `created`) zachovej při slučování — `created` vezmi z nejstaršího zdroje.

---

## Routing (podle argumentu)

| Argument | Mód | Sekce |
|---|---|---|
| žádný / `consolidate` | Full 4-phase | [Consolidate](#consolidate) |
| `prune` | Jen pruning pass | [Prune](#prune) |
| `nightly` | Schedule cron | [Nightly](#nightly) |
| `status` | Report stavu | [Status](#status) |

Pokud argument neodpovídá, default = `consolidate`.

---

## Consolidate

### Phase 1 — Orient
- `ls ~/.claude/projects/<your-project-id>/memory/` — co existuje
- Read `MEMORY.md` — aktuální index
- Skim existující topic files (ne všechny, vzorky podle kategorií v indexu) abys rozšířil místo duplikoval
- Zkontroluj `~/.claude/homunculus/observations.jsonl` posledních ~200 řádků

### Phase 2 — Gather recent signal
Zdroje v prioritě:
1. **Observations** — `tail -200 ~/.claude/homunculus/observations.jsonl` — append-only stream, primární zdroj
2. **Existing memories that drifted** — fakta contradicted codebasem/aktuálním stavem (ssh, files, git log)
3. **Transcript grep** (jen cílený, ne full read):
   ```bash
   grep -l "<narrow term>" ~/.claude/projects/<your-project-id>/*.jsonl | tail -5
   ```
   Grep za konkrétními pojmy co už tušíš, že jsou důležité. Nečti celé.
4. **Session handoff** — `~/.claude/projects/<your-project-id>/memory/session_handoff.md` pokud existuje

Nečti transcripts exhaustivně. Hledej jen co už tušíš, že matters.

### Phase 3 — Consolidate
Pro každý fact worth remembering napiš nebo updatuj soubor v memory dir.

**Pravidla:**
- Merge nový signál do existujícího topic souboru místo vytváření near-duplikátů
- Relativní data → absolutní (`včera` → `2026-04-11`, `příští týden` → konkrétní datum)
- Smaž contradicted fakta — pokud dnešní investigace vyvrátila starou memory, oprav u zdroje
- Typy: `user`, `feedback`, `project`, `reference` (podle auto-memory sekce v CLAUDE.md)
- Feedback memories: struktura `rule` + `**Why:**` + `**How to apply:**`

**Immutability:** sloučení = smaž staré soubory, napiš jeden nový. Zachovej nejstarší `created` z frontmatteru.

### Phase 4 — Prune & index
Aktualizuj `MEMORY.md`:
- Max 200 řádků AND max ~25KB
- Každá entry: `- [Title](file.md) — one-line hook` (≤150 znaků)
- Odstraň pointers na stale/wrong/superseded memories
- Demote verbose entries (>200 chars → zkrať, detail patří do topic souboru)
- Přidej pointers na newly important memories
- Vyřeš kontradikce — pokud dva soubory disagree, oprav špatný

### Výstup
Napiš `~/.claude/homunculus/.dream_result.json`:
```json
{"merged": N, "pruned": N, "added": N, "deleted": N, "ts": "ISO8601", "mode": "consolidate"}
```

Aktualizuj gate markery:
```bash
date +%s > ~/.claude/homunculus/.last_dream_run
wc -l < ~/.claude/homunculus/observations.jsonl | tr -d ' ' > ~/.claude/homunculus/.last_dream_sessions
```

Vrať krátké shrnutí: kolik sloučeno/přidáno/prunováno. Pokud nic nezměnilo, řekni to.

---

## Prune

Lehčí pass — jen mazání stale a collapse duplikátů. Bez gather signal fáze.

1. `find ~/.claude/projects/<your-project-id>/memory/ -name '*.md'` — enumeruj
2. Pro každý soubor rozhodni:
   - **Stale/invalidated** — contradicted codebasem/aktuálním stavem → smaž
   - **Duplicate** — jiná memory už pokrývá → smaž redundantní. Pokud jeden richer file nahradí cluster, smaž cluster a napiš jeden nový (zachovej nejstarší `created`)
   - **Still good** — nech být

**Conservative defaults:**
- `feedback_*.md` + credential files: nikdy bez tvrdého důkazu contradicted
- Session handoff: nech být (auto-přepisuje se)

Výstup: `{"deleted": N, "combined": N, "kept": N, "ts": "ISO8601", "mode": "prune"}` do `.dream_result.json`.

---

## Nightly

Nastav recurring cron přes CronCreate tool (remote trigger, durable).

**Step 1 — Dedup:** Call CronList, najdi task s prompt `"/dream consolidate"`. Pokud existuje, CronDelete nejdřív.

**Step 2 — Schedule:**
```
CronCreate:
  cron: "0 3 * * *"
  prompt: "/dream consolidate"
  recurring: true
  durable: true
```

**Step 3 — Potvrď:**
- /dream poběží denně v ~03:00 local, konsoliduje memory
- Schedule přežije napříč sessiony (`.claude/scheduled_tasks.json`)
- Recurring auto-expire po 90 dnech → obnov `/dream nightly`
- Cancel přes CronDelete + job ID

**Step 4 — Run immediate consolidation:** spusť [Consolidate](#consolidate) teď.

---

## Status

Report aktuálního stavu bez změn.

```bash
MEMORY_DIR=~/.claude/projects/<your-project-id>/memory
echo "Memory files: $(ls $MEMORY_DIR/*.md 2>/dev/null | wc -l)"
echo "MEMORY.md lines: $(wc -l < $MEMORY_DIR/MEMORY.md)"
echo "MEMORY.md size: $(wc -c < $MEMORY_DIR/MEMORY.md) bytes"
echo "Observations: $(wc -l < ~/.claude/homunculus/observations.jsonl)"
echo "Last dream run: $(date -r $(cat ~/.claude/homunculus/.last_dream_run 2>/dev/null || echo 0))"
cat ~/.claude/homunculus/.dream_result.json 2>/dev/null
```

Vrať tabulku: soubory, velikost indexu, kdy poběžel poslední dream, co naposledy udělal, kolik dnů do další auto-konsolidace.

---

## Auto-trigger integration

Skript `~/.claude/scripts/auto-dream.sh` se spouští při session startu (přes `session-context-loader.sh`). 3 gates:
1. **Time:** ≥24h od posledního runu
2. **Sessions:** ≥5 nových (nebo první run)
3. **Lock:** exclusive (`.dream.lock`, stale po 10 min)

Pokud gates pass, skript injektne prompt do session context loaderu. Když uvidíš v context loaderu message `[AutoDream] Memory konsolidace je připravena`, spusť po dokončení aktivního tasku:
```
Skill: dream (run_in_background: true)
```

---

## Banned

- Read full transcripts (JSONL jsou velké, vždy grep narrow)
- Vytvářet near-duplikáty místo mergování
- Mazat `feedback_*` nebo credential soubory bez tvrdého důkazu
- Modifikovat `MEMORY.md` content inline — je to index, ne dump
- Vymýšlet dates — když nevíš datum, použij dnešek z `currentDate` contextu
