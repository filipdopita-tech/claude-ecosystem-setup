---
name: mythos-narrator
description: Use when turning a project, feature, or product update into a narrative artifact. Produces three length-calibrated story versions from raw facts using a 4-act structure. Triggers on "narrate launch", "founder update", "internal memo", "story for X", "what's the story of this feature", "write a launch post".
allowed-tools: [Read, Write, Bash]
last-updated: 2026-04-27
version: 1.0.0
---

# Mythos Narrator

Turn raw facts — a feature shipped, a milestone hit, a product launched — into narrative artifacts ready for X/IG, email/blog, or a sales deck. Output is three versions of the same story at three lengths.

## Step 1 — Extract the facts

Pull from whatever the user provides (PRD, changelog, Slack message, bullet list, codebase diff). Produce a fact inventory:

```
WHAT shipped / happened (concrete nouns, no adjectives yet)
WHO is affected (specific user segment, not "users")
NUMBERS available (latency drop, user count, time saved, revenue, %)
BEFORE state (what was true yesterday)
AFTER state (what is true today)
TEAM / individual behind it (name the people if relevant)
```

If numbers are absent, flag: "No metric found — add one before publishing."

## Step 2 — Map the 4-act structure

Apply this frame to the fact inventory. Write one sentence per act before drafting prose:

| Act | Question | Anti-pattern to avoid |
|-----|----------|-----------------------|
| **Stakes** | Why does this matter to the reader's life? | "We're excited to announce…" |
| **Conflict** | What was genuinely hard or broken? | "Our team worked hard to…" |
| **Resolution** | What specific thing was built/decided/shipped? | Vague: "a new approach" |
| **Implication** | What can the reader do or feel now that they couldn't before? | Future tense hand-waving |

Stakes must be about the reader, not the company. Conflict must name the actual obstacle (technical, market, human), not effort. Resolution must name the artifact. Implication must be concrete.

## Step 3 — Draft three versions

### Short — 300 words (X / Instagram caption / Slack announcement)

- Hook in first 8 words (no "We're excited", no "Introducing")
- Stakes sentence (why the reader should care)
- Conflict in one sentence (what was broken)
- Resolution in two sentences (what shipped, one concrete detail)
- Implication as a call to action or invitation
- Close with a number or named fact

### Medium — 700 words (blog post / email / founder update)

- Lead paragraph: Stakes + hook (no preamble)
- Section 1 — Conflict: what the problem actually was, with one specific anecdote or data point
- Section 2 — Resolution: what was built, how it works at one level below the surface (not a tech deep-dive, but not a press release either)
- Section 3 — Implication: who can now do what, with a forward-looking sentence grounded in the product roadmap
- Close: one sentence that sounds like something a founder would say out loud

### Long — 1500 words (sales deck narrative / investor update / press pitch)

Expand the medium version with:
- A named customer or persona experiencing the Stakes (real or composite)
- A "before" scene: a paragraph narrating life without this
- The decision that triggered the Conflict (why this problem, why now)
- An "after" scene: the same persona, post-Resolution
- One quote-ready sentence per act (pull-quote formatted)
- A market/trend framing for the Implication (1 paragraph, no more)

## Step 4 — Quality checklist

Run each version through before delivering:

**Buzzword scan** — flag and rewrite any of:
`synergy`, `leverage` (verb), `robust`, `holistic`, `seamless`, `world-class`, `next-generation`, `cutting-edge`, `innovative`, `disruptive`, `ecosystem`, `empower`, `solution`

**Narrative test** — read the short version aloud. If it would not work as a 60-second spoken story, it fails. Rewrite until it passes.

**Specificity test** — every claim must have either a number or a named thing:
- BAD: "users save significant time"
- GOOD: "users cut their review cycle from 4 days to 40 minutes"

**Stakes test** — does the first sentence mention the reader's problem, not the company's product? If no, rewrite the opening.

## Output format

1. **Fact inventory** (bullet list, labeled as above)
2. **4-act map** (one sentence per act)
3. **SHORT** (labeled, word count shown)
4. **MEDIUM** (labeled, word count shown)
5. **LONG** (labeled, word count shown)
6. **Quality checklist results** (pass / flag per test, with flagged phrases quoted)
