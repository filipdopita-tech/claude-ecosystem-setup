---
name: ads-tiktok
description: TikTok ads strategy and execution — Spark Ads vs Standard In-Feed, creative requirements, hook patterns, audience targeting, algorithm signals, kill rules, and compliance traps. Includes Czech-market CPM benchmarks.
allowed-tools: Read, Write, WebFetch, WebSearch, Bash
last-updated: 2026-04-27
version: 1.0.0
---

# TikTok Ads Agent

Expert-level TikTok advertising strategy and creative direction.

## Triggers
"TikTok ads", "TikTok Spark Ads", "Spark Ads", "TikTok creative", "TT campaign", "TikTok campaign", "TikTok In-Feed", "TopView", "TikTok targeting"

---

## 1. Spark Ads vs Standard In-Feed

### Spark Ads
- **Definition:** Boosts an existing organic TikTok post as a paid ad. The post remains on the creator's/brand's profile.
- **Advantage:** Inherits organic engagement (likes, comments, shares) from the original post — social proof is visible in the ad
- **Advantage:** Feels native; users who engage can follow the account directly
- **Advantage:** Higher trust signals; viewer can click through to verify the account is real
- **Use for:** Brand accounts with organic content performing well; creator partnerships; UGC campaigns
- **Setup:** Creator or brand provides an authorization code (TikTok Business Center); code expires after 30-365 days
- **Limitation:** Cannot modify the creative or caption of the original post

### Standard In-Feed Ads
- **Definition:** Paid ad creative uploaded directly through TikTok Ads Manager. Not tied to any profile.
- **Advantage:** Full control over creative, caption, and CTA; can test many variations
- **Advantage:** Can run as a brand without an active organic TikTok presence
- **Use for:** Direct response campaigns; product launches; controlled A/B creative tests
- **Limitation:** No inherited social proof; cold ad from the viewer's perspective

### Decision Rule
- Organic post with >100K views or strong engagement → Spark it
- Need to test 4+ creative angles fast → Standard In-Feed
- UGC partnership → Spark (with creator authorization)
- New brand account, no organic history → Standard In-Feed while building organic

---

## 2. Creative Requirements

### Technical Specs
| Spec | Requirement |
|------|-------------|
| Aspect ratio | 9:16 (mandatory; 1:1 accepted but underperforms) |
| Resolution | 1080x1920 minimum |
| Duration | 9-60 seconds (15-34s is the algorithm sweet spot) |
| File format | MP4 or MOV |
| File size | Max 500MB |
| Frame rate | 24-60fps |
| Audio | Stereo, 44.1kHz |
| Ad text limit | 80 characters (recommended); 100 max |

### 21-34 Second Sweet Spot
- TikTok internal data: 15-34s ads have highest completion rates vs longer formats
- 21s minimum: gives enough time for hook (1.5s) + problem setup (5s) + solution demo (10s) + CTA (5s)
- Over 60s: sharp completion cliff; only justified for high-story-value content

### The 1.5-Second Rule
- TikTok's distribution algorithm evaluates scroll-through rate at the 1.5-second mark
- Content that loses the viewer before 1.5s is suppressed regardless of later quality
- **Frame 1 must justify staying:** face, motion, text overlay, or visual surprise — no slow pans, no logo reveal
- Auto-captions display from second 1 — include a strong opening line that reads well as text

### Native Feel Mandate
- TikTok's feed rejects foreign objects. Polished studio production looks like "ad." Native UGC looks like a scroll.
- Signals of native content: handheld camera, natural light, informal setting, authentic voice, on-screen captions matching speech, TikTok-style editing (cuts, transitions, text pop-ins)
- The most effective TikTok ads are indistinguishable from organic content until the CTA
- Ratio: 70% native feel, 30% branded signal — never more branded than native in the first 10 seconds

---

## 3. Hook Patterns Specific to TikTok

### 1. POV (Point of View)
"POV: you've been running ads for 3 months and finally understand what's been wrong"
Why: POV framing is native TikTok language. Immediately signals relatable experience. Viewer inserts themselves into scenario.

### 2. Day-in-the-Life
Walking through an actual workflow, routine, or process with voiceover.
Example: "Here's how I set up a TikTok ad campaign in under 20 minutes [screen record + voiceover]"
Why: Tutorial + authenticity. Viewer gets value from watching; brand positioned as expert by default.

### 3. Transformation
Show before state → action → after state in rapid succession.
Example: Cut 1 (3s): cluttered Ads Manager dashboard, low ROAS numbers. Cut 2 (2s): making one change. Cut 3 (3s): same dashboard, ROAS 4.1x.
Why: TikTok's compression of time makes transformation satisfying. No long explanation needed.

