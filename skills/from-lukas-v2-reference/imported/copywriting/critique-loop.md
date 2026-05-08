---
title: Self-Critique Reflection Loop (CoVe Pattern)
version: 1.0.0
applies-to: paid-ads, landing-page-copy, high-stakes-copy
trigger: CPC > 10 Kč OR budget > 500 Kč/den OR launch copy
---

# Critique Loop — Chain-of-Verification (CoVe) for Ad Copy

> Expected quality uplift: 20–30% via structured self-critique before final output.
> Based on Chain-of-Verification (CoVe) pattern — generate → verify → refine → validate.

## When to Run This Loop

Run critique-loop when ANY of these are true:
- Paid ad copy where CPC > 10 Kč
- Daily budget > 500 Kč/den
- Launch copy (product launch, new offer, campaign kickoff)
- Client-facing copy where revisions are expensive
- Copy flagged as "weak" by quick quality check in main copywriting skill

Skip for: internal docs, organic social posts, email drafts (use standard flow instead).

---

## Stage 1 — Draft: Generate 3 Variants

Use the standard copywriting pipeline to produce **3 distinct variants**.
Each variant must use a different primary angle:

| Variant | Angle Strategy |
|---------|---------------|
| A | **Dream Outcome** — lead with the transformation, not the product |
| B | **Pain Agitate** — open with the problem, amplify urgency, then solve |
| C | **Social Proof / Number** — open with a specific result or stat |

**Output per variant:**
- Hook (1–2 sentences, the "scroll-stopper")
- Body (2–4 sentences, the value build)
- CTA (1 clear action)
- Platform target (Meta / TikTok / Google)

Label them clearly: `[VARIANT A]`, `[VARIANT B]`, `[VARIANT C]`

---

## Stage 2 — Critic: Evaluate Each Variant

Spawn a Sonnet critic sub-agent (or run as second pass in same session).
The critic evaluates each variant against the **Hormozi Critic Checklist** in `critic-checklist.md`.

**Critic must score each variant on 5 dimensions (1–5 scale):**

| Dimension | What to check |
|-----------|--------------|
| **Hormozi Value Equation** | Does it raise Dream Outcome AND lower Time/Effort? |
| **CZ/SK Linguistic Quality** | Natural Czech/Slovak? No anglicismy? Correct grammar? |
| **Concrete Numbers** | At least 1 specific number (not "rychle", but "za 48 hodin") |
| **Hook Strength** | Would it stop scroll? Specific + emotion + curiosity = strong |
| **CTA Clarity** | One action, zero ambiguity, outcome-oriented verb |

**Critic output format:**
```
VARIANT [X] SCORES:
- Value Equation: [1-5] — [one-line reason]
- CZ/SK Quality:  [1-5] — [one-line reason]
- Numbers:        [1-5] — [one-line reason]
- Hook Strength:  [1-5] — [one-line reason]
- CTA Clarity:    [1-5] — [one-line reason]
TOTAL: [sum/25]
TOP 3 ISSUES: [bullet list]
```

**Tiebreaker:** If two variants score equal, pick the one with the stronger hook (hook score wins).

---

## Stage 3 — Refine: Apply Top 3 Fixes to Winner

Take the highest-scoring variant. Apply the critic's top 3 issues as targeted fixes.

**Rules for refinement:**
1. Fix ONLY what the critic flagged — do not rewrite from scratch
2. Every fix must be traceable: show old line → new line
3. If adding a number: use real data from brand profile OR a plausible benchmark clearly labeled as estimate
4. Do not weaken the hook while fixing body copy (most common mistake)
5. CZ/SK: prefer "Získejte" over "Get", "Zjistěte" over "Find out" — stay in native register

**Refine output format:**
```
WINNER: Variant [X] (score: [N]/25)

FIX 1 — [Issue name]:
  Before: "[original line]"
  After:  "[improved line]"
  Why:    [one sentence rationale]

FIX 2 — [Issue name]:
  Before: "[original line]"
  After:  "[improved line]"
  Why:    [one sentence rationale]

FIX 3 — [Issue name]:
  Before: "[original line]"
  After:  "[improved line]"
  Why:    [one sentence rationale]

REFINED COPY (full):
[Hook]
[Body]
[CTA]
```

---

## Stage 4 — Final Validate: Boolean Gate

Binary check — did the refinement fix issues without breaking the message?

Run through this 5-question gate. ALL must pass (YES) to ship:

1. **Hook intact?** Is the scroll-stopping power preserved or improved? `YES / NO`
2. **Number present?** At least one concrete number in body or hook? `YES / NO`
3. **CTA singular?** Exactly one action asked of the reader? `YES / NO`
4. **CZ/SK natural?** Would a native speaker write this? (no translated feel) `YES / NO`
5. **Value Equation positive?** Reader gains > effort required to click? `YES / NO`

If any answer is NO → go back to Stage 3 and fix that specific element only.
Do not regenerate from scratch — targeted fix only.

**If all YES:** ship the refined copy.

---

## Final Output Structure

Deliver to the user in this format:

```
## FINAL AD COPY

[Platform]: [Meta Feed / TikTok / Google Search / etc.]
[Objective]: [Leads / Sales / Awareness]

---
HOOK:
[hook text]

BODY:
[body text]

CTA:
[cta text]
---

## CRITIQUE SUMMARY

Variants tested: 3 (A: Dream Outcome | B: Pain Agitate | C: Social Proof)
Winner: Variant [X] — [total score]/25
Fixes applied: [3 bullet list of what changed]

## IMPROVEMENT DELTA

| Dimension | Before (Variant [X] raw) | After (Refined) |
|-----------|--------------------------|-----------------|
| Value Equation | [score] | [score] |
| CZ/SK Quality | [score] | [score] |
| Numbers | [score] | [score] |
| Hook Strength | [score] | [score] |
| CTA Clarity | [score] | [score] |
| **TOTAL** | **[N]/25** | **[N]/25** |

Estimated quality uplift: +[N]% (based on score delta)
```

---

## Token Budget Guide

| Stage | Model | Est. tokens |
|-------|-------|-------------|
| Stage 1: Draft 3 variants | Sonnet 4.6 | ~800 |
| Stage 2: Critic evaluation | Sonnet 4.6 | ~600 |
| Stage 3: Refine winner | Sonnet 4.6 | ~400 |
| Stage 4: Validate gate | Haiku 4.5 | ~100 |
| **Total** | | **~1,900** |

Total cost: ~$0.006 per critique loop run at Sonnet 4.6 pricing. ROI: measurable on first A/B test.

---

## Related Files

- `critic-checklist.md` — 15 Hormozi-style validation questions for Stage 2
- `SKILL.md` — main copywriting skill (run first to produce raw drafts)
- `references/copy-frameworks.md` — headline formulas and page templates
