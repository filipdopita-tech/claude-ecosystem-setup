# Czech B2B Outbound Playbook

Source: Filip Dopita / OneFlow.cz — expertise/outbound-sales-science.yaml + expertise/email-deliverability.yaml (April 2026)

---

## Czech Market Positioning

Czech B2B buyers — especially investors — require MORE social proof than German or Austrian counterparts. Proof hierarchy matters:
1. ROI case studies with named clients or verifiable numbers (e.g., "Ze 67 000 Kč → 10 000 000 Kč" — from CZK 67k raised to CZK 10M raised)
2. Referrals from mutual contacts (3–5× higher conversion vs. cold approaches)
3. Phone number in email signature (signals legitimacy; measurably increases reply rates)
4. Formal address (vykání — formal "you") mandatory at all stages; switching to tykání (informal) without permission is a disqualifier

**Anti-patterns that kill Czech campaigns:**
- Opening with "Dovoluji si" ("I take the liberty of...") — flags as template spam to Czech readers
- Missing opt-out link (ZoOÚ / GDPR legal requirement)
- Sending without DMARC policy published (deliverability and legal risk)

---

## Lead Sourcing

### ARES API (Czech Business Registry)
- Free, official source for all Czech legal entities (IČO number as primary key)
- Fields available: company name, registered address, legal form, founding date, NACE code
- Rate: no hard cap but respect 1 req/sec to avoid blocks
- Limitation: no contact email; enrichment required post-pull
- Output: tag leads as `ares-scan` in CRM on import

### LinkedIn Sales Navigator
- GCC/MENA search: 90 queries per Sunday 06:00 UTC batch
- Filter by seniority (Director+), company size, sector
- 4-variant A/B testing: Fund | RE (real estate) | HNWI (high-net-worth individual) | Generic
- Export to CRM pipeline immediately; don't let data age >48h before first touch

### Scraping Engine (OneFlow v4.0)
- 10,067 firms processed; 503 qualified (5% qualification rate after enrichment)
- Qualification criteria: Emitent Score across 6 dimensions (Financial 25%, Legal 20%, Business Model 20%, Team 15%, Collateral 15%, Market 5%)
- Score threshold for outreach-ready: pass all 6 dimension minimums

---

## Enrichment Workflow

1. ARES pull → company shell (IČO, name, address, legal form)
2. LinkedIn match → decision-maker identification (founder/CEO/CFO)
3. Apollo enrichment → email + phone (70% hit rate for companies >50 employees; poor for micro-entities)
4. ARES cross-verify for micro/small entities (100% coverage CZ, basic data only)
5. Email verification (ZeroBounce or equivalent) before adding to sequence — bounce rate >3% kills domain reputation
6. GHL (GoHighLevel) import → tag: `ares-scan` or `linkedin-connect` + tier tag

Track enrichment completion in custom GHL field "ARES checks". Mark incomplete enrichments as `tier-c` until verified.

---

## Outreach Cadence

### 5-Email 21-Day Sequence

| Day | Format | Max Length | CTA Style | Key Principle |
|-----|--------|-----------|-----------|---------------|
| 0 | Personalized curiosity hook | 120 words | Soft — low-commitment question | Pattern-interrupt subject line |
| 3 | "Re:" threaded reply | 80 words | Alternative angle | Continuity illusion; never open a new thread |
| 7 | Social proof + case study | 150 words | Medium — book a call | Proof-focused; include specific number |
| 14 | Direct question | 60 words max | Direct — yes/no ask | Remove all friction |
| 21 | "Breaking up" open door | 40–60 words | Soft reengagement | **Highest reply rate of the sequence** |

### Subject Line Principles
- Question format outperforms statement format in Czech B2B (A/B tested)
- Include a number when possible: "Jak jsme 67 000 Kč přeměnili na 10 mil." (How we turned CZK 67k into 10M)
- <45 characters for mobile preview
- Never: "RE: " on Day 0 (deceives; destroys trust if discovered)

### Template: Day 3 (Re: Thread)
```
Subject: Re: [same subject as Day 0]

[First name],

Ze 67 000 Kč jsme klientovi vyraisovali 10 000 000 Kč — za 4 měsíce.
(From CZK 67k we raised CZK 10M for a client — in 4 months.)

Máte zájem o 15 minut, abych vám ukázal, jak?
(Are you open to 15 minutes so I can show you how?)

S pozdravem,
[Name]
[Company] | [Phone +420 XXX XXX XXX]
```

### Template: Day 21 (Break-up)
```
Subject: Naposledy se ozývám (Last time reaching out)

[First name],

Rozumím — načasování nemusí být ideální.
(I understand — the timing may not be right.)

Kdyby se to někdy změnilo, dveře jsou otevřené.
(If that ever changes, the door is open.)

[Name]
```

### WhatsApp Channel Note
OneFlow's 26.2% reply rate was achieved via WhatsApp outreach, not email — for vertical-specific investor campaigns where mobile contact was available. Email baseline target: >3% reply rate. If below 3%, audit subject lines and Day 0 opener before any other variable.

---

## LinkedIn Automation

### Safety Constraints
- **50 connections/day max** without Sales Navigator — above 100/day triggers LinkedIn detection
- Follow-up DMs: 2–3 days post-accept, max 10 messages/day
- Session keepalive every 6 hours (JSESSIONID rotation)
- Playwright: headless, randomized delays 1–3 seconds, human-like scroll patterns

### Throttling Logic
| Acceptance Rate | Action |
|-----------------|--------|
| ≥20% | Normal volume (50/day) |
| <15% | Auto-flag; reduce to 20/day |
| Recovery to ≥20% | Resume normal volume |

