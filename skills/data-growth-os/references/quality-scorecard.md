# Data Growth OS Quality Scorecard

Score every serious run before calling it done.

## Rubric

| Dimension | Max | Criteria |
|---|---:|---|
| Source fit | 20 | Sources directly match ICP/problem and are not just convenient. |
| Compliance and safety | 20 | Hard stops respected, cost gates explicit, provenance present. |
| Raw evidence | 15 | Raw files/screenshots/API responses saved and traceable. |
| Clean schema | 15 | Output follows `output-schemas.md` and includes dedupe/provenance fields. |
| Verification | 15 | Sample checked against source URLs; row counts and gaps stated. |
| Actionability | 15 | Clear next action: enrich, score, outreach draft, build scraper, or stop. |

## Verdicts

- `90-100`: Production-grade data run.
- `75-89`: Usable with stated gaps.
- `60-74`: Pilot only; do not use for decisions without another pass.
- `<60`: Re-run or redesign source strategy.

## Mandatory Failure Conditions

Any of these caps score at 59:

- No raw evidence.
- Missing source URLs.
- No verification sample.
- Personal social cookies/session automation.
- Paid provider used without cost note.
- Outreach sent or ad changed during data collection.

## Review Template

```markdown
## Quality Scorecard

| Dimension | Score | Evidence |
|---|---:|---|
| Source fit | /20 | |
| Compliance and safety | /20 | |
| Raw evidence | /15 | |
| Clean schema | /15 | |
| Verification | /15 | |
| Actionability | /15 | |

Total: /100
Verdict:
Required fixes:
```
