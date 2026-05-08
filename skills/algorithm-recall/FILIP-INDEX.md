# FILIP-INDEX — TheAlgorithms Curated Top 30 Use Cases for OneFlow

> Žebříček algorithmů podle Filipova reálného workflow. Tier 1 = denně, Tier 2 = měsíčně, Tier 3 = občas/budoucí.
> Skip generic categorical lists — tady je jen co Filipovi reálně sype hodnotu.

## Quick reference (top 5 v hlavě)

| Use case | Recipe / source | One-liner |
|---|---|---|
| **DD financial calc** (DSCR/LTV/NPV/IRR) | `recipes/dd-financial.py` | `python3 recipes/dd-financial.py --screen --json metrics.json` |
| **ARES company name match** | `recipes/ares-fuzzy.py` | `python3 recipes/ares-fuzzy.py "ABC s.r.o." "A.B.C. s. r. o."` |
| **Outreach contact dedup** | `recipes/contact-dedup.py` | `python3 recipes/contact-dedup.py --input leads.csv --fuzzy` |
| **DD Bayesian risk + Monte Carlo** | `recipes/dd-bayesian-risk.py` | `python3 recipes/dd-bayesian-risk.py --metrics dscr=1.32 ltv_pct=68 --sector real_estate` |
| **Scraping link graph traversal** | `recipes/scraping-graph.py` | `python3 recipes/scraping-graph.py --crawl --start URL --max-depth 3` |

## TIER 1 — Denně/týdně použitelné (DD + outreach + scraping)

### 1. NPV / Present Value (emitent valuation)
- **Recipe:** `recipes/dd-financial.py --npv --discount 0.08 --cashflows -1000000 250000 ...`
- **Source:** `Python/financial/present_value.py`
- **Filip use:** Quick valuation emitenta cash flows pro DD report. Discount rate = OneFlow target IRR ~8-12%.
- **Chain:** dd-emitent → algorithm-recall (NPV) → investment-memo

### 2. DSCR Quick Screen (debt service coverage)
- **Recipe:** `recipes/dd-financial.py --dscr --noi 1500000 --debt-service 800000`
- **Source:** Custom (built on financial primitives)
- **Filip use:** Primary credit metric pro ECSP emitenti. >1.25 = healthy, <1.0 = pass. Auto-attached do DD reportu.
- **Chain:** dd-emitent → DSCR check → grade A/B/C/D/F

### 3. LTV Quick Screen (loan-to-value)
- **Recipe:** `recipes/dd-financial.py --ltv --loan 5000000 --value 8000000`
- **Source:** Custom (asset-backed metric)
- **Filip use:** Pro asset-backed dluhopisy. <60% = conservative, >80% = aggressive.

### 4. Levenshtein / Jaro-Winkler (ARES name match)
- **Recipe:** `recipes/ares-fuzzy.py "name1" "name2"` nebo `--batch input.csv`
- **Sources:** `Python/strings/{levenshtein,jaro_winkler,damerau_levenshtein}_distance.py`
- **Filip use:** ARES enrichment dedup — "ABC s.r.o." vs "A.B.C. s. r. o." vs "A.B.C." catch via weighted ensemble.
- **Chain:** ARES enrichment → ares-fuzzy → cold-outreach-v3

### 5. SHA-256 Email Hash + Bloom Filter (contact dedup)
- **Recipe:** `recipes/contact-dedup.py --input leads.csv --fuzzy`
- **Sources:** `Python/hashes/sha256.py` + `Python/data_structures/hashing/bloom_filter.py`
- **Filip use:** Pre-send dedup outreach kampaně. Detekuje exact dups + typo dups (jna@x.cz vs jan@x.cz).
- **Chain:** lead-ops → contact-dedup → cold-outreach-v3

### 6. Bayesian Risk Classifier (emitent grading)
- **Recipe:** `recipes/dd-bayesian-risk.py --metrics dscr=X ltv_pct=Y revenue_growth=Z --sector S`
- **Sources:** Custom Naive Bayes (TheAlgorithms gaussian_naive_bayes je broken) + sector adjustments
- **Filip use:** Statistical risk grade A-F + posterior distribution + default probability.
- **Chain:** dd-emitent → bayesian-risk → investment decision

