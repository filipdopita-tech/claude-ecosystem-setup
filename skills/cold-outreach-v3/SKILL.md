---
name: cold-outreach-v3
description: "OneFlow-specific cold outreach pipeline 2026: ARES + LinkedIn + Hunter waterfall enrichment, Cialdini + Voss messaging, deliverability gate, Instantly send. Apollo Apify dead (2026-09), nahrazuje to direct API + CZ alternatives. NE duplicate cold-email skill (ten je generic English B2B). Trigger: /cold-outreach-v3 <campaign_name>, 'cold outreach kampaň pro CZ ICP', 'leadgen pipeline OneFlow'."
argument-hint: "<campaign_name> [--icp=ceo_sro_50plus|cfo_500plus|founder_b2b] [--volume=100|500|1000] [--domain=A|B|C]"
user-invocable: true
allowed-tools:
  - Bash
  - Task
  - Read
  - Write
  - Edit
  - Grep
  - WebFetch
metadata:
  source: "skool-intel cherry-pick 2026-04-28: chase-ai 'Cold Outreach Machine 3.0' + 'n8n & Apollo Lead Gen Finally Solved' + cc-strategic 'How are you guys actually automating LinkedIn outreach?'"
  filip-adaptace: "Místo Apollo Apify (deprecated 2026-09) → ARES + LinkedIn Voyager + Hunter direct + Apollo direct API. CZ ICP focus. Voss CTAs."
  related-skills: "cold-email (generic English), outreach-oneflow (single message), leadgen (lead-ops pipeline)"
---

# Cold Outreach v3 — OneFlow CZ Pipeline

**Cíl:** Spustit OneFlow-grade cold outreach kampaň 100-1000 leadů za <2 dny od ICP definice po first reply. Cost-zero infrastructure, žádné Apify Apollo (dead 2026-09).

**Argument:** `$ARGUMENTS` — campaign name + flags.

## Why a v3 (not just upgrade cold-email skill)

| skill | scope | language | use case |
|---|---|---|---|
| `cold-email` (existing) | generic copy templates | English | quick B2B email writing |
| `outreach-oneflow` | single personalized message | CZ | one-off podcast/investor reach |
| `cold-outreach-v3` (new) | full pipeline 100-1000 leadů | CZ | OneFlow lead-gen kampaň |

`cold-outreach-v3` orchestruje enrichment + messaging + deliverability + send infrastructure. Volá ostatní skills jako sub-components.

## Pipeline (6 fází, ~6-12 hodin total per kampaň)

### Phase 1: ICP definition + ARES bulk (30-60 min)

```bash
ICP="$1"  # např. "ceo_sro_50plus"
CAMPAIGN="$2"
OUTPUT="$HOME/Documents/01_OneFlow/campaigns/$CAMPAIGN"
mkdir -p "$OUTPUT"

# Existing /scraping-engine/ has 10067 firem (per memory project_scraping_engine.md)
# Filter per ICP:
#   ceo_sro_50plus:    pravni_forma=s.r.o. AND pocet_zamestnancu>=50
#   cfo_500plus:       pocet_zamestnancu>=500
#   founder_b2b:       sektor=B2B AND vintage<5y

# Output: $OUTPUT/leads-raw.csv (cols: ico, nazev, sektor, ...)
```

### Phase 2: Multi-source enrichment waterfall (1-3 hodiny)

**Waterfall order (cheap → expensive):**

```
1. ARES (free, CZ) → základní data, IČO, adresa, NACE
   ↓ Pokud chybí kontakt
2. ARES Justice (free, CZ) → registr osoby (statutární orgán = jméno + funkce)
   ↓ Pokud chybí email
3. LinkedIn Voyager API (Filip má v expertise/linkedin-automation.yaml) → email + role + connection
   ↓ Pokud LinkedIn fail / žádný email
4. Hunter.io domain search (free 25/měsíc, paid $49/mo) → catch-all email patterns
   ↓ Pokud Hunter fail
5. Apollo direct API (75 free credits/měsíc) → email reveal
   ↓ Pokud Apollo fail
6. SMTP verify (smtp_verifier.py local) → final validation pre-send
```

