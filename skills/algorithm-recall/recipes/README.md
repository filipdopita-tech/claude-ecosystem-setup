# Recipes — Quick Reference

5 production-ready Python skripty postavené nad TheAlgorithms (MIT) + OneFlow-specific layer. Žádná externí dependency mimo Python stdlib.

## TL;DR

| Recipe | Hot use case | One-liner |
|---|---|---|
| **dd-financial.py** | DSCR/LTV/NPV/IRR/EMI emitent screen | `python3 dd-financial.py --screen --json metrics.json` |
| **ares-fuzzy.py** | CZ company name match (s.r.o. normalize) | `python3 ares-fuzzy.py "ABC s.r.o." "A.B.C., spol. s r.o."` |
| **contact-dedup.py** | Outreach contact dedup + typo detection | `python3 contact-dedup.py --input leads.csv --fuzzy --out unique.csv` |
| **dd-bayesian-risk.py** | A-F grade + default probability + MC | `python3 dd-bayesian-risk.py --metrics dscr=1.32 ltv_pct=68 --sector real_estate` |
| **scraping-graph.py** | Link/network BFS/DFS/cycles | `python3 scraping-graph.py --crawl --start URL --max-depth 3` |

## Detailed examples

### `dd-financial.py` — Investment metrics

```bash
# Quick DSCR check
python3 dd-financial.py --dscr --noi 1500000 --debt-service 800000
# → {"dscr": 1.875, "category": "healthy", "ok": true}

# LTV
python3 dd-financial.py --ltv --loan 5000000 --value 8000000
# → {"ltv_pct": 62.5, "category": "standard"}

# NPV
python3 dd-financial.py --npv --discount 0.08 --cashflows -1000000 250000 250000 250000 250000 250000
# → {"npv": -1822.49}  (negative = discount > yield, pass)

# IRR (Newton-Raphson)
python3 dd-financial.py --irr --cashflows -1000000 250000 250000 250000 250000 250000
# → {"irr_pct": 7.93}

# Amortization schedule (loan 5M @ 6% / 60 months)
python3 dd-financial.py --amortization --principal 5000000 --rate 0.06 --months 60

# Compound interest
python3 dd-financial.py --interest --type compound --p 100000 --r 0.05 --t 5 --n 12

# Full quick-screen (combo DSCR + LTV + NPV → A-F grade)
python3 dd-financial.py --screen --json examples/emitent.json
```

### `ares-fuzzy.py` — Company name matching

```bash
# Single pair
python3 ares-fuzzy.py "Petr Novák Holding a.s." "Petr Novak Holdings AS"
# → {"confidence": 0.94, "action": "DEDUP"}

# Batch dedup (CSV)
python3 ares-fuzzy.py --batch fixtures/sample-companies.csv --col name --threshold 0.92 --out dedup.csv

# Skip CZ normalization (raw mode)
python3 ares-fuzzy.py "name1" "name2" --no-normalize
```

**Thresholds:**
- ≥0.92 → DEDUP (auto-merge)
- 0.78-0.92 → REVIEW (human eyeball)
- <0.78 → UNIQUE

### `contact-dedup.py` — Email deduplication

```bash
# Exact dedup (SHA-256 + Bloom O(1))
python3 contact-dedup.py --input fixtures/sample-leads.csv --email-col email --out unique.csv

# Fuzzy mode — also catches typos (jna@x.cz vs jan@x.cz)
python3 contact-dedup.py --input fixtures/sample-leads.csv --fuzzy --out unique.csv

# Just hash (no dedup) — for ID-based tracking
python3 contact-dedup.py --input fixtures/sample-leads.csv --hash-only

# Full report
python3 contact-dedup.py --input fixtures/sample-leads.csv --report
```

**Gmail aliases handled:** `john.doe+work@gmail.com` → `johndoe@gmail.com` (canonical).

### `dd-bayesian-risk.py` — Statistical risk grading

```bash
# Naive Bayes A-F classifier
python3 dd-bayesian-risk.py --metrics dscr=1.32 ltv_pct=68 revenue_growth=0.15 --sector real_estate
# → {"grade": "C", "default_probability": 0.0, "recommendation": "WATCH"}

# Available sectors: real_estate, manufacturing, fintech, energy, retail, agriculture, tech_services

# Monte Carlo DSCR confidence intervals (10k simulations)
python3 dd-bayesian-risk.py --monte-carlo --noi-mean 1500000 --noi-std 200000 --debt-service 1000000
# → {"p5": 1.173, "probability_default": 0.006, "interpretation": "..."}
```

**Tuning:** parametry sektorů a grade thresholds jsou v `risk_config.json` (override default in-script values).

### `scraping-graph.py` — Network traversal

```bash
# Demo run (built-in graph)
python3 scraping-graph.py
# → BFS summary + cycle detection + connected components

# Live crawl (polite, 0.5s delay, same-host only, 2MB cap per page)
python3 scraping-graph.py --crawl --start https://oneflow.cz --max-depth 3 --max-pages 50 --out graph.json

# Just BFS on existing graph
python3 scraping-graph.py --bfs --edges-file graph.json --start https://oneflow.cz --max-depth 2

# Cycle detection (avoid scraping infinite loops)
python3 scraping-graph.py --cycle-detect --edges-file graph.json

# Connected components
python3 scraping-graph.py --components --edges-file graph.json
```

## Chains (auto-fired by Claude routers)

```
dd-emitent skill → dd-financial.py + dd-bayesian-risk.py (auto-attach to report)
dd-batch-sql → ares-fuzzy.py --batch + dd-bayesian-risk.py per row
cold-outreach-v3 → contact-dedup.py --fuzzy (PRE-SEND gate)
lead-ops → contact-dedup.py (Bloom O(1) at scale)
competitor-intel → scraping-graph.py --crawl
```

## Testing & benchmarking

```bash
# Run test suite (asserts on all 5 recipes)
python3 tests.py

# Benchmark performance
python3 benchmark.py
```

## Citation requirement

Když adaptujete substantial code, vždy citujte:

```python
# Adapted from TheAlgorithms/Python (MIT License)
# Source: https://github.com/TheAlgorithms/Python/
```

## Files

```
recipes/
├── README.md                    # tento dokument
├── dd-financial.py              # DSCR/LTV/NPV/IRR
├── ares-fuzzy.py                # CZ company name match
├── contact-dedup.py             # SHA-256 + Bloom + typo
├── dd-bayesian-risk.py          # Naive Bayes + MC
├── scraping-graph.py            # BFS/DFS/cycles/components
├── tests.py                     # pytest-style assertions
├── benchmark.py                 # perf measurements
├── risk_config.json             # tunable Bayesian params
└── fixtures/
    ├── sample-leads.csv         # 20 outreach contacts (with dups)
    ├── sample-companies.csv     # 15 CZ companies (with variants)
    └── sample-emitent.json      # full DD screen example
```