### 7. Monte Carlo DSCR (confidence intervals)
- **Recipe:** `recipes/dd-bayesian-risk.py --monte-carlo --noi-mean 1500000 --noi-std 200000 --debt-service 1000000`
- **Sources:** `Python/maths/monte_carlo.py` (adapted)
- **Filip use:** Když je DSCR borderline — kvantifikuje "jaká pravděpodobnost defaultu v worst 5% scenarios?"

### 8. Amortization Schedule (loan splátkový kalendář)
- **Recipe:** `recipes/dd-financial.py --amortization --principal 5000000 --rate 0.06 --months 60`
- **Source:** `Python/financial/equated_monthly_installments.py`
- **Filip use:** Pro emitent prospekty s úvěrovou expozicí — kontrola tvrzení "EMI = X Kč/měs".

### 9. Compound Interest (yield calc)
- **Recipe:** `recipes/dd-financial.py --interest --type compound --p 100000 --r 0.05 --t 5 --n 12`
- **Source:** `Python/financial/interest.py`
- **Filip use:** Quick yield calc pro investor materiály. Compound = realistic, simple = teorie.

### 10. EMA (yield trend smoothing)
- **Recipe:** `recipes/dd-financial.py --ema --window 20 --data ...`
- **Source:** `Python/financial/exponential_moving_average.py`
- **Filip use:** Smoothing měsíčních yieldů z portfolio reportů — recent values weighted more.

## TIER 2 — Měsíčně (analytics + scraping + intel)

### 11. BFS Web Crawler (competitor link discovery)
- **Recipe:** `recipes/scraping-graph.py --crawl --start URL --max-depth 3`
- **Source:** `Python/graphs/breadth_first_search.py`
- **Filip use:** "Najdi všechny stránky na konkurenčním webu do 3 hopů" — competitor intel.
- **Chain:** competitor-intel → scraping-graph BFS → mapping

### 12. Cycle Detection (avoid scraper infinite loops)
- **Recipe:** `recipes/scraping-graph.py --cycle-detect --edges-file links.json`
- **Source:** `Python/graphs/check_cycle.py`
- **Filip use:** Pre-flight check scraping graph před production run.

### 13. Connected Components (cluster analysis)
- **Recipe:** `recipes/scraping-graph.py --components --edges-file links.json`
- **Source:** `Python/graphs/connected_components.py`
- **Filip use:** "Které firmy jsou v stejné síti?" — partnership/ownership cluster z scraped data.

