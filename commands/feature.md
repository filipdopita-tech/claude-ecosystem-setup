---
name: feature
description: Generuje strukturovaný spec dokument z popisu featury (Jaymin West Pit of Success pattern). Output jde do .claude/specs/
---

# /feature — Spec Generator

Vezmi vstup uživatele jako "intent" a vygeneruj strukturovaný spec dokument, který pak bude použit příkazem `/implement` jako high-quality kontext pro implementačního agenta.

## Kontext

Tento příkaz je součástí Jaymin West "Pit of Success" patternu. Oddělení planning a implementation fáze dramaticky zvyšuje kvalitu výstupů, protože implementation agent dostává strukturovaný spec místo vágního promptu.

**Pravidlo:** Kvalita output tokenů je přímo úměrná kvalitě input tokenů.

## Workflow

1. **Analyzuj intent uživatele** — co přesně chce postavit, jaká je scope
2. **Prozkoumej existující codebase** — Grep/Glob relevantní soubory, pochopil kontext
3. **Vytvoř spec soubor** v `~/.claude/specs/SPEC-YYYYMMDD-HHMM-slug.md`
4. **Ukaž uživateli výsledek** a zeptej se, jestli má nějaké doplňky
5. **Navrhni další krok:** `/implement ~/.claude/specs/SPEC-xxx.md`

## Spec template

```markdown
# SPEC: {krátký název}

**Created:** {ISO timestamp}
**Intent source:** {uživatelův původní popis v uvozovkách}
**Status:** DRAFT

## Problem Statement
{1-3 věty: jaký problém řešíme, proč je důležitý}

## Desired Outcome
{1-3 věty: jak vypadá hotový stav, měřitelné kritérium úspěchu}

## Non-Goals
{explicitně co NEbudeme dělat — stejně důležité jako goals}
- {non-goal 1}
- {non-goal 2}

## Relevant Files
{soubory, které bude implementace číst/měnit/vytvářet}
- `path/to/file.py` — {role: read-only context / edit / create}
- `path/to/other.md` — {role}

## Step-by-Step Tasks
{ordered by dependency — builder postupuje shora dolů}

1. **{Task name}** — {konkrétní akce, které soubory, jaký výstup}
2. **{Task name}** — {...}
3. **{Task name}** — {...}

## Risks & Mitigations
- **Risk:** {co se může pokazit}
  **Mitigation:** {jak to zvládneme}

## Validation Strategy
{jak ověříme, že implementace funguje}

**Commands to run:**
```bash
# {popis co kontrolujeme}
{command}
```

**Manual checks:**
- {co uživatel ručně ověří}

## Commit Message Format
```
{type}: {description}

{body}
```

## References
- Related specs: {pokud existují}
- Related issues/tasks: {GHL task ID, beads ID, GitHub issue}
- External docs: {URLs}
```

## Pravidla

- **Nikdy neimplementuj během /feature.** Jen generuj spec. Implementaci dělá /implement.
- **Spec musí být samostatný.** Implementation agent ho dostane bez context tvého brainstormingu.
- **Non-goals jsou POVINNÉ.** Bez nich agent často přidá features navíc.
- **Validation commands musí být exekutovatelné.** Ne "run tests" ale `pytest tests/test_feature.py -v`.
- **Step-by-step ordering MUSÍ být dependency order.** Task N nesmí záviset na tasku N+1.

## Edge cases

- **Pokud je intent jasný a jednoduchý** (např. "přidej logging do function X"): stále vytvoř spec, ale stručně — 1-2 tasky jsou OK.
- **Pokud je intent příliš vágní**: zeptej se uživatele na clarification PŘED vytvořením specu. Lepší 2 minuty diskuze než 30 minut špatného kódu.
- **Pokud existuje podobný spec**: reference ho ve spec souboru pod References.

## Po dokončení

Vypiš:
1. Cestu k vytvořenému spec souboru
2. 3-5 bullet points summary (co spec obsahuje)
3. Návrh: "Spusť `/implement ~/.claude/specs/{filename}` pro implementaci."
