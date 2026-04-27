# Skill Variant Template — How to Structure a Fair A/B Test

A well-designed variant isolates exactly one change so that any observed difference in scores can
be attributed to that change. This document explains the rules, the rationale, and the anti-patterns
to avoid.

---

## The Core Rule

Change exactly one dimension at a time.

A "dimension" is a coherent category of prompt behavior:
- Instruction content (what you tell the model to do)
- Constraint (what you forbid)
- Persona/tone (how the model presents itself)
- Output format (structure, length, ordering)
- Reasoning style (chain-of-thought, step-by-step, direct)

If you change two dimensions at once and the variant wins, you do not know which change was
responsible. You cannot roll back selectively. You have learned less than you think.

---

## What Is Fair to Change

**Valid single-dimension changes:**

1. Add one instruction rule
   - "Always cite the psychological lever you are using (e.g., scarcity, social proof, authority)."
   - Control: no such rule. Variant: adds it at the end of the instruction list.

2. Remove one constraint
   - Remove: "Output must include a minimum of 3 copy variants."
   - Control: has the minimum-3 rule. Variant: removes it entirely.

3. Change one persona attribute
   - "You are a conversion-focused copywriter" -> "You are a direct-response copywriter"
   - Only the persona descriptor changes; all other instructions stay identical.

4. Change one format rule
   - "Output as plain prose" -> "Output as a bulleted list with a one-line rationale per item"
   - Only the output format changes.

5. Change one threshold or numeric constraint
   - "Keep headlines under 12 words" -> "Keep headlines under 8 words"
   - Numeric tightening of one existing rule.

---

## What Is NOT Fair to Change

**Anti-patterns:**

1. Changing multiple dimensions at once
   - Do not add a new instruction AND change the persona AND remove a constraint in one variant.
   - If you want to test a "v2 rewrite" that touches everything, that is a product decision, not
     a controlled experiment. Ship it via judgment, not via this framework.

2. Changing the dataset between arms
   - Control and variant must run on exactly the same cases in the same order.
   - Swapping in "easier" or "harder" cases for one arm invalidates the comparison.

3. Changing the judge model between arms
   - If control uses haiku and variant uses sonnet, the score difference reflects judge behavior,
     not skill quality.

4. Changing the eval rubric between arms
   - The rubric defines what "good" means. Changing it changes the definition of winning.
   - Fix rubric problems in a separate commit before running the experiment.

5. Testing a variant on a dataset that was used to write the variant
   - If you read the eval outputs, noticed failures, and edited the prompt to fix those specific
     cases, the variant will overfit to the dataset. Use a held-out set or a fresh sample.

---

## How to Write the Variant Section

When editing a skill file for a variant, mark what you changed:

```markdown
<!-- VARIANT: added citation rule 2026-04-26 -->
When recommending a tactic, always name the psychological principle you are invoking
(e.g., "scarcity", "social proof", "authority", "loss aversion"). One phrase is sufficient.
<!-- END VARIANT -->
```

This comment is stripped before the prompt is sent to the model (or kept as context — your
choice), but it serves as a diff marker for reviewers and for git history.

---

## Template: Minimal Variant Diff

Below is the minimal structure for a variant file. Only the section marked VARIANT changes.

```
# [Skill Name] — VARIANT

[All original instructions verbatim]

---

## [Section being modified]

[Original content OR modified content — exactly one thing different]

<!-- VARIANT CHANGE: <one-line description of the change>
  Hypothesis: <what you expect to improve and at what cost>
  Date: <ISO date>
  Control ref: <git SHA>
-->
```

---

## Checklist Before Running

- [ ] I changed exactly one dimension
- [ ] The dataset is the same for both arms (handled automatically by run-experiment.sh)
- [ ] The judge model is the same for both arms (handled automatically)
- [ ] I have written down my hypothesis before looking at results
- [ ] I have chosen n >= 8 (preferably >= 16 for medium-effect detection)
- [ ] I am not testing a variant on cases I used to write the variant

---

## Hypothesis Format

State your hypothesis before running the experiment. A good hypothesis has three parts:

1. The change: "Adding the citation rule..."
2. The predicted outcome: "...will increase rubric-criterion 'lever-named' pass rate..."
3. The predicted cost: "...with no significant drop in overall score."

Example:
> "Adding an explicit 'cite the psychological lever' instruction will increase the pass rate on
> the 'lever-named' criterion from ~40% to ~80% with no more than a 0.5-point drop in overall
> mean score."

Writing this down before running protects you from post-hoc rationalization when the results
are ambiguous.