### 14. Quick Sort / Tim Sort (DD batch ranking)
- **Search:** `~/.claude/skills/algorithm-recall/search.sh "tim_sort" Python`
- **Source:** `Python/sorts/tim_sort.py` (Python's built-in default)
- **Filip use:** Sort emitenti podle DSCR/grade/yield. Default `sorted()` je TimSort.

### 15. Binary Search (DD batch lookup)
- **Search:** `search.sh "binary_search" Python`
- **Source:** `Python/searches/binary_search.py`
- **Filip use:** Lookup IČO v sorted ARES batch (50k+ records).

### 16. Linear Regression (revenue trend)
- **Search:** `search.sh "linear_regression" Python`
- **Source:** `Python/machine_learning/linear_regression.py`
- **Filip use:** Trend forecasting emitent revenues z 3-5 let dat.

### 17. Logistic Regression (binary classifier)
- **Search:** `search.sh "logistic_regression" Python`
- **Source:** `Python/machine_learning/logistic_regression.py`
- **Filip use:** "Bude default v 12M? Y/N" classifier nad emitent metrics.

### 18. SHA-256 Standalone (file integrity)
- **Search:** `search.sh "sha256" Python`
- **Source:** `Python/hashes/sha256.py`
- **Filip use:** Integrity check emitent prospect PDF (nemění se mid-DD process).

### 19. Luhn Checksum (IČO/credit card validation)
- **Search:** `search.sh "luhn" Python`
- **Source:** `Python/hashes/luhn.py`
- **Filip use:** Pre-validate IČO format before ARES API call (saves quota).

### 20. Straight-line Depreciation (asset valuation)
- **Recipe:** `recipes/dd-financial.py --depreciation --cost 500000 --salvage 50000 --life 5`
- **Source:** `Python/financial/straight_line_depreciation.py`
- **Filip use:** Asset book value pro emitenta s velkou tangible asset base.

## TIER 3 — Občas/budoucí (ECSP, security, advanced)

### 21. RSA Cipher (NDA/document signing — REFERENCE ONLY)
- **Search:** `search.sh "rsa" Python`
- **Sources:** `Python/ciphers/{rsa_cipher,rsa_key_generator}.py`
- **Filip use:** Reference for understanding. **PROD: use `cryptography` lib** — TheAlgorithms RSA lacks padding/timing protection.

### 22. AES Cipher (data at rest — REFERENCE ONLY)
- **Search:** `search.sh "aes" Python`
- **Filip use:** Education. **PROD: use `cryptography.fernet`**.

### 23. Bloom Filter Standalone (URL crawl-frontier dedup)
- **Search:** `search.sh "bloom" Python`
- **Source:** `Python/data_structures/hashing/bloom_filter.py`
- **Filip use:** "Crawled this URL before?" check at scale (millions URLs, ~1% false positive).

### 24. Trie (autocomplete pro emitent search)
- **Search:** `search.sh "trie" Python`
- **Source:** `Python/data_structures/trie/trie.py`
- **Filip use:** Future Vault search autocomplete.

### 25. Dijkstra (shortest path — partnership graph)
- **Search:** `search.sh "dijkstra" Python` (14 implementations across 5 langs)
- **Filip use:** "Nejkratší cesta vlastnictví firma A → firma B" v ARES ownership graphu.

### 26. Diophantine Equation (blockchain primitive — limited use)
- **Search:** `search.sh "diophantine" Python`
- **Source:** `Python/blockchain/diophantine_equation.py`
- **Filip use:** Reference pro budoucí ECSP tokenization (smart contracts v Solidity).

### 27. Solidity Patterns (ECSP futures)
- **Path:** `Solidity/` (různé .sol files)
- **Filip use:** Pokud OneFlow půjde do tokenizace dluhopisů (smart contract templates).

### 28. Knapsack 0-1 (portfolio optimization)
- **Search:** `search.sh "knapsack" Python`
- **Source:** `Python/knapsack/knapsack.py`
- **Filip use:** "Maximize yield s capital constraint" — portfolio allocation problem.

### 29. Hamming Distance (binary string compare — niche)
- **Search:** `search.sh "hamming" Python`
- **Source:** `Python/strings/hamming_distance.py`
- **Filip use:** Pre-check pro fuzzy match když máš equal-length strings (saves Levenshtein cost).

### 30. Project Euler (interview/learning)
- **Path:** `Python/project_euler/`
- **Filip use:** Math puzzles. Skip — není business value, jen brain training.

## Skip rationale (NOT in this index)

- **C/C++/Java/MATLAB** — Filip nepíše, mirror clones tyto skipped.
- **Quantum/computer_vision/audio_filters** — out of scope for OneFlow.
- **Sorting algorithms (kromě top picks)** — Python's `sorted()` is TimSort, no need to reinvent.
- **Most string algos** — `re` module + the 4 fuzzy ones are enough.
- **Game/fractals/cellular automata** — entertainment value only.

## Update strategy

```bash
# Weekly upstream pull (or before major DD batch)
~/.claude/skills/algorithm-recall/update.sh

# Add Czech-specific algos as Filip discovers them
echo "FILIP_NEW_USE_CASE: <use case> — recipe: <path>" >> FILIP-INDEX.md
```

## Citation rule (always)

```python
# Adapted from TheAlgorithms/Python/<path> (MIT License)
# Source: https://github.com/TheAlgorithms/Python/blob/master/<path>
```
