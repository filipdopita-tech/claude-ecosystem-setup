---
name: ig-content-creator
description: "Vytvoř IG obsah pro [YOUR_COMPANY]: carousel, reel script, static post. 3 tóny: Patient Observer / Dramatic Prophet / Quiet Devastator. Hook -> tón -> struktura -> caption -> CTA."
compatibility: No external API needed. Reads brand assets from ~/Documents/[your-brand-assets]/.
metadata:
  allowed-hosts: []
  version: "2.0"
---

# /ig-content-creator — [YOUR_COMPANY] IG Content Creator

## Kdy použít
- Uživatel chce vytvořit nový IG post (carousel, reel, static)
- Uživatel řekne "vytvoř carousel", "napiš reel script", "nový IG post"
- Uživatel dá téma a chce hotový obsah

## POSTUP

### Krok 1: Načti brand kontext
Před jakýmkoli výstupem VŽDY přečti:
1. `~/Documents/[your-brand-assets]/PROJECT_INSTRUCTIONS.md` — Brand DNA, hooks, anti-robotic, CTA
2. `~/.claude/rules/[your_name]-style-clone.md` — [YOUR_NAME] styl, banned words
3. `~/.claude/rules/[your-service].md` — [YOUR_COMPANY] voice, visual, content rules

### Krok 2: Identifikuj formát
- **Carousel** (7-10 slidů): nejlepší engagement (10%), pro edukační obsah
- **Reel script** (30-90s): pro personal brand, behind the scenes, hot takes
- **Static post** (single image + caption): pro announcements, quotes, milníky

### Krok 3: Vyber content pilíř
| Pilíř | Podíl | Příklady |
|---|---|---|
| Investment insights | 30% | DD breakdown, asset class srovnání, portfolio strategie |
| Fundraising BTS | 25% | Jak probíhá emise, due diligence proces, právní kroky |
| CZ Market data | 20% | Makro čísla, ČNB rozhodnutí, dluhopisový trh |
| Personal brand | 15% | Behind the scenes, lessons learned, mindset |
| AI/Tech | 10% | Jak používám AI v investicích, automatizace |

### Krok 3b: Vyber tón (Dan Koe archetypes)

Pokud [YOUR_NAME] nespecifikuje tón, vyber **1 nejlepší variantu** pro téma a na konci nabídni ostatní 2.

| Tón | Délka | Kdy použít |
|---|---|---|
| **Patient Observer** | 150-200 slov | Founder story, lessons learned, BTS, validace problému |
| **Dramatic Prophet** | 100-150 slov | Market contrarian, unpopular truths, pattern interrupt |
| **Quiet Devastator** | 50-100 slov | LinkedIn quote, single insight, ironic observation |

#### PATIENT OBSERVER
- Struktura: Pozorování problému → Empatie → Nečekaný úhel → Akce
- Time escalation: "3 roky", "každý den", "za 10 let"
- Opening vzor: "Viděl jsem to stokrát. Investor s dobrým příjmem, žádný majetek."
- Technika: validate struggle → give hope → reframe

#### DRAMATIC PROPHET
- Struktura: Provokativní tvrzení → Extrémní metafora → Přesné řešení
- Jazyk: "Rozbijte to", "Zapomeňte na X", "Tohle vás brzdí od"
- Opening vzor: "Česká investiční scéna hraje na jistotu. A proto prohrává."
- Technika: burn-it-down imagery → concrete rebuild

#### QUIET DEVASTATOR
- Struktura: 1-2 věty popis reality → twist / nečekané přirovnání → tečka (bez CTA)
- Jazyk: minimální, každé slovo nese váhu
- Opening vzor: "Diversifikace portfolio. Česky: mít 5 fondů od stejné banky."
- Technika: ironic observation → haunting reflection → silence

---

### Krok 4: Generuj hook (KRITICKÉ)
Použij jednu z těchto technik:
- **Emotional contrast**: "Vydělal jsem 2M na dluhopisech. Pak jsem o 800K přišel."
- **Provokace**: "90% českých dluhopisů je odpad. Tady je důvod."
- **Číslo + teaser**: "3 věci, které zjistím o emitentovi za prvních 15 minut."
- **In medias res**: "Sedím v kanceláři emitenta. Něco mi nesedí."
- **Pattern interrupt**: "Neříkej mi, že investuješ. Řekni mi, co jsi odmítl."

### Krok 4b: Contrast Formula — 15 úhlů (vždy, automaticky)
Pro každé téma vygeneruj 15 úhlů přístupu, pak vyber TOP 3 a z nich hook:

| # | Úhel | Vzor |
|---|------|------|
| 1 | Emotional | "Přišel jsem o X. Naučil jsem se Y." |
| 2 | Data | "X% investorů neví, že [fakt]." |
| 3 | Contrarian | "Všichni dělají X. Správná odpověď je Y." |
| 4 | Story | "Byl jsem v místnosti, kde [moment]." |
| 5 | Question | "Co dělá investor, když [situace]?" |
| 6 | Urgency | "Do [datum/event], tohle se změní." |
| 7 | Identity | "Takhle přemýšlí investor s [výsledek]." |
| 8 | Reveal | "Nikdo vám to neřekne, ale [pravda]." |
| 9 | Framework | "3 kroky, které oddělují [A] od [B]." |
| 10 | Mistake | "Chyba č. 1, kterou vidím u [persona]." |
| 11 | Behind scenes | "Jak vypadá [proces] zevnitř." |
| 12 | Comparison | "[X] vs [Y]: proč se mýlíš v obou." |
| 13 | Prediction | "Za 12 měsíců, [trh/situace] bude [stav]." |
| 14 | Challenge | "Zkus tohle: [akce]. Výsledek tě překvapí." |
| 15 | Myth bust | "[Rozšířená víra] je lež. Tady je důkaz." |

