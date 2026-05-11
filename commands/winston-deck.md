---
name: winston-deck
description: "Patrick Winston MIT presentation framework aplikovaný na OneFlow prezentace. 6 modes: full-deck (1-6 sekvenčně), opening (1), audit (2), star (3), structure (4), props (5), closing (6). CZ output, OneFlow brand, integrace s pitch-deck-factory.md. Trigger: '/winston', 'winston framework', 'patrick winston', 'MIT presentation', 'připrav prezentaci', 'pitch deck full', 'audit slidů', 'opening pro pitch', 'closing pro talk'."
metadata:
  version: "1.0"
  source: "IG @artificialintelligence.co DXjSbsVCSUv (2026-04-25), originál God of Prompt na X"
  knowledge-file: "~/.claude/knowledge/winston-presentation-framework.md"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
---

# /winston-deck — Patrick Winston Presentation Framework

## Kdy použít

- **Pitch deck pro investora** (OneFlow fundraise, Patricny, ASR partneři)
- **DD report prezentace** klientovi (executive summary)
- **Klientská nabídka** (ASR retainer, custom DD)
- **Konference talk** (CZ fintech eventy, retailový investor day)
- **Webinář** (lead magnet, podcast lead-in)
- **Slide audit** existujícího decku (10 Winston Slide Crimes)
- **Opening / closing** rescue pro stávající prezentaci

## NEPOUŽÍVAT pro

- Single IG carousel (use `ig-content-creator`)
- LinkedIn post (use `content-creator`)
- Email / cold outreach (use `cold-email`)
- Pure content struktura bez delivery (use `pitch-deck-factory.md` knowledge)

## Argumenty

```
/winston [mode] [topic] [audience]

mode:
  full     — všech 6 promptů sekvenčně (kompletní deck)
  opening  — Prompt 1 (start + 60s)
  audit    — Prompt 2 (slide crimes audit existujícího decku)
  star     — Prompt 3 (memorability — Star framework)
  structure — Prompt 4 (VSNC — Vision/Work/Contributions)
  props    — Prompt 5 (props + storytelling pro complex idea)
  closing  — Prompt 6 (contributions slide + 60s ending)

topic:    krátký popis (např. "OneFlow fundraise 5M EUR")
audience: kdo (např. "10M+ HNW investor, finance background")
```

Pokud uživatel zadá jen `/winston` bez argumentů → ptej se na mode + topic + audience interaktivně.

---

## POSTUP

### Krok 0: Načti knowledge
Vždy před exekucí: `cat ~/.claude/knowledge/winston-presentation-framework.md` pro full kontext (6 prompts verbatim + CZ adaptace).

### Krok 1: Identifikuj mode
- Pokud uživatel řekl explicitně (`/winston full`, `/winston audit`) → use it
- Pokud popisuje úkol ("připrav pitch pro investora") → mapuj:
  - "celá prezentace" / "deck" / "full" → **full**
  - "úvod" / "opening" / "prvních 60s" / "začátek" → **opening**
  - "audituj" / "kontrola" / "co je špatně" → **audit**
  - "memorable" / "remember" / "zapamatovat" → **star**
  - "struktura" / "persuasion" / "přesvědčit" → **structure**
  - "vysvětlit složité" / "props" / "demo" → **props**
  - "závěr" / "ending" / "konec" / "Q&A" → **closing**

### Krok 2: Sběr kontextu
Vždy potřebuješ:
- **Topic** (co prezentuješ)
- **Audience** (komu)
- **Desired outcome** (co má publikum udělat / vědět / rozhodnout)

