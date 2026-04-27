# Dopita Operating System v1.0

> "Nedosahnes cilu tim, ze o nich snis. Dosahnes jich tim, ze si nastavis standardy tak vysoko, ze pod ne odmitnes klesnout."

---

## Master algoritmus: Belief > Action > Result > Feedback

1. Definuj belief (= standard)
2. Massive action
3. Mer vysledek
4. Iteruj belief na zaklade feedbacku
5. Opakuj

Tohle neni motivacni citace. Je to operacni smycka. Kazdy standard v tomhle dokumentu prochazi timhle cyklem.

---

## OneFlow standardy

### Emise & Due Diligence
- Kazdy emitent projde DD pred uvedenim na platformu
- DD checklist: DSCR >1.5x, LTV <70% Praha / <60% regiony, zastava 1. poradi, audit min 2 roky
- Transparentni track record. Zadne skryte fee.
- Zadna emise nad limit bez prospektu (>8M EUR = povinny)

### Investor Relations
- Investor first. Vzdy.
- Kazdy investor dostane pristup k DD materialum
- Response time na dotaz investora: <24h pracovni den
- Zadny marketing bez disclaimeru ("propagacni sdeleni", rizika, past performance)

### Content & Brand
- Zadny post bez konkretniho cisla nebo dat
- Zadny content s banned words (viz filip-style-clone.md)
- Kazdy text projde skeptic + red-team auditem
- Min 4 posty/tyden (3 Reels + 1 carousel)
- Kvalita > kvantita. Radeji 0 postu nez spatny post.

### Outreach & Sales
- Kazdy cold email personalizovany (1. veta = proc TATO osoba)
- Max 150 slov cold email. Zadne "dovoluji si".
- Podcast outreach = primarni kanal. Kazdy kontakt projde kvalifikaci.
- Response rate pod 2% po 2 tydnech = iteruj sablony (Feedback Loop Engine to hlida automaticky)

---

## Osobni standardy

### Denni minimum
- Rano: precist standardy + vizualizace milniku (10 min) — Morning Briefing automaticky pripomene pres ntfy v 7:00
- Pres den: massive action dle planu, zero procrastination
- Vecer: review dne (co posunulo iglu vs. sum) + intence na zitrek (5 min)

### Pattern awareness
- Sledovat highs/lows v energii a vykonu
- Markery bliziciho se propadu: spatny spanek, izolace, doom-scrolling, odkladani hodin
- Chytit se DRIV nez spadnes. Propad = poruseni standardu.
- Feedback Loop Engine sleduje outreach metriky automaticky — pokud klesaji 2 tydny, dostanes PATTERN ALERT

### Character design
- Kdo musim byt, aby OneFlow uspel?
- Filip = brain behind OneFlow. Fundraising + personal brand + content + networking.
- Rozhodovaci filtr: "Udelal by tohle ten Filip, ktery vede OneFlow za 3 roky? Pokud ne, nedelej to."

### Komunikace
- Primy, sebevedomy, zadne omluvy
- Cisla misto adjektiv
- Kazdy text konci akci
- Vykani novym. Podpis: Dopita.
- Zadne: inovativni, revolucni, win-win, synergie, paradigma, v dnesni dobe

---

## Red lines (NIKDY)

- Nikdy negarantovat vynos
- Nikdy neobetovat compliance za rychlost
- Nikdy neposilat nekvalitni content
- Nikdy nerikat "to nejde" (najdi alternativu)
- Nikdy neschvalovat emitenta pod tlakem bez DD
- Nikdy neodeslat email/kampan bez review
- Nikdy nehalucinovat cisla — pokud nevis, over

---

## Automatizovane guardrails (aktivni v ekosystemu)

| System | Co dela | Kde bezi | Frekvence |
|---|---|---|---|
| Morning Briefing | ntfy push: standardy + outreach metriky + kalendar | Flash cron 7:00 | Denne |
| Feedback Loop Engine | 2-week trend alert na RR, bounce rate, send volume | Flash cron Mon 9:00 | Tydne |
| Quality Gate Hook | Banned words, chybejici cisla, disclaimer check | Claude Code PreToolUse:Write | Pri kazdem zapisu content souboru |
| STANDARDS pressure pattern | Automaticky frame pri goal-settingu a rozhodovani | Claude Code rules | Vzdy |

---

## Feedback loop pro iteraci

| Oblast | Metrika | Frekvence review | Automatizovano |
|---|---|---|---|
| Content | ER, saves, shares, profile visits | Tydne | Ne (manual) |
| Emise | Fill rate, investor demand, default rate | Mesicne | Ne |
| Outreach | Response rate, meeting rate, close rate | Tydne | Ano (Feedback Loop Engine) |
| Osobni | Energie, focus, dodrzeni rutiny | Denne | Castecne (Morning Briefing) |

Pravidlo: Pokud metrika klesa 2 tydny po sobe, zastav se a iteruj belief/standard.

---

## Zdroje
- Sam Ovens "Alchemy of Self" (Billionaire's Journal) — principy belief loops, standards > dreams, character design
- Filip style: ~/.claude/knowledge/filip-style-clone.md
- OneFlow brand: ~/Documents/oneflow-claude-project/PROJECT_INSTRUCTIONS.md
- Business model: podcast funnel -> marketing services (memory/business_model.md)

v1.0 — 2026-04-09. Zive provazano s Morning Briefing, Feedback Loop Engine a Quality Gate Hook.
