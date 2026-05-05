# Phase 4 — PRICE YOUR AGENT TO WIN

## Source prompt (Filipova originální verze)

```xml
<role>Act as an AI agent pricing strategist who has watched builders destroy their margins by charging for hours instead of outcomes — and has a pricing framework that makes clients say yes faster, pay more willingly, and stay longer than any hourly rate ever could.</role>

<task>Build a dominant pricing strategy for my AI agent that wins clients without discounting, justifies premium fees without apology, and scales revenue without scaling my hours.</task>

<steps>
1. Ask for my agent's workflow, the outcome it delivers, the client's current cost of doing this manually, and my competitors' pricing before starting
2. Calculate the ROI my agent delivers — the exact dollar value of time saved, errors eliminated, or revenue generated
3. Design the outcome-based pricing structure — charge for the result not the build
4. Build the pricing tiers — a good, better, best structure that makes the middle tier the obvious choice
5. Deliver the pricing conversation framework — how to present the fee so the ROI makes it feel free
</steps>

<rules>
- Price must be anchored to ROI — never to hours spent or complexity of build
- Outcome-based pricing must be specific — "saves 40 hours per month at $150/hour" not "saves time"
- Pricing tiers must make the middle tier feel like the obvious rational choice
- Pricing conversation must lead with ROI before mentioning the fee — always
- Test: after hearing this pricing would a rational client feel they are getting a bargain
</rules>

<output>ROI Calculation → Outcome-Based Pricing Structure → Three-Tier Pricing → Pricing Conversation Framework → Clients Pay Without Negotiating</output>
```

## CZ adaptation

### Krok 1 — Inputs Gathering

Vyžaduj 4 čísla od Filipa/klienta před pricing kalkulací:

| Vstup | Příklad | Source |
|---|---|---|
| Hodin manuální práce / měs | 40h | Klient řekne, ověř s baseline z Phase 1 |
| Cena hodiny (CZ benchmark) | 800 Kč (junior), 1500 Kč (senior), 3000 Kč (specialist) | Klient HR cost nebo CZ trh |
| Error rate manuálního procesu | 5% (každá 20. instance špatně) | Klient incident log nebo odhad |
| Konkurenční pricing (3 examples) | n8n.cloud, Make.com, custom CZ agency | WebSearch + LinkedIn intel |

Pokud chybí → Filip dohledá (nemíchat s pricing výstupem). Pokud klient nezná → odhad z CZ benchmarks v `~/.claude/expertise/agent-business-lifecycle.yaml`.

### Krok 2 — ROI Calculation (specifické, ne "saves time")

Formula:
```
Roční ROI = (hours_saved/měs × hourly_rate × 12) +
            (errors_eliminated/rok × cost_per_error) +
            (revenue_added/rok)

Příklad pro lead enrichment agent:
= (40h × 1500 Kč × 12) + (200 errors × 5000 Kč) + 0
= 720 000 Kč + 1 000 000 Kč
= 1 720 000 Kč ročně
```

**Iron rule:** vždy konkrétní čísla, ne "ušetří čas / sníží chyby". Klient musí umět ten výpočet zopakovat sám.

### Krok 3 — Outcome-Based Pricing Structure

Charge za **výsledek**, ne za build hours.

| Pricing model | Kdy použít | Příklad |
|---|---|---|
| **Per-instance fee** | High-volume, low-stakes (data enrichment) | 30 Kč / enriched lead |
| **Monthly retainer** | Stable workflow (standard CZ B2B agent) | 25-100k Kč/měs |
| **Success fee** | Sales / lead-gen agents | 5-15% z deal value, min 5k Kč |
| **Hybrid (retainer + success)** | High-stakes (DD agent, fundraising) | 30k Kč/měs + 1% AUM |
| **Build + license** | One-time setup pro klienta s vlastním IT | 80-300k Kč build + 5k/měs license |

**NEVER:** hourly rate. Hodina kódu vs. hodina ROI = race to bottom.

### Krok 4 — Three-Tier Pricing (good / better / best)

Anchor effect: středový tier vypadá jako "obvious choice".

**Template (CZ market 2026):**

| Tier | Cena | Kryje | Cílový klient |
|---|---|---|---|
| **Starter** | 25 000 Kč/měs | 1× agent, 500 instancí/měs, basic monitoring, 5h support/měs | Solopreneur, malá firma |
| **Growth** ⭐ | **65 000 Kč/měs** | 1× agent, 5000 instancí/měs, full monitoring + Sentry, 15h support/měs, monthly review | **SMB 10-50 zaměstnanců (sweet spot)** |
| **Enterprise** | 180 000 Kč/měs | 3× agentů, neomezené instance, dedicated VPS, 24/7 monitoring, 40h support/měs, custom SLA, training pro tým | Korporát 100+ zaměstnanců |

