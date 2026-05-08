---
name: llm-council
description: "5-advisor debate framework with peer review for strategic decisions. Use for DD verdikt, big-bet investice, architektonická rozhodnutí, pivoty, kontroverzní hires, kde stakes jsou vysoké a chceš adversarial perspektivy před commitnutím. MANDATORY TRIGGERS (always invoke): 'council this', 'run the council', 'war room this', 'pressure-test this', 'stress-test this', 'debate this', 'rozcupuj radou', 'svolej radu'. STRONG TRIGGERS (invoke if combined with real decision/tradeoff): 'should I X or Y', 'A nebo B', 'pivot or persevere', 'GO/NO-GO', 'mám se zaměřit na', 'is this the right move', 'validate this', 'co byste udělali', 'I'm torn between'. SKIP TRIGGERS (do NOT invoke): trivial yes/no, factual lookups, casual 'should I' bez stakes (e.g. 'should I use markdown'), implementation details, tooling choices. Adapted from tenfoldmarc/llm-council-skill + Karpathy methodology + onlinemama enhancements."
allowed-tools: Read, Write, Edit, Grep, Glob, WebFetch, WebSearch, Bash
---

# LLM Council — 5-Advisor Strategic Debate

## Trigger Sensitivity (when to invoke vs skip)

### MANDATORY (vždy invoke)
- "council this: ..."
- "run the council on ..."
- "war room this"
- "pressure-test this", "stress-test this"
- "debate this"
- "rozcupuj radou", "svolej radu"

### STRONG (invoke jen pokud je real decision/tradeoff/stakes)
- "should I X or Y", "A nebo B"
- "pivot or persevere"
- "GO/NO-GO"
- "mám se zaměřit na", "co byste udělali"
- "is this the right move", "validate this"
- "I'm torn between", "nemůžu se rozhodnout"

### SKIP (NIKDY auto-invoke)
- Trivial yes/no questions ("should I use markdown for this readme?")
- Factual lookups ("what's the capital of France?")
- Implementation details ("which font?", "kam soubor?")
- Tooling choices ("Vercel vs Netlify pro tento landing?")
- Casual exploration without commit ("co bych mohl udělat s X?")

**Disambiguator**: skutečné council otázky mají (1) genuine uncertainty, (2) high-cost-of-being-wrong, (3) multiple polarizing options. Pokud chybí byť 1 → není to council otázka.

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

### Phase 0: Workspace Context Scan (MANDATORY pre-framing, max 30s)

PŘED frame-ováním otázky proveď rychlý kontext scan. Filipovy `~/Documents/`, `~/.claude/projects/-Users-filipdopita-Desktop-Codex/memory/`, OneFlow Vault, project CLAUDE.md jsou plné dat která dělají rozdíl mezi generic radou a grounded radou.

**Quick scan checklist (under 30s):**
1. **CLAUDE.md** v project root + global → business context, constraints, preferences
2. **MEMORY.md** index → past decisions, recent project context, feedback patterns
3. **`memory/feedback_*.md` + `memory/project_*.md`** matching topic keywords → relevant prior decisions
4. **OneFlow Vault** (`~/Documents/OneFlow-Vault/`) — if topic financial/investor/dluhopisový
5. **Recent council transcripts** v project's `active/` directory — avoid re-counciling
6. **Files Filip explicitly attached/referenced** — primary source

**Tools**: Glob + quick Read calls. Cap 5 file reads. **Don't go deeper than 30s** — scan, not research.

**Output of Phase 0**: list of 2-3 files which give advisors specific grounding. Inject as "CONTEXT" v Phase 1 framing.

### Phase 1: Question Framing
Filip pošle: `council this: [otázka/rozhodnutí]`

Já transform na (s data z Phase 0 scan):
```
DECISION: [konkrétní volba]
CONTEXT: [stakes, deadline, alternatives, constraints — z OneFlow knowledge + Phase 0 grounding]
WORKSPACE GROUNDING:
  - [file 1: relevant fact]
  - [file 2: relevant fact]
  - [file 3: relevant fact]
DESIRED OUTPUT: [verdikt? plán? eliminace alternativ?]
```

Don't add own opinion. Don't steer. But DO ground each advisor with specific facts (revenue numbers, prior launch results, audience signals, deadline reality) so they give SPECIFIC advice, not generic.

**Vague question handling**: pokud otázka je vague ("council this: my OneFlow strategy"), zeptej se EXACTLY 1 clarifying question, pak proceed.

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

### Phase 3: Anonymized Peer Review (cross-advisor)

**Klíčový krok** — what makes the council > "ask 5 times". Karpathy's core insight.

**Anonymizace JE povinná** (eliminuje positional bias):
1. Collect all 5 advisor responses from Phase 2
2. **Randomly map** Contrarian/FirstPrinciples/Expansionist/Outsider/Executor → Response A/B/C/D/E (random shuffle each council session)
3. Show reviewers ONLY anonymized A-E labels, NEVER advisor names

Bez anonymizace = reviewers defer k thinking styles co cení (e.g. always rate Contrarian = strongest because Filip values skepticism). Anonymizace = evaluation on reasoning merit.

Po anonymizaci každý advisor čte ostatních 4 (jako A-E) a odpovídá na 3 questions:

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

- **Markdown v chatu, NIKDY HTML, NIKDY samostatný file** (defaultně) — Filip čte to v conversation
- Markdown tables/sections, ne plain text
- Emoji per advisor pro rychlou navigaci (🛡️🧱🚀👶⚡)
- Verdict bold + colored (GO=green, NO-GO=red, WAIT=yellow)
- Confidence vždy as %, ne "high/med/low" (calibrated)

## In-chat verdict format (FINAL OUTPUT, povinné)

Po Phase 4 synthesis prezentuj final verdict v chatu (ne soubor) v této struktuře:

```markdown
## 🎯 Council Verdict: {short topic}

### 🛡️🧱🚀👶⚡ Where the Council Agrees
{points multiple advisors converged on independently}

### ⚔️ Where the Council Clashes
{genuine disagreements, both sides s reasons}

### 🔍 Blind Spots the Council Caught
{things that emerged in peer review only}

### ✅ The Recommendation
{clear, direct, no hedging — A real answer}
**Action**: GO / NO-GO / WAIT-FOR-X / PIVOT-TO-Y
**Confidence**: XX% (calibrated)

### ⚡ The One Thing to Do First
{single concrete next step, ne list}
{includes deadline pokud time-sensitive}
```

**Optional transcript save**: Pokud Filip explicit požádá ("ulož transcript", "save council session") nebo je rozhodnutí epic stakes (>500k Kč nebo strategický pivot), ulož full transcript do `council-transcript-YYYY-MM-DD-HHMM.md` v project's `active/` directory.

Defaultně transcript NEZAPISUJ — verdict je in-chat.

## Integration s OneFlow

- **DD context auto-load:** pokud council řeší DD, načti `~/.claude/expertise/czech-regulatory.yaml` + `rules/domains/investment.md`
- **Cold email council:** auto-load `expertise/email-deliverability.yaml` + `rules/domains/cold-email.md`
- **Content council:** auto-load `oneflow-all.md` brand voice + banned words

## Reference

Original framework: tenfoldmarc/llm-council-skill (https://github.com/tenfoldmarc/llm-council-skill)
Adaptace pro OneFlow: 2026-04-25 — Filip Dopita
Vztah: doplňuje /mythos (epistemic) a /redteam (kritika), unique value = 5 polarized personas s peer review.
