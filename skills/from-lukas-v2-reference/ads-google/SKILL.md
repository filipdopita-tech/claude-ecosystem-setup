---
name: ads-google
description: Google Ads strategy and execution — Search, Display, YouTube, Performance Max, and Demand Gen. Covers campaign type selection, Quality Score, bidding strategies, negative keyword hygiene, RSA structure, and conversion tracking.
allowed-tools: Read, Write, WebFetch, WebSearch, Bash
last-updated: 2026-04-27
version: 1.0.0
---

# Google Ads Agent

Expert-level Google Ads strategy across all campaign types.

## Triggers
"Google Ads", "Google ads", "Search ads", "PMax", "Performance Max", "YouTube ads", "Display campaign", "Google campaign", "RSA", "Smart Shopping", "Demand Gen", "Discovery ads"

---

## 1. Campaign Types — Decision Tree

### Which Campaign Type to Use

```
Is the audience actively searching for your product/service?
├─ YES → Search campaign (highest intent, lowest funnel)
│
Is it visual / e-commerce product catalog?
├─ YES → Performance Max (Shopping feed + all placements)
│         → or Standard Shopping (more control)
│
Is the goal brand awareness / reaching new audiences visually?
├─ YES → Demand Gen (YouTube, Discover, Gmail, Maps)
│         → was "Discovery" campaign, rebranded 2023
│
Is it a YouTube video ad specifically?
├─ YES → Video campaign (in-stream, in-feed, bumper)
│
Remarketing / staying top-of-mind for warm audiences?
└─ YES → Display campaign (GDN) with audience lists
```

### Campaign Type Strengths
| Type | Best for | Avoid for |
|------|---------|-----------|
| Search | Bottom-funnel; purchase intent keywords | Awareness; broad brand discovery |
| Performance Max | E-commerce with product feed; max reach | Products without clear Google Shopping feed |
| Video / YouTube | Brand building; demonstration products | Direct response on small budgets |
| Demand Gen | Social-native audiences; visual products | Performance marketing without creative |
| Display | Retargeting; awareness sequencing | Cold traffic without audience signals |
| Standard Shopping | E-com brands needing bid control per product | Brands without product feed optimization |

---

## 2. Search Campaigns — Core Mechanics

### Keyword Match Types (2026 behavior)
Match type hierarchy (precision to volume):
1. **Exact [keyword]:** Only triggers for that query (and very close variants). Lowest volume, highest intent.
2. **Phrase "keyword":** Triggers for queries containing the phrase in order. Medium precision.
3. **Broad +audience:** Triggers for related queries; Google uses audience signals and landing page context to decide relevance.

**2026 reality:** Broad match + Smart Bidding + strong audience signals often outperforms exact match stacking for established accounts. For new accounts: start exact/phrase to control spend; graduate to broad with tCPA once 50+ conversions/month.

**Funnel: Exact for proven high-performers → Phrase for expansion → Broad with tCPA/tROAS for discovery.**

