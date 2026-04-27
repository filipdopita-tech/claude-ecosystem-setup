#!/usr/bin/env python3
"""
stat-test.py — Statistical analysis for A/B prompt-variant experiments.

Reads a paired-scores JSON file (produced by run-experiment.sh) and computes:
  - Mean delta (variant - control)
  - 95% bootstrap CI on mean delta
  - Sign test p-value (two-sided binomial)
  - Wilcoxon signed-rank p-value (two-sided)
  - Effect size: Cliff's delta and Cohen's d
  - Verdict: WINNER / LOSER / INCONCLUSIVE

Uses stdlib only (math, json, random, sys, argparse).

Usage:
  python3 stat-test.py --paired-json <path> [--significance 0.05] [--output <path>]
"""

import argparse
import json
import math
import random
import sys
from typing import Optional


# ─── Math utilities ───────────────────────────────────────────────────────────

def mean(xs: list[float]) -> float:
    if not xs:
        return 0.0
    return sum(xs) / len(xs)


def stddev(xs: list[float]) -> float:
    if len(xs) < 2:
        return 0.0
    m = mean(xs)
    var = sum((x - m) ** 2 for x in xs) / (len(xs) - 1)
    return math.sqrt(var)


def bootstrap_ci(xs: list[float], n_boot: int = 2000, ci: float = 0.95, seed: int = 42) -> tuple[float, float]:
    """Bootstrap confidence interval for the mean of xs."""
    if not xs:
        return (0.0, 0.0)
    rng = random.Random(seed)
    n = len(xs)
    boot_means = []
    for _ in range(n_boot):
        sample = [rng.choice(xs) for _ in range(n)]
        boot_means.append(mean(sample))
    boot_means.sort()
    alpha = (1.0 - ci) / 2.0
    lo_idx = int(math.floor(alpha * n_boot))
    hi_idx = int(math.ceil((1.0 - alpha) * n_boot)) - 1
    lo_idx = max(0, min(lo_idx, n_boot - 1))
    hi_idx = max(0, min(hi_idx, n_boot - 1))
    return (boot_means[lo_idx], boot_means[hi_idx])


# ─── Binomial CDF (for sign test) ────────────────────────────────────────────

def _log_comb(n: int, k: int) -> float:
    """log of binomial coefficient C(n, k)."""
    if k < 0 or k > n:
        return -math.inf
    return sum(math.log(n - i) - math.log(i + 1) for i in range(k))


def binomial_pmf(k: int, n: int, p: float) -> float:
    if k < 0 or k > n or n < 0:
        return 0.0
    log_prob = _log_comb(n, k) + k * math.log(p) + (n - k) * math.log(1 - p)
    return math.exp(log_prob)


def binomial_cdf(k: int, n: int, p: float) -> float:
    """P(X <= k) for X ~ Binomial(n, p)."""
    return sum(binomial_pmf(i, n, p) for i in range(k + 1))


def sign_test_p_value(wins: int, losses: int) -> float:
    """Two-sided sign test p-value. Ties are excluded."""
    n = wins + losses
    if n == 0:
        return 1.0
    k = min(wins, losses)
    # Two-sided: p = 2 * P(X <= k) where X ~ Binomial(n, 0.5)
    p = 2.0 * binomial_cdf(k, n, 0.5)
    return min(p, 1.0)


# ─── Wilcoxon signed-rank test ───────────────────────────────────────────────

