---
name: unreasonable-hospitality
description: "Will Guidara 'Unreasonable Hospitality' framework aplikovaný na product/UX/feature ideation. Když mě napadne fix nebo feature, zeptej se: 'Pokud by tohle byl 5-star hotel, co by udělali, ještě než by host řekl?' Trigger: 'unreasonable version', '5-star hotel approach', 'wow this user', 'beyond expectation', 'co dělat víc než klient čeká', 'jak nás zapamatovat'. Use pro: OneFlow landing UX (investor first impression), DD reportu polish (over-deliver), klientský deliverable above contract scope, podcast guest příprava, IG/LinkedIn signature moves, sales call follow-up. NIKDY ne pro: triviální polish, throwaway content, internal tools where ROI < 30 min."
allowed-tools: Read, Write, Edit, Grep, Glob, WebFetch
---

# Unreasonable Hospitality — Will Guidara framework

## Filozofie

Will Guidara (Eleven Madison Park) = nejvyšší restaurantní service standard za poslední dekádu. Princip: **když se host zmíní o čemkoli, tým reaguje preemptivně způsobem, který je nezapomenutelný.**

**Klasický příklad**: Tým slyšel 4-člennou rodinu si stěžovat, že už 5 dní v New Yorku ještě neviděli pořádné město. Zaplatili rikšu, dali jim 30-min projížďku Centrálním parkem během dezertu. Cost: $40. Memorable forever. Tahle generuje wordof-mouth, ne advertising.

**Aplikace na product/UX**:
- Klient se snaží něco udělat → reakce: "Co by 5-star hotel udělal, ještě než by se zeptal?"
- Detekce friction (přes ELU.dev, PostHog, Hotjar, manual user testing) → ne "obvious fix" co každý ship → **unreasonable version**

## Kdy použít