### 4. Debate-Bait / Controversial Claim
Take a position that invites disagreement.
Example: "Unpopular opinion: TikTok ads work better than Meta for e-commerce in 2026. Here's why."
Why: Comments are an algorithm signal. Debate in comments = extended distribution. Use real opinion, not manufactured controversy.

### 5. Satisfying Loop
Design the video to loop perfectly. Viewer rewinds without noticing.
Example: Animation or process that ends where it began; viewer watches multiple times.
Why: Rewatches are amplified 3x in TikTok's algorithm. More rewatches = more distribution.

### 6. ASMR Trigger / Sensory Hook
Product sounds, tactile close-ups, satisfying processes.
Example: Product packaging opens with crisp sound; texture visible in macro shot; product assembles with click sounds.
Why: ASMR content has near-universal stop-scroll power regardless of topic familiarity.

### 7. "Wait for it"
Build anticipation explicitly.
Example: "Wait for it... [3 seconds of setup] [payoff]"
Why: Explicit instruction to wait creates commitment. Viewer cannot leave before the payoff without a sense of loss.

### 8. Stitch / Duet Bait
Create content that invites responses.
Example: "Tell me what your biggest Meta ads mistake was — I'll tell you how to fix it."
Why: Stitch and Duet create derivative content; original gets distributed when derivatives are viewed.

---

## 4. Audience Targeting

### Targeting Hierarchy
1. **Custom audiences from TikTok Pixel** (highest precision — your own data)
   - Website visitors (30/60/90 day windows)
   - Purchase events
   - Video viewers (2s, 6s, complete)
   - Profile followers / engagers
2. **Lookalike audiences from custom audiences**
   - 1%, 2%, 5%, 10% similarity tiers
   - Start at 1-2% for prospecting; expand to 5-10% as 1% saturates
3. **Interest + Behavior targeting**
   - Interest categories: Electronics, Beauty, Fashion, Food, Travel, etc.
   - Behavior: Users who interacted with specific content types recently
   - Hashtag engagement: target users who engaged with specific hashtags
4. **Broad (no targeting)**
   - For accounts with TikTok Pixel + 50+ conversions: let TikTok's algorithm find your audience
   - Often outperforms manual stacking at scale

### Audience Size (CZ market estimates)
- Czech TikTok MAU: ~2.5-3M (2025 estimate; primarily 16-35 age demographic)
- Typical 1% LAL from customer list: 25-50K
- Interest-based audience (single category): 100K-500K
- Broad Czech targeting: 1.5-2.5M reachable

### Age and Gender
- TikTok skews 18-34 significantly; 35+ growing but minority
- For B2C products targeting 35+: TikTok is secondary to Meta; budget accordingly
- No demographic targeting available for 13-17 (platform restriction on targeting minors with ads)

---

## 5. Numerical Thresholds

### CTR
- Target: >1% CTR (TikTok benchmark)
- Acceptable: 0.5-1%
- Kill signal: <0.5% after 1,000+ impressions

### CPM (Czech / Slovak market, 2026 estimates)
| Market | Cold CPM range |
|--------|---------------|
| Czech Republic | €3-10 |
| Slovakia | €2-8 |
| Germany | €5-15 |
| United States | $8-25 |

TikTok CPMs are structurally lower than Meta. Efficient for reach. Conversion efficiency depends on product-audience fit.

### Hook Retention
- Target: 50%+ still watching at 3 seconds = strong hook
- Acceptable: 35-50%
- Kill signal: <30% at 3 seconds — rebuild hook entirely; body copy is irrelevant if hook fails

### Completion Rate
- 15-30s ad: target 30%+ completion
- Kill signal: <15% completion on 21s ad = strong signal that video is losing audience mid-way

### Kill Rules
- 1,000 impressions + CTR <0.5% → kill creative, test new hook
- 2,000 impressions + CPA >2x target → kill; test new angle
- Hook retention <30% at 3s → rebuild from frame 1; don't adjust body copy first
- Frequency >4x in 7 days for same audience → refresh creative or expand audience

### Budget Scaling
- TikTok learning phase: requires 50 conversions per ad group per week
- Budget increase: maximum 50% per day (TikTok algorithm is more sensitive to budget changes than Meta)
- Horizontal scale: duplicate ad groups with new creative rather than doubling budget on winning ad group

---

## 6. TikTok Algorithm Signals

