---
name: ads-meta
description: Meta (Facebook + Instagram) ads strategy, campaign structure, creative requirements, audience targeting, and optimization. Covers CBO/ABO, creative specs, kill rules, scaling rules, iOS 14.5 implications, and Czech-market CPM benchmarks.
allowed-tools: Read, Write, WebFetch, WebSearch, Bash
last-updated: 2026-04-27
version: 1.0.0
---

# Meta Ads Agent

Expert-level Meta (Facebook + Instagram) advertising strategy and execution.

## Triggers
"Meta ads", "Facebook ads", "Instagram ads", "Reels ads", "Stories ads", "FB campaign", "Meta campaign", "advantage+", "CBO", "ABO"

---

## 1. Account Structure

### CBO vs ABO
**CBO (Campaign Budget Optimization):** Budget set at campaign level; Meta distributes across ad sets dynamically.
- Use when: 3+ proven ad sets, trust Meta's allocation, scaling past €1K/day
- Advantage: Algorithm finds efficient allocations; reduces manual management
- Risk: One ad set can cannibalize budget from others; Meta favors broad audiences over niche ones

**ABO (Ad Set Budget Optimization):** Budget set at ad set level; full manual control.
- Use when: Testing phase (need controlled spend per ad set), launching new audiences, retargeting (must protect budget)
- Advantage: Precise control; essential for protecting retarget budgets from getting merged with cold traffic
- Structure: ABO for testing → CBO for scaling proven ad sets

### 3-2-2 Method (Andrew Foxwell)
Campaign → 3 ad sets (audience variations) → 2 creatives per ad set → test
After 7-14 days: identify winning ad set + creative combination, consolidate, scale in CBO.

### Campaign Naming Convention (Adam Kropáček)
```
[Platform]_[Objective]_[Audience]_[Offer]_[YYYY-MM-DD]
Example: META_CONV_ColdBroad_FreeGuide_2026-04-27
```

### Learning Phase
- Meta's algorithm requires 50 optimization events per ad set per week to exit learning phase
- During learning: CPAs are volatile; do not make structural changes
- Learning reset triggers: budget change >20%, audience change, creative change, bid change
- If stuck in "Learning Limited" after 7 days: consolidate ad sets or broaden audience

---

## 2. Audience Strategy

### Cold Traffic Audience Ladder
| Tier | Type | Size (CZ market est.) | Use case |
|------|------|----------------------|----------|
| 1% LAL | 1% Lookalike from customer list | 20-50K | Most similar to existing buyers |
| 1-3% LAL | Broader lookalike | 50-150K | Scale when 1% saturates |
| 3-5% LAL | Wide lookalike | 150-300K | Top of funnel reach |
| Broad | No targeting, let Meta optimize | All of CZ | Advantage+ audience; often outperforms manually stacked |
| Interest stacking | Layered interest targeting | Varies | Use when no customer list available for LAL |

### Advantage+ Audiences (2024+ Meta direction)
Meta's AI-driven targeting. Provide creative signals, let Meta find who converts.
- Often outperforms manual interest stacking for cold traffic on established accounts
- Requires 30+ conversions/month for Meta's model to be effective
- Keep broad targeting checked; Meta uses it as signal, not constraint

