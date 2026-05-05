---
name: ads-linkedin
description: LinkedIn Ads strategy and execution — Sponsored Content, Message Ads, Conversation Ads, Lead Gen Forms, Document Ads, Thought Leader Ads. Covers ABM targeting, audience templates, bidding (Max Delivery vs Manual CPC vs Target Cost), creative specs, B2B SaaS playbook, kill rules, and Czech/EU regulatory specifics. Triggers on "LinkedIn ads", "Sponsored Content", "InMail", "Message Ads", "Conversation Ads", "Lead Gen Form", "ABM campaign", "B2B paid".
allowed-tools: [Read, Write, Edit]
last-updated: 2026-04-28
version: 1.0.0
---

# LinkedIn Ads Agent

Expert-level LinkedIn advertising strategy and execution for B2B SaaS.

---

## 1. When to Use LinkedIn Ads vs Alternatives

LinkedIn CPM is $30-150 — 3-10x Meta. The premium is only justified when:

**Use LinkedIn when:**
- ACV ≥ $5,000 (enterprise SaaS, consulting, professional services)
- You need ABM into named accounts (company-level targeting is LinkedIn's only moat)
- Recruiting senior roles (Director+, VP, C-suite) where job title targeting is the constraint
- Regulated industries where job function/seniority determines who can legally receive the message (fintech, legal, healthcare)
- B2B demo requests from decision-makers who don't click Meta ads

**Do not use LinkedIn when:**
- SMB, consumer, or sub-$1K ACV products — CPL will be 5-10x viable
- E-commerce, DTC, lifestyle products
- You need volume/reach at low CPM — Meta Broad or Google Display will outperform by 5x
- Brand awareness at scale — LinkedIn reach is small vs Meta; CPM is high

**Threshold test:** If your target persona is a manager-or-above at a company with 50+ employees buying software, LinkedIn passes the filter. If not, start with Meta and revisit.

---

## 2. Campaign Objective Decision Tree

LinkedIn Campaign Manager objective → algorithm optimization goal:

```
What is the campaign goal?
│
├─ Reach a broad B2B audience cheaply? → Brand Awareness
│   Optimizes: CPM. Use: top-of-funnel video or thought leadership.
│
├─ Drive traffic to a landing page? → Website Visits
│   Optimizes: CPC. Use: content offer, blog, product page.
│
├─ Get likes/comments/shares on posts? → Engagement
│   Optimizes: engagement actions. Use: amplifying organic content.
│
├─ Maximize video watch-throughs? → Video Views
│   Optimizes: cost per view. Use: brand story, product demo.
│
├─ Native form fill without leaving LinkedIn? → Lead Generation
│   Optimizes: CPL via Lead Gen Form. Use: top/mid-funnel content offers.
│
├─ Conversion on your own website? → Website Conversions
│   Optimizes: conversion events via Insight Tag. Use: demo, trial, purchase.
│   Requires: LinkedIn Insight Tag + conversion event defined.
│
├─ Hiring a specific role? → Job Applicants
│   Optimizes: application clicks. Use: open roles, employer brand.
│
└─ Filling CRM pipeline from LinkedIn Recruiter-style? → Talent Leads
    Use: executive recruiting, specialized roles.
```

**SaaS progression:** Brand Awareness (video views) → Lead Generation (content offer) → Website Conversions (demo request). Do not jump straight to Website Conversions on cold audiences without warming.

---

## 3. Ad Formats

### Sponsored Content
Appears in feed. All formats require a Company Page.

**Single Image Ad**
- Recommended size: 1200×627 px (1.91:1) or 1080×1080 px (1:1)
- 1:1 performs better on mobile (larger real estate)
- Intro text: 150 chars visible before "see more" (600 max)
- Headline: 70 chars (200 max)
- Description: 100 chars (300 max)
- File: JPG or PNG, max 5MB

**Video Ad**
- Ratios: 1:1, 4:5, 9:16, 16:9 (1:1 or 4:5 best for mobile feed)
- Duration: 3 seconds to 30 minutes (15-30s optimal for paid)
- File: MP4, max 200MB
- Captions: mandatory — 85% watched without sound (same as Meta)
- Thumbnail: JPG/PNG at video resolution

**Carousel Ad**
- 2-10 cards
- Card size: 1080×1080 px (1:1 required)
- Card headline: 45 chars max
- Intro text: 255 chars
- Each card has its own destination URL

**Document Ad**
- Upload: PDF, DOCX, PPTX (max 100MB, max 300 pages)
- Preview shows first few slides inline — no email gate for viewing
- Intro text: 150 chars visible
- Headline: 70 chars
- Lead Gen Form can be gated at end (optional)
- Best format 2024-2026: 8-12 page PDF designed for native preview

**Event Ad**
- Promotes a LinkedIn Event
- Drives registrations directly on LinkedIn

**Thought Leader Ad** (2023+)
- Boosts a personal post from a company employee (CEO, exec, SME)
- Requires employee to authorize the boost
- Company Page is not required in the ad unit — shows as the individual
- +30-50% CTR vs equivalent branded Sponsored Content
- Intro text: comes from the original organic post

### Message Ads (formerly Sponsored InMail)
- Delivered to LinkedIn Inbox
- Subject line: 60 chars
- Body: 1,500 chars max; personalization tokens: {{firstName}}, {{lastName}}, {{companyName}}, {{jobTitle}}
- CTA button: 20 chars
- Frequency cap enforced by LinkedIn: each member receives max 1 Message Ad per 30 days from any advertiser
- Open rate: 30-45%; CTR: 3-6% (above-average B2B email benchmarks)
- Use for: direct offers, event invites, high-intent BOFU outreach

### Conversation Ads
- Chat-style multi-branch Message Ad
- Up to 5 CTA buttons per message node; each button ≤25 chars
- Each branch can send to URL or to another message node (max depth: 5 exchanges)
- Open rate: 50-60%; reply rate: 5-10%
- Frequency cap: same 30-day rule as Message Ads
- Use for: webinar invite → qualify → route (attend vs recording vs demo)
- Opener must offer value — do not open with a demo ask

### Dynamic Ads
- Spotlight Ad: personalized with member's profile photo + name; redirects to URL
- Follower Ad: drive Company Page follows
- Job Ad: surface open roles dynamically
- Right-rail placement (desktop only); smaller format
- CTR lower than Sponsored Content; use for retargeting brand awareness

### Text Ads
- Right-rail or top banner (desktop only)
- Headline: 25 chars; description: 75 chars; image: 100×100 px
- Low relevance in 2024-2026; only use if CPM budget is critical and audience is desktop-heavy

---

## 4. Audience Targeting

LinkedIn's targeting is its only hard moat over Meta. Use it precisely.

### Professional Attributes
- **Job Title:** most precise; risk of missing titles that vary by company ("Head of Growth" vs "VP Marketing")
- **Job Function + Seniority:** broader but reaches more; combine Function (Marketing, Sales, IT) + Seniority (Director, VP, C-level, Manager)
- **Years of Experience:** use for seniority proxy when titles vary widely
- **Skills:** self-reported but useful for technical personas (e.g., "Salesforce", "Python", "ABM")

### Company Attributes
- **Company Name:** ABM — up to 300K companies via CSV upload, min 1K matched to serve
- **Company Size:** 1-10, 11-50, 51-200, 201-500, 501-1K, 1K-5K, 5K-10K, 10K+
- **Industry:** LinkedIn SIC-equivalent; useful for vertical campaigns
- **Company Revenue:** (LinkedIn Sales Insights data, available on some accounts)
- **Company Growth Rate:** high-growth filter; useful for targeting fast-scaling orgs
- **Follower Count of Company:** proxy for brand recognition

### Member Attributes
- **Degree field, school:** useful for highly specialized audiences (MBAs, engineers)
- **Groups:** LinkedIn Groups membership; use for niche communities
- **Interests:** topic-based; less precise than professional attributes

### Audience Types
**Retargeting (Matched Audiences):**
- Website visitors (via Insight Tag) — segment by URL path
- Video viewers — 25%, 50%, 75%, 97% completion segments
- Lead Gen Form openers and submitters
- Company Page visitors and followers
- Single-image ad engagers, Document Ad readers
- Event registrants and attendees

**Upload-based:**
- Contact list upload: emails, hashed — min 300 matched for EU (min 1,000 elsewhere)
- Company list upload: company names or LinkedIn Company URLs — min 1K matched
- Both require explicit consent under GDPR for EU audiences

**Predictive Audiences (formerly Lookalikes, 2024+):**
- LinkedIn's ML-based expansion from a seed list (Lead Gen Form submitters, website converters, customer list)
- Replaces the old Lookalike Audiences feature
- Min seed: 500 matched members; audience generates ~200K-500K members
- Predictive Audiences based on high-LTV customers outperform broad seeds (same principle as Meta LAL — seed quality > seed volume)

### Exclusions — Always Apply
- Existing customers (upload company list or contact list)
- Employees (use Company Page followers exclusion or employee company exclusion)
- Irrelevant seniority (e.g., exclude Individual Contributor if selling enterprise)
- Audiences already converted in current campaign

### Audience Size Guidelines
- Minimum for delivery: 300 members (EU), 1,000 (rest)
- Optimal for prospecting: 50K-500K
- ABM campaigns: can run at 1K-10K (smaller = higher frequency, tighter message)
- If audience <5K: frequency will exceed limits quickly; monitor hard

---

## 5. Bidding Strategies

### Max Delivery (default)
- LinkedIn automates bids to spend full budget and maximize objective
- Equivalent to Meta's "Highest Volume" — no manual ceiling
- Use: when starting out, when you want to fill spend quickly
- Risk: can overspend on low-quality inventory in small audiences

### Manual CPC
- You set the max CPC; LinkedIn optimizes within that
- Use: when you have historical CPC benchmarks and want cost control
- Suggested entry: set CPC at 20-30% above LinkedIn's suggested bid to ensure delivery, then compress as you get data
- Phase 2+ (once performance is known): switch to Manual CPC to control CPL

### Target Cost
- Semi-automated; LinkedIn tries to hit your cost per result target
- Use: mid-phase, when you have 20-30 conversions and a CPL target
- Set target at 20-30% above your actual CPL floor (give algorithm room)

### Cost Cap (2024+)
- Hard ceiling per result; LinkedIn will under-deliver rather than exceed cap
- Use: strict CPL or CPA budgets where overspend is not acceptable
- Risk: delivery can stall if cap is too tight for the audience

### Phase Progression (mirror Adam Kropáček framework)
```
Phase 1 — Initial (0 conversions): Max Delivery or Manual CPC
  Purpose: gather baseline CPL, CPC, CTR data

Phase 2 — Accumulation (1-50 conversions): Manual CPC + creative optimization
  Purpose: identify winning creatives and audiences; do not automate prematurely

Phase 3 — Automation (50+ conversions): Target Cost or Cost Cap
  Purpose: algorithm has signal; anchor target to observed Phase 2 CPL

Phase 4 — Refinement: Adjust target ±10-15%; watch for audience exhaustion
```

**Never switch bid strategy during peak campaign windows** (product launch, webinar week). Learning phase reset wastes critical budget.

---

## 6. Numerical Thresholds

### CPM Benchmarks (B2B, 2025-2026)
| Region | Cold Prospecting | Retargeting |
|--------|-----------------|-------------|
| North America | $40-100 | $60-150 |
| UK / Western EU | $30-80 | $50-120 |
| CZ / CEE | $20-60 | $35-90 |
| APAC | $15-50 | $25-75 |

CPM spikes indicate: audience too small (frequency forcing cost up), excessive competition for that persona, or creative scoring low on LinkedIn's relevance metric.

### CPC Benchmarks
- Average B2B: $5-15
- Senior decision-makers (VP, C-suite): $8-25
- Highly competitive verticals (fintech, HR tech, cybersecurity): $15-40
- CZ market: ~30% lower than equivalent EU-West targeting

### CTR
| Performance level | CTR |
|------------------|-----|
| Kill | <0.3% after 1K impressions |
| Review creative | 0.3-0.4% |
| Pass | >0.4% |
| Strong | >0.6% |
| Exceptional | >1.0% (usually Thought Leader Ads) |

### Lead Gen Form Benchmarks
- Form fill rate (openers who submit): strong = 10-15%; acceptable = 5-10%; review = <5%
- If fill rate <5%: form is too long, asks for too much, or offer is mismatched to audience temperature

### Cost per Lead (CPL)
| Segment | Benchmark CPL |
|---------|--------------|
| SMB SaaS (ACV $1K-10K) | $50-150 |
| Mid-market SaaS (ACV $10K-100K) | $150-400 |
| Enterprise (ACV $100K+) | $300-1,000 |
| Native Lead Gen Form (top-funnel content) | $30-100 |
| Website conversion (demo request) | $100-500 |

### Frequency
- Cold prospecting: cap at 3-5 impressions/member/week before creative fatigue
- Retargeting: cap at 5-10 impressions/member/week acceptable
- ABM (small named accounts): frequency can run higher (10-15/week); persona knows the brand
- Monitor in Campaign Manager: frequency column on ad-level view

### Pipeline Quality
- Lead Gen Form to MQL rate: acceptable = 15-30%; below 10% = audience or offer misalignment
- MQL to SQL: 20-40% acceptable for LinkedIn-sourced leads (higher intent vs. display)

---

## 7. Creative Best Practices

### Intro Text — First 150 Characters
The first 150 chars appear before "see more" in feed — equivalent to Meta's first 125 chars. These chars determine the scroll or engage decision.

Hook patterns that work on LinkedIn:
- **Data-driven:** "73% of B2B buyers complete research before talking to sales. Here's how to be in their shortlist."
- **Role-relevant identity:** "For VP Sales teams managing 10+ reps: the pipeline visibility gap most CRMs don't solve."
- **Contrarian:** "Demo requests are a vanity metric. Here's what the top 5% of SaaS companies track instead."
- **Specific outcome:** "We reduced customer onboarding from 3 weeks to 4 days. The process is in this document."
- **Peer proof:** "How [Company] went from 60-day sales cycles to 30. CFO explains the one process change."

Avoid: generic corporate opener ("We're excited to share..."), mission statements, feature lists as opening line.

### Document Ads — Dominant Format 2024-2026
- 8-12 page PDF native preview is the highest-performing format for B2B content offers
- No email gate required to view (removes friction; readers self-qualify by depth of reading)
- Retarget document readers (75%+ read = high intent; gate demo offer here)
- Design for mobile preview: large text, single concept per slide, high contrast
- Title page must work as a standalone ad: specific outcome + number + credibility signal
- Example: "The 2026 B2B SaaS Outbound Playbook: 14 templates used by teams closing $1M+ ARR"
- Gate optional: add Lead Gen Form at end for readers who want the full resource download

### Video Specs and Approach
- 15-30 seconds for paid cold; up to 2 minutes for retarget (audience is warm)
- Captions mandatory (85% sound-off)
- First 3 seconds: text overlay + face or bold visual; same hook principle as Meta
- Authentic over polished: phone-camera footage of a practitioner explaining a real problem outperforms studio video with corporate graphics 60%+ of the time on LinkedIn
- Avoid: generic stock imagery, people shaking hands, staged office scenes

### Thought Leader Ads
- Amplify a CEO, VP, or technical expert's organic post
- Individual posts perform 2-5x better than company posts organically — paid amplification compounds this
- +30-50% CTR vs branded Sponsored Content equivalent
- Use for: product announcements, case studies, provocative takes that are already getting organic traction
- Workflow: post organically, wait 24h to see organic engagement, then boost if engagement is strong

---

## 8. B2B SaaS Playbook

### Full-Funnel Sequence (3-touch minimum before form ask)

**Stage 1 — Awareness (cold audience)**
- Format: Video Ad or Thought Leader Ad
- Objective: Video Views (optimize for 50%+ completion)
- Budget allocation: 30% of LinkedIn spend
- Cost: $0.10-0.30 per view (50% completion)
- Audience: Persona (job function + seniority) OR Company List (ABM)
- Duration: 4-6 weeks before retargeting

**Stage 2 — Consideration (video viewers 50%+ or web visitors)**
- Format: Document Ad (case study, framework, benchmark report)
- Objective: Lead Generation or Website Visits
- Budget allocation: 40% of LinkedIn spend
- Offer: ungated PDF native preview; optional Lead Gen Form at end
- Audience: retarget Stage 1 video viewers + website visitors (30-day)
- Duration: 2-4 weeks

**Stage 3 — Decision (document readers 75%+ or form openers)**
- Format: Single Image or Conversation Ad
- Objective: Website Conversions (demo) or Lead Generation (demo request form)
- Budget allocation: 30% of LinkedIn spend
- Offer: demo, free trial, ROI calculator, live assessment
- Audience: retarget document readers + Lead Gen Form openers + pricing page visitors
- Duration: ongoing BOFU

### ABM Layer
For named-account targeting (ICP companies known by name):
1. Upload target account list (CSV with company names or LinkedIn URLs)
2. Layer persona targeting on top (Function + Seniority)
3. Run all three funnel stages within the named account audience simultaneously
4. Supplement with LinkedIn Buyer Intent data (native) or 6sense/Bombora integration for prioritization
5. ABM audiences can run higher frequency (accounts expect to see your brand multiple times)

**Minimum ABM requirements:** 1,000 matched companies for delivery; 3,000+ recommended for meaningful scale.

---

## 9. Lead Gen Forms — Native vs Landing Page

### When to Use Native Lead Gen Form
- Top-of-funnel content offers: ebooks, reports, frameworks, webinar registrations
- Audience is cold or warm (not yet BOFU)
- Speed of setup is a priority (no LP to build)
- Benchmark expectation: 2-3x form fill rate vs equivalent landing page
- Lead quality caveat: lower intent — members auto-fill from LinkedIn profile without thinking; scrub more carefully

### When to Use Landing Page (Website Conversions)
- Demo requests, free trials, paid signups — any high-intent action where you want the prospect to make a conscious decision
- You need to show social proof, testimonials, or pricing before the form (LP allows this; native form does not)
- You want GA4 / CRM data alongside LinkedIn data
- Lower volume, higher quality — the friction filters for intent

### Form Field Rules
- Maximum 4 fields for strong fill rates: name (pre-filled) + email + company + job title
- Each additional field reduces fill rate 10-20%
- For enterprise: adding "Company size" or "Annual revenue" adds qualification but reduces volume
- Hidden fields: use to capture campaign/audience metadata for CRM routing
- GDPR: must include privacy policy link and explicit consent checkbox for EU members

### Routing to CRM
- Native integrations: HubSpot, Marketo, Salesforce, GHL — sync via LinkedIn's built-in connectors
- Zapier fallback for others
- Set up lead routing immediately — LinkedIn leads degrade fast (contact within 24h is critical)

---

## 10. Conversation Ads Playbook

### Structure
- Opener message: value offer, no hard sell. Max 500 chars.
- Branch 1 (primary CTA): primary desired action — "Get the playbook", "Save my seat"
- Branch 2 (objection handler): "Not ready yet? See how teams like yours use it"
- Branch 3 (soft exit): "Just browsing? Follow us for weekly insights"
- Each button: ≤25 chars; action-oriented ("Send me the report", "Book 20 min", "Tell me more")

### Copy Rules
- Open with a question or observation that is immediately relevant to their role
- Do not start with your company name or product
- Example opener: "{{firstName}}, are you tracking pipeline by rep or by territory? Most VP Sales teams that switch see a 20% forecast accuracy jump. Here's why."
- Branch naturally from the first response — Conversation Ads are closer to email sequences than banner ads

### Benchmarks
- Open rate: 50-60% (LinkedIn delivers to Inbox; novelty vs email inbox is still high)
- Reply rate (CTA click): 5-10%
- CPL via Conversation Ad: typically 20-40% lower than Sponsored Content for same offer, due to personalization and direct delivery

### Frequency
- Same 30-day cap per member as Message Ads
- Do not run Conversation Ads and Message Ads simultaneously to the same audience — one will suppress the other

---

## 11. Kill Rules

| Signal | Threshold | Action |
|--------|-----------|--------|
| Spend without conversion | $200 spent, 0 conversions | Kill creative; test new angle |
| CTR too low | <0.3% after 1,000 impressions | Kill creative immediately |
| Frequency too high, no lift | >7 cold / >12 warm, CTR dropping | Audience burned; expand or pause |
| CPL above target | >2x CPL target after 50 leads | Split-test audience and creative separately |
| Lead form spam | >20% leads with junk data | Add qualifying field; switch to LP |
| Video not completing | <25% avg completion at 3s | Hook failure; rebuild first 3 seconds |
| Form fill rate | <3% (openers who submit) | Form too long or offer wrong for stage |

**Sequence for creative kill:** pause → duplicate ad with new creative in same ad set → run both for 48h → kill loser. Do not change audience and creative simultaneously (can't attribute cause).

---

## 12. Scaling Rules

**Budget increments:** Maximum 20-30% increase per 3-5 days. Mirror Adam Kropáček's Meta rule — same algorithm discipline applies. Never double budget at once.

**Horizontal scaling (preferred):**
- Duplicate winning campaign to a new audience seed (different job function, different seniority, different company size)
- Each duplicate starts with fresh learning; preserves the winning creative
- Best for: expanding from one persona to adjacent personas

**Vertical scaling:**
- Increase budget on existing winner only after CPL is stable for 7 consecutive days
- Watch for audience exhaustion: if frequency rises and CTR drops >30% in 7 days, the seed is saturated
- LinkedIn universe is smaller than Meta — audience exhaustion happens faster

**Audience exhaustion signals:**
- Frequency >5 on cold + CTR drop 30%+ week-over-week
- CPM rising without obvious competitive reason
- Same 1,000-5,000 person audience hit repeatedly

**Response to exhaustion:**
1. Expand seed: broaden job function, loosen seniority, add adjacent industries
2. New creative: same audience, new hook/angle
3. Pause for 2-3 weeks: let the audience reset; LinkedIn's frequency cap resets

---

## 13. Czech/EU Specifics

### GDPR and LinkedIn Insight Tag
- LinkedIn Insight Tag (pixel) requires explicit opt-in consent from EU site visitors before firing
- Cookie banner must include "Marketing/Advertising" category toggle — do not bundle with functional cookies
- Use a Consent Mode-compatible CMP (Cookiebot, CookieYes, Usercentrics) to gate Insight Tag activation
- Server-side Conversions API (LinkedIn equivalent of Meta CAPI) can supplement but does not replace Insight Tag consent requirement
- Retargeting EU audiences: consent rate typically 30-60% — effective retarget audience is smaller than total visitors

### Audience Minimums (EU)
- LinkedIn enforces privacy-protection minimum: 300 matched members before an audience can serve ads (vs 1,000 in US)
- Verify current threshold in Campaign Manager — has fluctuated; 300 is the 2025 documented minimum for EU
- Contact list uploads: explicit consent required for each email address; do not upload cold prospect lists

### Czech Market Copy
- Vykání ("Vy/Vám") for all personas Senior Manager and above; this is the default for B2B LinkedIn copy in CZ
- Tykání acceptable only for startup/tech communities where the brand uses informal tone consistently across all channels
- Czech-language ads see ~25-35% lower CPC vs equivalent English targeting (less advertiser competition for Czech-language inventory)
- Caveat: Czech-language targeting narrows the audience significantly; model audience size drop before committing

### Czech Regulatory
- Financial services ads (fintech, investment, lending): same ČNB risk disclaimer requirements as on Meta — no guaranteed returns, required risk warnings
- GDPR consent documentation: keep records of consent basis for contact list uploads (particularly if sourced from outbound prospecting tools like Apollo or Clay)

---

## 14. Common Mistakes

**Targeting too broad:** LinkedIn's algorithm does not automatically find your buyer like Meta's does. Over-broad targeting (e.g., "all Marketing professionals") burns budget on irrelevant impressions. Add seniority, company size, and function layers.

**No exclusion lists:** Running cold campaigns without excluding existing customers, employees, and converted leads wastes 5-15% of budget. Always load exclusion lists before first ad goes live.

**Insight Tag missing or firing without consent:** If Insight Tag is not installed or consent is blocked, Website Conversions objective cannot optimize, retargeting audiences won't build, and Conversions API has no baseline to match against.

**Running same creative >3-4 weeks:** LinkedIn audiences exhaust faster than Meta due to smaller universe. Creative fatigue is visible by week 3-4 on most B2B campaigns. Rotate or the CTR decay becomes terminal.

**Defaulting native form for everything:** Native Lead Gen Forms for demo requests capture unqualified leads who auto-filled without intent. Route bottom-funnel offers to landing pages; native forms for top-of-funnel content only.

**Audience overlap between campaigns:** Multiple campaigns targeting the same persona compete against each other in LinkedIn's auction, driving up CPM. Use the Audience Overlap tool in Campaign Manager and separate campaigns clearly.

**Skipping the 3-touch rule:** LinkedIn's own data shows 3+ touchpoints before form submission for B2B buying decisions. Cold → demo ask in one step produces CPLs 3-5x above benchmark.

**Not testing Thought Leader Ads:** Most LinkedIn advertisers only run branded Sponsored Content. Thought Leader Ads from executives/practitioners routinely outperform branded ads at lower CPM — it is an underused format.

---

## 15. Tooling Integration

### LinkedIn Insight Tag
- JavaScript snippet on all pages (equivalent to Meta Pixel)
- Fires: PageView, custom conversions defined by URL or event
- Install via GTM tag or direct script; verify via LinkedIn Tag Helper Chrome extension
- Required for: Website Visits objective, Website Conversions objective, retarget audiences

### LinkedIn Conversions API (CAPI)
- Server-side conversion signals sent directly to LinkedIn, bypassing browser tracking loss
- Setup: via LinkedIn's API or partner integration (Segment, GTM server-side, HubSpot)
- Deduplication: use `eventId` parameter to match browser + server events
- Required for accurate reporting in EU where cookie consent opt-in rates are <60%

### CRM Integration for Lead Gen Forms
- **HubSpot:** Native connector in LinkedIn Campaign Manager → instant sync to HubSpot contact
- **Salesforce:** Via LinkedIn Lead Gen Forms integration (requires Salesforce connector setup)
- **GHL (Go High Level):** Zapier or webhook-based; webhook URL in LinkedIn LGF settings; test with a real form submit before going live
- **Marketo:** Native connector available; maps LinkedIn form fields to Marketo fields

### Member ID Matching for Offline Conversions
- Upload CRM deal stages as offline conversions via LinkedIn's Conversion API
- Use case: mark a qualified lead at $100 value; closed deal at $5,000 value
- LinkedIn optimizes toward conversions that predict downstream revenue, not just form fills
- Requires matching on email (hashed SHA-256) or LinkedIn Member ID

### LinkedIn Sales Navigator + Ads Alignment
- Sync target account lists from Sales Navigator → LinkedIn Campaign Manager (ABM list)
- Use Navigator's intent signals to prioritize which accounts to run higher-frequency ABM campaigns against

---

## 16. Campaign Naming Convention

Consistent with the cross-platform convention from paid-ads:

```
LI_[OBJECTIVE]_[AUDIENCE]_[FORMAT]_[OFFER]_[YYYY-MM-DD]
```

Examples:
```
LI_LEAD_ABM-TechCo-List_DocAd_PipelineReport_2026-04-28
LI_CONV_Retarget-VideoViewers-50pct_SingleImg_DemoRequest_2026-04-28
LI_AWARE_VPSales-Mid-Market_Video_BrandStory_2026-04-28
```

---

## 17. Sources

- **Adam Kropáček paid-ads framework:** Phase progression (Phase 1-4 bidding), 70/30 budget split, 50-conversion threshold for automation, 20-30% budget scaling increments, lookalike seed quality principle (LTV > volume), frequency caps by retargeting stage — all directly applied here with LinkedIn-specific parameters.
- **LinkedIn Marketing Solutions documentation:** Campaign objectives, audience minimums, ad format specs, frequency caps, Lead Gen Form integration options, Insight Tag and Conversions API.
- **AJ Wilcox (B2Linked):** LinkedIn Ads industry benchmark source for CPM/CPC ranges, CTR thresholds, and format performance rankings.
- **LinkedIn B2B Institute research:** 3-touch minimum before conversion claim; buyer journey data.
- **Adam Goyer:** LinkedIn Ads practitioner; Document Ads dominance 2024+, Thought Leader Ads CTR uplift data.
- **Filip outbound patterns (reference):** LinkedIn outreach principles (personalization, value-first opening, short paths) inform Conversation Ads structure and Message Ads copy approach — paid InMail follows the same psychological principles as cold outbound sequences.