**Output:** `$OUTPUT/leads-enriched.csv` (cols: ico, nazev, kontakt_jmeno, kontakt_role, email, email_verified, source, enrichment_score)

**Reject criteria:**
- email_verified = false
- catch-all domain bez personal email
- Filip nebo OneFlow team domain (avoid self-spam)

### Phase 3: Personalization (Claude subagenty parallel)

```
Per lead (paralelně Haiku 4 concurrent):
1. Read enriched data + ARES history + LinkedIn profile
2. Generate personalized opener (1 specifický fact)
3. Cialdini hook (reciprocita: nabídnout free analysis pro jejich firmu)
4. Voss calibrated CTA (NIKDY ano-ne otázka)
5. Plain text email (NO HTML, no images, no tracking pixels — deliverability)
```

**Banned phrases (per oneflow-all.md, hard reject):**
- "Dovoluji si"
- "Rád bych Vám"
- "Obracím se na Vás"
- "Inovativní řešení"
- "Win-win"
- Vykřičníky v B2B

**Required structure:**
1. **Subject line** (5-7 slov, no caps, no spam triggers)
2. **First sentence** = personalization (specifický detail z enrichment)
3. **Hook** = reciprocita / value-first (1-2 věty)
4. **Proof** = 1 konkrétní číslo (ověřené z OneFlow track record)
5. **CTA** = Voss calibrated question
6. **Sign-off** = "Dopita" (DM) nebo "Filip Dopita | OneFlow" (email)
7. **PS** = optional, soft second hook

**Length:** max 100 slov (mobile-first per oneflow-all.md)

### Phase 4: Deliverability gate (per email v batch)

Volej `oneflow-deliverability-check` (OpenSpace skill) pro každý email:

```
Checks:
- Subject line spam score (Litmus / Mailgun heuristic)
- Body readability (Flesch-Kincaid CZ)
- HTML tags count (must be 0)
- Link count (must be 0 v prvním emailu)
- Unsubscribe link present (GDPR + deliverability)
- SPF/DKIM/DMARC for sender domain
- Domain warm-up status

Output: SEND | HOLD | FIX | BLOCK
```

**Reject pre-send:**
- Anything other than SEND verdict
- Bounce risk score > 5%
- Spam score > 3 (out of 10)

### Phase 5: Domain rotation + Send (Instantly nebo Postfix)

**Domain strategy (per memory cold_email_setup.md):**
- Domain A: high-priority prospects (warmed >90 days)
- Domain B: testing new sequences (warmed 30-90 days)
- Domain C: warmup only (no sales emails)

**Send infra:**
- **Instantly.ai** (paid, $97/mo) — IF Filip má sub
- **Postfix on Flash** (free, Filip má) — DEFAULT, zero-cost option

**Per-domain limits (warmup-aware):**
- Day 1-7 warmup: max 50 emails/domain/day
- Day 8-21: max 100 emails/domain/day
- Day 22+: max 200 emails/domain/day

**Sequence (5-step):**
- Email 1 (Day 0): personalized, NO CTA, jen value
- Email 2 (Day +3): follow-up s 1 insight
- Email 3 (Day +5): case study nebo metric
- Email 4 (Day +7): direct calibrated question
- Email 5 (Day +10): breakup ("chcete mě odebrat?")

**Gap mezi emailem 1 → 2 ke stejnému adresátovi:** min 48h
**Max sekvencí najednou:** 50 kontaktů/doménu (anti-spam)

### Phase 6: Tracking + Reply handling

```
Daily metrics (cron 22:00):
- Open rate (target >30%)
- Reply rate (target >5%)
- Bounce rate (alert >2%, STOP >4%)
- Spam rate (alert >0.1%, STOP >0.3%)

Output: $OUTPUT/metrics-{date}.json + ntfy push pokud STOP threshold
```

**Reply handling:**
- Auto-route to `~/Documents/01_OneFlow/replies/{campaign}/`
- Filip's daily inbox triage 09:00 (manual, NIKDY auto-reply)
- HARD-STOP: žádné auto-send replies bez Filipova explicit svolení

