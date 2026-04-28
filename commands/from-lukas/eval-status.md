# /eval-status

Quick visual check of all skill scores vs baselines.

Reads `evals/runs/*.json` and `evals/baselines/*.json`, displays dashboard table with:
- Last score per skill
- Baseline score
- Trend (up/down/stable)
- Regressions and pending fixes highlighted

## Usage

```
/eval-status              # Terminal table
/eval-status --json       # JSON output for parsing
/eval-status --html       # Generate evals-dashboard.html
```

## Allowed Tools

- Bash (runs scripts/eval-dashboard.sh)
- Read (queries evals/runs/ and evals/baselines/)

## Examples

Check all skills:
```
/eval-status
```

Export for CI/CD:
```
/eval-status --json | jq '.dashboard.skills[] | select(.pending_fix == true)'
```

Generate HTML report:
```
/eval-status --html && open evals-dashboard.html
```

## Implementation

Invokes `scripts/eval-dashboard.sh`, which reads all baseline and run JSON files, calculates deltas, and renders dashboard in requested format.

Regressions (delta < -0.5) printed to stderr. Pending fixes flagged in warning output.
