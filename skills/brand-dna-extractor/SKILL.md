---
name: brand-dna-extractor
description: Use when reverse-engineering brand voice from existing content artifacts into a reusable BRAND_VOICE.md profile. Output is consumed by ig-content-creator, mythos-narrator, and content-batch. Triggers on "extract brand voice", "brand DNA", "voice profile", "tone of voice analysis", "what's our voice", "analyze our copy".
allowed-tools: [Read, Write, Bash]
last-updated: 2026-04-27
version: 1.0.0
---

# Brand DNA Extractor

Reverse-engineer a brand's voice from 10–20 existing artifacts (website copy, IG captions, emails, transcripts, ad copy) into a structured BRAND_VOICE.md. The output file is consumed by other skills — it is not a mood board, it is a rule set.

## Step 1 — Collect samples

Ask the user to paste or point to samples. Minimum 10, ideally 20. Acceptable sources:

- Website homepage + 2–3 product/service pages
- 5–10 IG captions (mix of high-engagement and typical posts)
- 2–3 email subject lines + body excerpts
- Any ad copy, pitch deck slides, or founder transcripts

For each sample, note the **format** (caption, headline, email, etc.) — voice varies by format and the extractor must account for it.

If the user has fewer than 10 samples: proceed with what exists but flag "Low sample count — patterns may not generalize. Validate before using in production."

## Step 2 — Run analytic dimensions

For each dimension, produce a 1–3 sentence rule, not a vague description:

| Dimension | What to capture |
|-----------|----------------|
| **Vocabulary tier** | Academic / casual / street / technical? Which specific words recur? Which register is absent? |
| **Sentence rhythm** | Avg sentence length? Short punchy bursts, or flowing complex clauses? Mixed? |
| **Imagery type** | Abstract ("freedom") vs concrete ("Tuesday morning, coffee still hot")? Metaphor-heavy or literal? |
| **POV default** | First person singular, plural "we", second person "you", or impersonal? |
| **Taboo phrases** | Words or constructions that appear never in the samples and would sound wrong. Min 5. |
| **Signature constructs** | Repeated structural moves (e.g., "Not X. Y.", em-dash asides, rhetorical questions, numbered lists in prose). |
| **Hook archetypes** | What patterns open posts/emails? (Provocative statement? Scenario? Statistic? Direct address?) |
| **Emoji policy** | None / sparse (1–2 per post) / decorative / semantic (replaces words) / heavy |
| **Taboo topics** | Subjects that are conspicuously absent (competitors, price, negativity about the category) |
| **Energy register** | Calm authority / urgent hustle / warm friend / detached expert / playful challenger |

## Step 3 — Produce 3 translation examples

Take a piece of generic copy and rewrite it three times — once badly (generic brand), once correctly (this brand's voice), and label why:

**Template to fill in:**

```
GENERIC INPUT:
"We help businesses grow with our powerful marketing software."

BAD (sounds like every SaaS):
"Supercharge your marketing with our robust, all-in-one platform."

GOOD ([Brand Name] voice):
"[rewrite using brand's actual vocabulary, rhythm, POV, signature constructs]"

WHY: [2–3 specific rules from Step 2 that this translation applies]
```

Produce 3 translation examples covering different formats (e.g., headline, caption, email opener).

## Step 4 — Write BRAND_VOICE.md

Default path: `docs/BRAND_VOICE.md` in the current project. If no project directory is detected, write to the current working directory.

Respect the env var `BRAND_VOICE_FILE` if set:
```bash
echo ${BRAND_VOICE_FILE:-docs/BRAND_VOICE.md}
```

File structure:

```markdown
# Brand Voice — [Brand Name]
_Generated: [date]. Re-run brand-dna-extractor when sample set grows past 40 pieces._

## Energy register
[one sentence]

## Vocabulary
- **Use:** [5–10 words/phrases that recur]
- **Never use:** [taboo phrases, min 5]
- **Register:** [casual/formal/etc + specific note]

## Sentence rhythm
[rule + example sentence from samples]

## Imagery
[rule + example phrase from samples]

## POV
[rule + when exceptions are allowed]

## Hook archetypes
1. [pattern] — example: "[quote from samples]"
2. [pattern] — example: "[quote from samples]"
3. [pattern] — example: "[quote from samples]"

## Emoji policy
[rule]

## Taboo topics
[list]

## Translation examples
### Example 1 — [format]
**Generic:** [text]
**Brand voice:** [text]
**Why:** [rules applied]

### Example 2 — [format]
...

### Example 3 — [format]
...

## Integration
- **ig-content-creator:** set `BRAND_VOICE_FILE=docs/BRAND_VOICE.md` before running
- **mythos-narrator:** reference this file in the prompt: "Apply voice rules from docs/BRAND_VOICE.md"
- **content-batch:** pass `--voice-file docs/BRAND_VOICE.md` or set the env var
```

## Step 5 — Deliver the integration note

After writing the file, output:

```
BRAND_VOICE.md written to: [path]

To wire this into other skills:
  export BRAND_VOICE_FILE=[path]

ig-content-creator: reads BRAND_VOICE_FILE automatically if set.
mythos-narrator: append "Apply voice rules from [path]" to your prompt.
content-batch: set BRAND_VOICE_FILE before invoking.
```

## Output format

1. **Sample inventory** (count by format type)
2. **Dimension analysis** (table: dimension → rule, with 1 example each)
3. **Quality flag** if sample count < 10
4. **Translation examples** (3, as specified)
5. **BRAND_VOICE.md written** (confirm path + line count)
6. **Integration note**