**Hook Engine scoring** — ohodnoť každý hook (1-10) na 3 dimenzích:
- **Engagement**: způsobuje reakci (komentář, save)?
- **Surprise**: překvapí i investičně zkušeného čtenáře?
- **Relevance**: sedí na [YOUR_COMPANY] brand a aktuální pilíř?

Composite score = (Engagement × 0.4) + (Surprise × 0.35) + (Relevance × 0.25)
→ Vyber hook s nejvyšším composite score. Nabídni top 3.

### Krok 5: Vytvoř obsah podle formátu

#### A) Carousel (7 slidů)
```
Slide 1: HOOK (max 8 slov, velký font, vizuálně silný)
Slide 2: PROBLÉM (proč je to téma důležité, 1-2 věty)
Slide 3-5: ŘEŠENÍ/OBSAH (konkrétní body, čísla, příklady)
Slide 6: DŮKAZ (data, screenshot, číslo, case study)
Slide 7: CTA (Comment [KEYWORD] + Save CTA)
```
Pravidla: Max 18 slov/větu. Min 1 číslo na slide. Žádné seznamy s přesně 5 položkami.

#### B) Reel Script
```
[0-3s] HOOK: Silná první věta (pattern interrupt nebo provokace)
[3-15s] KONTEXT: Proč je to důležité, osobní angle
[15-45s] OBSAH: 2-3 konkrétní body s čísly
[45-55s] TWIST/INSIGHT: Nečekaný závěr nebo perspektiva
[55-60s] CTA: "Comment [KEYWORD]" nebo "Sdílej tohle někomu, kdo investuje"
```
Pravidla: Mluvit jako [YOUR_NAME] (přímý, žádné omluvy). Aktivní slovesa. Žádné "v dnešní době".

#### C) Static Post (caption)
```
Hook (1 věta, silná)
—
Tělo (3-5 vět, max 2 věty/odstavec)
—
CTA (otázka nebo příkaz)
```

### Krok 6: Caption + hashtags
- Caption: max 150 slov pro carousel, max 100 pro static
- Hashtags: 5-8, mix (#investice #dluhopisy #finance + niche #duediligence #fundraising)
- VŽDY končí akcí (comment, save, share, DM)

### Krok 7: LLM-as-Judge quality audit
Před odevzdáním ohodnoť výstup na těchto kritériích (1-10, vypiš skóre):

**Checklist:**
- [ ] Zní jako [YOUR_NAME]? (přímý, sebevědomý, žádné omluvy)
- [ ] Banned words? (inovativní, revoluční, komplexní řešení, win-win, synergie, paradigma, disruptivní)
- [ ] Min 1 konkrétní číslo v obsahu?
- [ ] Končí akcí/CTA?
- [ ] Aktivní slovesa (ne "je důležité", ale "zjistěte/udělejte")?
- [ ] Žádné em dash v textu?
- [ ] Žádné seznamy s přesně 5 nebo 10 položkami?
- [ ] Uniform sentence length odstraněn? (mix krátkých a delších vět)

**Judge scoring:**
```
Hook score:    [1-10] — způsobuje zastaveníscrollování?
Brand fit:     [1-10] — sedí na [YOUR_COMPANY] voice + monochrome?
Save potential:[1-10] — chtěl bys to uložit?
Overall:       [průměr]
```
Pokud Overall < 7.0 → přegeneruj s feedback: "Hook slabý / brand drift / žádná hodnota k uložení".
Pokud Overall ≥ 7.0 → doručit.

### Krok 8: Nabídni follow-up + Evolving Brain
- "Chceš to adaptovat i pro LinkedIn/newsletter?"
- "Mám připravit vizuální brief pro Canvu?"
- "Chceš vygenerovat 3 varianty hooku?"

**Evolving Brain (po schválení [YOUR_NAME]):**
Jakmile [YOUR_NAME] schválí post nebo sdílí výkon (saves, reach, komentáře), zaznamenej do Graphiti:
```
graphiti_add("IG post výkon", {
  hook: "[první věta]",
  format: "carousel|reel|static",
  pillar: "investment|fundraising|market|personal|ai",
  tone: "patient_observer|dramatic_prophet|quiet_devastator",
  hook_angle: "[č. 1-15 z Contrast Formula]",
  saves: [číslo],
  reach: [číslo],
  comments: [číslo],
  verdict: "winner|average|flop"
})
```
Při příští generaci: `graphiti_search("IG post výkon winner [pilíř]")` → prioritizuj vítězné formáty/angely/tóny.

## Common Mistakes

1. **Nepiš bez brand kontextu.** VŽDY nejdřív načti PROJECT_INSTRUCTIONS.md + [your-service].md.
2. **Nepoužívej banned words.** Viz [your-service].md. "Inovativní", "revoluční", "synergie" = okamžitý fail.
3. **Nevynechávej CTA.** Každý post MUSÍ končit akcí (comment, save, DM).
4. **Nepiš uniformní věty.** Mix krátkých (3-5 slov) a delších (15-20 slov). Žádné seznamy s přesně 5/10 položkami.
5. **Neházkuj vizuální brief.** Carousel formát je 1080x1350, barvy z brand guide (#0f1113, #cdb186).
