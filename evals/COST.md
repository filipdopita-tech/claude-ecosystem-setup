# Eval Cost Analysis

Understanding the cost profile helps you run evals without hesitation — cheap judges mean you can measure every meaningful change.

---

## Per-Run Cost Estimate

### Components per test case
1. **Target invocation** — calling `claude -p` to get the skill's output
2. **Judge invocation** — calling Haiku to score the output

### Haiku pricing (as of 2026)
- Input: ~$0.80 / 1M tokens
- Output: ~$4.00 / 1M tokens

### Typical token counts per case
| Component | Input tokens | Output tokens |
|-----------|-------------|---------------|
| Target invocation (skill + brief) | ~800 | ~400 |
| Judge invocation (judge prompt + case + output) | ~1,200 | ~200 |
| **Per case total** | **~2,000** | **~600** |

### Cost per case (both invocations, Haiku judge)
- Input: 2,000 × $0.80 / 1M = **$0.0016**
- Output: 600 × $4.00 / 1M = **$0.0024**
- **Total per case: ~$0.004 ($0.40 per 100 cases)**

---

## Dataset Cost Estimates

| Dataset | Cases | Estimated cost |
|---------|-------|---------------|
| copywriting.jsonl | 10 | $0.04 |
| storyboard.jsonl | 10 | $0.04 |
| security-redteam.jsonl | 8 | $0.03 |
| lean-refactor.jsonl | 8 | $0.03 |
| prompt-decompose.jsonl | 8 | $0.03 |
| **Full suite (44 cases)** | **44** | **~$0.17** |

Security and copywriting cases run slightly longer (more output tokens from target). Realistic full-suite cost: **$0.20–$0.40**.

---

## Scenario Costs

| Scenario | Cases | Estimated cost |
|----------|-------|---------------|
| Single skill, single dataset | 8–10 | $0.03–$0.05 |
| Full suite (all datasets) | 44 | $0.20–$0.40 |
| Full suite, Sonnet judge (higher quality) | 44 | $1.50–$3.00 |
| 50-case custom dataset, Haiku judge | 50 | $0.20–$0.50 |
| 50-case custom dataset, Sonnet judge | 50 | $1.20–$2.50 |

**Haiku is the right default judge.** The calibration anchors in `runner/judge-prompt.md` are designed to compensate for Haiku's tendency to inflate. Only use Sonnet judge for final validation of a major rewrite.

---

## Recommended Cadence

### Per meaningful skill change
Run the eval for the affected skill immediately after any change to its system prompt, examples, or tool list. Cost: $0.03–$0.05. This is the core use case — cheap enough to be habitual.

**What counts as meaningful:**
- Adding or removing a section from the system prompt
- Changing tone, persona, or output format instructions
- Adding or removing tools
- Adding few-shot examples

**What does not need an eval:**
- Fixing a typo
- Updating a comment
- Changing the model field without changing the prompt

### Weekly full suite
Run all datasets once per week to catch drift across the board. Cost: ~$0.25. This catches: model version changes, prompt interactions, or cases where one skill change broke another unexpectedly.

### After a Claude Code update
When a new Claude version is deployed to this workspace (settings.json model change), run the full suite and review diffs. This is the highest-risk moment for unexplained score changes.

---

## Cost Guardrails

To avoid accidentally burning money:
- Use `--dry-run` flag to verify dataset parsing before a real run
- The runner always uses Haiku as default judge — do not change the default to Sonnet for routine runs
- Each run file is saved so you never need to re-run just to see past results
- The `--threshold` default of 1.0 is intentionally loose — don't tighten it below 0.5 or you'll get false regression alerts that waste re-run costs

---

## Token Burn Profile (Empirical Estimates)

Based on test runs across similar prompts:

| Skill | Avg output tokens per case | Notes |
|-------|---------------------------|-------|
| copy-strategist | 500–800 | 3 variants = ~600 tokens |
| video-director | 600–900 | 6-scene storyboard = ~700 tokens |
| security-auditor | 700–1,100 | Vuln lists are verbose |
| lean-refactor | 400–600 | List format, concise |
| prompt-decompose | 300–500 | Structured list output |

High-output skills (security, storyboard) cost ~2x the minimum estimate. Budget $0.50 for a full suite run to be safe.
