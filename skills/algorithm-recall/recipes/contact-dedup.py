#!/usr/bin/env python3
# === Adapted from TheAlgorithms/Python (MIT License) ===
# Building blocks: Python/hashes/sha256.py + Python/data_structures/hashing/bloom_filter.py
#                  + Python/strings/levenshtein_distance.py
# Use case: Outreach contact dedup — exact + fuzzy detection of duplicates.
#
# Usage:
#   python3 contact-dedup.py --input leads.csv --email-col email
#   python3 contact-dedup.py --input leads.csv --email-col email --name-col company --fuzzy
#   python3 contact-dedup.py --input leads.csv --out unique.csv --report

import argparse
import csv
import hashlib
import json
import math
import re
import sys


# === Bloom filter (adapted from Python/data_structures/hashing/bloom_filter.py) ===
class BloomFilter:
    """O(1) membership test, ~1% false-positive rate.
    Use for fast 'have I seen this email before' across millions."""

    def __init__(self, expected_items: int = 100_000, false_positive_rate: float = 0.01):
        self.size = self._optimal_size(expected_items, false_positive_rate)
        self.num_hashes = self._optimal_hash_count(self.size, expected_items)
        self.bit_array = [False] * self.size
        self.count = 0

    @staticmethod
    def _optimal_size(n: int, p: float) -> int:
        return max(8, int(-(n * math.log(p)) / (math.log(2) ** 2)))

    @staticmethod
    def _optimal_hash_count(m: int, n: int) -> int:
        return max(1, int((m / n) * math.log(2)))

    def _hashes(self, item: str):
        h1 = int(hashlib.md5(item.encode()).hexdigest(), 16)
        h2 = int(hashlib.sha1(item.encode()).hexdigest(), 16)
        return [(h1 + i * h2) % self.size for i in range(self.num_hashes)]

    def add(self, item: str):
        for idx in self._hashes(item):
            self.bit_array[idx] = True
        self.count += 1

    def __contains__(self, item: str) -> bool:
        return all(self.bit_array[idx] for idx in self._hashes(item))


# === Email normalization ===
def normalize_email(email: str) -> str:
    """Lowercase + strip whitespace + handle Gmail aliases (foo+anything@gmail = foo@gmail)."""
    if not email:
        return ""
    e = email.strip().lower()
    if "@" not in e:
        return e
    local, domain = e.split("@", 1)
    if domain in ("gmail.com", "googlemail.com"):
        local = local.split("+")[0].replace(".", "")
        domain = "gmail.com"
    return f"{local}@{domain}"


def sha256_email(email: str) -> str:
    """Canonical hash for storage / API. Use normalized email."""
    return hashlib.sha256(normalize_email(email).encode()).hexdigest()


# === Levenshtein for typo detection (cheap re-import) ===
def levenshtein(a: str, b: str) -> int:
    if len(a) < len(b):
        return levenshtein(b, a)
    if not b:
        return len(a)
    prev = list(range(len(b) + 1))
    for i, ca in enumerate(a):
        curr = [i + 1]
        for j, cb in enumerate(b):
            curr.append(min(prev[j + 1] + 1, curr[j] + 1, prev[j] + (ca != cb)))
        prev = curr
    return prev[-1]


def is_likely_typo(e1: str, e2: str, max_dist: int = 2) -> bool:
    """Same domain, local-part Levenshtein <= 2 = typo (jan@x.cz vs jna@x.cz)."""
    if "@" not in e1 or "@" not in e2:
        return False
    l1, d1 = e1.split("@", 1)
    l2, d2 = e2.split("@", 1)
    if d1 != d2:
        return False
    if abs(len(l1) - len(l2)) > max_dist:
        return False
    return levenshtein(l1, l2) <= max_dist


def dedup(rows: list[dict], email_col: str, fuzzy: bool = False) -> dict:
    """Returns: {unique, exact_dups, typo_dups (if fuzzy), total}."""
    seen_exact = {}    # normalized_email -> first row index
    bloom = BloomFilter(expected_items=max(len(rows) * 2, 1000))
    typo_pairs = []
    exact_dups = []
    unique_rows = []

    for i, row in enumerate(rows):
        raw_email = row.get(email_col, "")
        if not raw_email:
            continue  # skip empty
        norm = normalize_email(raw_email)
        if not norm:
            continue

        if norm in seen_exact:
            exact_dups.append({
                "row": i,
                "email": raw_email,
                "normalized": norm,
                "duplicate_of_row": seen_exact[norm],
            })
            continue

        if fuzzy and norm in bloom:
            for prev_norm in seen_exact.keys():
                if is_likely_typo(norm, prev_norm):
                    typo_pairs.append({
                        "row": i,
                        "email": raw_email,
                        "normalized": norm,
                        "possible_duplicate_of": prev_norm,
                        "row_idx": seen_exact[prev_norm],
                    })

        seen_exact[norm] = i
        bloom.add(norm)
        unique_rows.append(row)

    return {
        "total_input": len(rows),
        "unique_count": len(unique_rows),
        "exact_duplicates": len(exact_dups),
        "typo_duplicates": len(typo_pairs),
        "exact_duplicate_details": exact_dups[:10] + (["..."] if len(exact_dups) > 10 else []),
        "typo_duplicate_details": typo_pairs[:10] + (["..."] if len(typo_pairs) > 10 else []),
        "unique_rows": unique_rows,
    }


def main():
    p = argparse.ArgumentParser(description="OneFlow outreach contact dedup")
    p.add_argument("--input", required=True, help="Input CSV path")
    p.add_argument("--email-col", default="email", help="Column name for email (default: email)")
    p.add_argument("--out", help="Write unique rows to this CSV")
    p.add_argument("--fuzzy", action="store_true", help="Also detect typo near-duplicates")
    p.add_argument("--report", action="store_true", help="Print full JSON report")
    p.add_argument("--hash-only", action="store_true", help="Just hash all emails, skip dedup")

    args = p.parse_args()

    with open(args.input, encoding="utf-8") as f:
        rows = list(csv.DictReader(f))

    if args.hash_only:
        for row in rows:
            email = row.get(args.email_col, "")
            print(f"{email}\t{sha256_email(email)}")
        return

    result = dedup(rows, args.email_col, fuzzy=args.fuzzy)

    if args.out:
        unique = result.pop("unique_rows")
        with open(args.out, "w", encoding="utf-8", newline="") as f:
            if unique:
                writer = csv.DictWriter(f, fieldnames=unique[0].keys())
                writer.writeheader()
                writer.writerows(unique)
        print(f"Wrote {len(unique)} unique rows to {args.out}", file=sys.stderr)

    if args.report or not args.out:
        result.pop("unique_rows", None)  # don't dump 100k rows to stdout
        print(json.dumps(result, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()
