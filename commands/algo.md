---
description: Alias for /algorithm-recall — quick lookup do TheAlgorithms 6-lang knihovny + 5 OneFlow recipes (DD financial, ARES fuzzy, contact dedup, Bayesian risk, scraping graph)
---

# /algo — TheAlgorithms quick access

Alias k `/algorithm-recall` skill. Použij pro:

- **Algoritmus lookup**: `/algo dijkstra` → search napříč Python/JS/TS/Rust/Go/Solidity
- **Use case mapper**: `/algo "spočítat NPV pro emitenta"` → recipe + cesta + chain advice
- **Recipe call**: `/algo dd-financial --screen` → spustí DSCR/LTV/NPV combo
- **Cite-and-fork**: `/algo extract Python/strings/levenshtein_distance.py` → čistý snippet s MIT header

## Quick CLI shortcuts

```bash
# Search
~/.claude/skills/algorithm-recall/search.sh "<pattern>" [Python|JavaScript|TypeScript|Rust|Go|Solidity]

# Use case mapper
~/.claude/skills/algorithm-recall/find-for.sh "<use case in CZ/EN>"

# Cite-and-fork (strip test scaffolding)
~/.claude/skills/algorithm-recall/extract.sh <path-from-mirror-root>

# Recipes (5 ready-to-use OneFlow scripts)
python3 ~/.claude/skills/algorithm-recall/recipes/dd-financial.py --help
python3 ~/.claude/skills/algorithm-recall/recipes/ares-fuzzy.py "name1" "name2"
python3 ~/.claude/skills/algorithm-recall/recipes/contact-dedup.py --input leads.csv --fuzzy
python3 ~/.claude/skills/algorithm-recall/recipes/dd-bayesian-risk.py --metrics dscr=1.32 ltv_pct=68
python3 ~/.claude/skills/algorithm-recall/recipes/scraping-graph.py --crawl --start URL

# Maintenance
~/.claude/skills/algorithm-recall/update.sh        # weekly upstream pull (auto Sunday 04:00)
python3 ~/.claude/skills/algorithm-recall/recipes/tests.py       # run test suite
python3 ~/.claude/skills/algorithm-recall/recipes/benchmark.py   # perf measurements
```

## Top 5 use cases

1. **DD emitent screen** → `recipes/dd-financial.py --screen --json metrics.json`
2. **ARES fuzzy match** → `recipes/ares-fuzzy.py "ABC s.r.o." "A.B.C., spol. s r.o."`
3. **Outreach dedup** → `recipes/contact-dedup.py --input leads.csv --fuzzy`
4. **Bayesian risk** → `recipes/dd-bayesian-risk.py --metrics dscr=1.32 ltv_pct=68 --sector real_estate`
5. **Link traversal** → `recipes/scraping-graph.py --crawl --start URL --max-depth 3`

Full docs: `~/.claude/skills/algorithm-recall/SKILL.md` + `recipes/README.md` + `FILIP-INDEX.md` (top 30 use cases).