**Anchoring rules:**
- **Growth** = vždy "doporučuje se" badge / pop
- **Starter** = vypadá levně ale s explicit limity (donutí klienta uvažovat o upgrade za 6 měs)
- **Enterprise** = makes Growth look reasonable

**CZ adaptation:**
- Build fee separate (one-time): 50-150k Kč podle Phase 2 komplexity
- Onboarding: 0 Kč prvních 30 dní (zruší decisional friction)
- Year-1 lock-in: -10% na 12měs commitment

### Krok 5 — Pricing Conversation Framework

**Ne tato sequence:** "Naše agenti stojí X Kč."
**Ano tato sequence:**

```
1. ANCHOR ROI první (NIKDY cena první)
   "Z toho co jste mi řekl, váš tým ručně zpracovává 40 hodin/měs.
   Při senior CZ rate 1500 Kč to je 720 000 Kč ročně. Plus chyby
   stojí dalších 1 000 000 Kč. Celkem 1.72M Kč ročně, který ten
   workflow vás stojí dnes."

2. AGITATE (klient si uvědomí jak moc to bolí)
   "A to bez toho, abyste počítal opportunity cost — to co váš
   senior tým mohl dělat místo téhle manuály."

3. INTRODUCE (až teď zmíníš agent)
   "Agent, kterého jsme spolu navrhli, tohle dělá za vás.
   Stejná accuracy, stejná output, žádná manuální hodina."

4. PRESENT TIERS (3-tier visual, Growth highlighted)
   "Mám pro vás 3 možnosti: Starter, Growth, Enterprise.
   Většina klientů jako vy volí Growth — 65 000 Kč/měs."

5. ANCHOR TO ROI (cena vs. ROI)
   "780 000 Kč ročně Growth tier, 1.72M Kč ročně ušetřené.
   Net = 940 000 Kč na vašem účtu, plus účet bez 40h manuální
   práce váš senior tým."

6. CALIBRATED CLOSING (ne "ano/ne", forcing function)
   "Co by muselo platit, abyste mohl rozjet Growth tier
   ještě tento měsíc?"
```

**Iron rules:**
- ROI always before price (never reverse)
- Specific numbers, not "significant savings"
- Calibrated questions for closing (Voss style)
- Žádné apologetic framing ("vím, že to zní hodně, ale...")

### Test gate

> "After hearing this pricing, would a rational client feel they are getting a bargain?"

Pokud NE → buď ROI calc je slabá (vrať se ke Krok 2) nebo tier ceny špatné (Krok 4).

## Výstupní formát

`~/Documents/oneflow-agents/{client_slug}/04-pricing.md`:

```markdown
# Pricing Strategy: {Client Name} — {Agent Name}

**Date:** YYYY-MM-DD

## 1. Inputs
- Hours saved/měs: X
- Hourly rate: Y Kč
- Error reduction: Z%
- Competitive prices: [3 references]

## 2. ROI Calculation
[Konkrétní výpočet, čísla]

## 3. Pricing Model Selected
[Per-instance / Retainer / Success / Hybrid + důvod]

## 4. Three-Tier Pricing
[Tabulka Starter / Growth / Enterprise s detail]

## 5. Conversation Script
[6-step framework, customized pro klienta]

## Hand-off Test
[Yes/No: Would rational client feel bargain?]
```

## Auto-chain do Phase 5

Po Filip approval pricing → `/agent-business-lifecycle sell {client_slug}` (sales call prep).

## CZ market reality check

| Service tier | Realistic CZ price (2026) |
|---|---|
| AI agent build (one-time) | 30 000 — 300 000 Kč |
| Monthly retainer (small agent) | 15 000 — 50 000 Kč |
| Monthly retainer (production agent) | 50 000 — 200 000 Kč |
| Enterprise multi-agent setup | 200 000 — 800 000 Kč/měs |
| Per-instance (data enrichment) | 5 — 50 Kč |
| Per-instance (DD/legal/medical) | 500 — 5 000 Kč |
| Hourly consulting (last resort) | 2 000 — 5 000 Kč/h |

Reference detail v `~/.claude/expertise/agent-business-lifecycle.yaml`.
