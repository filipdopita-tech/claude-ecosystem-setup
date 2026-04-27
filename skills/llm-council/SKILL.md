---
name: llm-council
description: 5-advisor debate framework with peer review for strategic decisions. Use for DD verdikt, big-bet investice, architektonická rozhodnutí, pivoty, kontroverzní hires, kde stakes jsou vysoké a chceš adversarial perspektivy před commitnutím. Adapted from tenfoldmarc/llm-council-skill (https://github.com/tenfoldmarc/llm-council-skill).
allowed-tools: Read, Write, Edit, Grep, Glob, WebFetch, WebSearch, Bash
---

# LLM Council — 5-Advisor Strategic Debate

## Kdy použít

- **Strategická rozhodnutí >100k Kč** dopad nebo nevratná
- **DD verdikt borderline** (B/C grade, není jasné GO/NO-GO)
- **Architektonická volba** mezi 2-3 přístupy s tradeoffs
- **Pivot vs persevere** rozhodnutí o produktu/službě
- **Kontroverzní content** před shippnutím (možná reputační dopad)
- **Big-bet ad creative** před scale spending

## Kdy NEPOUŽÍT

- Triviální rozhodnutí (model selection, tooling)
- Reverzibilní akce s nízkou cenou chyby
- Když odpověď je zřejmá (ušetři tokeny)
- Operativa (deploy, refactor, debug)
- Když máš /mythos pro multi-step epistemic reasoning (council = decision, mythos = investigation)

## Vztah k jiným skills

| Skill | Use case | Když místo /council |
|---|---|---|
| /redteam | Rozcupovat nápad | Když jen hledáš slabiny, ne syntézu |
| /challenge | Critical analýza s 4 layery | Single-model deep critique |
| /scenario | Best/worst/likely projekce | Future-state simulation |
| /wargame | Competitor reaction | Adversarial market modeling |
| /mythos | Falsification + Bayesian + ACH | Epistemicky složitá investigace |
| **/council** | **5 personas + peer review** | **Strategická volba s polarizujícími views** |

## Framework — 5 Advisors

### Advisor 1: The Contrarian
**Mandát:** Hledá fatal flaw. Předpokládá, že nápad selže — co je důvod?
**Output style:** Konkrétní mechanismy selhání, ne vágní rizika. Cituj historické precedenty.
**Power question:** "Co by se muselo stát, aby tohle byl katastrofální omyl za 6 měsíců?"

### Advisor 2: The First Principles Thinker
**Mandát:** Strip předpoklady. Řešíš správný problém vůbec?
**Output style:** Decompose to physics/economics/human psychology basics. Question framing.
**Power question:** "Pokud bys problem definoval znovu od nuly, byla by tahle volba na seznamu?"

### Advisor 3: The Expansionist
**Mandát:** Co když to funguje 10× lépe než čekáš? Jaký upside přehlížíš?
**Output style:** Steelman best-case. Hidden compound effects. Network effects.
**Power question:** "Pokud tohle uspěje a budeš za rok zpátky, co byla nečekaná výhra?"

### Advisor 4: The Outsider
**Mandát:** Zero context o tobě, oboru, OneFlow. Catch curse of knowledge.
**Output style:** "Wait, why?" otázky. Předpoklady, které insider nevidí.
**Power question:** "Vysvětli to babičce. Pokud nemůžeš v 2 větách, je nápad ještě vařený?"

### Advisor 5: The Executor
**Mandát:** Co děláš v pondělí ráno? Pokud žádný first step, žádný plán.
**Output style:** Concrete next 3 actions s timelines. Žádná strategie, jen execution.
**Power question:** "Tohle je rozhodnutí, nebo plán? Pokud rozhodnutí, kdy první akce?"

## Workflow

### Phase 1: Question Framing
Filip pošle: `council this: [otázka/rozhodnutí]`

Já transform na:
```
DECISION: [konkrétní volba]
CONTEXT: [stakes, deadline, alternatives, constraints — z OneFlow knowledge]
DESIRED OUTPUT: [verdikt? plán? eliminace alternativ?]
```

### Phase 2: Independent Advisor Responses

Každý advisor odpovídá NEZÁVISLE (pretend ostatní neexistují):

```markdown
## 🛡️ THE CONTRARIAN

**Position:** [GO / NO-GO / WAIT]
**Strongest objection:** [1-2 věty, konkrétní]
**Failure mechanism:** [jak to selže, krok po kroku]
**Historical precedent:** [kdo to zkusil a selhal — pokud existuje]
**Confidence:** [low/med/high]

## 🧱 THE FIRST PRINCIPLES THINKER
... (stejná struktura)

## 🚀 THE EXPANSIONIST
... 

## 👶 THE OUTSIDER
... (otázky, ne závěry — outsider se ptá)

## ⚡ THE EXECUTOR
... (Monday morning plan jako primary output)
```

### Phase 3: Peer Review (cross-advisor)

Po fázi 2 každý advisor čte ostatní 4 a odpovídá na 3 questions:

```markdown
## PEER REVIEW

### Strongest response & why
[advisor X, protože Y]

### Biggest blind spot
[advisor X přehlédl Y]

### What all five missed
[meta-insight — co nikdo z rady neviděl]
```

### Phase 4: Synthesis (já jako orchestrátor)

```markdown
## 🎯 COUNCIL VERDICT

**Consensus signal:** [strong/weak/split]
**Recommended action:** [GO / NO-GO / WAIT-FOR-X / PIVOT-TO-Y]
**Confidence:** [calibrated %]

### Why this verdict
[2-3 věty syntéza]

### Dissenting view (steel-manned)
[nejsilnější opozice — i když verdict je opačný]

### Monday morning steps (Executor)
1. [konkrétní akce + deadline]
2. [konkrétní akce + deadline]
3. [konkrétní akce + deadline]

### Trip-wires (kdy reconsider)
- Pokud [X], council reconvene
- Pokud [Y], escalate /mythos pro deeper investigation
```

## Calibration Rules (proti AI sycophancy)

1. **Žádný advisor nesmí hedge** — every position musí být committed (GO/NO-GO/WAIT, žádné "záleží na...")
2. **Contrarian a Expansionist musí být polarizing** — pokud oba říkají to samé, jeden z nich nehraje roli
3. **Outsider nesmí znát kontext** — pokud začne citovat OneFlow specifika, je out of role
4. **Executor neřeší "is it good idea"** — jenom "what's the first action"
5. **Peer review není politeness** — explicitně označ slabšího respondéra
6. **Final verdict má dissenting view** — i když 5/5 souhlasí, najdi nejsilnější protiargument

## Anti-patterns (NE)

- "Všech 5 advisors souhlasí — go!" → suspicious, hledej dissent
- Vague positions ("zvažte...", "možná...") → reject, force commitment
- Outsider zná background → reset jeho prompt
- Executor's plan obsahuje "research more" jako first step → není akce
- Synthesis je průměr 5 odpovědí → není to consensus, je to slabost

## Příklady použití (OneFlow context)

### Příklad 1: DD borderline B-grade
```
council this: Emise XYZ s.r.o., DSCR 1.18, LTV 78%, track record 18 měsíců, 
sektor stavebnictví. Klient chce 30M Kč emisi, B-grade. Doporučit nebo odmítnout?

→ Contrarian: stavebnictví v 2026 = volatilní cash flow, 18 měsíců = pre-recession track. 
  NO-GO.
→ First Principles: DSCR 1.18 = 18% buffer. Question: jaký standard pro stavebnictví? 
  (sektor avg = 1.4)
→ Expansionist: pokud stavební trh recover Q4 2026, DSCR roste na 1.5+. WAIT.
→ Outsider: "Co je DSCR 1.18 vs 1.4? Proč 18 měsíců málo? Kdo platí, když selže?"
→ Executor: Monday: zavolat emitenta, požádat Q1+Q2 2026 cash flow projekce. 
  Tuesday: rozhodnutí.

VERDICT: WAIT-FOR-X (Q1+Q2 projections) — pokud DSCR projection >1.3, GO at adjusted yield.
```

### Příklad 2: Pivot OneFlow podcast → newsletter
```
council this: Vyměnit OneFlow podcast za daily fundraising newsletter? 
Podcast = 50 hodin/měsíc work. Newsletter = 10 hodin/měsíc, ale neznámý reach.

→ Contrarian: Daily je peklo na sustain. Po 3 měsících quit rate 78%. NO-GO.
→ First Principles: Cíl podcastu = lead gen pro emise. Newsletter dělá tohle líp? 
  (Podcast saves > Newsletter clicks pro stejnou audience.)
→ Expansionist: Newsletter scales bez time. 10k subs = 100 leads/měsíc passive.
→ Outsider: "Kdo z investorů čte daily emaily? Já to mažu."
→ Executor: Monday: 30-day pilot — 5 newsletter epizod paralelně s podcast. 
  Den 30: porovnat conversion.

VERDICT: PIVOT-TO-Y (weekly newsletter, ne daily) + keep podcast pro Tier 1 emise.
```

## Output formatting

- Markdown tables/sections, ne plain text
- Emoji per advisor pro rychlou navigaci (🛡️🧱🚀👶⚡)
- Verdict bold + colored (GO=green, NO-GO=red, WAIT=yellow)
- Confidence vždy as %, ne "high/med/low" (calibrated)

## Integration s OneFlow

- **DD context auto-load:** pokud council řeší DD, načti `~/.claude/expertise/czech-regulatory.yaml` + `rules/domains/investment.md`
- **Cold email council:** auto-load `expertise/email-deliverability.yaml` + `rules/domains/cold-email.md`
- **Content council:** auto-load `oneflow-all.md` brand voice + banned words

## Reference

Original framework: tenfoldmarc/llm-council-skill (https://github.com/tenfoldmarc/llm-council-skill)
Adaptace pro OneFlow: 2026-04-25 — Filip Dopita
Vztah: doplňuje /mythos (epistemic) a /redteam (kritika), unique value = 5 polarized personas s peer review.
