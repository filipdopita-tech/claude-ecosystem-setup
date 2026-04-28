---
name: session-handoff
description: "Automatic session context preservation. Auto-saves session summary at end of conversation for seamless pickup in next session. /handoff. Enhanced v2 with checkpoint schema (per-branch YAML frontmatter + structured sections)."
allowed-tools:
  - Bash
  - Read
  - Write
metadata:
  version: 2.0.0
  source: "Enhanced with gstack/checkpoint v1.0 schema (2026-04-17)"
---

# Session Handoff v2

Zachovej kontext konverzace mezi sessions. Strukturovaný checkpoint formát + flat memory fallback.

## Kdy aktivovat
- Uživatel řekne `/handoff`, `/checkpoint`, `/checkpoint save`
- Konec produktivní session (auto-suggest po 15+ turns)
- Před zavřením komplexního multi-step tasku
- Před major context compaction

## Dva režimy uložení

### Režim A: Strukturovaný checkpoint (PREFER pro GSD / git repos / komplexní tasky)

Uložit do: `~/.claude/projects/<your-project-id>/checkpoints/{YYYYMMDD-HHMMSS}-{title-slug}.md`

**Sběr stavu (vždy nejdřív):**

```bash
mkdir -p ~/.claude/projects/<your-project-id>/checkpoints
echo "=== BRANCH ==="
git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "no-git"
echo "=== STATUS ==="
git status --short 2>/dev/null | head -20
echo "=== DIFF STAT ==="
git diff --stat 2>/dev/null | tail -5
echo "=== RECENT LOG ==="
git log --oneline -10 2>/dev/null
```

**Schema souboru:**

```markdown
---
title: {3-6 slov title}
status: in-progress | blocked | completed
branch: {current branch or "no-git"}
timestamp: {ISO-8601, např. 2026-04-17T15:30:00+02:00}
session_duration_min: {N nebo "unknown"}
session_type: {gsd | ops | content | research | debug | diagnose}
files_modified:
  - path/to/file1 [MODIFIED|CREATED|DELETED]
  - path/to/file2 [MODIFIED]
next_action: {jedno-větný konkrétní další krok}
---

## Working on: {title}

### Summary
{1-3 věty high-level goal + current progress. Co se stalo, ne co bude.}

### Decisions Made
- {Rozhodnutí 1}: proč + tradeoff
- {Rozhodnutí 2}: proč + tradeoff
- {...}

### Remaining Work
1. {Konkrétní krok 1 — s file paths}
2. {Konkrétní krok 2}
3. {...}

### Notes
- Gotchas: {co mě překvapilo}
- Blocked: {co čeká na Filipův input / external}
- Tried-and-failed: {přístupy, co nefungovaly, a proč}
- Open questions: {co potřebuje rozhodnutí}
```

**Slug rules:**
- Title → lowercase, spaces → hyphens, remove special chars
- Max 40 znaků
- Example: "gstack analýza pro OneFlow" → `gstack-analyza-pro-oneflow`

### Režim B: Flat memory handoff (FALLBACK, backward-compat)

Pokud session byla jednoduchá nebo mimo git repo, uložit do:
`~/.claude/projects/<your-project-id>/memory/session_handoff.md`

**Schema (přepíše předchozí):**

```markdown
---
name: Session Handoff
description: Context z poslední session pro seamless pokračování
type: project
originSessionId: {session ID if available}
---

# Last Session: {YYYY-MM-DD} — {krátký title}

## Co bylo uděláno
- {bullet list dokončené práce}

## Rozpracováno
- {nedokončené tasky se stavem + file paths}

## Klíčová rozhodnutí
- {důležitá rozhodnutí a PROČ}

## Další kroky
- {co by mělo být dál, prioritizováno}

## Otevřené otázky
- {co potřebuje Filipův input}

## Změněné soubory
- {seznam s krátkým popisem akce}
```