### Ranking Signals (highest to lowest impact)
1. **Completion rate** — PRIMARY signal. Percentage of viewers who watch the full video. Optimize everything for this.
2. **Rewatches** — Weighted 3x+ in distribution decisions. Loops, satisfying content, "did I miss something?" endings.
3. **Shares** — Strongest positive signal; indicates "I need to send this to someone." Share > Save > Comment > Like.
4. **Comments** — Volume and velocity matter. Even negative comments increase distribution (debate-bait works).
5. **Saves** — Indicates high value; saved = they'll come back = high retention signal.
6. **Likes** — Weakest signal; passive engagement.
7. **Profile visits / Follows** — Positive quality signal; suggests creator connection.

### Distribution Mechanics
- TikTok serves each new video to a small test cohort (50-200 users)
- If completion rate + engagement exceeds threshold → expanded distribution (next cohort: 500-5,000)
- This waterfall continues until engagement rate drops to average → distribution caps
- For ads: same signals apply alongside CPM bidding. A high-engagement ad gets cheaper CPMs over time.

### Paid vs Organic Algorithm Synergy
- Organic posts that perform well have lower CPMs when Sparked
- Posting organic content from the same account as ad campaigns improves overall account-level signal
- TikTok favors advertisers who also have active organic presence (account health signal)

---

## 7. Music Licensing for Ads

### Commercial Sound Library (mandatory for ads)
- Organic TikTok: licensed music available in the full sound library
- TikTok Ads: MUST use sounds from the **Commercial Music Library** only — not the organic library
- Using non-commercial sounds in ads = policy violation → ad disapproval
- Access: TikTok Ads Manager → Creative → Commercial Sound Library
- Trend sounds: some trend sounds are available in commercial library; check before using

### Sound Strategy
- 15% of TikTok is watched with sound off (inverse of Meta: most TikTok is sound-on)
- Audio-reactive content: sync cuts and transitions to music beats → completion rate +15-25%
- ASMR product sounds: replace music for sensory products (food, cosmetics, packaging)
- Voice-over + subtitles: dual strategy for accessibility and algorithm (subtitles increase watch time)

---

## 8. Policy Traps — TikTok Ban Triggers

### Prohibited Content Categories
- **Medical claims:** No "cures," "treats," "clinically proven" without full regulatory documentation. Even implying health benefits without disclaimer = rejection.
- **Financial promises:** "Make €5,000 per month from home" = automatic rejection. Financial products require regulatory disclaimer (ČNB license / equivalent).
- **Weight loss and body image:** Before/after body transformation = banned. No claims about losing specific amounts of weight.
- **Cryptocurrencies and NFTs:** Highly restricted; most crypto ads require specific approval and are unavailable in many markets.
- **Age-restricted products:** Alcohol, tobacco, gambling — require specific TikTok approval and are banned in most markets for standard advertisers.
- **Political content:** Electoral and political advertising banned on TikTok Ads globally.
- **Misleading testimonials:** Fake reviews, staged "reaction" videos presented as organic, paid endorsements without #ad disclosure.

### Common Rejection Reasons (operational)
1. Ad text mentions competitor brand by name (comparative advertising restrictions)
2. Landing page content doesn't match ad promise (policy violation AND algorithm penalty)
3. Sensational health or financial claims in first-frame text
4. Creative contains third-party watermarks (Instagram Reels with Reels logo = rejection)
5. Music used is not from Commercial Sound Library

### ČNB / Czech Regulatory Note
Financial product ads (investment, lending, insurance) on TikTok must include:
- Risk disclaimer: "Investování je rizikové, hodnota investic může klesat i stoupat."
- Regulatory status: ČNB license number if applicable
- No guaranteed return claims of any kind

---

## 9. TikTok-Specific Creative Checklist

Before publishing:

**Technical:**
- [ ] 9:16 aspect ratio, 1080x1920 minimum
- [ ] Duration 15-34 seconds
- [ ] Sound from Commercial Music Library OR original sound
- [ ] No watermarks from other platforms
- [ ] Subtitles/captions added (auto-generate + review)

**Creative:**
- [ ] Frame 1 contains a face, motion, or bold text — no static logo
- [ ] Hook resolves at 1.5s (viewer has a reason to stay)
- [ ] Native feel: no studio production look in first 10s
- [ ] CTA is visible on-screen in final 5 seconds
- [ ] Ad text (caption): <80 characters, hook-led, includes relevant hashtags (3-5 max)

**Compliance:**
- [ ] No medical or financial performance claims
- [ ] No before/after body transformation
- [ ] Landing page matches ad promise exactly
- [ ] Paid partnership disclosed if using creator content (#ad or TikTok's branded content toggle)
