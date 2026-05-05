#!/usr/bin/env bash
# algorithm-recall use-case mapper
# Usage: find-for.sh "<use case in plain English/Czech>"
# Maps Filip's actual workflows to TheAlgorithms paths + ready recipes.

set -euo pipefail

ROOT="$HOME/Documents/research-cache/algorithms-the-algorithms"
SKILL="$HOME/.claude/skills/algorithm-recall"

if [ -z "${1:-}" ]; then
  cat <<EOF
Usage: $0 "<use case>"

Examples:
  $0 "calculate NPV for emitent"
  $0 "fuzzy match ARES company names"
  $0 "deduplicate outreach contacts"
  $0 "DD risk scoring with confidence"
  $0 "hash for password storage"
  $0 "scrape link network traversal"
  $0 "amortization schedule"
  $0 "RSA sign NDA"
  $0 "find DSCR bayesian confidence"
  $0 "spočítat úrok"
  $0 "porovnat dva texty"

Top use cases mapped → ready recipes in:
  $SKILL/recipes/

Direct algo lookup:
  $SKILL/search.sh <pattern> [Python|JavaScript|TypeScript|Rust|Go|Solidity]
EOF
  exit 0
fi

QUERY="$(echo "$1" | tr '[:upper:]' '[:lower:]')"

echo "=== Use case: \"$1\" ==="
echo

# Pattern matching → curated recipes/algos
case "$QUERY" in
  *npv*|*present\ value*|*present_value*|*discount*|*čistá\ současná*|*discount\ cash\ flow*)
    cat <<EOF
🎯 RECIPE: dd-financial.py — NPV/present value calc
    \$ python3 $SKILL/recipes/dd-financial.py --npv

📦 SOURCE: Python/financial/present_value.py (42 lines)
    \$ cat $ROOT/Python/financial/present_value.py

🔗 CHAIN: dd-emitent (use as building block in DD report)
EOF
    ;;
  *irr*|*internal\ rate*|*vnitřní\ míra*)
    cat <<EOF
🎯 RECIPE: dd-financial.py --irr (IRR via Newton-Raphson on present_value)
    \$ python3 $SKILL/recipes/dd-financial.py --irr

📦 SOURCE: Python/financial/present_value.py (NPV building block)
    No standalone IRR in TheAlgorithms — recipe uses bisection over present_value.
EOF
    ;;
  *amorti*|*emi*|*splátkový\ kalendář*|*equated\ monthly*|*loan\ schedule*)
    cat <<EOF
🎯 RECIPE: dd-financial.py --amortization
    \$ python3 $SKILL/recipes/dd-financial.py --amortization --principal 1000000 --rate 0.06 --months 60

📦 SOURCE: Python/financial/equated_monthly_installments.py (EMI formula)
EOF
    ;;
  *interest*|*úrok*|*compound*|*simple\ interest*|*složené*)
    cat <<EOF
🎯 RECIPE: dd-financial.py --interest
    \$ python3 $SKILL/recipes/dd-financial.py --interest --type compound --p 100000 --r 0.05 --t 5

📦 SOURCE: Python/financial/interest.py (simple + compound)
EOF
    ;;
  *depreciation*|*odpis*|*straight\ line*)
    cat <<EOF
🎯 RECIPE: dd-financial.py --depreciation
    \$ python3 $SKILL/recipes/dd-financial.py --depreciation --cost 100000 --salvage 10000 --life 5

📦 SOURCE: Python/financial/straight_line_depreciation.py
EOF
    ;;
  *moving\ average*|*sma*|*ema*|*exponential\ moving*|*klouzavý\ průměr*)
    cat <<EOF
🎯 RECIPE: dd-financial.py --sma|--ema (price/yield trend smoothing)
    \$ python3 $SKILL/recipes/dd-financial.py --sma --window 20 --data ...

📦 SOURCE: Python/financial/exponential_moving_average.py + simple_moving_average.py
EOF
    ;;
  *fuzzy*ares*|*ares*name*|*company*match*|*porovnej*firmy*|*deduplik*firm*)
    cat <<EOF