## Resume flow (/handoff resume nebo /checkpoint resume)

```bash
echo "=== RECENT CHECKPOINTS ==="
find ~/.claude/projects/<your-project-id>/checkpoints -maxdepth 1 -name "*.md" -type f 2>/dev/null | xargs ls -1t 2>/dev/null | head -10
echo "=== FLAT HANDOFF ==="
ls -la ~/.claude/projects/<your-project-id>/memory/session_handoff.md 2>/dev/null
```

**Priority čtení:**
1. Pokud existuje checkpoint ze stejné branch → use it (per-branch continuity)
2. Pokud existuje checkpoint z jiné branch → zmiň "Last checkpoint was on branch X"
3. Fallback: flat `session_handoff.md`

**Po načtení prezentuj:**

```
RESUMING CHECKPOINT
════════════════════════════════════════
Title:       {title}
Branch:      {branch}
Saved:       {relative, např. "2h ago"}
Duration:    {session_duration_min} min
Status:      {status}
Next action: {next_action}
════════════════════════════════════════

### Summary
{summary}

### Remaining Work
{items}

### Notes
{notes}
```

Pak zeptat přes AskUserQuestion:
- A) Pokračuj v remaining work od položky 1
- B) Ukaž full checkpoint file
- C) Jen kontext, díky — začnu něco jiného

## List flow (/checkpoint list)

```bash
find ~/.claude/projects/<your-project-id>/checkpoints -maxdepth 1 -name "*.md" -type f 2>/dev/null | xargs ls -1t 2>/dev/null
```

Prezentuj jako tabulku:

```
CHECKPOINTS (most recent first)
════════════════════════════════════════
#  Date        Title                    Branch            Status
─  ──────────  ───────────────────────  ────────────────  ───────────
1  2026-04-17  gstack-integration       main              completed
2  2026-04-17  oneflow-diagnose-skill   main              in-progress
3  2026-04-16  cold-email-warmup        main              in-progress
════════════════════════════════════════
```

## Graphiti Reasoning Extraction (po checkpoint save)

Pro každé klíčové rozhodnutí ze sekce "Decisions Made":
1. Formuluj jako: "[CO] bylo rozhodnuto [PROČ] v kontextu [SITUACE]"
2. Zavolej `graphiti_add` s tímto obsahem (MCP graphiti-oneflow)
3. Max 3-5 rozhodnutí per session — jen skutečně klíčová (architektura, bezpečnost, strategie)

Cíl: Graphiti ví nejen CO se stalo, ale PROČ — reasoning kompounduje across sessions.

Skip pokud: session byla triviální (grep, read-only, žádná rozhodnutí).

## Pravidla

- **Append-only checkpointy:** nikdy nepřepisuj existující checkpoint soubor. Každý save = nový soubor.
- **Flat handoff je přepisovatelný** (jen nejnovější).
- **Max 30 řádků na sekci** — stručně, action-oriented.
- **File paths povinné** pro rozpracované věci (ne "ten scraper", ale `/root/scrapers/v4/pipeline.py`).
- **NIKDY credentials/secrets/API keys** v checkpointu.
- **Infer, don't interrogate:** title, decisions, remaining work → odvoď z konverzace. AskUserQuestion jen pokud title genuinely neodvoditelný.
- **Pokud se nic smysluplného nestalo, nevytvářej checkpoint** — ušetři místo.

## Auto-trigger condition

Auto-suggest `/handoff` když:
- Session má 15+ turns AND nebyl handoff v posledních 10 turns
- User říká "končím", "musím jít", "zítra pokračujeme"
- Detekce "major milestone completed" (commit, deploy, ship)

## Chain-of-skills

Po checkpoint save nabídni:
- **Completed status** → `/extract-learnings` nebo `/retro`
- **In-progress status** → nic, prostě uloženo
- **Blocked status** → `/redteam` na blokující předpoklad
