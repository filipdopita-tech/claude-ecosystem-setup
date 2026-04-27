# Power Prompts — Top 12 Pro OneFlow

Cherry-pick z tenfoldmarketing.com/60-claude-prompts (2026-04-25). Originál byl beginner-friendly, tohle je adaptace pro Filipa (founder, advanced user, OneFlow context).

Použití: ad-hoc reference. Když Filip potřebuje rychlý prompt na common situaci, copy-paste a customize. Žádný skill — jen library.

---

## Email & Komunikace

### P-01: Polite "No" Email
Když: investor request mimo scope, výzva k partnerství která nezapadá, prosba o čas zdarma.

```
Draft polite "no" email k [request]. Vděčný ale firm. Max 1 věta důvod.
Bez over-explaining. Sign Dopita. Česky, max 60 slov.
```

### P-02: Cold Email v Filip stylu
Pro emise leads, ASR prospects, podcastové guesty.

```
Cold email pro [jméno, role, kontext z LinkedIn/podcastu].
Pitchuju [konkrétní hodnota — ne mě, ale je]. Subject < 7 slov.
Body 3 věty: proč JE (specifická personalizace) + co nabízím + jedna otázka.
Filip Dopita styl: přímý, 0 omluv, 0 "doufám že se vám daří".
Žádné CTA tlačítka, jen otázka. Sign Dopita.
```

### P-03: 3-version Draft (cold/warm/just-right)
Když email má citlivý kontext a nejsi si jistý tone.

```
Draft 3 verze [zprávy] pro [příjemce]:
1) Příliš studená (formální, distancovaná)
2) Příliš teplá (familiar, casual)
3) Just right (Filip styl: přímý + věcný)
Identifikuj nuance — proč je verze 3 správná pro tento context.
```

### P-04: Cut 40% Without Losing Meaning
Když máš draft co cítí "moc dlouhý". Použij místo /trim pro klientské/investor materiály.

```
Cut 40% slov z [text] bez ztráty meaning. Pak řekni co jsi cut a proč.
Zkus: -filler (very, just, really), -redundant context, -hedging,
-compound sentences, -obvious transitions. Output: cut version + diff log.
```

---

## Decision Making (kdy NE /llm-council)

### P-05: Decision A vs B (sales-hidden)
Pro tooling, vendor, partnership decisions. Light variant /llm-council pro non-strategic.

```
Rozhoduji mezi [A] a [B] pro [use case].
Real pros/cons včetně toho co vendor/sales SCHOVÁVAJÍ.
Pak: kterou bys vybral pro OneFlow context (CZ B2B, founder-led, SMB klienti)?
Důvod konkrétní, ne "depends on...". Commit to one.
```

### P-06: Pre-Purchase Red Flags
Pro nový SaaS, agency hire, nákup služeb.

```
Chystám se koupit [produkt/službu] od [vendor].
3 otázky které musím položit PŘED zaplacením?
3 red flags které musím watch v jejich pitch / contractu?
Cena: známé hidden charges typu [setup fees, lock-in, overage rates]?
```

### P-07: Devil's Advocate (light /redteam)
Když /redteam je overkill, ale chceš self-check.

```
Hraj devil's advocate na [můj nápad/plán]:
- Kde to může selhat?
- Jaký nejhorší scenario během 90 dnů?
- Předpokládám že jsem overconfident.
Top 3 risk vectors, ranked by likelihood × impact.
Ne hedging, jen attack.
```

### P-08: Workarounds (kdy stuck)
Když nemůžeš přímo X, hledej all paths to similar outcome.

```
Chci [goal] ale [obstacle/constraint].
List 10 workarounds, od obvious po ridiculous.
Rank by feasibility (h/m/l) × impact (h/m/l).
Top 3 nejlepší: konkrétní first-step pro každý.
Žádné "consider hiring help" — actionable only.
```

---

## Research & Fact-Check

### P-09: Fact-Check Claim (light /verify-claim)
Pre-ship check pro DD reporty, IG carousels s konkrétními čísly o třetích stranách.

```
Fact-check tento claim: [paste verbatim].
Co je 100% true (cituj source)?
Co je misleading (kontext chybí)?
Co je flat-out wrong?
Pokud nejsi schopen verify v real-time, řekni "NEVERIFIED — nutno checkout sources X, Y".
Ne hallucinace. Ne best guess. Verify or flag.
```

### P-10: Research Topic + 2 Common Myths
Pro pre-build diagnostics, market intel pre nový pillar.

```
Research [topic/market segment].
- 5 facts které pravděpodobně neznám (citace povinná)
- 2 common myths které lidé v oboru věří (a proč jsou špatně)
- 1 contrarian view (minoritní, ale defensible)
OneFlow context: CZ B2B, fundraising, dluhopisy 1M-5M EUR emise.
Cite sources nebo flag NEVERIFIED.
```

---

## Negotiation & Sales

### P-11: Negotiation Script + Pushback Handling
Pro klientské nabídky, retainer ceny, vendor discounts.

```
Vyjednávám [salary/retainer/cena] s [protistrana, kontext].
- Otevírací position (anchor)
- Justification (3 body proč tahle cena)
- Co říct když pushback "to je moc"
- Co říct když pushback "konkurence dělá levněji"
- Walk-away point + jak ho komunikovat
Filip styl: confident, ne aggresivní, žádné groveling.
```

### P-12: Naming Brainstorm
Pro nové služby, lead magnets, content series.

```
Potřebuji jméno pro [thing].
20 options napříč 4 styly:
- Playful (5 — humor, hravost)
- Professional (5 — credibility, B2B-fit)
- Weird (5 — pattern interrupt, memorable)
- Simple (5 — 1-2 slabiky, clear)
Každé option 1 věta proč funguje. Filtruj banned words: revoluční, inovativní, smart, AI.
```

---

## Použití

Žádný skill, žádný command. Když potřebuješ jeden z těchto patternů:

1. Otevři tenhle soubor (`~/.claude/knowledge/power-prompts.md`)
2. Copy příslušný prompt
3. Paste do Claude, replace placeholders
4. Adapt podle context

Pro frequent use → můžu vytvořit skill (řekni "udělej z P-XX skill").

---

## Reference

- Source: https://guides.tenfoldmarketing.com/60-claude-prompts (60 total, 12 cherry-picked)
- Adapter: 2026-04-25, Filip Dopita styl + OneFlow context
- Komplementární k existing skills: /megaprompt, /autoprompt, /promptfix (meta-prompts), /redteam, /challenge, /verify-claim, /llm-council (decision-heavy)
