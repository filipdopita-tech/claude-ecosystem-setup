---
name: deep-post-ideas
description: "Extrahuje 5 post outlines z libovolného zdrojového materiálu (DD report, prospekt, analýza, článek). Výstup: Core Paradox, Key Quotes, Transformation Arc, Core Problems, Aspirational Statement. Dan Koe framework, [YOUR_COMPANY] brand."
---

# deep-post-ideas

## Trigger
- Uživatel zadá: "vytěž posty z", "post ideas z tohoto", "repurpose tuto analýzu", "5 postů z"
- Nebo: libovolný delší text (DD, prospekt, analýza) + žádost o content

## Co to dělá
Transformuje jakýkoli zdrojový materiál (DD report, investiční analýza, prospekt, článek, rozhovor) na 5 konkrétních post outlines pro [YOUR_COMPANY] IG/LinkedIn.

---

## Před začátkem: načti kontext
- `~/.claude/expertise/[your-service].yaml` — hlas, zakázaná slova
- `~/.claude/expertise/content-creation.yaml` — hook formulas, struktury

---

## Postup

### Krok 1: Přečti zdrojový materiál
Extrahuj klíčové myšlenky, čísla, kontraintuitivní zjištění, citace.

### Krok 2: Vygeneruj 5 outlines

**OUTLINE 1 — Core Paradox**
- Najdi napětí: co lidi věří vs. co data ukazují
- Format: "Všichni říkají X. Data říkají Y."
- Nejsilnější hook: stat_bomb nebo contrarian
- Vhodné tóny: Dramatic Prophet nebo Quiet Devastator

**OUTLINE 2 — Key Quotes / Data Points**
- 3 nejsilnější čísla nebo citace z materiálu
- Format: Quote carousel nebo "3 fakta o [téma] která nikdo neříká nahlas"
- Nejsilnější hook: pattern_interrupt nebo stat_bomb
- Vhodné tóny: Patient Observer

**OUTLINE 3 — Transformation Arc**
- Před → Po structure
- "Jak [cílová skupina] přešla od [problém] k [výsledek]"
- Musí mít konkrétní kroky (ne generické rady)
- Vhodné tóny: Patient Observer nebo Dramatic Prophet
- Format: carousel

**OUTLINE 4 — Core Problems**
- 3-5 konkrétních problémů které materiál identifikuje
- Format: "X chyb které [cílová skupina] dělá při [akci]"
- Každý problém = 1 slide
- Vhodné tóny: Dramatic Prophet

**OUTLINE 5 — Aspirational Statement**
- Jak vypadá ideální svět po vyřešení problémů
- Format: single-insight static post nebo závěrečný slide carouselu
- Max 100 slov
- Vhodné tóny: Quiet Devastator

---

### Krok 3: Pro každý outline uveď

```
## Outline [číslo]: [název]
**Hook:** [max 10 slov]
**Tón:** Patient Observer / Dramatic Prophet / Quiet Devastator
**Formát:** carousel / reel / static post
**Klíčový insight ze zdroje:** [1 věta — co konkrétně z materiálu]
**Core claim:** [1-2 věty — hlavní sdělení]
**CTA:** Comment [KEYWORD] — navrhni keyword
```

---

## Výstup

5 vyplněných outlines ve formátu výše.

Poté nabídni: "Chceš, abych rozepsal plný carousel/reel script pro outline [číslo]?"

## Řetězení
Po výběru outline → spusť `ig-content-creator` pro plnou produkci.
