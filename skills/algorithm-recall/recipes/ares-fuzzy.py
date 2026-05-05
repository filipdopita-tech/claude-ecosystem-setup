#!/usr/bin/env python3
# === Adapted from TheAlgorithms/Python (MIT License) ===
# Building blocks: Python/strings/{levenshtein_distance, damerau_levenshtein_distance,
#                  jaro_winkler, hamming_distance}.py
# Combined into CZ company name fuzzy matching pipeline.
#
# Usage:
#   python3 ares-fuzzy.py "ABC s.r.o." "A.B.C. s. r. o."
#   python3 ares-fuzzy.py --batch input.csv --col company_name --threshold 0.85 --out dedup.csv
#   python3 ares-fuzzy.py --pair "Petr Novák Holding a.s." "Petr Novak Holdings"
#
# Output: similarity 0-1, recommended action (DEDUP/REVIEW/UNIQUE)

import argparse
import csv
import json
import re
import sys
import unicodedata


# === Building blocks adapted from TheAlgorithms ===

def levenshtein_distance(a: str, b: str) -> int:
    """Edit distance: min ops to transform a → b. Insert, delete, substitute."""
    if len(a) < len(b):
        return levenshtein_distance(b, a)
    if not b:
        return len(a)
    prev = list(range(len(b) + 1))
    for i, ca in enumerate(a):
        curr = [i + 1]
        for j, cb in enumerate(b):
            curr.append(min(prev[j + 1] + 1, curr[j] + 1, prev[j] + (ca != cb)))
        prev = curr
    return prev[-1]


def damerau_levenshtein_distance(a: str, b: str) -> int:
    """Edit distance + transposition (handles 'jna'↔'jan' as 1 op, not 2)."""
    d = {(i, -1): i + 1 for i in range(-1, len(a))}
    for j in range(-1, len(b)):
        d[(-1, j)] = j + 1
    for i in range(len(a)):
        for j in range(len(b)):
            cost = 0 if a[i] == b[j] else 1
            d[(i, j)] = min(d[(i - 1, j)] + 1, d[(i, j - 1)] + 1, d[(i - 1, j - 1)] + cost)
            if i > 0 and j > 0 and a[i] == b[j - 1] and a[i - 1] == b[j]:
                d[(i, j)] = min(d[(i, j)], d[(i - 2, j - 2)] + cost)
    return d[(len(a) - 1, len(b) - 1)]


def jaro_similarity(a: str, b: str) -> float:
    """Jaro similarity 0-1. Better than Levenshtein for short strings (names)."""
    if a == b:
        return 1.0
    la, lb = len(a), len(b)
    if la == 0 or lb == 0:
        return 0.0
    match_dist = max(la, lb) // 2 - 1
    a_match = [False] * la
    b_match = [False] * lb
    matches = 0
    for i in range(la):
        for j in range(max(0, i - match_dist), min(lb, i + match_dist + 1)):
            if not b_match[j] and a[i] == b[j]:
                a_match[i] = b_match[j] = True
                matches += 1
                break
    if matches == 0:
        return 0.0
    transpositions = 0
    k = 0
    for i in range(la):
        if a_match[i]:
            while not b_match[k]:
                k += 1
            if a[i] != b[k]:
                transpositions += 1
            k += 1
    transpositions //= 2
    return (matches / la + matches / lb + (matches - transpositions) / matches) / 3


def jaro_winkler_similarity(a: str, b: str, p: float = 0.1) -> float:
    """Jaro-Winkler boosts similarity if common prefix exists. Best for names."""
    jaro = jaro_similarity(a, b)
    prefix = 0
    for ca, cb in zip(a, b):
        if ca == cb:
            prefix += 1
        else:
            break
        if prefix == 4:
            break
    return jaro + prefix * p * (1 - jaro)


def hamming_distance(a: str, b: str) -> int:
    """For equal-length strings only. Fast pre-check."""
    if len(a) != len(b):
        raise ValueError("hamming_distance requires equal-length strings")
    return sum(c1 != c2 for c1, c2 in zip(a, b))


# === CZ company name normalization (OneFlow-specific) ===

CZ_LEGAL_FORMS = [
    # ORDER MATTERS — longer patterns first to avoid partial match swallowing
    r"\bspol\s*\.?\s*s\s*\.?\s*r\s*\.?\s*o\s*\.?\b",  # spol. s r.o.  (longest, must be first)
    r"\bv\s*\.?\s*o\s*\.?\s*s\s*\.?\b",  # v.o.s.
    r"\bs\s*\.?\s*r\s*\.?\s*o\s*\.?\b",  # s.r.o., s. r. o., sro, s r o
    r"\ba\s*\.?\s*s\s*\.?\b",            # a.s., a. s., as
    r"\bk\s*\.?\s*s\s*\.?\b",            # k.s.
    r"\bo\s*\.?\s*s\s*\.?\b",            # o.s. (občanské sdružení)
    r"\bp\s*\.?\s*o\s*\.?\b",            # p.o. (příspěvková organizace)
    r"\bz\s*\.?\s*ú\s*\.?\b",            # z.ú. (zapsaný ústav)
    r"\bz\s*\.?\s*s\s*\.?\b",            # z.s. (zapsaný spolek)
    r"\bs\s*\.?\s*p\s*\.?\b",            # s.p. (státní podnik)
    r"\bse\b",                            # SE (evropská společnost)
    r"\bgmbh\b", r"\bag\b", r"\bllc\b", r"\binc\b", r"\bltd\b",
]