## OneFlow Brand Voice (mandatory)

Per `oneflow-brand-voice-check` (OpenSpace) + `oneflow-all.md`:

✅ **Use:**
- Vykání novým kontaktům
- Konkrétní čísla (3 emise / 47M Kč / 0 defaultů)
- Calibrated questions (Voss)
- "Dopita" sign-off

❌ **Never:**
- "Dovoluji si"
- "Rád bych"
- "Obracím se na Vás"
- "Inovativní"
- Vykřičníky
- Em dashes
- Generic "Hello"
- Dlouhé úvody

## Cost Discipline (per campaign 100 leadů)

| Item | Cost |
|---|---|
| ARES API enrichment | 0 Kč |
| LinkedIn Voyager API | 0 Kč (Filip's session cookies) |
| Hunter.io free tier | 0 Kč (25 calls/měsíc) |
| Apollo free tier | 0 Kč (75 credits/měsíc) |
| SMTP verify local | 0 Kč |
| Claude personalization | ~$2 (100× Haiku call ~$0.02 each) |
| Postfix Flash send | 0 Kč |
| Instantly.ai (alternativa) | $97/měsíc fixed |
| **Total per 100 leads** | **~$2 (Postfix path) nebo ~$3 (Instantly path)** |

**Apollo Apify removal saves:** ~$50-100/měsíc subscription

## HARD-STOP zóna respect

- ❌ NIKDY auto-send bez Filipova explicit per-campaign approval
- ❌ NIKDY auto-reply k odpovědím
- ❌ NIKDY emaily na FB/Meta accounts (per fb-scrape-safety.md)
- ✅ Draft + verdict + queue → Filip approves → batch send
- ✅ Per-campaign budget cap explicit before run

## Anti-Patterns (NIKDY)

- **Apify Apollo scraper jako default** — DEAD 2026-09. Use direct API.
- **Same domain pro warmup + production** — nuke deliverability
- **HTML emaily v prvním kontaktu** — spam triggers
- **Tracking pixels v cold email** — Gmail flags as spam
- **Skipping deliverability gate** — burns domain reputation
- **Generic "Dobrý den" opening** — žádná personalizace = ignore
- **Ano-ne CTA** — nízká reply rate vs Voss calibrated
- **>200 emails/den/doména v warmup fázi** — Gmail/Outlook flag
- **Auto-reply na replies** — Filip MUSÍ schválit per reply

## Verification

```bash
# Test malá kampaň (5 leadů, dry-run)
~/.claude/skills/cold-outreach-v3/run.sh "test-q2-2026" \
  --icp=ceo_sro_50plus \
  --volume=5 \
  --domain=B \
  --dry-run

# Verify outputs
ls ~/Documents/01_OneFlow/campaigns/test-q2-2026/
# Expected: leads-raw.csv, leads-enriched.csv, drafts/, deliverability-report.json
```

## Integrace s ostatními skills

- `cold-email` (existing) — nizkoulevělný copy templates pokud kreativní block
- `outreach-oneflow` — single high-stakes message (ne batch)
- `leadgen` — lead-ops pipeline (různá vrstva, můj /cold-outreach-v3 spotřebuje její output)
- `expertise/outbound-sales-science.yaml` — Cialdini + Voss + Schwartz frameworks
- `expertise/email-deliverability.yaml` — SPF/DKIM/DMARC technické detaily
- OpenSpace `oneflow-deliverability-check` + `oneflow-brand-voice-check` — gate
- `expertise/data-enrichment.yaml` — ARES + LinkedIn + Hunter + Apollo waterfall config

## Reference

- Source: skool-intel/chase-ai "Cold Outreach Machine 3.0" + "n8n & Apollo Lead Gen Finally Solved"
- OneFlow setup: `~/.claude/projects/<your-project-id>/memory/cold_email_setup.md`
- Domain status: `~/.claude/projects/<your-project-id>/memory/deliverability_2026_04_26.md`
- ICP definitions: `~/.claude/expertise/outbound-sales-science.yaml` § ICP profiles