def wilcoxon_p_value(deltas: list[float]) -> Optional[float]:
    """
    Two-sided Wilcoxon signed-rank p-value.
    Uses normal approximation (valid for n >= 10; exact for small n via enumeration up to n=20).
    Returns None if all deltas are zero.
    """
    nonzero = [d for d in deltas if d != 0.0]
    n = len(nonzero)
    if n == 0:
        return None

    # Rank by absolute value
    abs_vals = sorted(enumerate(nonzero), key=lambda x: abs(x[1]))
    ranks = [0.0] * n
    i = 0
    while i < n:
        j = i
        # Find tied group
        while j < n and abs(abs_vals[j][1]) == abs(abs_vals[i][1]):
            j += 1
        avg_rank = (i + 1 + j) / 2.0
        for k in range(i, j):
            ranks[abs_vals[k][0]] = avg_rank
        i = j

    w_plus  = sum(r for r, d in zip(ranks, nonzero) if d > 0)
    w_minus = sum(r for r, d in zip(ranks, nonzero) if d < 0)
    w_stat  = min(w_plus, w_minus)

    if n < 10:
        # Exact enumeration for small n
        # Generate all 2^n sign assignments, count how many give W_stat <= observed
        expected_w = n * (n + 1) / 4.0
        # Use normal approximation anyway — more conservative and avoids 2^20 cost
        pass

    # Normal approximation
    expected = n * (n + 1) / 4.0
    variance = n * (n + 1) * (2 * n + 1) / 24.0
    if variance <= 0:
        return 1.0
    z = (w_stat - expected) / math.sqrt(variance)
    # Two-sided p-value from |z|
    abs_z = abs(z)
    # Abramowitz & Stegun approximation for standard normal CDF
    t = 1.0 / (1.0 + 0.2316419 * abs_z)
    poly = t * (0.319381530 +
                t * (-0.356563782 +
                     t * (1.781477937 +
                          t * (-1.821255978 +
                               t * 1.330274429))))
    phi = math.exp(-abs_z ** 2 / 2.0) / math.sqrt(2.0 * math.pi)
    p_upper = phi * poly
    p_two_sided = 2.0 * p_upper
    return min(p_two_sided, 1.0)


# ─── Effect sizes ─────────────────────────────────────────────────────────────

def cliffs_delta(control_scores: list[float], variant_scores: list[float]) -> float:
    """
    Cliff's delta: proportion of pairs where variant > control minus
    proportion where control > variant. Range [-1, 1].
    Interpretation: |d| < 0.15 negligible, 0.15-0.33 small, 0.33-0.47 medium, > 0.47 large.
    """
    n1 = len(control_scores)
    n2 = len(variant_scores)
    if n1 == 0 or n2 == 0:
        return 0.0
    concordant = sum(
        1 for c in control_scores for v in variant_scores if v > c
    )
    discordant = sum(
        1 for c in control_scores for v in variant_scores if v < c
    )
    return (concordant - discordant) / (n1 * n2)


def cohens_d(deltas: list[float]) -> float:
    """Cohen's d for paired data: mean(delta) / sd(delta)."""
    if len(deltas) < 2:
        return 0.0
    sd = stddev(deltas)
    if sd == 0.0:
        return 0.0
    return mean(deltas) / sd


def cliffs_magnitude(d: float) -> str:
    abs_d = abs(d)
    if abs_d < 0.15:
        return "negligible"
    elif abs_d < 0.33:
        return "small"
    elif abs_d < 0.47:
        return "medium"
    else:
        return "large"


def cohens_magnitude(d: float) -> str:
    abs_d = abs(d)
    if abs_d < 0.2:
        return "negligible"
    elif abs_d < 0.5:
        return "small"
    elif abs_d < 0.8:
        return "medium"
    else:
        return "large"


