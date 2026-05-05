---
name: ab-test-design
description: A/B test design for landing pages and onboarding flows — hypothesis format, sample size, what not to test, run duration, and ship/kill decisions.
allowed-tools: Read, Write, Edit
last-updated: 2026-04-27
version: 1.0.0
triggers:
  - A/B test
  - experiment
  - split test
  - conversion test
---

# A/B Test Design — Landing Pages and Onboarding Flows

## Hypothesis Format

A hypothesis is not "let's try a different button color." It names a mechanism.

Format: **If we change [X] to [Y], then [metric Z] will [increase/decrease] because [mechanism M].**

Examples:
- "If we change the hero headline from feature-focused to outcome-focused, then free trial signups will increase because visitors understand the value before seeing the product."
- "If we move the social proof section above the fold, then scroll depth past the CTA will decrease (users will convert earlier) because trust is established before the ask."
- "If we reduce the onboarding form from 8 fields to 3, then step-1 completion will increase because friction is the primary drop-off cause at this stage."

A weak hypothesis (no mechanism) predicts nothing. If the test fails, you learn nothing. A strong hypothesis makes the result informative either way.

## Sample Size Estimation

Never start a test without knowing the required sample size. Running underpowered tests produces false positives — the most expensive mistake in experimentation.

Steps:
1. Establish your **baseline conversion rate** (from analytics, last 30–90 days).
2. Define the **minimum detectable effect (MDE)** — the smallest improvement worth shipping. 5–10% relative lift is the practical floor for most landing pages; smaller effects require traffic you likely don't have.
3. Set **statistical power** at 0.8 (80%) — standard. Use 0.9 for high-stakes tests.
4. Set **significance level** at 0.05 (95% confidence) — standard.

Use a calculator: [Evan Miller's sample size calculator](https://www.evanmiller.org/ab-testing/sample-size.html) or the built-in calculators in Statsig or PostHog.

Example: Baseline 3% conversion, MDE 10% relative (i.e., 3% → 3.3%), 80% power, 95% confidence → ~30,000 visitors per variant. If your page gets 500 visitors/day, that is 60 days per variant — likely not worth running.

If the required sample is unreachable, either:
- Increase the MDE (only test bigger changes), or
- Move the test to a higher-traffic funnel step.

## What NOT to Test

Avoid these mistakes:
- **Low-traffic pages.** If the page gets fewer than 500 conversions/month on the primary metric, you cannot reach significance in a reasonable time. Fix traffic first.
- **Multivariate tests without traffic.** MVT requires sample size that scales multiplicatively with the number of variants. 2 changes × 2 options each = 4 variants = 4× the traffic requirement.
- **Multiple simultaneous tests on the same page.** Interaction effects contaminate results. Run one test per page at a time.
- **Tests during anomalous periods.** Product launches, holidays, paid spend spikes — any of these skew the baseline and make results non-generalizable.
- **Micro-copy tests on low-frequency pages.** Button label tests require enormous traffic to detect lift. Save them for pages with >10,000 visits/month.

## Running Window — Minimum Duration

A test must run for **at least one full business cycle** regardless of whether it hits significance early. For most B2B products, that is 2 full weeks to capture weekday/weekend behavior variation.

Rules:
- Never call a test in under 7 days, even if p < 0.05 on day 3. Early significance is almost always a false positive from day-of-week bias.
- If the test involves purchases or contract renewals, the cycle may be 4–8 weeks to capture monthly behavior.
- Do not extend a test indefinitely fishing for significance — that inflates false positive rate (p-hacking). Set the end date before you start.

Recommended minimum: **2 weeks or sample size reached, whichever comes later.**

## Ship / Kill Decision Rule

Define the decision rule before the test starts, not after seeing results.

Default rule:
- **Ship** if: p < 0.05, MDE achieved or exceeded, minimum run window passed, no data quality issues (SRM check passed — see below).
- **Kill** if: p > 0.05 after full run. Do not ship a "directionally positive" result. A non-significant result is not a near-win; it is a non-result.
- **Extend** only if: the test was underpowered due to a traffic drop and you can document the cause. Not because you want a different answer.

**Sample Ratio Mismatch (SRM) check:** Verify that the actual split matches the intended split (e.g., 50/50 should be within ±2% in practice). A significant SRM (more than 5% off) means the randomization is broken and results are invalid. Check before reading conversion numbers.

## Execution Tools

- **Statsig** (statsig.com) — strong for product teams, built-in power analysis, SRM detection, Bayesian and frequentist modes.
- **PostHog** (posthog.com) — open source, good for onboarding flow tests where you need event-level tracking alongside the experiment.
- **Google Optimize** — deprecated. Do not use.

For landing pages without engineering resources: VWO or Optimizely handle client-side splits, but client-side flicker is a UX risk on above-the-fold elements.

## Test Prioritization Framework

When you have more test ideas than traffic, rank them by:

**ICE score:** Impact × Confidence × Ease, each 1–10.

- Impact: how large is the potential lift if the hypothesis is correct?
- Confidence: how strong is the evidence (user research, heatmaps, session recordings) that this is a real problem?
- Ease: how much engineering effort does the variant require?

Run the highest ICE score first. Do not run easy tests that have no evidence behind them just because they are easy.

## One-Page Test Brief Template

```
Test name: [descriptive slug]
Page / flow step: [URL or funnel step]
Primary metric: [single conversion event]
Secondary metrics: [2-3 guardrail metrics — things you don't want to degrade]
Hypothesis: If we change [X] to [Y], metric [Z] will move because [M].
Baseline rate: [X%] (measured: [date range])
MDE: [X% relative lift]
Required sample: [N per variant] — calculator link
Traffic estimate: [N/day] → estimated run time: [N days]
Start date: [date]
End date (hard): [date]
Decision rule: Ship if p < 0.05 + MDE met + SRM pass + min 2 weeks elapsed.
Owner: [name]
```

Fill this out before any implementation begins. If any field is unknown, find out before starting — not after.