- **OneFlow landing redesign** (investor first impression — wow moment vs functional)
- **DD report final polish** (over-deliver — co přidat co klient nečekal)
- **Klientský deliverable** (above contract scope — what's the rikša moment)
- **Podcast guest hosting** (pre-show prep, send-off swag, follow-up)
- **Sales call follow-up** (after no nebo yes — co dělat aby si pamatovali)
- **IG/LinkedIn post hooks** — co je "unreasonable" version této hooky
- **Onboarding klienta po podpisu** (NDA + welcome → co je unreasonable verze)
- **Investor follow-up po pitch** (whether yes/no/ghost — unreasonable touch)

## Kdy NEPOUŽÍT

- Triviální copy edits, internal tools, throwaway content
- Když ROI < 30 minut Filipova času (opportunity cost)
- Když rule of "underpromise overdeliver" už dávno splněno (3+ unreasonable touches v jednom kontaktu = fake/forced)
- Pre-product fit (focus na PMF, ne hospitality theater)

## Workflow (3-step)

### Phase 1: Identify the moment
Pro každou aktuální situaci/feature/touchpoint:

```
USER WANTED TO: [co user chtěl udělat]
WHERE THEY STOPPED: [exact friction point — měření, ne odhad]
WHO ARE THEY: [persona, stage, expectations baseline]
EMOTIONAL STATE: [frustrated? excited? confused? neutral?]
```

Bez tohoto = jen brainstorming. S tímto = grounded ideation.

### Phase 2: Three-tier ideation (5-star hotel framework)

```
Tier 1 — OBVIOUS FIX (co každý ship)
  [What most product teams do — table stakes]

Tier 2 — GOOD FIX (above competitor average)
  [Solid execution but not memorable]

Tier 3 — UNREASONABLE (5-star hotel before host asks)
  [What makes user think: "I can't believe they did that."]
```

**Klíčová otázka pro Tier 3**: "Pokud by tohle byl Four Seasons / Ritz-Carlton / Eleven Madison Park, co by udělali — preemptivně, personalizovaně, anticipated — než by host stihl říct cokoliv?"

Možnosti:
- **Proaktivní**: action před user request
- **Personalizované**: based on user signal (jméno, kontext, předchozí interakce)
- **Auto-konfigurované**: defaults match user's likely intent
- **Anticipated**: addressed need user nevěděl, že má

### Phase 3: Wow x Speed scoring

Score each Tier 3 idea:
- **Wow factor (1-10)**: how memorable, how shareable, how novel
- **Build speed (1-10)**: how fast to ship (1=měsíce, 10=hodina)
- **Composite**: wow × speed (top score wins, not max wow)

Output: top 1 idea s reasoning. **Ne 3-5 alternative — pick the one a build it.**

## OneFlow-specific anchors

### Investor onboarding po podpisu emise
- Tier 1: Welcome email + login link
- Tier 2: Welcome email + portfolio dashboard tour video
- Tier 3 unreasonable: **Hand-written postcard from Filip** (or pre-printed, scaled) doručený na fyzickou adresu day 2. Personalized: "Vítám tě v emisi. Zde je můj telefon: 608... Volej kdykoliv mezi pondělím a pátkem." Cost: 50 Kč/investor. Result: trust + perceived white-glove. ROI vs paid acquisition: massive.

### DD report delivery
- Tier 1: PDF přes email
- Tier 2: PDF + executive summary + brief 30-min call walkthrough
- Tier 3 unreasonable: **Fyzická kniha nebo limited edition print** s key insights, Filipova handwritten poznámka uvnitř, courier delivery. Pro emisi >50M Kč. Memory permanent. Klient ji ukáže ostatním → referrals.

### Cold outreach reply (yes nebo even no)
- Tier 1: "Děkuji za odpověď."
- Tier 2: Follow-up s relevantní case study
- Tier 3 unreasonable: Send 1 unique resource (book chapter, internal report, custom slide) NESouvisející s pitch — purely value, no ask. "Viděl jsem, že tě zajímá X. Tahle stránka prospektu Y je gold." Sets up future relationship even if no current deal.

### Podcast guest pre-show
- Tier 1: Send Zoom link + topic outline
- Tier 2: Send link + Spotify playlist of recent episodes for context
- Tier 3 unreasonable: Send physical OneFlow swag (notebook, hand-roasted coffee) day-of-show with note "Looking forward to your perspective on Y. Here's something to fuel the prep." Costs 200 Kč. Guest mentions on air → free distribution.

### Investor pitch follow-up (whether yes/no)
- Tier 1: Recap email
- Tier 2: Recap + custom deck addressing their specific concerns
- Tier 3 unreasonable: 5-min Loom video addressing 1 specific concern they raised, recorded within 6h of meeting (urgency = care signal). + handwritten thank-you postcard physical. Even if NO, this is what they remember when they refer next opportunity.

### IG/LinkedIn DM reply
- Tier 1: Reply with answer
- Tier 2: Reply + relevant article link
- Tier 3 unreasonable: 30-sec personal voice note (use IG voice messages) addressing them by name, specific to their question. Voice >> text for 5-star feel. Takes 90 seconds. They never forget.

### Klient AI agent build (agent-business-lifecycle)
- Tier 1: Deliver agent + handoff doc
- Tier 2: Deliver + 30-day retainer email support
- Tier 3 unreasonable: **First 30 days = embedded mode** — Filip joins their internal Slack, weekly Loom showing agent metrics, **invites them to OneFlow internal tooling demo** as a perk. Klient feels: "I got the founder, not just a deliverable."

## Rules

1. **Specificita > generic** — "send swag" is generic; "send their favorite book based on their LinkedIn" is specific
2. **Effort signal** — unreasonable should have visible effort (handwritten, custom video, physical delivery). Generic auto-email of $50 voucher = NOT unreasonable.
3. **Personalization > scale** — Tier 3 nemůže být fully automated. Auto-personalization (Mail Merge name) is Tier 2.
4. **Cost ≠ wow** — $1000 corporate gift is less memorable than $20 hand-delivered note. Marginal cost should NOT be primary filter.
5. **Anti-pattern: Theatrical** — overstaged effort feels desperate. Subtle, anticipated, not announced. Don't post about it on social media (unless guest does it organically).
6. **Frequency cap**: 1 unreasonable touch per relationship phase (acquisition, onboarding, retention, exit). Inflation kills it.

## Anti-patterns

- ❌ Tier 3 idea co je jen "spend more money" → that's not hospitality, that's gifting
- ❌ Tier 3 co se opakuje pro každého klienta → automated = no longer unreasonable  
- ❌ Tier 3 publicly broadcast (IG post "look what I did for client X") → ruins the magic for future clients
- ❌ Tier 3 vyžadující 5+ hodin Filipova času → unsustainable, doesn't scale
- ❌ Tier 3 jako manipulation tactic — pokud má clear conversion intent (e.g., handwritten note 1h before close), feels transactional. Use po close, ne před.

## Source

- Will Guidara, "Unreasonable Hospitality" (2022) — book
- ELU.dev "Unreasonable Hospitality ELU Setup" PDF (2026) — SaaS application of framework to product friction (saved at `~/Desktop/Codex/inbox-pdfs/2026-05-05/`)
- Filip's adaptation: 2026-05-05

## Reference (lazy)

`~/Desktop/Codex/inbox-pdfs/2026-05-05/unreasonable-hospitality-elu.md` — original PDF analysis
`~/Desktop/Codex/inbox-pdfs/2026-05-05/page-001-ocr.txt` ... `page-003-ocr.txt` — OCR'd ELU prompts

## Triggers (auto-routing)

In knowledge-router.md / workflow-routing.md, route to this skill when user prompt contains:
- "unreasonable version", "5-star hotel", "wow factor", "wow this user"
- "beyond expectation", "above contract", "over-deliver"
- "co dělat víc než klient čeká", "jak nás zapamatovat", "memorable touch"
- "rikša moment" (internal Filip codename for the framework)
- "Will Guidara", "Eleven Madison Park", "EMP hospitality"

Auto-chain after:
- `oneflow-diagnose GO` → suggest `unreasonable-hospitality` for launch onboarding plan
- `dd-emitent` final report → suggest `unreasonable-hospitality` for delivery polish
- `agent-business-lifecycle deploy` → suggest for klient onboarding (first 30 days)
- `outreach-oneflow` (after positive reply) → suggest for follow-up touch
