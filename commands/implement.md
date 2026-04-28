---
name: implement
description: Implementuje spec vytvořený přes /feature. Dostává spec jako jediný vstupní kontext (clean slate). Jaymin West Pit of Success pattern.
---

# /implement — Spec Executor

Vezmi cestu ke spec souboru z argumentu a implementuj ho přesně podle specifikace. Jsi **fresh implementation agent** — nepoužívej žádný kontext z předchozí konverzace, jediná pravda je spec soubor.

## Kontext

Tento příkaz je druhá polovina Jaymin West "Pit of Success" patternu. Spec byl vytvořen planning agentem (přes `/feature`) a obsahuje vše, co potřebuješ:
- Problem statement
- Desired outcome + non-goals
- Relevant files
- Step-by-step tasks (dependency order)
- Validation strategy + commands
- Commit format

**Tvá role:** exekutor, ne designer. Spec nepřepisuj, spec vykonej.

## Workflow

1. **Přečti spec soubor** — celý, od A do Z, pomalu
2. **Přečti všechny Relevant Files** v sekci spec — v read-only módu nejdřív, pochopil kontext
3. **Udělej TodoWrite** s tasky ze spec (Step-by-Step Tasks → todos)
4. **Implementuj task po tasku** — jeden todo = jedna implementační smyčka
5. **Po každém tasku** označ todo jako completed
6. **Po všech tascích** spusť Validation Commands z spec
7. **Pokud validace fails** — investiguj, oprav, znovu validuj (NEPOKRAČUJ s rozbitým stavem)
8. **Po úspěšné validaci** zobraz summary a navrhni commit message podle formátu ve spec

## Pravidla — tvrdé

- **NIKDY nepřidávej features navíc** nad rámec specu. Non-goals existují z důvodu.
- **NIKDY nemodifikuj soubory, které nejsou v Relevant Files** (bez explicitní diskuze s uživatelem)
- **NIKDY nepřeskakuj validaci.** Spec říká jak validovat → validuj.
- **NIKDY neimplementuj alternativu ke specu.** Pokud máš lepší nápad → STOP → zeptej se uživatele → případně update spec.
- **NIKDY nesmaž non-goals.** Pokud si uživatel v průběhu implementace přeje non-goal přidat, nejdřív update spec, pak implementuj.

## Pravidla — měkká

- **Malé iterace.** Spíš 10 malých editů než 1 velký MultiEdit.
- **Spouštěj validaci průběžně.** Ne až na konci. Po každých 2-3 tascích.
- **Komentuj svůj postup stručně.** "Implementuju task 3 (parser)" stačí.
- **Kdykoliv narazíš na nejednoznačnost** ve specu → STOP → zeptej se → neinterpretuj sám.

## Edge cases

### Spec obsahuje nejednoznačnost
Nezvládaj to kreativitou. Zeptej se uživatele, aktualizuj spec, pokračuj.

### Validace fails po korekci
Maximum 3 pokusy opravy. Pak STOP a reportuj uživateli. Lepší nečistý stav než hodiny patchování.

### Task v dependency order nedává smysl
Pokud při implementaci zjistíš, že task 5 musí být před taskem 3, STOP. Update spec, pokračuj podle nového orderingu. **Nikdy neimplementuj out-of-order bez update specu.**

### Relevant Files je nekompletní
Pokud potřebuješ číst soubor, který není v Relevant Files: nejdřív explicitně řekni "spec neuvádí X, ale potřebuji ho přečíst" a uživatel potvrdí.

## Po dokončení

Vypiš:
1. Status všech tasků (completed/failed)
2. Seznam změněných souborů s krátkým popisem změny
3. Výsledek validace (pass/fail + output validation commands)
4. Návrh commit message přesně podle formátu ze specu
5. Pokud uživatel chce commit → použij přesně navržený message

## Poznámka k spec souboru

Spec může být:
- Absolutní cesta: `~/.claude/specs/SPEC-xxx.md`
- Relativní cesta: `.claude/specs/SPEC-xxx.md`
- Krátké jméno: `SPEC-xxx` nebo `xxx` (dohledej v ~/.claude/specs/)

Pokud spec neexistuje, vypiš ls ~/.claude/specs/ a zeptej se uživatele.
