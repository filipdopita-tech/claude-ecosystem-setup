---
name: algorithm-recall
description: Recall canonical algorithm implementations from TheAlgorithms reference library (Python/JavaScript/TypeScript/Rust/Go/Solidity, 220k★ Python repo). Use when user asks "implementuj X algoritmus", "jak udělat Y v Pythonu", "potřebuju binary search / Dijkstra / RSA / SHA / sorting / DP / Bayesian / financial calc / fuzzy match / blockchain primitive". Cascades local grep → file Read → cite source. Token-cheap by design.
allowed-tools: Bash, Read, Grep, Glob
---

# /algorithm-recall — Canonical Algorithm Library Lookup

Local mirror of [TheAlgorithms](https://github.com/TheAlgorithms) at `~/Documents/research-cache/algorithms-the-algorithms/`. Six languages, 1500+ implementations, MIT-licensed.

## When to use

- User asks for a classical algorithm implementation (sorting, graphs, DP, ML, crypto, math)
- DD/finance task needs Bayesian / Monte Carlo / NPV / IRR / amortization → check `Python/financial/`
- Security task needs SHA / RSA / AES / hash / cipher → check `Python/ciphers/` or `Python/hashes/`
- Scraping needs fuzzy match / Levenshtein / KMP / Rabin-Karp → check `Python/strings/`
- Blockchain / ECSP / tokenization needs primitives → check `Python/blockchain/` or `Solidity/`
- Frontend needs JS/TS algo (RxJS lookup, Trie autocomplete, debounce variants) → check `JavaScript/` or `TypeScript/`
- Performance code needs Rust impl → check `Rust/`
- VPS daemon needs Go impl → check `Go/`

## When NOT to use

- User wants a one-off custom algorithm (use ad-hoc code)
- User wants a heavy lib (use real library: numpy/scipy/scikit-learn instead of recreating)
- User wants conceptual explanation only (use `/teachme` or WebSearch)
- Implementation needs production hardening (TheAlgorithms is reference-quality, not prod-hardened)

## Cascading lookup pattern

### Step 1 — Identify category + language
Map user request to one of these top-level dirs in `Python/` (most complete):
```
audio_filters     bit_manipulation  blockchain        boolean_algebra
cellular_automata ciphers           computer_vision   conversions
data_compression  data_structures   digital_image_processing
divide_and_conquer dynamic_programming electronics    file_transfer
financial         fractals          fuzzy_logic       genetic_algorithm
geodesy           geometry          graphics          graphs
greedy_methods    hashes            knapsack          linear_algebra
linear_programming machine_learning maths             matrix
networking_flow   neural_network    other             physics
project_euler     quantum           scheduling        scripts
searches          sorts             strings           web_programming
```

### Step 2 — Search via helper
```bash
~/.claude/skills/algorithm-recall/search.sh <pattern> [language]
# Examples:
~/.claude/skills/algorithm-recall/search.sh "dijkstra"
~/.claude/skills/algorithm-recall/search.sh "rsa" Python
~/.claude/skills/algorithm-recall/search.sh "binary_search" Rust
~/.claude/skills/algorithm-recall/search.sh "trie" TypeScript
```

Helper does: case-insensitive filename grep + content grep across selected language(s), returns ranked file paths with line counts.

### Step 3 — Read implementation
Use `Read` tool on returned path. TheAlgorithms files have docstrings + doctests at top — those are usually what you want to cite.

### Step 4 — Adapt + cite
- Adapt to project conventions (rename, type hints, error handling)
- Cite source in PR/commit: `Adapted from TheAlgorithms/<lang>/<path> (MIT)`
- Don't copy the whole file blindly — pick the algorithmic core, drop test scaffolding

## Available repos (local)

| Repo | Path | Size | Use case |
|---|---|---|---|
| **Python** ⭐ | `Python/` | 26MB | DD, scraping, ML, crypto, finance — primary |
| JavaScript | `JavaScript/` | 3.7MB | Conductor frontend, Node.js scripts |
| TypeScript | `TypeScript/` | 1.4MB | Modern Next.js + shadcn projects |
| Rust | `Rust/` | 3.5MB | RTK ecosystem, perf-critical |
| Go | `Go/` | 3.1MB | VPS daemons, concurrency-heavy |
| Solidity | `Solidity/` | 472KB | ECSP tokenization, smart contracts |

## Update the mirror

```bash
~/.claude/skills/algorithm-recall/update.sh
```
Pulls latest from upstream (shallow). Run weekly or before major coding session if pinning matters.

## Examples

### Filip: "potřebuju implementovat binary search v Pythonu pro DD batch lookup"
```bash
~/.claude/skills/algorithm-recall/search.sh "binary_search" Python
# → returns: Python/searches/binary_search.py + Python/searches/binary_tree_traversal.py
```
Read the file, adapt to DD use case, cite.

### Filip: "fuzzy match na ARES company names"
```bash
~/.claude/skills/algorithm-recall/search.sh "levenshtein" Python
~/.claude/skills/algorithm-recall/search.sh "fuzzy" Python
~/.claude/skills/algorithm-recall/search.sh "jaro_winkler" Python
# → returns: Python/strings/levenshtein_distance.py + Python/strings/jaro_winkler.py + ...
```

### Filip: "Bayesian inference pro DSCR confidence intervals"
```bash
~/.claude/skills/algorithm-recall/search.sh "bayes" Python
~/.claude/skills/algorithm-recall/search.sh "naive_bayes" Python
~/.claude/skills/algorithm-recall/search.sh "monte_carlo" Python
```

### Filip: "RSA podpis pro NDA workflow"
```bash
~/.claude/skills/algorithm-recall/search.sh "rsa" Python
# → returns: Python/ciphers/rsa_cipher.py + Python/ciphers/rsa_key_generator.py
```

## Chain pattern

- algorithm-recall → adapt code → `/code-review` (security gate before deploy)
- algorithm-recall (financial) → chain `dd-emitent` (use as building block)
- algorithm-recall (crypto) → chain `security-toolkit` (verify hardening)
- algorithm-recall (ML) → chain `data-analysis` or `dd-batch-sql` (scale up)

## License

TheAlgorithms is MIT. Always cite when copying substantial code. Adaptations and snippets are fine without attribution but include a comment for traceability.

## Maintenance

- Mirror lives in `~/Documents/research-cache/algorithms-the-algorithms/` (gitignored, not committed to OneFlow repos)
- Total disk: ~38MB
- Update cadence: weekly via `update.sh` or before bigger algo-heavy task
- If repo grows or 6 langs aren't enough, add via shallow clone:
  ```bash
  cd ~/Documents/research-cache/algorithms-the-algorithms
  git clone --depth=1 https://github.com/TheAlgorithms/<NewLang>.git
  ```