def normalize_cz_company(name: str) -> str:
    """Normalize CZ company name for fuzzy matching:
    1. lowercase
    2. strip diacritics (Petr Novák → petr novak)
    3. remove legal form (s.r.o./a.s./...)
    4. normalize whitespace
    5. strip punctuation
    """
    s = name.strip().lower()
    # Strip diacritics
    s = unicodedata.normalize("NFD", s)
    s = "".join(c for c in s if unicodedata.category(c) != "Mn")
    # Remove legal forms (must be done before stripping punctuation since they often have dots)
    for pattern in CZ_LEGAL_FORMS:
        s = re.sub(pattern, "", s)
    # Strip punctuation, normalize whitespace
    s = re.sub(r"[^\w\s]", " ", s)
    s = re.sub(r"\s+", " ", s).strip()
    return s


# === Combined fuzzy match (cascade: cheapest → strictest) ===

def fuzzy_match(a: str, b: str, normalize: bool = True) -> dict:
    """Multi-algorithm match. Returns confidence + recommended action."""
    if normalize:
        a_norm = normalize_cz_company(a)
        b_norm = normalize_cz_company(b)
    else:
        a_norm, b_norm = a.lower().strip(), b.lower().strip()

    # Quick checks
    if a_norm == b_norm:
        return {"confidence": 1.0, "action": "DEDUP", "reason": "exact_after_normalize",
                "input": [a, b], "normalized": [a_norm, b_norm]}

    if not a_norm or not b_norm:
        return {"confidence": 0.0, "action": "UNIQUE", "reason": "empty_after_normalize",
                "input": [a, b], "normalized": [a_norm, b_norm]}

    # Compute multiple similarities
    max_len = max(len(a_norm), len(b_norm))
    lev = levenshtein_distance(a_norm, b_norm)
    lev_sim = 1 - (lev / max_len)
    dam_lev = damerau_levenshtein_distance(a_norm, b_norm)
    dam_sim = 1 - (dam_lev / max_len)
    jw = jaro_winkler_similarity(a_norm, b_norm)

    # Weighted ensemble (Jaro-Winkler gets highest weight for short names)
    confidence = round(0.25 * lev_sim + 0.25 * dam_sim + 0.50 * jw, 4)

    if confidence >= 0.92:
        action = "DEDUP"
    elif confidence >= 0.78:
        action = "REVIEW"
    else:
        action = "UNIQUE"

    return {
        "confidence": confidence,
        "action": action,
        "reason": f"weighted ensemble (Lev={lev_sim:.3f}, DamLev={dam_sim:.3f}, JW={jw:.3f})",
        "input": [a, b],
        "normalized": [a_norm, b_norm],
        "scores": {"levenshtein": lev_sim, "damerau_levenshtein": dam_sim, "jaro_winkler": jw},
    }


def batch_dedup(rows: list[dict], col: str, threshold: float = 0.92) -> dict:
    """Find dup clusters in CSV. Returns {clusters, unique, total}."""
    n = len(rows)
    parent = list(range(n))

    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x, y):
        px, py = find(x), find(y)
        if px != py:
            parent[px] = py

    # O(n²) for now — fine for <10k rows. For larger use blocking by 1st letter.
    pairs_checked = 0
    for i in range(n):
        for j in range(i + 1, n):
            pairs_checked += 1
            r = fuzzy_match(rows[i][col], rows[j][col])
            if r["confidence"] >= threshold:
                union(i, j)

    # Collect clusters
    clusters = {}
    for i in range(n):
        root = find(i)
        clusters.setdefault(root, []).append(i)

    return {
        "total_rows": n,
        "unique_clusters": len(clusters),
        "duplicates_found": n - len(clusters),
        "pairs_checked": pairs_checked,
        "clusters": [
            {"canonical": rows[idxs[0]][col], "members": [rows[i][col] for i in idxs]}
            for idxs in clusters.values() if len(idxs) > 1
        ],
    }


def main():
    p = argparse.ArgumentParser(description="ARES company name fuzzy matcher")
    p.add_argument("a", nargs="?", help="First name to compare")
    p.add_argument("b", nargs="?", help="Second name to compare")
    p.add_argument("--pair", nargs=2, metavar=("A", "B"))
    p.add_argument("--batch", help="CSV file for batch dedup")
    p.add_argument("--col", default="name", help="Column name in CSV (default: name)")
    p.add_argument("--threshold", type=float, default=0.92, help="DEDUP threshold (default 0.92)")
    p.add_argument("--out", help="Write deduped CSV to this path")
    p.add_argument("--no-normalize", action="store_true", help="Skip CZ normalization")

    args = p.parse_args()

    if args.batch:
        with open(args.batch, encoding="utf-8") as f:
            rows = list(csv.DictReader(f))
        result = batch_dedup(rows, args.col, args.threshold)
        print(json.dumps(result, indent=2, ensure_ascii=False))
        if args.out:
            seen_canonicals = set()
            unique = []
            for cluster in result["clusters"]:
                seen_canonicals.update(cluster["members"][1:])
            for row in rows:
                if row[args.col] not in seen_canonicals:
                    unique.append(row)
            with open(args.out, "w", encoding="utf-8", newline="") as f:
                if unique:
                    writer = csv.DictWriter(f, fieldnames=unique[0].keys())
                    writer.writeheader()
                    writer.writerows(unique)
            print(f"\nWrote {len(unique)} unique rows to {args.out}", file=sys.stderr)
    elif args.pair:
        a, b = args.pair
        print(json.dumps(fuzzy_match(a, b, normalize=not args.no_normalize), indent=2, ensure_ascii=False))
    elif args.a and args.b:
        print(json.dumps(fuzzy_match(args.a, args.b, normalize=not args.no_normalize), indent=2, ensure_ascii=False))
    else:
        p.print_help()
        sys.exit(1)


if __name__ == "__main__":
    main()
