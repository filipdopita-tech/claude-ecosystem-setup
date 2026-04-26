---
name: content-repurpose
description: "1 pilíř obsahu -> 9 formátů: reel, carousel, newsletter, LinkedIn, blog, stories, PDF, podcast notes, X/Twitter. Trigger: 'repurpose', 'rozmnož obsah', 'udělej z toho víc formátů'."
---

# /content-repurpose — Content Repurposing Engine

## Kdy použít
- Uživatel má hotový obsah (text, video transkript, článek, reel) a chce ho rozmnožit
- Uživatel řekne "repurpose", "udělej z toho carousel", "rozmnož to"
- Po nahrání podcastu / reelu / článku

## POSTUP

### Krok 1: Identifikuj pilíř
Zjisti co je vstupní obsah:
- Video/reel transkript
- Článek / blog post
- Podcast / audio transkript
- Poznámky z meetingu
- Téma (jen keyword/idea)

Pokud je vstup URL na reel/video -> nejdřív spusť `/instagram-analyzer` pro transkripci.

### Krok 2: Extrahuj jádro
Z pilíře vytáhni:
```
1. HLAVNÍ MYŠLENKA (1 věta)
2. PODPŮRNÉ BODY (3-5 konkrétních faktů/čísel)
3. PŘÍBĚH/PŘÍKLAD (osobní angle)
4. CTA (co má čtenář udělat)
5. CÍLOVÁ SKUPINA (investor/emitent/obecná)
```

### Krok 3: Načti brand kontext
- `~/Documents/[your-brand-assets]/PROJECT_INSTRUCTIONS.md`
- `~/.claude/rules/[your_name]-style-clone.md`
- `~/.claude/rules/[your-service].md`

### Krok 4: Generuj formáty
Generuj postupně, každý formát jako samostatný blok:

#### 1. IG Carousel (7 slidů)
```
Slide 1: Hook (max 8 slov)
Slide 2: Problém
Slide 3-5: Řešení s čísly
Slide 6: Důkaz/data
Slide 7: CTA
+ Caption (max 150 slov) + 5-8 hashtagů
```

#### 2. IG Reel Script (60s)
```
[0-3s] Hook
[3-15s] Kontext
[15-45s] 2-3 body
[45-55s] Twist
[55-60s] CTA
```

#### 3. LinkedIn Post (max 200 slov)
```
Hook (1 věta, personal angle)
3-4 odstavce (max 2 věty každý)
Takeaway
CTA (otázka pro diskuzi)
```
Pravidla: formálnější než IG, žádné hashtags spam (max 3), vykání.

#### 4. Newsletter Blok (max 300 slov)
```
Subject line (max 50 znaků, curiosity gap)
Preview text (max 90 znaků)
Intro (osobní, 2 věty)
Obsah (strukturovaný, čísla)
CTA (odkaz na konzultaci / další čtení)
```

#### 5. Blog/Web Článek (500-800 slov)
```
H1: SEO-optimized nadpis
Intro (2-3 věty, problém)
H2 sekce (3-4, každá 100-200 slov)
Závěr s CTA
Meta description (max 155 znaků)
```

#### 6. IG Stories Sekvence (5-7 stories)
```
Story 1: Poll/otázka (engagement bait)
Story 2: Kontext
Story 3-5: Klíčové body (text overlay style)
Story 6: Swipe up / Link CTA
Story 7: "Uložte si carousel" (cross-promo)
```

#### 7. PDF Lead Magnet (1 strana)
```
Nadpis (benefit-oriented)
3-5 bodů s ikonami
1 graf/tabulka
CTA: "Chcete víc? Napište mi."
```

#### 8. X/Twitter Thread (5-7 tweetů)
```
Tweet 1: Hook + "Thread:"
Tweet 2-5: Jednotlivé body (max 280 znaků)
Tweet 6: Shrnutí
Tweet 7: CTA + follow
```

#### 9. Podcast Talking Points
```
Intro angle (30s)
3 hlavní body s příklady
Kontroverzní take
Outro CTA
```

### Krok 5: Quality check
Pro KAŽDÝ formát:
- [ ] Zní jako [YOUR_NAME]?
- [ ] Banned words?
- [ ] Min 1 číslo?
- [ ] Končí akcí?
- [ ] Adaptováno na platformu (formálnost, délka, formát)?
- [ ] Žádné em dash?
- [ ] Nejsou si formáty příliš podobné? (každý musí mít jiný angle/hook)

### Krok 6: Výstup
Prezentuj jako strukturovaný blok, každý formát pod vlastním nadpisem.
Nabídni: "Který formát chceš dopracovat do finální verze?"