### A/B Variant Distribution
- Control A: 40% of sends
- Variant B/C/D: 20% each
- Track in `outreach_sent.ab_variant` DB field
- Minimum 50 sends per variant before declaring a winner

---

## Compliance (GDPR + ZoOÚ)

ZoOÚ = Zákon o ochraně osobních údajů (Czech Personal Data Protection Act), aligned with GDPR.

**Legal basis for cold email in Czech B2B:**
- Legitimate interest (čl. 6 odst. 1 písm. f GDPR) applies when: recipient is a legal entity, email is professional, content is relevant to their business activity
- Individual (soukromá osoba / natural person) requires explicit consent — do not cold-email personal addresses even if business-related

**Required in every email:**
- Clear opt-out mechanism (unsubscribe link or reply "ODHLÁSIT")
- Sender identity + company registered address
- Process opt-outs within 48 hours; remove from all sequences

**Data retention:**
- Contacted leads with no response: delete or anonymize after 2 years
- Opt-out records: retain indefinitely (needed to honor future requests)

**GDPR documentation required:**
- Record of processing activities (ROPA) for prospecting lists
- Legitimate interest assessment (LIA) if using LI as legal basis

---

## Tooling Stack

| Tool | Role | Key Config |
|------|------|-----------|
| GoHighLevel (GHL) | CRM + pipeline + automation | v1 API: `https://rest.gohighlevel.com/v1`; rate limit ~100 req/min |
| Apollo | Email enrichment | Best for >50-employee companies; 70% hit rate |
| Lemlist | Email sequencing | DKIM/SPF/DMARC must be pre-configured per sending domain |
| LinkedIn Sales Navigator | Lead discovery | 90-query Sunday batch; 4-variant A/B |
| ARES API | Czech company data | Free; IČO as primary key |
| ZeroBounce (or equiv.) | Email verification | Run before any sequence import |
| Playwright | LinkedIn automation | Headless; 1–3s delays; keepalive every 6h |

### GHL Tag Architecture
```
Sourcing:       dubai | ares-scan | crowdfunding
Qualification:  tier-a-hot | tier-b | tier-c
Outreach:       cold-email | linkedin-connect | email-replied
Entity type:    hnwi | developer | fund
```

### GHL Sync
- `ghl_sync.py` runs every 15 minutes
- Contact created on first email send; stage advanced on reply/bounce via webhook
- Deduplication: email as primary key; auto-merge on duplicate emails
- No bulk endpoint — all operations iterate with exponential backoff on 429

---

## KPI Thresholds

| Metric | Green | Yellow | Red / Action |
|--------|-------|--------|--------------|
| Open rate | >40% | 25–40% | <25% → fix subject lines |
| Reply rate | >3% | 1–3% | <1% → fix opener + offer |
| Bounce rate | <1% | 1–3% | >3% → auto-pause immediately |
| Spam rate | <0.05% | 0.05–0.1% | >0.1% → halt all campaigns |
| LinkedIn acceptance | >20% | 15–20% | <15% → throttle to 20/day |
| Meeting booking rate | >1% of contacted | — | Track weekly, not per-campaign |

---

## Email Deliverability

### Domain Infrastructure
- **SPF:** `-all` hard fail (not `~all` soft — soft fail does not protect reputation)
- **DKIM:** 2048-bit minimum; rotate every 6 months
- **DMARC progression:**
  1. `p=none` (monitoring only, 2 weeks)
  2. `p=quarantine;pct=10` (partial enforcement, 2 weeks)
  3. `p=quarantine;pct=100` (full quarantine, 4 weeks)
  4. `p=reject;pct=100` (full rejection — target state)
- Separate sending domain from primary domain (e.g., send from `mail.company.cz`, protect `company.cz`)

### Warmup Progression
```
Week 1:  20 emails/day
Week 2:  50 emails/day
Week 3:  100 emails/day
Week 4+: 200+ emails/day
```
Rule: consistent daily frequency beats burst patterns. Gmail and Czech ISPs penalize sudden volume spikes.

### Proofpoint Blocking Incident (April 2026)
- **Blocked IP:** 173.212.220.67 (Flash IP) — 554 error on delivery
- **Root cause:** IP reputation on shared SendGrid infrastructure; not domain-specific
- **Immediate fix:** Switch to Czech backup IP 89.221.212.203 (unblocked, operational)
- **Delisting:** https://support.proofpoint.com/dnsbl-lookup.cfm — 24–72 hour processing time
- **Monitoring:** 2× daily cron checking 89.221.212.203 range via local blacklist scripts
- **Lesson:** Never rely on a single sending IP; maintain verified backup IP before campaigns launch

### Google Postmaster Tools
- Tracks domain reputation independently from SendGrid/Lemlist metrics
- Check weekly — a domain reputation drop precedes inbox placement issues by 3–5 days
- Green = >95% inbox; Yellow = 80–95%; Red = <80% (stop and remediate immediately)

---

## Replicable Patterns (Copy-Paste Ready)

1. **Bounce auto-pause:** Trigger at >3%; resume only when verification rate returns to acceptable baseline
2. **Day 21 "break-up" email:** Highest reply rate in the sequence — never skip it
3. **26.2% reply rate channel insight:** WhatsApp outperforms email for investor verticals where mobile contact exists; channel selection > copy optimization
4. **Referral multiplier:** Mutual connection mention in opener = 3–5× conversion lift vs. fully cold
5. **Phone in signature:** Simple trust signal; add to all templates
6. **Emitent 6-dimension scoring:** Financial 25% + Legal 20% + Business Model 20% + Team 15% + Collateral 15% + Market 5% — qualify before enrichment to avoid wasted API calls