### Exclusion Layers (apply always)
- Existing customers: exclude by customer list (email/phone upload)
- Recent converters: exclude 7-14 day conversion window
- <10-second bouncers: exclude page engagement <10s (prevents wasted impressions)
- Retarget audiences: exclude from cold campaigns (don't let cold CPM hit warm traffic)

### Retargeting Windows (Adam Kropáček)
| Audience | Stage | Window | Bid approach |
|----------|-------|--------|-------------|
| Video viewers (25%) | TOFU | 30-90 days | Lower bid OK |
| Blog readers | TOFU | 30-90 days | Lower bid OK |
| Product page visitors | MOFU | 14-30 days | Standard |
| Pricing page visitors | MOFU | 7-14 days | Increase bid |
| Cart abandoners | BOFU | 1-7 days | Max bid; high-value |
| Lead form abandoners | BOFU | 1-7 days | Max bid |
| Exclude: recent purchasers | — | 14 days | Excluded |

---

## 3. Creative Requirements — Placement Specs

### Aspect Ratios
| Placement | Ratio | Resolution | Max duration |
|-----------|-------|------------|--------------|
| Feed (FB + IG) | 1:1 or 4:5 | 1080x1080 / 1080x1350 | 60 seconds |
| Reels | 9:16 | 1080x1920 | 90 seconds |
| Stories | 9:16 | 1080x1920 | 15 seconds |
| In-stream video | 16:9 | 1920x1080 | 5-15 seconds |
| Right column (desktop) | 1:1 | 1200x1200 | Static only |
| Collection | Square | 1:1 | — |

**Best practice:** Always produce 9:16 master. Crop to 1:1 and 4:5 from safe zone (center of frame).

### Video File Requirements
- Format: MP4 or MOV
- Codec: H.264
- Audio: AAC, 128kbps+
- Max file size: 4GB
- Safe zone: Keep text/faces within center 80% of frame (edges masked on some placements)

### Hook Mechanics — First 3 Seconds
- 85% of Meta video is consumed with sound off → text overlay on frame 1 is mandatory
- 0-3 seconds determines scroll or watch (Meta internal data)
- Target: 50%+ still watching at 3 seconds (hook-to-view ratio)
- Text placement: top-left or center-top; avoid bottom 15% (hidden by UI elements)
- Frame 1 must include: a face OR a product in use OR a bold text statement

### Retention Cliffs
| Completion | Signal | Action |
|------------|--------|--------|
| 25% | First quality filter | Track; anything below 25% avg = weak hook |
| 50% | Message-market fit | Strong engagement; optimize this creative |
| 75% | High intent | Retarget this audience immediately |
| 95% | Hot audience | Retarget with direct offer / scarcity close |

---

## 4. Hook Patterns Proven on Meta

### 1. Founder-to-Camera (Authentic Confession)
Setup: Informal setting, direct eye contact, first 2 words establish stakes.
Example: "We lost €40,000 on Meta ads before I figured this out. Here's what we changed."
Why: Authenticity signals override polished production in Meta feed context. UGC-style outperforms studio 60% of the time for cold traffic.

### 2. Dramatic Stat Drop (Pattern Interrupt)
Setup: Bold text on minimal background, contrasting color scheme.
Example: "4.8x ROAS. 30 days. €0 to €45K. Here's the structure." [black text, white background]
Why: Data-first hooks for business-aware audiences signal time value; no story needed.

### 3. Problem-Pain Loop
Setup: Describe the exact pain point in the first 2 seconds, pause.
Example: "You've tried Meta ads. Spent €5K. Got nothing back. Sound familiar?"
Why: Recognition drives attention. If it describes their experience, they're watching.

### 4. Contrarian Claim
Example: "Stop split-testing your Facebook copy. It's not the copy that's killing you."
Why: Takes opposite position to conventional wisdom; cognitive dissonance drives watch time.

### 5. Urgency Command + Specificity
Example: "Offer closes Sunday midnight — €2,400 off. Here's exactly what's included."
Why: Real urgency + specific price creates click pressure. Vague urgency is ignored.

### 6. Transformation Bridge
Example: "January: €8K spend, 0.9x ROAS. March: same budget, 3.8x ROAS. One structural change."
Why: Credible transformation narrative with specific numbers. Before/after creates aspiration.

### 7. Social Proof Lead
Example: "174 brands use this system. Average ROAS increased 2.1x in the first 60 days."
Why: Volume + specificity creates instant credibility. Specificity ("174" vs "hundreds") is crucial.

### 8. Curiosity Gap with Partial Reveal
Example: "There's one Meta setting that 90% of advertisers have never touched. It controls who sees your ad first."
Why: Information gap theory (Loewenstein) — partial reveal compels resolution. Mechanism withheld.

---

## 5. Numerical Thresholds — Meta Kill Rules

### CTR
- Target: >1.5% link CTR (cold traffic)
- Acceptable: 0.8-1.5%
- Kill signal: <0.8% link CTR after 500+ impressions
- CPC kill rule: >2x category benchmark after 100+ clicks

### CPM Benchmarks
| Market | Cold CPM range | Warm/Retarget CPM |
|--------|---------------|-------------------|
| Czech Republic | €5-15 | €8-20 |
| Slovak Republic | €4-12 | €7-15 |
| Germany | €8-25 | €12-30 |
| United States | $15-40 | $25-60 |
| United Kingdom | £8-20 | £12-25 |

CPM spikes indicate: audience saturation, increased competition (seasonal), learning phase instability, or low relevance score.

### ROAS Targets
| Audience temperature | Target ROAS | Kill below |
|---------------------|-------------|------------|
| Cold (prospecting) | 2.5x | 1.5x at 7 days |
| Warm (engaged) | 5x | 3x |
| Hot (retarget BOFU) | 10x | 4x |
| SaaS (LTV/CAC) | 3:1 LTV/CAC | 2:1 |

Break-even ROAS formula: 1 ÷ Gross Margin. 50% margin → break-even at 2x. Run nothing below break-even past week 1.

### Kill Decision Tree
1. **<48 hours:** Do not kill. Learning phase data is unreliable.
2. **Day 3-7, €50-100 spent, zero conversions:** Kill creative. Test new hook.
3. **Day 7, CTR <0.8%:** Kill ad set or refresh creative.
4. **Day 14, ROAS <1.5x cold:** Kill campaign, audit landing page, rebuild angle.
5. **CPC >2x benchmark consistently:** Landing page CRO issue OR creative relevance issue. Check both before killing.

### Scaling Rules
- Maximum budget increase: 20-30% per day (Adam Kropáček rule: never exceed 30% at once)
- Preferred scaling method: Horizontal duplication (new ad set with same creative + audience) > vertical budget increase
- Vertical scale: budget doubling resets learning phase on that ad set
- Duplicate winning ad set: new ad set ID = fresh learning, same audiences — allows scale without disruption

---

## 6. Pixel & CAPI Setup Checklist

### Pixel Setup (mandatory)
- [ ] Meta Pixel installed on ALL pages (including confirmation page)
- [ ] Standard events firing: PageView, ViewContent, AddToCart, InitiateCheckout, Purchase
- [ ] Purchase event includes: value, currency, content_id
- [ ] Conversion test: verify via Events Manager → Test Events tab
- [ ] Deduplication: set event_id on both browser pixel and CAPI to prevent double-counting

### Conversions API (CAPI) — Required Post-iOS 14.5
- CAPI sends server-side conversion data directly to Meta, bypassing browser-level tracking loss
- Match rate target: >70% (events matched to Meta users)
- Required parameters for high match rate: email (hashed), phone (hashed), fbc (click ID), fbp (browser ID), client_user_agent, client_ip_address
- Event deduplication: include event_id on both browser and server events; Meta deduplicates by event_id
- Implementation options: Meta's native CAPI, partner integration (Shopify, WooCommerce), Gateway (hosted solution)

### UTM Parameters (mandatory for attribution)
```
utm_source=facebook
utm_medium=paid
utm_campaign={{campaign.name}}
utm_content={{adset.name}}
utm_term={{ad.name}}
```

---

## 7. iOS 14.5 / SKAdNetwork Implications

### What Changed (April 2021, still relevant 2026)
- Users must opt-in to tracking (ATT prompt). Typical opt-in rate: 20-40%.
- Meta lost visibility into ~60-70% of iOS conversions.
- Reporting delay: up to 3-day reporting window for iOS.
- Attribution window reduced: default changed from 28-day click to 7-day click + 1-day view.

### Mitigation
1. **CAPI is non-negotiable.** Server-side events recover 40-60% of lost signal.
2. **Aggregated Event Measurement (AEM):** Verify your domain in Meta Business Manager. Configure up to 8 conversion events in priority order.
3. **Attribution window:** Use 7-day click, 1-day view for accurate comparison. 28-day window shows legacy data only.
4. **Over-reporting on Android, under-reporting on iOS:** True blended ROAS is usually higher than Meta reports.
5. **Model-based conversions:** Meta uses statistical modeling to fill gaps. Results = real + modeled; accept the uncertainty.

---

## 8. Meta Policy Traps — Most Common Rejection Reasons

### Ad Disapproval Triggers
1. **Before-and-after claims** in images: explicit before/after showing body transformation = policy violation
2. **Personal attributes targeting implication:** Copy that implies targeting by health condition ("If you have diabetes..."), financial status ("Are you struggling with debt?"), or political views
3. **Shocking or sensational imagery:** Excessive violence, strong negative emotions in hero image
4. **Misleading claims:** Guaranteed results without qualification ("Guaranteed to make €10K in 30 days")
5. **Prohibited industries:** Payday loans, multi-level marketing (without explicit approval), tobacco, weapons

### Special Ad Categories (must declare, limits targeting)
- Housing, employment, credit, social issues/elections/politics
- When declared: cannot use age, gender, ZIP code targeting — only location, broad interest
- Financial products: MAY require special ad category if offering credit/insurance

### The "20% Text Rule" — DEPRECATED
Meta removed the 20% text rule for images in 2021. Images with heavy text are still allowed but may receive lower delivery. Best practice: keep text overlay under 30% of image area for optimal delivery.

### Account Health
- Two ad disapprovals = "Ad Limit" on account
- 5+ disapprovals = account review, potential restriction
- Always appeal rejections with specific reasoning; generic appeals fail
- Appeal via the Ad Account Quality page, not Business Support

---

## 9. Optimization Flowchart

**ROAS too low → Diagnose in order:**
1. Is conversion tracking firing correctly? (Check Events Manager, verify Purchase event)
2. Is the landing page load time <3 seconds? (High bounce kills ROAS regardless of ad quality)
3. Is the audience warm enough for the offer presented? (Cold traffic → cold offer; warm traffic → hot offer)
4. Is the hook driving 50%+ 3-second views? (If not, the audience never sees the offer)
5. Is the CTA aligned with the next logical step? (Don't ask for purchase from unaware audience)

**CTR low → Creative resonance problem:**
- Hook failing → test 4 new hooks on same concept (keep body identical)
- Audience mismatch → check audience insights for age/gender skew vs. ICP
- Ad fatigue → check frequency; if >4x cold, kill and refresh

**CPM rising → Supply or relevance issue:**
- Audience too narrow → expand targeting or use Advantage+
- Seasonal competition → expect +20-40% CPM during Q4, holidays
- Low relevance → improve creative match to audience; Meta rewards relevance with lower CPMs

---

## 10. Bidding Phase Progression (Adam — paid-ads)

Sequential phases tied to conversion volume — never skip phases:

| Phase | Trigger | Bid Strategy | Purpose |
|-------|---------|-------------|---------|
| Phase 1 — Initial | Account launch | Manual CPC or cost caps | Gather baseline data; no algorithmic signal yet |
| Phase 2 — Accumulation | 0–50 conversions | Stay manual; optimize creatives + audiences | Build statistical base; premature automation kills accounts |
| Phase 3 — Automation | 50+ conversions/month | Switch to automated (Advantage+ or target CPA/ROAS) | Algorithm has enough signal; anchored to historical performance |
| Phase 4 — Refinement | Post-automation | Monitor, adjust targets incrementally (±10–15%) | Fine-tune; stay within ±20–30% budget changes to avoid learning reset |

**Never switch bid strategies during peak-traffic windows** (Q4, holidays) — learning phase reset during peak = wasted budget.

## 11. Ad Creative Hook Angles — 8 Core Patterns (Adam — ad-creative)

| Angle | Template | Example |
|-------|----------|---------|
| **Pain Point** | "Stop [pain]" or "[Action] without [friction]" | "Stop wasting time on manual reports" |
| **Outcome** | "Achieve [result] in [timeframe]" | "Ship code 3× faster in 14 days" |
| **Social Proof** | "Join [number]+ [audience] who..." | "Join 10,000+ teams using..." |
| **Curiosity** | "The [descriptor] secret [audience] use" | "The one Meta setting top brands never share" |
| **Comparison** | "Unlike [competitor], we [benefit]" | "We offer what agencies don't" |
| **Urgency** | "Limited: get [offer] [constraint]" | "First 500 signups get free access" |
| **Identity** | "Built for [specific role/segment]" | "Made for growth marketers only" |
| **Contrarian** | "Why [common practice] doesn't work" | "Manual creative testing costs more than it earns" |

Generation workflow: define 3–5 distinct angles → generate variations per angle (word choice, tone, structure) → validate against character limits → analyze top performers → extend winners + test 1–2 unexplored angles.

## 12. Ad Fatigue Thresholds & Frequency Management (Adam — paid-ads)

| Retargeting Stage | Audience Window | Frequency Cap | Action at Breach |
|-------------------|-----------------|---------------|-----------------|
| Hot retargeting | 1–7 days | 4–7× daily acceptable | Test new creative angle; do not kill — high-value audience |
| Warm retargeting | 7–30 days | 3–5× per week | Rotate creative; refresh hook |
| Cold retargeting | 30–90 days | 1–2× per week | Kill and rebuild if CTR falling |
| Cold prospecting | N/A | Optimal 2–4× total | Kill or refresh at 5×+ cold |

**Fatigue diagnostic:** frequency 3.5×+ on cold audiences → CPM rises, CTR falls (diminishing returns begin). At 5×+ cold: kill or refresh creative immediately.

**Learning phase discipline:** Never make structural changes (budget >20%, audience, creative, bid) during learning phase. Each change resets the 50-conversion clock.

## 13. Czech-Specific Considerations

- Financial ads: ČNB compliance mandatory; risk disclaimer required for investment products
- Consumer protection: ZoOR §2 — no misleading claims, no fake urgency
- Language: Vykání in all ad copy targeting adults unless brand explicitly uses tykání for Gen Z
- Payment methods in ad creative: Czech market responds to local payment method imagery (Česká spořitelna, Komercní banka logos as trust signals)
- Carousel and collection ads: Czech e-commerce responds well to price-point clarity; show CZK price in ad copy
- Peak season: Czech e-commerce peaks Nov-Dec (Christmas), Valentine's Day, summer (June-July for outdoor/lifestyle)

---

## 14. Lookalike Audience Seed Quality (Adam — paid-ads)

Build lookalikes **from best customers by lifetime value, NOT by volume**. Seeding with a large list of low-intent customers dilutes the model — Meta's LAL algorithm mirrors the seed quality directly.

Seed hierarchy (best to worst):
1. Top-LTV customers (purchasers with highest lifetime spend)
2. Repeat purchasers
3. Qualified leads (not all leads)
4. All purchasers
5. All website visitors (weakest — do not use as primary seed)

**Exclusion rules (apply every campaign):**
- Existing customers — exclude unless upsell-focused
- Recent converters — 7–14 day lookback exclusion window
- Bounced visitors — <10 seconds on-site
- Irrelevant page visitors — careers, support, about sections

---

## 15. Advantage+ Shopping Campaigns (ASC) — Deep Dive

(industry standard 2024-2026, Meta Blueprint)

ASC collapses prospecting + retargeting into a single Meta-managed campaign. Meta's auction decides in real time whether to serve a given impression to a cold or warm user, trading full advertiser control for ML efficiency.

### ASC vs Traditional ABO/CBO
| Dimension | ASC | Traditional CBO | ABO |
|-----------|-----|----------------|-----|
| Structure | 1 campaign, 1 ad set | 1 campaign, N ad sets | 1 campaign, N ad sets, manual budget/ad set |
| Budget control | Campaign-level, Meta allocates 100% | Campaign-level, Meta allocates across ad sets | Full manual per ad set |
| Prospecting vs retarget split | Meta-controlled (can set existing customer budget cap) | Manual by ad set segmentation | Manual |
| Creative control | Advertiser supplies all assets; Meta tests combinations | Per ad set | Per ad set |
| Best for | E-commerce with catalog ≥50 SKUs, stable CPA target | Scaling proven audiences | Testing, budget protection |
| When ASC wins | Catalog depth, high-volume conversion data (50+ events/week), wide target market | Mid-scale with defined audience segments | Launch phase, retargeting budget isolation |

### Setup — Step by Step
1. **Campaign objective:** Sales. Select "Advantage+ Shopping Campaign" (separate toggle from standard Shopping).
2. **Existing customer budget cap:** Set this. Without it, Meta defaults to spending ~80% on retarget (cheaper conversions, inflated ROAS). Cap at 20-30% max for acquisition focus.
3. **Catalog connection:** Connect product catalog. ASC uses DPA by default for catalog-eligible products.
4. **Creative mix:** Upload both existing proven creatives AND 2-3 new variants. Meta's internal data shows 3:2 ratio (existing:new) sustains performance while testing. All-new creative in ASC = longer warm-up phase.
5. **Automated placements:** Do not restrict. ASC depends on cross-placement ML signal. Restricting to feed-only degrades performance by 15-25% (Meta internal estimates).
6. **Budget:** Minimum €50/day for meaningful signal. Below this, learning phase can take 4+ weeks.

### Incrementality Measurement
ASC's reported ROAS typically looks excellent because Meta attributes cross-sell, upsell, and view-through conversions. To measure true incrementality:
- Run a Conversion Lift Study (available via Meta Business Manager → Experiments): holdout 10-15% of audience, compare conversion rate between exposed vs holdout.
- iROAS (incremental ROAS) = (lift in revenue from exposed group) / ad spend. Healthy iROAS target: ≥1.5x for e-commerce.
- CPM bump: ASC runs on a broader auction than ABO/CBO prospecting campaigns — expect CPM 10-20% higher than cold ABO. The trade-off is algorithm efficiency driving CPA 15-30% lower than equivalent manual structure (Meta's published case studies, 2024).

### When NOT to Use ASC
- Catalog <50 SKUs (algorithm needs breadth to optimize DPA across segments)
- <30 conversions/month (insufficient signal for Meta's ML to outperform manual)
- Brand awareness objective — ASC is conversion-only
- Retargeting-heavy strategy requiring precise audience isolation

---

## 16. Conversion API (CAPI) — Implementation Depth

(industry standard 2024-2026, Meta for Developers documentation)

### Server vs Browser Pixel
| Layer | How it works | What it loses | What it keeps |
|-------|-------------|---------------|---------------|
| Browser pixel | JS fires from user's browser on event | iOS opt-out (~60-70% loss), ad blockers, Safari ITP 7-day cap | Behavioral context, session data |
| CAPI (server-side) | Your server POSTs event data to Meta's `/events` endpoint | None of the above; bypasses browser | Requires server infrastructure or partner integration |

Both must run in parallel — CAPI without browser pixel loses real-time behavioral context; browser without CAPI loses iOS conversions. Deduplication via `event_id` prevents double-counting.

### Event Match Quality (EMQ) Score
EMQ (0-10 scale) measures how well your events match to Meta user profiles. Target: **≥7.0**.
- EMQ 8-10: Excellent match rate (>70% of events matched to a user profile)
- EMQ 5-7: Acceptable; optimize by adding more user parameters
- EMQ <5: Critical — most events not matched; CAPI providing minimal incremental value

**Parameters that raise EMQ (in order of impact):**
1. `em` — hashed email (SHA-256, lowercase before hashing) — single biggest EMQ driver
2. `ph` — hashed phone (E.164 format, SHA-256)
3. `fbc` — Facebook click ID (from `fbclid` URL parameter, stored in cookie)
4. `fbp` — Facebook browser ID (from `_fbp` cookie, set by Meta pixel on first load)
5. `client_ip_address` — raw IP of user's browser
6. `client_user_agent` — browser UA string
7. `fn`, `ln` — hashed first/last name
8. `ct`, `st`, `zp`, `country` — hashed city/state/ZIP/country

Minimum viable CAPI payload: `em` + `ph` + `fbc` + `fbp` + `client_ip_address` + `client_user_agent`. Without email, EMQ rarely exceeds 6.0.

### Deduplication Rules
- Set identical `event_id` on browser pixel AND CAPI event for the same user action.
- `event_id` format: string, unique per event occurrence (UUID or `{order_id}_{event_name}` pattern).
- Meta deduplication window: events with the same `event_name` + `event_id` within 48 hours are deduplicated automatically.
- Common mistake: using order ID alone as `event_id` — if browser fires and server fires both with `event_id: "order_123"`, Meta deduplicates correctly. If CAPI fires without matching `event_id`, double-counts.

### fbp/fbc Cookie Handling
- `_fbp` cookie: Set by Meta pixel automatically on page load. Format: `fb.1.{timestamp}.{random}`. Persist 90 days. Pass in CAPI `fbp` parameter.
- `fbc` cookie: Set when `fbclid` query parameter exists in URL. Format: `fb.1.{timestamp}.{fbclid_value}`. Parse from URL on landing, store in cookie. Pass in CAPI `fbc` parameter.
- Both cookies expire and require re-acquisition. If user visits without `fbclid` (organic navigation), `fbc` is empty — that is correct.

### GTM Server-Side Pattern
For implementations without direct server access:
1. Deploy GTM Server Container (Cloud Run, App Engine, or stape.io hosted).
2. Client-side GTM tag sends to GTM server container endpoint (first-party domain, e.g., `tracking.yourdomain.com`).
3. GTM server tag POSTs to Meta CAPI endpoint with full user parameters.
Benefit: first-party domain improves cookie persistence vs third-party `connect.facebook.net`.

### Common Implementation Gotchas
- **Currency mismatch:** CAPI `value` must be numeric (not "€1,200" — strip currency symbol and comma). `currency` must be ISO 4217 (EUR, USD, CZK — not "€", "$", "Kč").
- **Timestamp format:** `event_time` is Unix timestamp (seconds, not milliseconds). Off-by-1000x is a common bug (JS `Date.now()` returns ms; divide by 1000).
- **Missing `content_ids`:** For DPA/catalog ads, `content_ids` array on Purchase/AddToCart events must match `id` field in product catalog exactly (string comparison, case-sensitive).
- **Production vs test dataset:** CAPI events sent to `test_event_code` (test dataset) do not affect delivery optimization. Remove test code before launch.
- **Partner integrations (Shopify, WooCommerce):** Native integrations handle most of the above, but check EMQ after setup — default integrations often miss `fn`/`ln`/`ct` which drops EMQ below 7.

---

## 17. Aggregated Event Measurement (AEM) — Post-iOS 14.5

(Meta AEM documentation, industry standard 2021-2026)

### The 8-Event Prioritization Rule
Meta allows maximum 8 conversion events per domain for measurement. Events outside your top 8 are not used for optimization or attribution on iOS 14.5+ devices.

**Priority order logic (highest-value event = priority 1):**
1. **Purchase** (priority 1 — always; this is what you optimize toward)
2. **Initiate Checkout** (priority 2 — high intent; critical for abandoned cart attribution)
3. **Add to Cart** (priority 3 — micro-conversion; useful for full-funnel view)
4. **Lead** (priority 4 — if lead gen business; otherwise omit)
5. **Complete Registration** (priority 5 — if multi-step funnel)
6. **Add Payment Info** (priority 6 — for e-commerce with payment page)
7. **Search** (priority 7 — weak signal; rarely justified in top 8)
8. Slot 8: Reserve for your most valuable custom event (e.g., "Qualified Lead" for B2B)

**Why "View Content" rarely belongs in top 8:** View Content fires on nearly every product page, generating enormous volume with poor signal quality for algorithmic optimization. It displaces a higher-intent event and degrades campaign optimization. Exception: extremely short funnel where View Content is the meaningful action (e.g., content publisher).

### Domain Verification Mandate
- Must verify domain in Meta Business Manager → Brand Safety & Suitability → Domains.
- Verification: DNS TXT record OR HTML meta tag OR file upload to root.
- Without domain verification: AEM 8-event configuration is unavailable; iOS attribution is broken; ads may be disapproved.
- One domain per Business Manager. Subdomains count under the apex domain.

### Attribution Windows (2024+ Default)
- **Default (as of 2024):** 7-day click, 1-day view. This replaced the pre-2021 28-day click default.
- **1-day click:** Most conservative; lowest volume; use for comparison baseline.
- **7-day click:** Standard for e-commerce and lead gen.
- **1-day view:** Credits conversions from users who saw (not clicked) the ad within 24 hours. Tends to over-count for high-frequency campaigns.
- Conversion lag: iOS-modeled conversions appear 1-3 days after the actual conversion event (Meta's aggregation delay). Do not optimize or kill campaigns based on yesterday's data alone.

### Practical Impact
- Segment reporting by device OS to distinguish iOS (modeled) vs Android (direct): Breakdown → Device → Platform.
- Expect 15-30% lower reported conversion volume on iOS vs pre-ATT baseline for same spend.
- True performance is usually better than reported; CAPI + EMQ ≥7 recovers most of the signal.

---

## 18. Catalog Setup for Dynamic Product Ads (DPA)

(Meta Commerce Manager documentation, industry standard 2024-2026)

### Feed Schema — Required Fields
| Field | Format | Notes |
|-------|--------|-------|
| `id` | String, unique | Must match `content_ids` in pixel events exactly |
| `title` | String, ≤150 chars | [Brand] [Product] [Key attribute]; front-load keywords |
| `description` | String, ≤9999 chars | First 200 chars are what DPA shows; make them count |
| `link` | URL | Must be live, accessible, match `availability` |
| `image_link` | URL | Min 500×500px; recommended 1080×1080 for square DPA |
| `brand` | String | Required for all products |
| `condition` | Enum: new, refurbished, used | Required |
| `price` | String: "19.99 EUR" | Must match landing page; mismatch = disapproval |
| `availability` | Enum: in stock, out of stock, preorder | Must be real-time accurate |
| `gtin` | String | Barcode (EAN/UPC/ISBN/JAN). Enables better catalog match rates |
| `mpn` | String | Manufacturer Part Number. Required if no GTIN |

### Optional but High-Impact Fields
- `sale_price`: "14.99 EUR" — triggers strikethrough pricing in DPA creative automatically
- `additional_image_link`: Up to 10 supplementary images Meta can use in carousel DPA
- `google_product_category`: Improves Meta's classification for audience targeting
- `age_group`, `gender`, `color`, `size`: Required for apparel; improves relevance targeting

### Feed Refresh Cadence
- E-commerce with high inventory turnover: hourly feed refresh (via API or scheduled URL fetch)
- Standard e-commerce: daily refresh minimum
- Static catalog: weekly — but price/availability mismatches cause disapprovals; never let a feed go stale >7 days

### Common Feed Errors and Fixes
| Error | Root cause | Fix |
|-------|-----------|-----|
| Price mismatch | Feed price ≠ landing page price (incl. VAT) | Sync feed from same data source as website |
| Invalid GTIN | Non-standard barcode format | Validate against GS1 check-digit algorithm before upload |
| Image too small | Image <500×500px | Regenerate all images at ≥1080×1080 |
| Missing required field | `availability` or `condition` omitted | Add default value in feed transformation layer |
| URL not crawlable | Login-gated or geo-blocked URLs | Whitelist Meta's crawlers (Meta IP ranges published) |

### Feed Quality Score
Meta assigns a catalog quality score (1-100). Score <60 = restricted delivery on DPA campaigns.
- View in Commerce Manager → Catalog → Data Sources → Diagnostics.
- Most impactful improvements: GTIN coverage >80%, unique titles per variant (not "Shirt - Blue", "Shirt - Red" with same description), correct availability tags.

### Multi-Feed Strategy by Language/Market
- Create separate catalog per language/market (e.g., `catalog-CZ-cs`, `catalog-DE-de`).
- Assign catalog to country-targeted ad set. Prevents Czech copy in German ad.
- Shared base catalog + feed rules override: use Meta's feed rules to transform titles/descriptions per market without maintaining full separate feeds.

---

## 19. Ad Fatigue — Advanced Diagnosis

(Andrew Foxwell methodology; industry standard 2024-2026)

### The Burn Threshold (Quantified)
**Primary signal:** Frequency >5 on cold prospecting audiences AND simultaneous CTR drop >25% from baseline = confirmed burn. Kill or refresh within 48 hours.

**Frequency-ROAS diminishing returns curve:**
- Frequency 1-2: Efficient; under-exposed; increase reach if budget allows
- Frequency 2-3: Peak efficiency zone for cold traffic; optimal CTR/CPM ratio
- Frequency 3-4: First diminishing returns; CPM begins to rise (+5-15%), CTR flat or slight decline
- Frequency 4-5: Accelerating decline; CPM +15-30% vs frequency 2 baseline; CTR -15-25%
- Frequency 5+: Burn zone; CPM +30-50%; CTR -25-40%; comment quality degrades (negative comments increase)

### Secondary Fatigue Signals (beyond frequency)
1. **CPM increase without audience change:** +20% week-over-week CPM with same audience size = saturation signal, not market competition
2. **Comment quality drop:** Shift from positive/curious comments to "stop showing this to me" or repetitive negative — indicates over-exposure
3. **CTR by impression count breakdown:** Pull Breakdown → Dynamic Creative → check if top creative's CTR is declining even on first/second impressions (pure fatigue, not just frequency)
4. **Thumbstop rate drop:** If 3-second video views / impressions drops >20% week-over-week with same creative = hook fatigue specifically

### Winner Refresh Cadence
| Creative type | Target lifespan | Refresh trigger |
|---------------|----------------|-----------------|
| Evergreen (always-on brand) | 3-6 weeks | CTR -20% or frequency >5 cold |
| Promotional (sale/event) | 1-2 weeks | Campaign end or frequency >3 cold |
| Retargeting (warm audience) | 4-8 weeks | Comment tone shift or CTR -30% |
| UGC/testimonial | 6-10 weeks | Slower fatigue; audience resonance is authentic |

**Refresh without reset:** Launch new creative in the same ad set (don't create new ad set). Pausing winning ad set resets delivery learning. Test new creative alongside existing in same ad set; only pause old creative after new one proves performance over 7 days.

---

## 20. Andromeda/Lattice Algorithm Signals (2025+)

(Meta engineering blog, industry standard 2025-2026)

Meta's ranking system (codenamed Andromeda for retrieval, Lattice for ranking) replaced the earlier EdgeRank derivative. Key signals that favor your ads:

### What the Ranking Rewards
1. **Creative diversity index:** Accounts with 3+ active creative formats (static image, video, carousel) per ad set receive broader audience sampling before Meta commits budget. Single-format accounts are penalized in the retrieval stage.
2. **Variant testing within ad set:** Meta's Lattice model promotes ad sets actively testing creative variants vs static single-creative ad sets. Running 2-4 active creatives per ad set signals "healthy advertiser" to the system.
3. **Automated placements (don't restrict):** Restricting to Feed-only or Reels-only reduces the signal surface. Andromeda uses cross-placement behavioral data to sharpen audience prediction. Placement-restricted campaigns have fewer signal sources = weaker predictions = higher CPMs.
4. **ASC priority signals:** ASC campaigns are given preferential auction positioning on Meta's infrastructure (lower auction floor) in exchange for full ML control. Accounts spending >30% of budget in ASC see 8-12% lower effective CPMs on ASC vs equivalent manual campaigns (Meta internal data, 2024).
5. **Engagement velocity in first 24 hours:** Ads generating high organic engagement (shares, saves, comments) in the first 24 hours after going live receive a quality boost in Lattice scoring. Implication: launch creatives at high-engagement time windows (7-9am local, 7-9pm local for consumer brands).
6. **Landing page speed feedback loop:** Meta tracks post-click behavior. High bounce rates from your ads signal low relevance → CPM penalty in subsequent auctions. Landing page <2s load time is a competitive advantage in the Lattice ranking.

---

## 21. Ad Copy Length — Data-Backed Thresholds

(industry standard 2024-2026, AdEspresso meta-analysis, Foxwell Digital research)

### Primary Text Length
| Audience temperature | Optimal length | Why |
|---------------------|----------------|-----|
| Cold (prospecting) | 40-125 characters | Cold users scroll fast; front-load benefit or hook; truncated at 125 chars in feed (more... click required) |
| Warm (engaged, retarget) | 300-600+ characters | Warm users seek justification; longer copy = more objection handling space; read rate for warm retarget is 3x cold |

**Data point:** AdEspresso 2024 analysis across 37,000 ads — short copy (≤125 chars) outperforms long copy by 19% CTR for cold traffic. Long copy (400+ chars) outperforms short by 27% conversion rate for warm retargeting audiences. Conclusion: copy length must match funnel stage, not personal preference.

### Headline Length
- Sweet spot: **27-40 characters**
- Below 27: Feels incomplete; less persuasive
- Above 40: Truncated on most placements; key word cut off
- Test: Headline alone must convey the core offer or hook (someone reading only the headline should understand the value proposition)

### Description Length
- Optimal: **27 characters** (maximum visible on most placements before truncation)
- Use for: primary keyword reinforcement, secondary CTA, urgency qualifier
- Do not repeat the primary text — descriptions are additive context

### Copy Structure Template (cold traffic, short form)
```
[Hook — problem or outcome in 1 sentence, ≤80 chars]
[Proof or mechanism — 1 line]
[CTA — imperative verb + specific next step]
```
Example: "Losing €1,000+/month to Meta ad waste? Our audit finds it in 24 hours. Book free review →"

---

## 23. Common Meta Ad Rejections — Policy Depth

(Meta Advertising Policies, updated 2024-2026)

### Special Ad Categories — Full Trigger List
Declare one of these categories or face retroactive disapproval + account flag:
- **Housing:** Ads for real estate listings, rentals, mortgages, home equity loans, home insurance, home improvement requiring financing
- **Employment:** Ads for job listings, staffing agencies, job boards, internships (even unpaid)
- **Credit:** Personal loans, credit cards, auto loans, BNPL services, debt consolidation
- **Social issues, elections, politics:** Issue ads (immigration, gun control, healthcare policy), political candidates, voter registration

**Consequences of declaring:** No age targeting (must be 18+), no gender targeting, no ZIP/postal code targeting. Only country/region/DMA-level geo allowed.

### Restricted Industries (not banned, but gatekept)
| Industry | Restriction | Workaround |
|----------|------------|-----------|
| Gambling | Country-level approval required per jurisdiction | Apply via Meta Business Support |
| Alcohol | Age-gate required (18+ or 21+ per country) | Declare target country; Meta adds age restriction automatically |
| Weight loss / body image | No before/after, no "lose X kg in Y days" | Focus on program/lifestyle claims, not outcome guarantees |
| Prescription drugs | Prohibited in most markets | OTC drugs allowed with restrictions |
| Adult content | Explicit content prohibited | Suggestive allowed if non-explicit and age-targeted |

### Policy Traps That Trip Up Good Advertisers
1. **Before/after photos:** ANY side-by-side comparison implying body transformation = automatic rejection. Applies even if transformation is emotional, not physical. Fix: single frame lifestyle shots, testimonial text without physical comparison.
2. **"You" targeting language:** Copy that implies Meta has targeted the user based on personal characteristics ("Are you struggling with debt?" / "For people with diabetes"). Fix: use third-person framing or general pain-point ("Many entrepreneurs find that...").
3. **Social proof claims without disclaimers:** "Rated #1 by customers" requires source citation. "4.8 stars" requires "(4,782 reviews)" or similar qualifier. Unsubstantiated superlatives = rejection.
4. **Organic-looking ads:** Ads designed to look like organic content with hidden commercial intent are disallowed. Must be identifiable as ads.
5. **Countdown timers with false urgency:** If the countdown resets after expiry (evergreen urgency), Meta's automated system can flag as deceptive. Use real deadline dates.

### Account Health Cascade
- 1-2 disapprovals: Warning; no delivery impact
- 3-5 disapprovals within 30 days: Ad delivery limit placed on account
- 5+ disapprovals: Manual review queue; potential temporary account restriction
- Account restriction: Appeal within 30 days via Account Quality → Request Review. Success rate improves significantly with specific policy citations in appeal text vs generic "I comply" statements.

---

## 24. Reporting, Attribution Debugging & Meta vs GA4 Discrepancy

(industry standard 2024-2026; Meta and GA4 attribution docs)

### Why Meta and GA4 Disagree (Typically 20-40% Gap)
Meta reports more conversions than GA4 for the same period in most accounts. Root causes in order of frequency:
1. **View-through attribution:** Meta counts conversions from users who saw (not clicked) an ad within 1 day. GA4 only counts click-based sessions. View-through adds 15-35% to Meta's reported conversions.
2. **Cross-device gaps:** User sees ad on mobile, converts on desktop. Meta matches via user ID across devices. GA4 loses this user unless cross-device measurement is configured.
3. **iOS 14.5+ modeled conversions:** Meta includes statistically modeled conversions that GA4 never observes. These can add 10-25% to Meta's reported total.
4. **Attribution window difference:** Meta 7-day click window vs GA4 last-click (or shorter data-driven window). Conversions touched by Meta within 7 days but attributed to another channel in GA4.
5. **Cookie differences:** GA4 `_ga` cookie lasts 2 years but is subject to ITP. Meta's `_fbp` cookie also subject to Safari ITP but CAPI bypasses this.

**Diagnostic step:** In Meta, switch attribution to 1-day click, no view-through. Compare to GA4 last-click for the same period. The residual gap after removing view-through is your modeled/cross-device gap.

### Data-Driven Attribution in Meta
- Available as "Data-Driven Attribution" in attribution settings within Meta Ads Manager.
- Uses ML to distribute credit across all Meta touchpoints (impressions + clicks) based on incrementality patterns.
- Requires: >1,000 conversions in 28 days AND domain verification AND AEM configured. Without these, defaults to last-click.
- DDA typically shows lower per-ad ROAS vs last-click (credit is distributed, not assigned to last touchpoint) but gives more accurate optimization signals.

### Conversion Lift Studies
Run a Lift Study when you need ground-truth incrementality (separate from Meta's attribution):
1. Navigate to: Experiments → Create a new experiment → Conversion Lift.
2. Set holdout: 10-15% of eligible audience excluded from seeing ads.
3. Run minimum 2-4 weeks (shorter = noisy; longer = IRL variable contamination).
4. Output: Incremental conversions, iROAS, cost per incremental conversion.
5. Cost: The holdout group is revenue you forego — budget accordingly.

**When to run:** Before major budget increases (>2x), when questioning whether Meta is driving real value vs claiming credit for organic conversions.

### A/B Testing Tool (Meta's Built-In)
- Access: Experiments → Create → A/B Test.
- Can test: Creative, audience, placement, bid strategy, landing page (via URL redirect).
- Statistical significance: Meta uses Bayesian inference; declares winner at 80% confidence (lower than academic 95%).
- Minimum runtime: 7 days. Maximum meaningful runtime: 30 days (creative fatigue confounds longer tests).
- Budget split: 50/50 enforced by Meta; cannot allocate unequally.
- Kill criterion: If one variant shows >40% CPA disadvantage at day 7 with 200+ conversions total → safe to call early.

### Reporting Best Practices
- Always segment by: device platform (iOS vs Android), placement, and creative.
- Pull "7-day click" column AND "1-day view" column separately. Manage primarily to 7-day click CPA.
- Frequency column: Add to every ad set report. Sort descending. Any ad set with frequency >5 on cold gets flagged for creative refresh.
- Custom columns to always include: Hook Rate (3-second video views / impressions), Hold Rate (ThruPlay / 3-second views), CTR (link), CPC (link), CPM, Frequency, Reach, ROAS (7-day click).
