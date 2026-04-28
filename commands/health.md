# /health -- Code Quality Dashboard

You are a Staff Engineer running a code quality dashboard. Run every available tool, score results, present a clear dashboard.

**HARD GATE:** Do NOT fix any issues. Dashboard and recommendations only.

## Step 1: Detect Health Stack

Auto-detect available tools in the current project:

```bash
echo "=== HEALTH STACK DETECTION ==="
[ -f tsconfig.json ] && echo "TYPECHECK: tsc --noEmit"
[ -f biome.json ] || [ -f biome.jsonc ] && echo "LINT: biome check ."
ls eslint.config.* .eslintrc.* .eslintrc 2>/dev/null | head -1 | xargs -I{} echo "LINT: eslint ."
[ -f pyproject.toml ] && grep -q "ruff\|pylint" pyproject.toml 2>/dev/null && echo "LINT: ruff check ."
[ -f package.json ] && grep -q '"test"' package.json 2>/dev/null && echo "TEST: npm test"
[ -f pyproject.toml ] && grep -q "pytest" pyproject.toml 2>/dev/null && echo "TEST: pytest"
[ -f Cargo.toml ] && echo "TEST: cargo test"
[ -f go.mod ] && echo "TEST: go test ./..."
command -v knip >/dev/null 2>&1 && echo "DEADCODE: knip"
[ -f package.json ] && grep -q '"knip"' package.json 2>/dev/null && echo "DEADCODE: npx knip"
command -v shellcheck >/dev/null 2>&1 && echo "SHELL: shellcheck"
```

## Step 2: Run Tools

Run each detected tool sequentially. For each:
1. Record start time
2. Run command, capture stdout+stderr (tail -50)
3. Record exit code and duration

## Step 3: Score Each Category (0-10)

| Category | Weight | 10 | 7 | 4 | 0 |
|-----------|--------|------|-----------|------------|-----------|
| Type check | 25% | Clean (exit 0) | <10 errors | <50 errors | >=50 errors |
| Lint | 20% | Clean (exit 0) | <5 warnings | <20 warnings | >=20 warnings |
| Tests | 30% | All pass (exit 0) | >95% pass | >80% pass | <=80% pass |
| Dead code | 15% | Clean (exit 0) | <5 unused | <20 unused | >=20 unused |
| Shell lint | 10% | Clean (exit 0) | <5 issues | >=5 issues | N/A |

Composite: weighted sum. If category skipped, redistribute weight.

## Step 4: Present Dashboard

```
CODE HEALTH DASHBOARD
=====================
Project: <name>    Branch: <branch>    Date: <today>

Category      Tool              Score   Status     Duration   Details
----------    ----------------  -----   --------   --------   -------
Type check    tsc --noEmit      10/10   CLEAN      3s         0 errors
Lint          biome check .      8/10   WARNING    2s         3 warnings
Tests         npm test          10/10   CLEAN      12s        47/47 passed

COMPOSITE SCORE: 9.1 / 10
```

Status labels: 10=CLEAN, 7-9=WARNING, 4-6=NEEDS WORK, 0-3=CRITICAL

For categories below 7, show top issues from tool output.

## Step 5: Recommendations

Prioritize by impact (weight * score deficit):

```
RECOMMENDATIONS (by impact)
1. [HIGH]  Fix 2 failing tests (Tests: 9/10, weight 30%)
2. [MED]   Address 12 lint warnings (Lint: 6/10, weight 20%)
3. [LOW]   Remove 4 unused exports (Dead code: 7/10, weight 15%)
```

## Rules
- Run the project's own tools. Never substitute your own analysis.
- Read-only. Never fix issues.
- Skipped is not failed. Don't penalize missing tools.
- Show raw output for failures (tail -50).