🎯 RECIPE: ares-fuzzy.py — CZ company name matching (Levenshtein + Damerau + Jaro-Winkler)
    \$ python3 $SKILL/recipes/ares-fuzzy.py "ABC s.r.o." "A.B.C. s. r. o."
    \$ python3 $SKILL/recipes/ares-fuzzy.py --batch input.csv --threshold 0.85

📦 SOURCE: Python/strings/{levenshtein,damerau_levenshtein,jaro_winkler,hamming}_distance.py

🔗 CHAIN: cold-outreach-v3 (ARES enrichment dedup), dd-batch-sql (50+ emitenti merge)
EOF
    ;;
  *fuzzy*|*string\ distance*|*similar*text*|*levenshtein*|*jaro*|*podobné\ texty*|*porovnej*texty*)
    cat <<EOF
🎯 RECIPE: ares-fuzzy.py (works on any string pair, not just companies)
    \$ python3 $SKILL/recipes/ares-fuzzy.py "text 1" "text 2"

📦 SOURCES:
    Python/strings/levenshtein_distance.py    (edit distance, classic)
    Python/strings/damerau_levenshtein_distance.py  (handles transpositions)
    Python/strings/jaro_winkler.py            (best for short strings, names)
    Python/strings/hamming_distance.py        (equal-length only, fast)
EOF
    ;;
  *dedup*contact*|*dedup*email*|*dedup*outreach*|*duplicate*lead*|*duplik*kontakt*)
    cat <<EOF
🎯 RECIPE: contact-dedup.py — outreach contact dedup (SHA-256 + Bloom + near-duplicate)
    \$ python3 $SKILL/recipes/contact-dedup.py --input leads.csv --email-col email --out unique.csv

📦 SOURCES:
    Python/hashes/sha256.py                          (canonical hash)
    Python/data_structures/hashing/bloom_filter.py   (O(1) lookup, 1% false-positive)
    Python/strings/levenshtein_distance.py           (typo detection: jan@x.cz vs jna@x.cz)

🔗 CHAIN: cold-outreach-v3, lead-ops, leadgen
EOF
    ;;
  *bayesian*|*risk\ scoring*|*credit\ risk*|*default\ probability*|*pravděpodobnost\ defaultu*|*dscr\ confidence*|*ltv\ confidence*)
    cat <<EOF
🎯 RECIPE: dd-bayesian-risk.py — DSCR/LTV risk scoring with confidence intervals
    \$ python3 $SKILL/recipes/dd-bayesian-risk.py --emitent ABC --metrics metrics.json

📦 SOURCES (TheAlgorithms gaussian_naive_bayes is .broken — recipe has standalone impl):
    Python/machine_learning/linear_regression.py      (trend baseline)
    Python/machine_learning/logistic_regression.py    (binary classifier baseline)
    Python/maths/monte_carlo.py                       (simulation for confidence)

🔗 CHAIN: dd-emitent (auto-attach risk score to report), dd-batch-sql (portfolio scoring)
EOF
    ;;
  *graph*scrape*|*link\ network*|*url\ traversal*|*scraping\ graph*|*crawl\ network*|*social\ graph*)
    cat <<EOF
🎯 RECIPE: scraping-graph.py — link network analysis pro scraping/competitor intel
    \$ python3 $SKILL/recipes/scraping-graph.py --start url --max-depth 3 --bfs

📦 SOURCES:
    Python/graphs/breadth_first_search.py        (BFS — discover layers)
    Python/graphs/depth_first_search.py          (DFS — go deep)
    Python/graphs/check_cycle.py                 (avoid loops)
    Python/graphs/connected_components.py        (cluster detection)

🔗 CHAIN: web-scraping, competitor-intel, instagram-analyzer
EOF
    ;;
  *dijkstra*|*shortest\ path*|*nejkratší\ cesta*|*route*planning*)
    cat <<EOF
