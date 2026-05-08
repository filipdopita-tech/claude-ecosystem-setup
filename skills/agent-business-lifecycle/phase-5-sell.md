# Phase 5 — SELL YOUR AGENT WITHOUT SELLING

## Source prompt (Filipova originální verze)

```xml
<role>Act as an AI agent sales strategist who knows that the fastest way to lose an agent sale is to talk about the technology — and has a sales framework that makes clients sell themselves by showing them the cost of not automating before ever mentioning what the agent does.</role>

<task>Build a complete agent sales system that closes clients without cold pitching, feature dumping, or explaining what an LLM is — by making the pain of their current process impossible to ignore.</task>

<steps>
1. Ask for my agent's workflow, target client type, and the manual process it replaces before starting
2. Map the client's current pain — the exact hours, errors, delays, and costs their current process creates
3. Build the pain quantification conversation — the specific questions that make clients calculate their own problem
4. Design the demonstration sequence — show the agent solving their exact problem, not a generic demo
5. Deliver the closing framework — the specific question that converts a convinced prospect into a signed client
</steps>

<rules>
- Never lead with technology — always lead with the client's current pain
- Pain must be quantified in dollars and hours — not described in adjectives
- Demonstration must use the client's actual data or workflow — never generic examples
- Closing question must create a decision moment — not leave the conversation open-ended
- Test: after this sales conversation would the client feel stupid for not automating sooner
</rules>

<output>Client Pain Map → Pain Quantification Conversation → Demonstration Sequence → Closing Framework → Client Signs Without Being Pushed</output>
```

## CZ adaptation

### Krok 1 — Inputs

Nutné před sales call:
- Phase 1-4 deliverables (plán, build status, deploy ready, pricing locked)
- Klientův manual proces (z Phase 1 baseline) + 3 datové instance pro live demo
- ICP profile (industry, size, role) — najdi v ARES + LinkedIn
- Předchozí komunikace s klientem (memory grep, Obsidian 13-Komunikace/)

### Krok 2 — Client Pain Map

Mapuj 4 dimenze bolesti, vše konkrétně CZ:

| Dimenze | Otázka | CZ příklady |
|---|---|---|
| **Time** | Kolik hodin/měs strávíte ručně tímhle procesem? | "40h/měs, dělá to senior za 1500 Kč/h = 720k Kč/rok" |
| **Errors** | Kolik chyb produkuje a co každá stojí? | "5% klasifikace špatně, oprava = 2 hodiny + reputace = 5000 Kč/incident" |
| **Delays** | Jak dlouho trvá od trigger → output? | "Lead přijde, zpracujeme za 3 dny → konkurence stíhá za 2 hodiny" |
| **Opportunity** | Co byste místo toho mohl dělat? | "Ten senior tým by mohl scoutovat nové leady místo enrichment manuálního" |

**Iron rule:** Konkrétní čísla, žádné "ušetříte čas" / "snížíte chyby". Klient musí umět spočítat svou bolest sám.

### Krok 3 — Pain Quantification Conversation

Sequence calibrated questions (Voss style, ne ano/ne):

```
1. ZAČÁTEK (low-stakes opening)
"Než vám ukazuju cokoliv, chci pochopit váš dnešní proces.
Kolik z vašich lidí dnes ručně dělá [konkrétní task]?"

2. OPEN-ENDED PROBE (ať klient mluví)
"A jak často to vede k chybě, kterou musíte řešit zpětně?"

3. SPECIFIC NUMBER PUSH (force quantification)
"Kdyby každý takový incident stál typicky [X Kč], kolik
takových za rok řešíte?"

4. OPPORTUNITY COST (širší rámec)
"A když ten člověk zrovna dělá tuhle manuálku, co dělat
nemůže? Co by místo toho mohl?"

5. COMPETITIVE ANGLE (FOMO)
"Vidíte u konkurence, že tohle dělají rychleji nebo
levněji? Jak na to reagujete?"

6. SUMMARY (klient potvrdí číslo)
"Takže jen co jste mi popsal: 40h/měs × 1500 Kč × 12 + 200
chyb × 5000 Kč = 1.72M Kč ročně. To je správně?"
```

**Iron rule:** Klient sám vypočítá výši bolesti (anchor effect). Filip neříká čísla, klient je říká.

### Krok 4 — Demonstration Sequence

NIKDY generic demo. VŽDY klientova data.

**Před call:** Vyžádej 3 reálné instance od klienta (lead, dokument, případ — anything jejich proces zpracovává). Spusť agent na nich offline. Ulož screenshoty/výstupy.

