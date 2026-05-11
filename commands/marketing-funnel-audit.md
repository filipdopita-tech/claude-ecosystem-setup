---
name: marketing-funnel-audit
description: Use when auditing a landing page, funnel, or marketing flow for conversion issues. Identifies TOFU/MOFU/BOFU mismatches, missing trust signals, friction points, and copy-clarity problems. Outputs a prioritized fix list.
allowed-tools: [Read, Bash]
last-updated: 2026-04-27
version: 1.0.0
---

# Marketing Funnel Audit

Audit a landing page or multi-step funnel. Output is a prioritized fix list, not a compliment sandwich.

## Step 1 — Establish funnel context

Before auditing, confirm:

- **Entry source**: cold traffic (TOFU) / retargeting (MOFU) / brand search (BOFU)
- **Goal**: lead gen / direct purchase / demo booking / email capture
- **Audience awareness level**: unaware / problem-aware / solution-aware / product-aware
- **Current conversion rate** (if known) — sets severity bar for fixes

If auditing HTML/code, read the page. If auditing a URL or screenshot, work from what is provided.

## Step 2 — Above-the-fold check (5-second test)

Evaluate what a visitor sees without scrolling:

- [ ] Headline states a specific outcome, not a feature or company name
- [ ] Subheadline clarifies who this is for and what they get
- [ ] Primary CTA is visible and unambiguous
- [ ] No competing CTAs or nav links that leak traffic
- [ ] Visual hierarchy: headline > subheadline > CTA (not the reverse)
- [ ] Load speed acceptable (no blocking hero video, no layout shift)

## Step 3 — TOFU / MOFU / BOFU alignment check

Match page content to traffic temperature:

**TOFU mismatch signals** (cold traffic sent to high-commitment page):
- First CTA asks for credit card or 30-min demo
- No social proof visible before the ask
- Industry jargon assumes prior knowledge
- No "what is this" explanation

**MOFU mismatch signals** (warm traffic sent to awareness-level page):
- Page re-explains basics that retargeted visitor already knows
- No comparison, differentiation, or objection handling
- Missing case studies or specific results

**BOFU mismatch signals** (ready-to-buy traffic losing momentum):
- Friction in checkout / form (too many fields, required phone)
- No urgency or scarcity element
- Competing CTAs dilute decision
- Missing guarantee, refund policy, or risk reversal

## Step 4 — Trust signal audit

Score each trust category as present / weak / missing:

| Category | Status | Issue |
|----------|--------|-------|
| Social proof (testimonials) | | |
| Specificity of proof (numbers, names, results) | | |
| Authority signals (press, awards, certifications) | | |
| Security / privacy indicators | | |
| Guarantee or risk reversal | | |
| Company / founder credibility | | |
| Recency (are testimonials dated? Are they fresh?) | | |

## Step 5 — Friction point inventory

List every point where a user could drop off:

- Form fields beyond name + email (each extra field = ~10% drop)
- Required account creation before value delivery
- Redirect away from page before CTA completes
- Pop-ups or interstitials interrupting flow
- Mobile UX: tap targets under 44px, text under 16px, horizontal scroll
- Page speed issues: images over 200KB, render-blocking scripts

## Step 6 — Copy clarity check

For the headline, subheadline, and CTA button text:

- Is the headline specific enough to pass the "so what?" test?
- Does the CTA describe what happens next, not just a verb? ("Get the guide" vs "Submit")
- Is the value proposition in the first 100 words?
- Does the page use customer language or internal jargon?

## Step 7 — Prioritized fix list

Output fixes ranked by impact / effort:

```
PRIORITY | FIX | IMPACT | EFFORT | CATEGORY
---------|-----|--------|--------|----------
P1       | ... | High   | Low    | Copy / Trust / Friction / Alignment
P2       | ... | High   | Med    | ...
P3       | ... | Med    | Low    | ...
```

P1 = high impact, low effort (do first)
P2 = high impact, high effort (schedule)
P3 = low impact, low effort (batch)
Skip: low impact, high effort

End with a one-line overall verdict: conversion-ready / needs work / broken.