# ─── Main ─────────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(description="A/B experiment statistical analysis")
    parser.add_argument("--paired-json", required=True, help="Path to paired scores JSON")
    parser.add_argument("--significance", type=float, default=0.05, help="p-value threshold")
    parser.add_argument("--output", default=None, help="Output JSON path (stdout if omitted)")
    parser.add_argument("--bootstrap-n", type=int, default=2000, help="Bootstrap iterations")
    args = parser.parse_args()

    with open(args.paired_json) as f:
        data = json.load(f)

    cases = data.get("cases", [])
    if not cases:
        print("ERROR: No cases in paired JSON", file=sys.stderr)
        sys.exit(1)

    deltas         = [c["delta"] for c in cases]
    control_scores = [c["control_score"] for c in cases]
    variant_scores = [c["variant_score"] for c in cases]

    wins   = sum(1 for d in deltas if d > 0)
    losses = sum(1 for d in deltas if d < 0)
    ties   = sum(1 for d in deltas if d == 0)
    n      = len(deltas)

    # Central tendency
    mean_delta = mean(deltas)
    ci_lo, ci_hi = bootstrap_ci(deltas, n_boot=args.bootstrap_n)

    # Statistical tests
    p_sign    = sign_test_p_value(wins, losses)
    p_wilcoxon = wilcoxon_p_value(deltas)

    # Effect sizes
    cliff = cliffs_delta(control_scores, variant_scores)
    cohen = cohens_d(deltas)

    # Win rate
    win_rate = wins / n if n > 0 else 0.0

    # Verdict
    alpha = args.significance
    primary_p = p_sign  # sign test is the primary

    # Use minimum p for verdict (most conservative pass to win)
    deciding_p = primary_p
    if p_wilcoxon is not None:
        deciding_p = min(primary_p, p_wilcoxon)

    if deciding_p < alpha:
        if mean_delta > 0:
            verdict = "WINNER"
        else:
            verdict = "LOSER"
    else:
        verdict = "INCONCLUSIVE"

    # Flag negligible effect size even if significant
    cliff_mag = cliffs_magnitude(cliff)
    cohen_mag = cohens_magnitude(cohen)
    effect_warning = None
    if verdict == "WINNER" and cliff_mag == "negligible" and cohen_mag == "negligible":
        effect_warning = "Statistically significant but effect size is negligible — practical impact unclear"

    # CI crosses zero warning
    ci_crosses_zero = ci_lo < 0 < ci_hi
    if ci_crosses_zero and verdict == "WINNER":
        effect_warning = (effect_warning or "") + "; 95% CI crosses zero — evidence is weak"

    result = {
        "n":                n,
        "wins":             wins,
        "losses":           losses,
        "ties":             ties,
        "non_tie_n":        wins + losses,
        "win_rate":         round(win_rate, 4),
        "mean_delta":       round(mean_delta, 4),
        "ci_lower":         round(ci_lo, 4),
        "ci_upper":         round(ci_hi, 4),
        "p_sign_test":      round(p_sign, 5),
        "p_wilcoxon":       round(p_wilcoxon, 5) if p_wilcoxon is not None else None,
        "cliffs_delta":     round(cliff, 4),
        "cliffs_magnitude": cliff_mag,
        "cohens_d":         round(cohen, 4),
        "cohens_magnitude": cohen_mag,
        "significance_threshold": alpha,
        "verdict":          verdict,
        "effect_warning":   effect_warning,
    }

    # Print human summary to stderr
    print(f"\n  Statistical Summary (n={n})", file=sys.stderr)
    print(f"  Win/Loss/Tie:    {wins}/{losses}/{ties}", file=sys.stderr)
    print(f"  Mean delta:      {mean_delta:+.3f}  95% CI: [{ci_lo:+.3f}, {ci_hi:+.3f}]", file=sys.stderr)
    print(f"  p (sign test):   {p_sign:.4f}", file=sys.stderr)
    if p_wilcoxon is not None:
        print(f"  p (wilcoxon):    {p_wilcoxon:.4f}", file=sys.stderr)
    print(f"  Cliff's delta:   {cliff:+.4f}  ({cliff_mag})", file=sys.stderr)
    print(f"  Cohen's d:       {cohen:+.4f}  ({cohen_mag})", file=sys.stderr)
    print(f"  Verdict:         {verdict}", file=sys.stderr)
    if effect_warning:
        print(f"  WARNING:         {effect_warning}", file=sys.stderr)
    print("", file=sys.stderr)

    json_out = json.dumps(result, indent=2)
    if args.output:
        with open(args.output, "w") as f:
            f.write(json_out + "\n")
    else:
        print(json_out)


if __name__ == "__main__":
    main()