OneFlow defaults pokud Filip neřekne:
- Audience: "HNW investor, 10M+ Kč alokace, finance/business background, 30–55 let, CZ/SK"
- Brand: monochrome (#0A0A0C dark / #F2F0ED light), Inter Tight, žádné saturované barvy, žádné zlato

### Krok 3: Aplikuj prompt(y)
Pro **full** mode: postupuj 1→6 sekvenčně, výstup každého kroku použij jako vstup dalšího (kontinuita).

Pro **single** mode: aplikuj jen ten jeden prompt z knowledge file.

### Krok 4: CZ output + OneFlow brand
- Výstup VŽDY česky (i když Filip napíše prompt anglicky — defaults to CZ)
- Banned words check (viz oneflow-all.md): žádné "inovativní", "revoluční", "komplexní řešení", "synergie", "v dnešní době"
- Brand voice: přímý, sebevědomý, žádné omluvy, max 1-2 emoji
- Čísla konkrétní (47M Kč, 0 defaultů, 142 investorů — ne "značné objemy")

### Krok 5: Output formát

**Pro full mode** (1 deck = 1 výstup):
```markdown
# {Topic} — Pitch Deck (Winston Framework)

## 1. Empowerment Promise
{1 věta — co publikum bude vědět/umět na konci}

## 2. Opening Script (60s)
{přesný mluvený text první minuty}

## 3. Slide-by-slide outline
| # | Slide | Co na slide | Co říkáš | Trvání |
|---|-------|-------------|----------|--------|
| 1 | Cover | Tagline | Empowerment promise | 30s |
| 2 | Vision | Problem + approach | VSNC vize | 90s |
| ... |

## 4. Star elements (memorable jádro)
- Symbol: {…}
- Slogan: {…}
- Surprise: {…}
- Salient Idea: {…}
- Story: {…}

## 5. Slide Crimes audit (preventivně)
{10 crimes checklist + jak jsme je vyhnuli}

## 6. Closing
- Contributions slide (final, drží během Q&A)
- 60s closing script
- Call to action / salute

## Speaker notes (per slide)
{…}
```

**Pro single mode**: výstup dle prompt-specific format z knowledge file.

### Krok 6: Verify (před handoff)
- [ ] Empowerment promise konkrétní (čísla, časový rámec)
- [ ] Žádné banned words
- [ ] Žádný z 10 slide crimes
- [ ] Final slide = contributions, ne "Thank you"
- [ ] Cycling key idea 3× v různých formách
- [ ] Verbal punctuation explicit ("druhá zásadní…")

---

## Příklady

### Příklad 1: Full deck pro OneFlow fundraise

```
/winston full "OneFlow fundraise 5M EUR Series A" "EU VC fintech, 10-30M EUR check, B2B SaaS background"
```

Output: kompletní 12-slide deck s opening 60s, Star elements, VSNC structure, contributions close, speaker notes.

### Příklad 2: Audit existujícího ASR pitch decku

```
/winston audit "ASR retainer pitch — 12 slidů z minulého týdne"
```

Filip pošle screenshoty / popis slidů → Claude vrátí audit s 10 crimes checklist + per-slide fix.

### Příklad 3: Jen opening pro DD report executive summary

```
/winston opening "DD report Emitent X — A-grade verdict" "klient (potenciální investor 5M Kč alokace)"
```

Output: empowerment promise + 60s mluvený script + cuts list.

### Příklad 4: Star framework pro single myšlenku

```
/winston star "0 defaultů na 47M Kč emitovaného kapitálu" "retailový investor 200k-2M Kč alokace"
```

Output: Symbol + Slogan + Surprise + Salient Idea + Story — connected story k téhle 1 myšlence.

### Příklad 5: Closing rescue (Filip má hotový deck, jen chce silný konec)

```
/winston closing "konference talk: Jak postavit dluhopisovou emisi v ČR za 90 dní"
```

Output: contributions slide design + 60s ending script + co eliminovat.

---

## Integrace s ostatními skills

### Chain: brief → winston-deck → publish
- `/brief` — zachytí raw nápad
- `/winston-deck full` — postaví deck + speaker notes
- `/publish` — exportuje do PDF / slide tooling

### Chain: ig-content-creator → winston-deck (pro webinar lead-magnet)
- `/ig-content-creator` — vytvoří IG promo carousel
- `/winston-deck full` — vytvoří webinar deck
- Výstup: aligned messaging IG → webinar

### Chain: dd-emitent → winston-deck (pro klientskou prezentaci DD)
- `/dd-emitent` — vyrobí DD report (text + verdict A-F)
- `/winston-deck structure` — vyrobí 5-slide executive summary deck pro klienta
- VSNC mapping: Vision = "tato investice ti dá X", Proof = "tady jsou čísla", Contributions = "co obdržíš"

---

## Reference

- Knowledge: `~/.claude/knowledge/winston-presentation-framework.md` (6 prompts verbatim)
- Komplementární: `~/.claude/knowledge/pitch-deck-factory.md` (struktura content, ne speaking)
- Brand: `~/.claude/rules/oneflow-all.md` + `~/docs/oneflow-brand-manual-2026.md`
- Source: IG @artificialintelligence.co post DXjSbsVCSUv (2026-04-25)
- MIT lecture: https://learn.mit.edu/?resource=5343
