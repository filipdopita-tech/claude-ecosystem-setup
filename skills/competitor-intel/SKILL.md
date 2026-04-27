---
name: competitor-intel
description: "Scrape konkurenční IG/YouTube účty, extrahuj hook patterny, best-performing angles — přímý vstup do ig-content-creator."
compatibility: playwright-mcp (již nainstalován). Reads ~/.claude/rules/oneflow-all.md.
metadata:
  allowed-hosts: []
  version: "1.0"
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - WebFetch
  - WebSearch
---

# /competitor-intel — Competitor Hook Intelligence

## Kdy použít
- Uživatel chce vědět co funguje u konkurence
- "Analyzuj IG tohoto účtu", "co dělá X dobře", "inspirace pro hook"
- Před generováním nového carousel/reelu — pro datovou inspiraci

## POSTUP

### Krok 1: Identifikuj target
Pokud Filip nedá konkrétní účet, použij default list:
```
IG (CZ investice/finance):
- @richnavujeme
- @investujeme.cz
- @daniel.mysak
- @ondrej_hartman

YouTube (CZ/SK finance):
- Finex
- INVESTMASTER
- Slúžka

International (benchmark):
- @codie_sanchez
- @thesaloness
- @alexhormozi
```

### Krok 2: Playwright scrape (max 10 postů)
Pomocí playwright-mcp:

```
1. Otevři IG profil: https://www.instagram.com/{username}/
2. Scroll down — načti 10 nejnovějších postů
3. Pro každý post zaznamenej:
   - První věta/slova (hook)
   - Typ obsahu (carousel/reel/static)
   - Přibližné engagement (likes viditelné)
   - Téma (o čem je post)
4. Pro Reely: extrahuj první větu z titulku
```

**playwright-mcp příkazy:**
```
navigate → screenshot → extract text → scroll → repeat
```

### Krok 3: Hook Pattern Extraction
Pro každý hook identifikuj angle z Contrast Formula:

| # | Angle | Detekce |
|---|-------|---------|
| 1 | Emotional | "přišel jsem", "ztratil jsem", "naučil mě" |
| 2 | Data | číslo + % + fakt |
| 3 | Contrarian | "proč X nefunguje", "zapomeňte na" |
| 4 | Story | "Byl jsem", "seděl jsem", "stalo se mi" |
| 5 | Question | otázka jako hook |
| 6 | Urgency | datum, deadline, "do X" |
| 7 | Identity | "takhle přemýšlí", "investor který..." |
| 8 | Reveal | "nikdo vám to neřekne", "tajemství" |
| 9 | Framework | "X kroků", "systém pro" |
| 10 | Mistake | "chyba č. 1", "co dělám špatně" |
| 11 | Behind scenes | "jak to vypadá zevnitř", "zákulisí" |
| 12 | Comparison | "X vs Y", "který je lepší" |
| 13 | Prediction | "za X měsíců", "co se stane když" |
| 14 | Challenge | "zkus tohle", "udělej toto" |
| 15 | Myth bust | "mýtus", "to je lež", "ve skutečnosti" |

### Krok 4: Scoring & Ranking
Seřaď extrahované hooky podle odhadovaného výkonu:

```
Hook scoring (odhad z dostupných dat):
- Engagement indicator: likes/views viditelné → HIGH/MED/LOW
- Hook angle frekvence: kolik postů používá stejný angle?
- Recency: posty z posledních 30 dní mají vyšší váhu

Output tabulka:
| Hook (první věta) | Angle | Engagement | Recency | Account |
|---|---|---|---|---|
```

### Krok 5: OneFlow Adaptation
Pro top 3-5 hookech navrhni OneFlow adaptaci:

**Vzor adaptace:**
```
Originál (@codie_sanchez): "I bought a laundromat for $50k. Here's what happened."
→ OneFlow adaptace: "Koupil jsem dluhopis za 2M Kč. Tady je co jsem zjistil."

Angle: Emotional (#1) + Reveal (#8)
Pilíř: Investment Insights
Doporučený formát: Carousel (7 slidů)
```

### Krok 6: Graphiti Storage
Po dokončení analýzy ulož winning patterny:

```python
graphiti_add("competitor hook pattern", {
  source_account: "@{username}",
  hook_text: "[první věta]",
  angle: "[č. 1-15]",
  engagement: "high|med|low",
  pillar_fit: "investment|fundraising|market|personal|ai",
  oneflow_adaptation: "[navržená adaptace]",
  date_scraped: "[datum]"
})
```

Při příštím `/ig-content-creator`: `graphiti_search("competitor hook pattern high")` → inspiruj hook generaci

### Krok 7: Output formát

```
## Competitor Intel Report — @{username} — [datum]

### Top Hooks (výběr 5)
1. "[hook text]" — Angle: Data (#2) — Engagement: HIGH
2. "[hook text]" — Angle: Story (#4) — Engagement: HIGH
...

### Pattern Summary
Nejčastější angles: Data (3x), Contrarian (2x), Story (2x)
Nejméně používané: Urgency, Challenge → PŘÍLEŽITOST pro OneFlow

### OneFlow Adaptace (ready-to-use)
1. "[adaptovaný hook]" → formát: carousel → pilíř: investment
2. "[adaptovaný hook]" → formát: reel → pilíř: personal
3. "[adaptovaný hook]" → formát: static → pilíř: market

### Gaps (co konkurence nedělá)
- [angle/téma které chybí u konkurence = příležitost pro OneFlow]
```

## Automatické řetězení
Po dokončení: "Chceš rovnou vygenerovat carousel z top adaptace? → `/ig-content-creator`"

## Common Mistakes
1. **Nepoužívej scraping pro přístup k soukromým účtům** — pouze veřejné profily
2. **Nerespektuj jen likes** — save rate je důležitější, ale není viditelná; proxy: carousel > static engagement
3. **Neskopíruj hook doslova** — vždy adaptuj na OneFlow brand, CZ kontext, investiční niche