### Quality Score (QS) — 1-10 Score
Three factors (Google's transparency):
1. **Expected CTR** (based on historical CTR for your keyword + match type)
2. **Ad Relevance** (how closely the ad matches the query intent)
3. **Landing Page Experience** (load time, mobile-friendliness, content relevance, low bounce)

**QS effect on CPC:**
- QS 10: CPC reduction up to 50%
- QS 7-9: Below average CPC
- QS 5-6: Average
- QS 4 and below: Above average CPC; ad shows less frequently
- Target: QS ≥7 on core keywords; ≥8 on brand terms

**Improving QS:**
- CTR: Tighter ad groups (1-3 closely related keywords per ad group — SKAG or close SKAG)
- Ad relevance: Include keyword in headline 1 and description
- Landing page: Match search query intent to page content. Slow page (>3s) = "Poor" landing page experience automatically

### Bidding Strategy Progression (Adam Kropáček framework)
```
Stage 1 (0-30 conversions/month): Manual CPC or Maximize Clicks
   → Purpose: data collection, avoid burning budget on smart bidding with no signal

Stage 2 (30-50 conversions/month): Target CPA or Maximize Conversions
   → Algorithm has enough signal; automated bidding starts outperforming manual

Stage 3 (50+ conversions/month): Target ROAS or Maximize Conversion Value
   → Full automation with value-based optimization; best for e-commerce

Brand campaigns: Target Impression Share (90%+ IS target) or Max Clicks with bid cap
```

**Never switch bid strategies during high-traffic periods (holidays, peak season).** Learning phase reset during peak = wasted budget.

### RSA (Responsive Search Ad) Structure
- 15 headlines (30 characters each) — Google tests combinations
- 4 descriptions (90 characters each)
- Asset performance grades: Best → Good → Low → Learning
- Rules:
  1. Every headline must stand alone AND in combination with any 2 other headlines
  2. Include primary keyword in at least 2 headlines
  3. Include CTA in at least 1 headline
  4. Include key benefit/differentiator in descriptions
  5. Do NOT pin headlines unless brand/legal requirement — pinning kills machine learning
  6. Include at least 3 "Best" or "Good" rated assets before scaling; low-performing assets pulled automatically but still hurt

**RSA Example (SaaS — lead gen):**
```
Headlines:
1. Save 4 Hours/Week on Reporting
2. [Keyword Insertion: {KeyWord: Marketing Analytics}]
3. Try Free for 14 Days — No Card
4. Trusted by 12,400+ Marketing Teams
5. Real-Time Dashboard in 2 Minutes
6. Cut Reporting Time by 75%
7. See Why Teams Switch to Us
8. Connect All Your Ad Accounts

Descriptions:
1. Stop exporting spreadsheets. Connect your ad accounts, CRM, and
   analytics in one live dashboard. Setup takes under 5 minutes.
2. 4.8/5 from 1,200 reviews. Join teams saving 4+ hours weekly on
   performance reporting. Free trial, no credit card.
```

### Negative Keyword Hygiene
- Must-have negative lists (apply at account level):
  - Brand competitor names (unless running competitor campaigns)
  - "Free," "jobs," "careers," "salary," "Wikipedia," "Reddit"
  - Irrelevant geographies
  - Irrelevant product categories

- Campaign-level negatives:
  - Add after reviewing Search Terms report weekly
  - Any query converting zero after 2x target CPA spend → add as negative
  - Cross-campaign negatives: exclude brand terms from non-brand campaigns; exclude non-brand from brand campaigns

- Negative keyword types: use exact negatives sparingly; phrase negatives cover more ground

### CTR Benchmarks (Search)
| Campaign type | Good CTR | Acceptable | Kill signal |
|---------------|----------|------------|-------------|
| Brand | >8% | 5-8% | <3% |
| Non-brand, high intent | >3% | 2-3% | <1% |
| Non-brand, informational | >2% | 1-2% | <0.5% |

CTR below floor = ad relevance issue OR wrong keyword match type. Check: is the query matching the right intent?

---

## 3. Performance Max

### What PMax Does
Runs across all Google inventory simultaneously: Search, Shopping, Display, YouTube, Discover, Gmail, Maps.
Uses Google's ML to find conversion opportunities across all placements with one campaign.

### Asset Groups — Structure for Success
- Each asset group = one product category or audience theme. Do NOT blend brand + generic terms.
- Separate asset groups for: brand-related, non-brand top products, non-brand categories
- Brand vs. non-brand blending: PMax cannibalizes brand traffic (cheap) and inflates reported ROAS without earning non-brand conversions. Separate or exclude brand terms.

**PMax Asset Checklist per group:**
- [ ] 15 images (product, lifestyle, logos)
- [ ] 5 videos (if none supplied, Google auto-generates — quality is poor; always supply)
- [ ] 5 headlines (30 char)
- [ ] 5 long headlines (90 char)
- [ ] 4 descriptions (60-90 char)
- [ ] Business name, logo, URL

### Audience Signals (feed to PMax)
Audience signals are starting hints, not targeting locks. PMax uses them to seed learning, then expands.
Priority signals to add:
1. Customer match list (existing customers/emails)
2. Website visitors (remarketing tags)
3. In-market audiences most relevant to product category
4. Custom audiences based on search terms or URLs

### Product Feed Quality (Shopping component)
- Title: [Brand] + [Product type] + [Key attribute] + [Size/Color/Model]
  Example: "Nike Air Max 2026 Running Shoes — Men's Size 42 — White/Black"
- Description: Top 150 characters = most important (truncated below)
- GTIN / MPN: Required for all products with one; better match rate, lower CPC
- Images: White background for apparel, lifestyle for home goods
- Price: Must match landing page exactly; mismatch = disapproval

### PMax Kill / Optimization Signals
- Low performance for 2+ weeks after 50+ conversions: check asset group structure; likely blending conflicting themes
- "Search themes" (2024 feature): add keyword themes to guide intent; use for niche products Google doesn't understand
- Placement exclusions: apply brand safety exclusions (parked domains, gambling, sensitive content) at account level

---

## 4. YouTube Ads

### Format Decision
| Format | Skip? | Length | Best for |
|--------|-------|--------|---------|
| In-stream skippable | Yes (5s) | 15s-3min | Brand awareness, direct response |
| In-stream non-skippable | No | 15-20s | Guaranteed message delivery |
| Bumper | No | 6s | Frequency / reminder |
| In-feed (discovery) | N/A | Any | Organic-style discovery |
| Outstream | Yes (immediate) | — | Mobile web reach |

### Hook — 5 Seconds Before Skip
The entire game for in-stream skippable is the first 5 seconds.
- Must create a reason not to skip: unresolved question, surprising visual, promise of specific value
- Viewer decision: Is this worth 15-120 more seconds of my time?
- Use the curiosity-gap or transformation hook patterns
- Do not front-load branding in seconds 1-5: show it after second 5 (brand recognition happens; skips happen if brand-first)

### YouTube Hook Examples
- "I'm going to show you a €0 to €45K/month Meta strategy in the next 90 seconds. Stay with me."
- "Most people running Google ads are wasting 40% of their budget on this one thing. Let me show you."
- "Before you skip this: you're losing money every day you run search ads without this one setting."

### Retention Curves
- For skippable in-stream: 30% retention at the 30-second mark = strong
- If <15% retention at 30s = hook isn't holding; rebuild first 10 seconds
- Watch time is the primary YouTube algorithm signal; longer-watch ads get cheaper CPVs

### Bidding for YouTube
- Awareness: CPM bidding (maximize reach per €)
- Consideration: CPV (cost per view — maximize 30s views)
- Direct response: Target CPA (requires 50+ conversions/week on YouTube specifically)

---

## 5. Display Campaigns

### Smart Display vs Standard
- **Smart Display:** Google manages targeting + creative assembly. Requires images + logos + headlines; Google tests combinations.
  - Use: established accounts, retargeting scale, when you don't want to manage placements
- **Standard Display:** Manual audience + placement control.
  - Use: specific audience lists, brand-safe placement targeting, competitive exclusions

### Must-Have Placement Exclusions (apply at account level)
- Parked domains
- Error pages
- App categories: casual games, children's apps (low intent)
- Mobile app (ALL) exclusion for B2B — in-app display traffic = accidental clicks, not conversions
- Check Placement Report monthly and manually exclude bottom-quartile sites

### Audience Strategy for Display
Priority audiences:
1. Customer match (highest value)
2. Website retargeting (14-day, 30-day, 90-day segments)
3. Similar audiences to converters
4. In-market audiences (Google's intent signals)
5. Custom intent (users who searched specific keywords)

Do NOT run display to "all adults 18-65" cold — CTR <0.1%, CPMs wasted. Always use audience + demographic layering.

---

## 6. Conversion Tracking

### GA4 + Google Ads Integration (mandatory)
- [ ] GA4 linked to Google Ads account
- [ ] Primary conversion: Purchase / Lead (from GA4 goal import OR native Google Ads tag)
- [ ] Secondary conversions: Add to cart, Begin checkout, Phone call (for optimization insight, not bidding)
- [ ] Verify: every conversion event firing once per actual conversion (no double-counting from page refresh)

### Enhanced Conversions
Sends hashed customer data (email, phone, name, address) alongside conversion events to improve match rates.
- Required for accurate measurement post-iOS 14+ / cookie deprecation
- Implementation: tag-based (Google Tag Manager) or API-based
- Improves attribution by matching offline signals to Google profiles

### Offline Conversion Import
For B2B with long sales cycles: import CRM deal stages as offline conversions.
- Mark a qualified lead at €100 value; closed deal at €5,000 value
- Google optimizes toward the signals that predict downstream revenue, not just form fills
- Use Google Ads Conversion Import API or Zapier/CRM connector

### Attribution Models (2026 Google position)
- Data-driven attribution (DDA): default and recommended — uses ML across all touchpoints
- Last-click: only for very simple single-step funnels; penalizes upper-funnel
- Linear, time-decay: legacy; generally inferior to DDA
- DDA requires 300+ conversions in 30 days; otherwise defaults to last-click

---

## 7. Kill Rules by Campaign Type

### Search
- Ad group: <0.5% CTR after 500 impressions AND 2x target CPA spend without conversion → pause
- Keyword: >2x target CPA with 0 conversions → add as negative or pause
- Campaign: 14 days, tCPA >150% of target → audit audience, match types, landing page

### Performance Max
- Week 1-2: Do not make structural changes (learning phase)
- Week 3+: No improvement and spend exceeding target CPA by >50% → restructure asset groups or split campaign
- Check Search Terms report (partial visibility) for irrelevant traffic → add negatives

### YouTube
- CPV >€0.15 (in-stream) with no view-through conversions → hook failure; rebuild first 5s
- Campaign: 30 days, no conversions, budget >€500 → video is not converting; test new angle

### Display
- Placement: >100 clicks, zero conversions → add to placement exclusion list
- Creative: >10K impressions, CTR <0.05% → replace creative
- Audience: 30 days, >2x target CPA → restrict or remove audience

---

## 8. Smart Bidding Learning Phase — 50-Conversion Rule (Adam — paid-ads)

The 50-conversion threshold is the hard prerequisite for reliable automated bidding — applies to both tCPA and tROAS:

- **Below 50 conv/month:** Smart Bidding has insufficient signal. tCPA targets will oscillate; algorithm makes random-walk decisions. Stay on Manual CPC or Maximize Clicks.
- **At 50 conv/month:** Switch to Target CPA or Maximize Conversions. Anchor initial tCPA target at 10–20% above historical actual CPA (give the algorithm room).
- **At 100+ conv/month:** Graduate to Target ROAS or Maximize Conversion Value for value-based optimization.
- **Per campaign, not account:** A campaign needs its own 50 conversions — account-level volume doesn't substitute.

**Learning phase protection:** After switching bid strategy, the algorithm enters a learning period (typically 7–14 days). Do NOT change bids, budgets (>20%), or audience during this window. Changes reset learning.

**Budget scaling rule (Adam — paid-ads):** Increase budget maximum 20–30% at a time; wait 3–5 days between changes to allow convergence. Never double a budget at once — it resets learning and the algorithm overspends in a volatile window.

## 9. Value-Based Bidding Architecture (Adam — paid-ads)

Use value-based bidding (Maximize Conversion Value / tROAS) when conversions have different revenue values:

**Setup requirements:**
- Conversion actions must pass a `value` parameter (purchase value, lead score, LTV estimate)
- For B2B with long cycles: use proxy values (qualified lead = €100, SQLed lead = €500, closed = €5,000) and import via Offline Conversion Import
- Google optimizes toward the signals that predict downstream revenue, not just form fills

**Customer Match as primary audience signal:**
1. Upload first-party customer list (email hashes) as Customer Match
2. Set bid adjustments or use as Smart Bidding signal
3. For tROAS: Customer Match lists of high-LTV customers steer the algorithm toward similar users

**Value-based signal hierarchy for PMax (priority order):**
1. Customer Match (existing high-LTV buyers)
2. Website converters with value data (remarketing + purchase value)
3. In-market audiences (Google's intent modeling)
4. Custom audiences (keyword or URL based)

## 10. Audience Architecture — Search + PMax (Adam — paid-ads)

### Search Campaigns: Audience Layering (Observation mode first)
- Add all relevant audiences in **Observation** mode first — collects bid modifier data without restricting reach
- After 30+ days: identify which audiences convert at lower CPA → apply positive bid adjustments (10–30%)
- Typical high-value segments: Customer Match, In-market (your category), Remarketing (14-day website visitors)

### PMax: Audience Signals as Seeds, Not Constraints
PMax uses audience signals as starting hints — it expands beyond them. Feed the highest-quality signals:
1. Customer Match list (existing purchasers / emails)
2. Website remarketing tag audiences (all visitors, converters separated)
3. In-market audiences matching your product category
4. Custom intent audiences based on high-converting search terms

**Brand term cannibalization:** PMax will absorb cheap brand traffic and inflate reported ROAS without earning non-brand conversions. Add brand terms as campaign-level negative keywords in PMax, or run a separate brand Search campaign with explicit brand keyword protection.

## 11. Negative Keyword Sculpting — PMax + Search Cross-Campaign (Adam — paid-ads)

### PMax Negative Keywords (limited but critical)
- PMax does not support standard negative keyword lists — use account-level negative keyword lists (Shared Library)
- Apply immediately: competitor brand names (unless running competitor campaigns), irrelevant product categories, job/career terms, "free" + category
- Search Themes (2024 feature): add keyword themes to guide intent for niche products; functions as positive signal, not negatives

### Search Cross-Campaign Sculpting
- **Brand vs Non-Brand isolation:** Brand terms as exact negatives on non-brand campaigns; non-brand as negative phrase on brand campaigns
- **Zero-conversion queries:** Any search term spending 2× target CPA with zero conversions → add as exact negative
- **Cannibalization audit:** Check Search Terms report weekly; queries appearing in both brand and non-brand = add as exact negative on non-brand
- **Match type negative hierarchy:** Phrase negatives cover more surface area than exact negatives — use phrase for category-level exclusions, exact for specific high-value query protection

## 12. Czech / CZ Market Notes (original section 8)

- Google's Czech market coverage: strong for commercial and research queries; less dominant for social-native audiences (Meta wins there)
- Czech language ads: Use Czech diacritics correctly — "nejlepší," "zákazníků." Google Ads spell-check does not catch CZ errors.
- Product feed for Czech market: prices in CZK; use Kč symbol consistently
- VAT note: Google Shopping shows prices as listed; ensure product feed prices include VAT for B2C (standard Czech consumer expectation)
- ČNB regulatory: financial product ads on Google must comply with same rules as Meta — risk warnings, no guaranteed returns
- Czech brand terms: register brand terms as exact keywords immediately; competitor bidding on your brand is common in CZ market

---

## 13. Performance Max — Deep Operational Guide

(industry standard 2024-2026; Google Ads Help, Brad Geddes SEM methodology)

### Asset Group Strategy — Theme Separation is Non-Negotiable
Each asset group must represent one coherent theme. PMax's ML uses asset group cohesion to understand intent. Mixed themes produce diluted signals and inflated reporting.

**Recommended asset group architecture:**
| Asset group | Theme | Audience signals to add |
|------------|-------|------------------------|
| Brand | Brand name + branded product names | Customer Match (existing buyers), brand search terms as custom intent |
| Non-brand core products | Top 3-5 SKUs or product lines by revenue | In-market audiences (your category), top converting search terms as custom intent |
| Non-brand new/seasonal | New launches, seasonal collection | Similar-to-buyers (lookalike equivalent), seasonal in-market |
| Category expansion | Adjacent categories or upsell | Existing customers (for cross-sell), in-market adjacent |

**Rule:** Never mix brand + non-brand in the same asset group. PMax will serve brand inventory (cheap, easy conversions) and inflate ROAS while starving non-brand of budget.

### Audience Signals vs Demographics — Critical Distinction
Audience signals in PMax are **seeds, not targeting constraints**. Google's ML starts with signal audiences and expands aggressively beyond them.
- Adding a 25-35 age signal does NOT mean only 25-35-year-olds see your ads
- Adding a competitors-keyword custom intent does NOT mean only searchers of that term see your ads
- Signals = "start your learning here" — the algorithm finds similar patterns and expands

**What this means operationally:** Narrow audience signals do not protect you from broad reach. Add your best signals (Customer Match, high-intent in-market) and trust expansion. Adding too many conflicting signals confuses the seed, not constrains it.

### Final URL Expansion — Now Effectively Mandatory
Google auto-sends users to the "most relevant" page on your site (determined by ML). Mandatory since 2023 for new PMax campaigns.
- **Risk:** Traffic can land on blog posts, about pages, or unintended pages if site architecture is messy
- **Mitigation:** Add exclusion URLs in PMax settings (Final URL Expansion → Exclude URLs). Exclude: /blog/*, /about, /careers, /support, /login
- **Opportunity:** PMax can discover landing pages you wouldn't have tested manually. Monitor via Insights → Asset Group → Landing page performance

### Brand Exclusion Lists — Non-Negotiable for Non-Brand PMax
Without brand exclusion, PMax absorbs branded search traffic. Branded conversions are cheap (high intent), which makes PMax ROAS look excellent while non-brand effort is neglected.

**Setup:**
1. Google Ads → Tools → Shared Library → Brand Lists
2. Create a brand list with your brand name and common misspellings
3. Apply to each PMax campaign → Settings → Brand exclusions
4. Verify: Pull Search Terms report (limited visibility) — if branded terms still appear, the exclusion needs refinement

**Cross-check:** Run a parallel branded Search campaign with exact match brand keywords. If PMax + brand exclusions are configured correctly, branded Search campaign should capture all brand intent traffic and PMax should show primarily non-brand search terms.

### Search Themes (Limited Feature, 2024+)
Search themes are positive keyword hints for PMax (up to 25 per asset group). They guide the algorithm without locking it to keyword match behavior.
- Use for: niche products Google's ML doesn't understand from product feed alone
- Do NOT use as a substitute for Search campaigns on high-intent keywords
- Search themes are lower priority than actual Search campaigns — if a query matches a Search campaign keyword AND a PMax search theme, Search campaign wins

### Creative Asset Pinning Trade-offs
PMax allows pinning specific headlines to positions within ads. Pinning = ML cannot test alternatives in that slot.
- **Only pin** for legal/compliance requirements (brand name in first position, required disclaimer)
- **Never pin** for "I prefer this headline" — you're paying for ML optimization; pinning defeats it
- **Asset performance visibility:** PMax shows "Learning / Low / Good / Best" ratings per asset. Assets rated "Low" for >3 weeks should be replaced, not pinned

### Account-Level Negative Keywords for PMax
PMax doesn't support ad group or campaign-level negatives via the standard interface. Workarounds:
1. **Account-level negative keyword lists** (Shared Library): Applies across all campaigns including PMax
2. **Google Customer Support request:** For large accounts, Google Support can manually apply campaign-level negatives to PMax (requires direct contact with rep)
3. **Brand lists** (see above): The proper mechanism for brand exclusions specifically

**Apply immediately at account level:** competitor brand terms (unless running competitor campaigns), job/career terms, geographic irrelevancies, "free" + product category.

---

## 14. Smart Bidding Strategy Decision Tree

(Adam Kropáček framework + industry standard 2024-2026, Brad Geddes)

### The Full Progression
```
Step 0 — Account launch / new campaign (0-10 conv/month):
  → Maximize Clicks with bid cap
  Purpose: Get traffic flowing; identify converting search terms; no automation yet
  Risk: No ROAS/CPA optimization; can waste budget on low-intent clicks
  Exit trigger: 15+ conversions in 30 days

Step 1 — Early data (10-30 conv/month):
  → Maximize Conversions (no target)
  Purpose: Let algorithm optimize volume; builds conversion history
  Risk: CPA can spike; set a budget cap as guardrail, not a tCPA target
  Exit trigger: 30+ conv/30d with stable CPA (≤30% week-over-week variance)

Step 2 — Learning complete (30-50 conv/month):
  → Target CPA
  Set initial tCPA target at: historical actual CPA × 1.15 (give algorithm 15% headroom)
  Purpose: Anchor CPA; algorithm has enough signal for reliable optimization
  Exit trigger: 50+ conv/30d with revenue tracking active

Step 3 — Scaling phase (50+ conv/30d, revenue data available):
  → Target ROAS or Maximize Conversion Value
  Set initial tROAS at: historical actual ROAS × 0.85 (give algorithm 15% downside headroom)
  Purpose: Optimize toward revenue, not conversion count
  Exit trigger: 100+ conv/30d for highest reliability

Step 4 — Full automation (100+ conv/month):
  → Maximize Conversion Value (no target) for aggressive growth
  → OR Target ROAS for efficiency-focused scaling
```

### Key Rule: Never Skip Steps
Jumping from Maximize Clicks → tROAS with 20 conversions = algorithm blind flight. The system will set bids based on insufficient patterns → CPAs spike → advertiser panics → changes bid strategy → algorithm resets → cycle repeats. The 50-conversion threshold exists because Google's internal research shows bid volatility drops below acceptable variance at that data volume.

---

## 15. Bid Strategy Migration — Triggers, Expectations, Recovery

(industry standard 2024-2026, Google Smart Bidding documentation)

### When to Switch Bid Strategy
| Trigger condition | Recommended switch |
|------------------|-------------------|
| Conversion volume hits threshold (30, 50, 100 conv/30d) | Graduate upward per Step decision tree (§14) |
| tCPA target persistently unachievable (actual CPA >150% of target for 3+ weeks) | Raise tCPA target 20-30% or step back to Maximize Conversions |
| tROAS too aggressive (conversion volume drops >40%) | Reduce tROAS target by 15-20% or step back to tCPA |
| Product/offer change significantly alters conversion value | Reset to tCPA or Maximize Conversions; re-establish baseline |
| Campaign paused >14 days and relaunched | Treat as new campaign; data becomes stale; re-enter at Step 1 |

### What to Expect During Migration
- **Recalibration period:** 1-2 weeks ("learning phase"). Conversion volume drops 20-40%, CPA rises 20-50% during this window. This is normal.
- **Do not intervene during learning:** Any budget change >20%, bid modifier change, or audience change resets the learning clock. One intervention = another 1-2 week recalibration.
- **Signal: learning complete** when CPA variance week-over-week drops below 20% AND conversion volume returns to near-baseline.

### How to Reset Learning Without Campaign Restart
If algorithm is clearly stuck (CPA trending continuously upward for 3+ weeks despite reasonable target):
1. Change tCPA target by >20% (triggers relearn) — less disruptive than campaign restart
2. Add a new audience signal (Customer Match upload) — stimulates algorithm exploration
3. Add 2-3 new RSA ad variants — creative refresh stimulates resampling

**Avoid over-pivoting:** Most accounts switch bid strategies too frequently. The algorithm needs 4-6 weeks of stable data to reach peak efficiency. Three switches in one month = the algorithm never fully matures on any strategy.

---

## 16. Quality Score Rebuild Playbook

(Brad Geddes SEM Best Practices; Google QS documentation)

### Landing Page Experience — Biggest QS Lever
Landing page experience is the hardest factor to fix but has the highest ceiling for QS improvement.
- **Load time:** Every 1s above 2s LCP decreases QS landing page component. Use PageSpeed Insights to target LCP <2.5s. Improvement from "Poor" to "Good" adds 1-2 QS points.
- **Relevance signals:** H1, page title, and first paragraph must contain the primary keyword cluster of the ad group. Google crawls the landing page and compares it to the ad's keywords — mismatch = "Below average" landing page experience.
- **Mobile experience:** >60% of Google Search traffic is mobile. A desktop-only landing page gets "Below average" automatically. Verify: Google's Mobile-Friendly Test.
- **Bounce rate correlation:** High bounce rate (from GA4) feeds indirectly into QS via Google's algorithm. If 80%+ of users immediately navigate away, it signals landing page-query mismatch.

### Ad Relevance via SKAGs vs RSAs Trade-off
- **SKAG (Single Keyword Ad Group):** 1 keyword per ad group → maximum ad relevance QS. Trade-off: hundreds of ad groups to manage, RSA ML has limited signal per group.
- **RSA-native clustering (recommended 2024+):** 3-5 tightly related keywords per ad group → strong QS ad relevance + enough search volume for RSA optimization. Best balance of QS and ML performance.
- Rule: Keywords in the same ad group must share the same user intent. "buy running shoes" and "running shoe reviews" do NOT belong together — different intent = ad relevance mismatch for one of them.

### Expected CTR Boost Mechanisms
| Tactic | Expected CTR improvement | Notes |
|--------|------------------------|-------|
| Dynamic Keyword Insertion `{KeyWord:fallback}` | +10-25% CTR on non-brand keywords | Makes ad feel personally relevant to query; avoid for brand (looks amateur) |
| Sitelink extensions (4+) | +10-15% CTR | Google shows up to 4; occupies more SERP real estate |
| Callout extensions (4+) | +5-8% CTR | Subtler; additive with sitelinks |
| Structured snippets | +3-7% CTR | Category-specific; services, types, features |
| Seller ratings (auto-populated from reviews) | +10-17% CTR | Requires 100+ Google reviews; automatic if eligible |
| Promotion extensions (during active promotions) | +15-20% CTR | Sale price, promo code, percent off |
| Combined extension stack (all of above) | +25-40% CTR total | Extensions interact — Google selects the optimal combination per auction |

### QS Improvement Timeline
Realistic expectations after implementing fixes:
- Landing page speed fix: QS update within 2-4 weeks (Google recrawls on a delay)
- Ad copy relevance fix: QS update within 3-7 days (impression data accumulates fast)
- CTR improvement via extensions: QS update within 1-2 weeks
- Full QS rebuild from 4 → 8: Expect 4-8 weeks of sustained optimization

---

## 17. Customer Match — Upload Workflow

(industry standard 2024-2026, Google Ads documentation; AJ Wilcox B2B LinkedIn methodology adapted for Google)

### Formatting Requirements
Google requires SHA-256 hashed data for all Customer Match uploads. Raw PII is not accepted.

**Email (most important):**
- Normalize before hashing: lowercase, strip leading/trailing spaces
- Hash algorithm: SHA-256
- Example: `echo -n "user@example.com" | sha256sum`

**Phone:**
- Format before hashing: E.164 international format (+12025551234)
- Include country code; strip spaces, dashes, parentheses
- Hash: SHA-256

**Name + Address (for address-based matching):**
- First name, last name: lowercase, no special characters
- Country: ISO 2-letter code (US, CZ, DE)
- ZIP: as-is, no standardization needed by Google

**CSV column order (Google's standard format):**
```
Email,Phone,First Name,Last Name,Country,Zip
[hashed],[hashed],[hashed],[hashed],US,10001
```

### Match Rate Expectations
- Email list of known Google account holders: 40-70% match rate
- Phone-only list: 20-50% match rate (phone linking to Google account less common)
- Combined email + phone: 50-75% match rate (Google matches if either matches)
- B2B email lists (work emails): 30-50% match rate (many work emails not associated with Google personal accounts)
- Minimum list size for meaningful use: 1,000 matched users (Google won't serve to smaller matched lists in most contexts)

### Audience Signal vs Targeting Usage
| Use case | Mode | Notes |
|---------|------|-------|
| PMax audience signal | Signal (not constraint) | Seed the algorithm toward similar buyer profiles; best use |
| Search observation | Observation | See bid modifier data by matched customers; apply positive bid adjustment after 30+ days |
| RLSA (Search targeting) | Targeting (target and bid) | Serve different ad to known customers; e.g., upsell copy |
| YouTube / Demand Gen | Targeting or signal | Exclude existing customers from prospecting; include for upsell |

### GDPR Consent for EU Lists
For any Customer Match list containing EU user data:
- User must have given explicit consent for their data to be used for advertising purposes
- Store consent records with timestamp and source
- Google requires consent mode v2 to be implemented for EU consent enforcement
- Lists without proper consent basis = account policy violation. Risk: account suspension.
- CZ market: GDPR applies; ČNB/ÚOOÚ enforcement active 2024+.

### Refresh Cadence
- E-commerce buyer list: Refresh weekly (new buyers need to be added; churned customers removed)
- B2B CRM list: Refresh monthly (slower churn/acquisition)
- Suppression list (do-not-target): Refresh whenever opt-outs occur — unmatched users remain targetable until next upload

---

## 18. Value-Based Bidding — Full Setup

(industry standard 2024-2026, Google Smart Bidding documentation)

### Offline Conversion Upload — Salesforce / HubSpot Integration

**Why:** For B2B, the Google Ads conversion (form fill) is a micro-conversion. The real value event is a closed deal. Uploading offline conversions (CRM deal stages → Google) allows the algorithm to optimize toward downstream revenue.

**Salesforce integration steps:**
1. Google Ads → Tools → Conversions → Import → Salesforce
2. Authenticate Salesforce CRM connection
3. Map Salesforce opportunity stages to conversion actions with values:
   - Stage "MQL" → conversion value €50
   - Stage "SQL" → conversion value €200
   - Stage "Closed Won" → conversion value €2,000 (or actual deal value)
4. Import runs automatically via Salesforce connector; 30-90 day lag common for B2B cycles

**HubSpot integration:**
- Native Google Ads integration in HubSpot (Marketing → Ads → Conversions)
- Map Deal Stage to Google Ads conversion action
- Alternatively: Zapier workflow (HubSpot Deal Stage Changed → Google Ads Offline Conversion upload via API)

**Manual CSV upload (fallback):**
- Download template from Google Ads → Conversions → Import
- Required fields: `Google Click ID (GCLID)`, `Conversion Name`, `Conversion Time`, `Conversion Value`, `Conversion Currency`
- GCLID storage: Must be captured on form submission from URL parameter and stored in CRM alongside the lead record

### Enhanced Conversions for Leads
Sends hashed customer data (email, phone) from the "thank you" page alongside the conversion event.
- Improves lead match rate when those leads later convert offline (Google cross-references hashed data)
- Setup: Google Tag Manager → Google Ads conversion tag → Enhanced conversions for web
- Required: collect email/phone on form; pass to conversion tag as variable

### Conversion Value Rules
Apply multipliers to conversion values based on context without changing the base value:
- **Location rule:** +20% value for conversions from London (higher LTV market)
- **Device rule:** +15% value for desktop conversions (B2B: desktop correlates with office/work context)
- **Audience rule:** +30% value for conversions from Customer Match (existing customer upsell signal)

Setup: Google Ads → Tools → Conversions → Conversion value rules. Requires Target ROAS or Maximize Conversion Value bid strategy.

---

## 19. YouTube In-Stream Action Campaigns

(industry standard 2024-2026, Google YouTube Ads documentation)

### The 5-Second Hook Window
For skippable in-stream: the first 5 seconds determine whether the user skips. After skip, Google still registers the impression (but not a "view" unless 30s watched).

**Hook architecture for action (DR) objectives:**
- Seconds 0-2: Pattern interrupt — unexpected visual, bold statement, or unresolved question
- Seconds 2-4: Stakes — what's at risk or what's the prize
- Second 5: Brand reveal (after skip option appears — viewer has chosen to continue)
- Seconds 5-30: Mechanism + proof
- Seconds 30+: Offer + CTA

**Hook patterns proven for in-stream:**
- "Before you skip: [specific claim]" — meta-awareness of skip button; works for high-skepticism audiences
- "I'm going to show you [specific result] in [specific time]" — explicit value promise before skip
- Visual hook (no audio needed): Something visually unusual in first 2 seconds; works for sound-off viewing

### Skippable vs Non-Skippable Optimization
| Format | Optimizes for | When to use |
|--------|--------------|-------------|
| Skippable in-stream (TrueView for Action) | Conversions, website traffic | DR campaigns; self-qualifying (only non-skippers are interested) |
| Non-skippable in-stream (15-20s) | Brand awareness, reach | Guaranteed message delivery; awareness campaigns; new product launches |
| Bumper (6s non-skip) | Frequency / recall | Reinforcement alongside longer video; remarketing reminder |

### View Rate Target
- View Rate (30s views / impressions) >30% = strong hook
- View Rate 15-30% = acceptable; rebuild first 10 seconds
- View Rate <15% = hook failure; video will underperform regardless of offer quality

### CPV Ranges by Industry (industry standard 2024-2026)
| Industry | CPV range (USD) | Notes |
|----------|----------------|-------|
| E-commerce | $0.03-0.08 | Skippable TrueView; broad audience |
| SaaS B2B | $0.08-0.20 | Smaller, more targeted; higher CPV |
| Education | $0.04-0.10 | Mid-range |
| Finance | $0.10-0.30 | Compliance-heavy; limited targeting = broader; higher CPV |
| Local services | $0.02-0.06 | Geographic limit reduces competition |

### Retargeting from View Duration Thresholds
Create YouTube audience lists based on watch duration — higher watch = higher intent:
- 25% watch: TOFU engaged; retarget with next-step content
- 50% watch: Strong interest; retarget with offer
- 75% watch: High intent; retarget with conversion-focused creative
- 95%+ watch: Hottest audience; retarget with direct CTA and urgency

Setup: Google Ads → Tools → Audience Manager → YouTube users → "Viewed any video (from a channel)" or "Watched specific video [X]%" thresholds.

### 3-Step Ad Sequencing
For product launches or considered purchases:
1. **Awareness (30-60s):** Introduce problem + brand; broad audience
2. **Consideration (15-30s):** Mechanism + differentiation; retarget 50%+ viewers from step 1
3. **Decision (6-15s bumper or 15s non-skip):** Offer + urgency; retarget 75%+ viewers from step 2

Setup: Google Ads → Campaign → New campaign → Video → Video sequence.

---

## 20. Demand Gen vs Discovery vs Display

(industry standard 2024-2026; Google Ads documentation)

### Discovery → Demand Gen Rebrand (2023)
Discovery campaigns were renamed Demand Gen in 2023 with expanded capabilities. If you have active Discovery campaigns, they migrated to Demand Gen automatically.

### When Each Wins
| Campaign type | Best use case | Avoid for |
|--------------|--------------|-----------|
| **Demand Gen** | Social-native audiences on YouTube, Discover, Gmail, Maps; visual product storytelling; mid-funnel interest | Bottom-funnel, high-intent keyword-based conversion |
| **Display (GDN)** | Retargeting at scale; placement-specific brand safety; awareness sequencing after Search | Cold traffic without audience lists — CTR rarely exceeds 0.1% cold |
| **Video (YouTube)** | Brand awareness with measurable completion; DR with strong creative | Low-budget accounts without creative assets |

### Demand Gen Audience Targeting
Demand Gen has audience options closer to Meta than traditional Google:
- **Optimized targeting:** Google expands beyond your defined audiences to find similar converters (similar to Advantage+ audience)
- **Lookalike segments:** Google's equivalent of Meta LAL. Based on: your customer list, website visitors, YouTube engagers. 1% lookalike = most similar 1% of Google users to your seed.
- **Custom segments:** Users who searched specific terms on Google.com recently (not just in-market category — specific query intent)

**Setup lookalike in Demand Gen:**
1. Upload Customer Match list (see §17)
2. In ad set audience: Select "Optimized targeting" OR select your Customer Match list and enable "Lookalike segments" toggle
3. Google creates a lookalike audience from your seed at the time of campaign creation

### Creative Requirements by Format
| Format | Demand Gen | Display | Video |
|--------|-----------|---------|-------|
| Image | 1200×628, 1200×1200, 960×1200 | Multiple responsive sizes; 300×250 essential | Thumbnail only |
| Video | Required for YouTube placements | Optional for rich media | Primary asset |
| Headlines | 40 chars (5 required) | 30 chars | Overlay text |
| Descriptions | 90 chars (5 required) | 90 chars | Overlay text |

---

## 21. Bidding Curve Manipulation — Advanced Adjustments

(Brad Geddes; industry standard 2024-2026)

### Bid Adjustments by Dimension (Observation Mode First)
**Process:** Set all adjustments in Observation for 30+ days. Collect CPA data by segment. Then apply bid adjustments based on evidence, not assumption.

| Dimension | Positive adjustment triggers | Negative adjustment triggers |
|-----------|-----------------------------|-----------------------------|
| Device | Mobile CPA 30% below desktop → +20-30% mobile bid | Tablet converts at 2× target CPA → -50% tablet bid |
| Location | Specific city CPA 40% below average → +25-35% | Rural ZIP CPA 3× target → -30-50% |
| Audience | Customer Match converts at 50% of CPA → +30% | Non-converting audience segment after 60+ days → -30% |
| Hour of day | Business hours for B2B convert 4× vs evenings → +30% business hours | Midnight-6am converts 0 → -100% (disable) |

### Dayparting for B2B Specifically
B2B search intent concentrates in business hours. Typical pattern:
- 8am-12pm: Highest intent; bid +20-30% above baseline
- 12pm-2pm: Slight dip (lunch); baseline bid
- 2pm-5pm: Second peak; bid +15-20%
- 5pm-8am: Low intent; bid -40-60% or disable entirely

**Implementation:** Google Ads → Campaign → Ad schedule → Add time segments → Bid adjustment per segment.

**Important:** Smart Bidding (tCPA/tROAS) overrides manual bid adjustments. Dayparting is most impactful on Manual CPC or Maximize Clicks. Under Smart Bidding, use ad scheduling to exclude time windows entirely rather than adjusting bids — Smart Bidding incorporates time-of-day signals automatically.

### Geographic Value Layering
For accounts serving multiple markets:
- Pull conversion data by country/region over 90+ days
- Identify markets with CPA >2× average → apply -30-50% bid adjustment
- Identify markets with CPA <50% of average → apply +20-40% bid adjustment
- Review quarterly; seasonal shifts (holiday season, summer) change geo performance patterns

---

## 23. Common Quality Issues + Rejection Reasons

(industry standard 2024-2026, Google Ads policies)

### Landing Page Mismatch
- Ad promises "free trial" → landing page has no free trial = immediate rejection + policy strike
- Ad headline contains keyword not present on landing page = "below average" ad relevance AND potential mismatch policy trigger
- Landing page redirects to a different domain than final URL = automatic disapproval

### Trademark in Ad Copy
- **Competitor trademarks in ad copy:** Generally prohibited without written authorization from trademark owner. Google's trademark policy enforces this.
- **Competitor trademarks as keywords:** Allowed in most jurisdictions (exception: some EU countries have stricter interpretation)
- **Your own trademark:** Can use freely; register it with Google to prevent competitors from using it in ad copy

### Healthcare and Financial Services
**Healthcare:**
- Prescription drug ads: Prohibited unless certified through Google's Healthcare & Medicines certification program
- Clinical trial recruiting: Allowed with specific restrictions (no misleading efficacy claims)
- Health claims: Must be substantiated; "clinically proven" requires citation; "cure" is prohibited

**Financial services:**
- Certification required for: personal loans, credit products, debt management, binary options/forex
- Apply via: Google Ads → Tools → Settings → Account certification
- EU financial services: Must include required risk warnings ("Capital at risk" type disclaimers) in ad copy
- Czech market: ČNB-regulated products require specific risk language; generic EU disclaimers may not suffice

### Restricted Content Categories
| Category | Status | What's allowed |
|---------|--------|---------------|
| Gambling | Restricted (certification required) | Licensed operators in allowed jurisdictions |
| Alcohol | Restricted (age targeting required) | Responsible alcohol promotion; no targeting minors |
| Counterfeit goods | Prohibited | N/A |
| Dangerous products | Prohibited | N/A |
| Sexually explicit content | Prohibited except certain adult content policies | Family-safe products only by default |
| Political ads | Varies by country | Election ads require authorization in most markets |

### Account-Level Rejection Cascade
- 3 disapprovals within 30 days → warning email
- Active policy violations without appeal → account suspension risk
- Suspended accounts: Appeal via Google Ads Policy Center. Include: specific policy section, evidence of compliance, steps taken. Generic appeals rejected. Average review time: 3-7 business days.

---

## 24. Search vs PMax Budget Split Rules

(industry standard 2024-2026; Brad Geddes, Andrew Foxwell adapted for Google)

### The Core Principle
Search campaigns give you control and visibility. PMax gives you reach and ML optimization. The optimal split preserves Search for proven high-intent traffic while allowing PMax to discover new conversion paths.

### Budget Allocation Framework
| Traffic type | Campaign | Budget allocation | Rationale |
|-------------|----------|-------------------|-----------|
| Branded keywords | Search (exact match) | 10-15% of total | Branded traffic is cheapest, highest intent; PMax will cannibalize it if not isolated here |
| High-intent non-brand (proven keywords with QS ≥7) | Search | 30-40% of total | Proven converters; need control over bid and creative |
| Mid-funnel unbranded | PMax | 30-40% of total | Let ML find conversion opportunities across placements |
| Discovery / new audience | PMax or Demand Gen | 10-20% of total | Awareness and mid-funnel; lowest CPA expectations |

### Branded Keywords in Search — Why They Must Stay Separate
If branded keywords are not isolated in a dedicated Search campaign with brand exclusions on PMax:
1. PMax absorbs branded search queries (easy conversions)
2. PMax ROAS inflates artificially (brand queries convert at 5-10× higher rate than non-brand)
3. Advertiser scales PMax budget thinking it's efficient
4. Non-brand acquisition actually stagnates or declines
5. True CAC is masked

**Test:** Pause PMax for 2 weeks. If branded conversion volume holds steady (via branded Search campaign), PMax was primarily a pass-through for brand traffic, not an incrementality driver. If overall volume drops significantly, PMax was adding genuine non-brand and discovery value.

### When to Shift Budget Toward PMax
- PMax non-brand search terms (visible via Insights tab) show competitive CPA vs Search non-brand
- PMax is discovering conversion paths from YouTube/Discover/Gmail that Search cannot reach
- Search campaign is exhausting its keyword universe (impression share >80% and CPC rising)

### When to Shift Budget Toward Search
- PMax Insights showing primarily branded queries despite brand exclusion
- Search campaign has keywords with QS <6 that could be optimized (better ROI improvement per dollar vs PMax scaling)
- Account has <50 conversions/month total — PMax needs to be fed by existing Search learning; premature PMax launch cannibalizes budget before enough signal exists