🎯 SOURCES (14 implementations across 5 langs):
    Python/graphs/dijkstra.py                        (canonical 119 lines)
    Python/graphs/dijkstra_algorithm.py              (full impl, 484 lines)
    Python/graphs/bi_directional_dijkstra.py         (faster for known target)
    Rust/src/graph/dijkstra.rs                       (perf-critical)
    Go/graph/dijkstra.go                             (concurrent-friendly)
EOF
    ;;
  *rsa*|*public\ key*|*sign\ document*|*nda\ podpis*|*digital\ signature*)
    cat <<EOF
🎯 SOURCES (use real lib for prod, TheAlgorithms is reference):
    Python/ciphers/rsa_cipher.py            (149 lines, encrypt/decrypt)
    Python/ciphers/rsa_key_generator.py     (key gen, 63 lines)
    Python/ciphers/rsa_factorization.py     (security demo only — DON'T use)

⚠️  PROD: use \`cryptography\` lib, not TheAlgorithms RSA — it lacks padding/timing protection.
EOF
    ;;
  *sha*|*hash*password*|*hash*content*|*content\ fingerprint*|*hashování*)
    cat <<EOF
🎯 SOURCES:
    Python/hashes/sha256.py     (7K, full SHA-256 impl)
    Python/hashes/sha1.py       (legacy, don't use for new)
    Python/hashes/md5.py        (legacy, don't use for new)
    Python/hashes/luhn.py       (credit card / IČO checksum)

⚠️  PROD passwords: use \`bcrypt\`/\`argon2\`, not raw SHA-256.
⚠️  PROD content fingerprint: use \`hashlib\`, not TheAlgorithms (perf).
✅  Reference / learning: TheAlgorithms is great.
EOF
    ;;
  *bloom*filter*|*o\(1\)*lookup*|*membership\ test*)
    cat <<EOF
🎯 SOURCE: Python/data_structures/hashing/bloom_filter.py
    Use for: contact dedup, URL crawl-frontier dedup, "have I seen this" checks at scale.
    Recipe: contact-dedup.py (already integrated)
EOF
    ;;
  *sort*|*řazení*|*seřaď*)
    cat <<EOF
🎯 SOURCES (32 sort variants in Python/sorts/):
    Python/sorts/quick_sort.py          (default for general data)
    Python/sorts/merge_sort.py          (stable, O(n log n) guaranteed)
    Python/sorts/tim_sort.py            (Python's built-in algorithm)
    Python/sorts/radix_sort.py          (integers only, O(nk) very fast)
    Python/sorts/counting_sort.py       (small range integers)

⚠️  Default: use Python's built-in \`sorted()\` — it's TimSort. TheAlgorithms = learning/edge cases.
EOF
    ;;
  *search*|*hled*|*binary*search*)
    cat <<EOF
🎯 SOURCES:
    Python/searches/binary_search.py            (sorted array, O(log n))
    Python/searches/jump_search.py              (sorted, square-root step)
    Python/searches/interpolation_search.py     (uniform distribution)
    Python/searches/fibonacci_search.py         (no division ops)
EOF
    ;;
  *monte*carlo*|*simulation*|*pravděpodobnost\ simulace*)
    cat <<EOF
🎯 SOURCES:
    Python/maths/monte_carlo.py                          (Pi estimation example)
    Python/maths/monte_carlo_dice.py                     (probability distributions)

🔗 RECIPE: dd-bayesian-risk.py uses Monte Carlo for DSCR/LTV confidence intervals.
EOF
    ;;
  *)
    echo "❓ No curated mapping for \"$1\""
    echo
    echo "Try fuzzy lookup:"
    echo "  \$ $SKILL/search.sh \"<keyword>\""
    echo
    echo "Or browse recipes:"
    echo "  \$ ls $SKILL/recipes/"
    echo
    echo "Top categories in Python/:"
    ls -d "$ROOT/Python"/*/ 2>/dev/null | xargs -n1 basename | column -c 80 | head -20
    ;;
esac

echo
echo "📋 Cite-and-fork ready snippet:"
echo "  \$ $SKILL/extract.sh <path-to-source>"