**Během call:**

```
1. SETUP CONTEXT (1 minuta)
"Vzal jsem 3 vaše skutečné [leady / dokumenty / případy]
z minulého týdne — ty, na kterých váš tým strávil [X hodin]."

2. SHOW BEFORE (1 minuta)
"Tohle je výstup, který produkuje váš tým dnes [screenshot
manual output]. Trvá to 45 minut na instanci."

3. SHOW AFTER (1 minuta)
"A tohle je výstup z agenta na stejných datech [screenshot
agent output]. Trvalo to 12 sekund a 3 koruny LLM cost."

4. ASK CLIENT (calibrated)
"Co by vám tohle změnilo na vašem tématu denním?"

5. LET CLIENT EXTRAPOLATE (silence)
[Klient sám si propočítá kolik mu to ušetří, ty MLČÍŠ]
```

**Iron rule:** Žádné "nabízíme automatizaci s LLM, který...". Klient vidí output a sám si dovodí co to znamená.

### Krok 5 — Closing Framework

NIKDY otevřená otázka ("co si o tom myslíte?"). VŽDY decision moment.

**Calibrated closes (Voss style):**

| Cíl | Question template |
|---|---|
| **Forcing function** | "Co by muselo platit, abyste tohle rozjel ještě tento měsíc?" |
| **No-oriented (low risk)** | "Bylo by mimo, kdybychom začali Growth tier s onboarding od 1.6.?" |
| **Decision frame** | "Vidím dvě možnosti: rozjedeme Growth od pondělí, nebo to ještě 14 dní zvážíme. Co dává smysl pro vás?" |
| **Empathy + reframe** | "Mýlím se, když si myslím, že tohle je přesně problém, který vás teď žere?" |
| **Specific commitment** | "Co by vám pomohlo říct ANO ještě tento týden?" |

**Po close:**
- Pokud klient řekne ANO → email s contract draft do 2 hodin
- Pokud klient řekne "musím to promyslet" → calibrated follow-up "Co ještě potřebujete vědět, abyste se rozhodl?"
- Pokud klient řekne NE → "Co by mě muselo přesvědčit, že je to ze mě?" (učení pro další)

### Test gate

> "After this sales conversation, would the client feel stupid for not automating sooner?"

Pokud NE → buď pain map slabá (Krok 2) nebo demo nepoužilo klientova data (Krok 4) nebo close otevřená otázka (Krok 5).

## Výstupní formát

`~/Documents/oneflow-agents/{client_slug}/05-sales-call.md`:

```markdown
# Sales Call: {Client Name} — {Agent Name}

**Date scheduled:** YYYY-MM-DD HH:MM
**Status:** PREP READY → POST-CALL UPDATE

## 1. Pre-Call Brief
- Klient profil: [ARES + LinkedIn intel]
- Předchozí komunikace: [memory link]
- 3 reálné instance: [paths]

## 2. Client Pain Map
[4-dimenze tabulka, čísla]

## 3. Pain Quantification Script
[6 calibrated questions, customized]

## 4. Demonstration Sequence
- 3 instance: [paths]
- Before output: [screenshot]
- After output: [screenshot]
- Pain per instance: [hours saved + error reduction]

## 5. Closing Framework
- Primary close: [question]
- Fallback close 1: [question]
- Fallback close 2: [question]

## Hand-off Test
[Yes/No: Would client feel stupid for not automating sooner?]

## POST-CALL (vyplň po hovoru)
- Outcome: SIGNED / FOLLOW-UP / NO
- Tier accepted: Starter / Growth / Enterprise
- Total contract value: X Kč
- Next action: [draft contract / scheduled follow-up / postmortem]
```

## OneFlow voice compliance

Aplikuj `~/.claude/rules/oneflow-all.md` § Voice + Banned Words:
- Vykání, žádné omluvy, žádné vykřičníky
- Žádné: "Dovoluji si", "Rád bych", "Obracím se na Vás", "S pozdravem"
- Podpis: "Dopita" nebo "Filip Dopita | OneFlow"
- Voss calibrated questions ✓ (built-in)
- Cialdini reciprocity (Krok 4 demo = už dáváš hodnotu) ✓

## Auto-chain post-close

Po SIGNED → vytvoř:
- Contract draft přes `/closer` skill (CZ B2B template)
- Onboarding email přes `outreach-oneflow` (welcome sequence)
- Calendar invite na kick-off call
- Memory entry: `client_{slug}_signed_{YYYY_MM_DD}.md` s tier + value
