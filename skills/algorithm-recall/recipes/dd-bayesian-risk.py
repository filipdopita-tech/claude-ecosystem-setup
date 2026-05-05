#!/usr/bin/env python3
# === Adapted from TheAlgorithms/Python (MIT License) ===
# Building blocks: Python/maths/monte_carlo.py + Python/machine_learning/{linear,logistic}_regression.py
# Note: TheAlgorithms gaussian_naive_bayes.py.broken — using standalone Bayesian impl.
# Use case: DD risk scoring with confidence intervals — CZ ECSP emitenti.
#
# Usage:
#   python3 dd-bayesian-risk.py --metrics dscr=1.32 ltv_pct=68 revenue_growth=0.18 sector=real_estate
#   python3 dd-bayesian-risk.py --monte-carlo --noi-mean 1500000 --noi-std 200000 --debt-service 1000000

import argparse
import json
import math
import random


# === Naive Bayes risk classifier (standalone, calibrated for OneFlow ECSP) ===
# Trained heuristics from OneFlow expertise/investment.yaml + DD historical incidents.
# Categories: A (low risk), B (medium-low), C (medium), D (medium-high), E (high), F (critical)

PRIORS = {"A": 0.15, "B": 0.25, "C": 0.30, "D": 0.18, "E": 0.08, "F": 0.04}

# P(feature | class) — calibrated from OneFlow DD historical data
LIKELIHOODS = {
    "dscr": {  # Debt Service Coverage Ratio
        "A": lambda x: gaussian_pdf(x, mean=2.0, std=0.4),
        "B": lambda x: gaussian_pdf(x, mean=1.5, std=0.25),
        "C": lambda x: gaussian_pdf(x, mean=1.25, std=0.15),
        "D": lambda x: gaussian_pdf(x, mean=1.05, std=0.10),
        "E": lambda x: gaussian_pdf(x, mean=0.90, std=0.15),
        "F": lambda x: gaussian_pdf(x, mean=0.50, std=0.30),
    },
    "ltv_pct": {  # Loan-to-Value %
        "A": lambda x: gaussian_pdf(x, mean=40, std=10),
        "B": lambda x: gaussian_pdf(x, mean=55, std=10),
        "C": lambda x: gaussian_pdf(x, mean=70, std=8),
        "D": lambda x: gaussian_pdf(x, mean=80, std=6),
        "E": lambda x: gaussian_pdf(x, mean=88, std=5),
        "F": lambda x: gaussian_pdf(x, mean=95, std=10),
    },
    "revenue_growth": {  # YoY revenue change (-0.5 to 1.0)
        "A": lambda x: gaussian_pdf(x, mean=0.30, std=0.15),
        "B": lambda x: gaussian_pdf(x, mean=0.15, std=0.10),
        "C": lambda x: gaussian_pdf(x, mean=0.05, std=0.10),
        "D": lambda x: gaussian_pdf(x, mean=-0.05, std=0.10),
        "E": lambda x: gaussian_pdf(x, mean=-0.20, std=0.15),
        "F": lambda x: gaussian_pdf(x, mean=-0.40, std=0.20),
    },
}

# Sector adjustments (multiplier on prior)
SECTOR_RISK = {
    "real_estate": {"A": 1.1, "B": 1.0, "C": 1.0, "D": 0.95, "E": 0.95, "F": 0.95},
    "manufacturing": {"A": 0.9, "B": 1.0, "C": 1.05, "D": 1.05, "E": 1.05, "F": 1.0},
    "fintech": {"A": 0.8, "B": 0.9, "C": 1.0, "D": 1.1, "E": 1.2, "F": 1.2},
    "energy": {"A": 1.0, "B": 1.0, "C": 1.0, "D": 1.0, "E": 1.0, "F": 1.0},
    "retail": {"A": 0.8, "B": 0.9, "C": 1.05, "D": 1.1, "E": 1.15, "F": 1.15},
    "agriculture": {"A": 0.9, "B": 1.0, "C": 1.05, "D": 1.05, "E": 1.05, "F": 1.0},
    "tech_services": {"A": 1.1, "B": 1.05, "C": 1.0, "D": 0.95, "E": 0.9, "F": 0.85},
}


def gaussian_pdf(x: float, mean: float, std: float) -> float:
    """Standard Gaussian PDF — building block for Naive Bayes."""
    return math.exp(-((x - mean) ** 2) / (2 * std ** 2)) / (std * math.sqrt(2 * math.pi))


def classify_emitent(metrics: dict, sector: str = None) -> dict:
    """Naive Bayes risk classification.
    metrics: {dscr: 1.32, ltv_pct: 68, revenue_growth: 0.15, ...}
    Returns: posterior probabilities + most likely grade + recommendation."""
    posteriors = {}
    sector_adj = SECTOR_RISK.get(sector, {})

    for grade in PRIORS:
        log_prob = math.log(PRIORS[grade])
        if sector and grade in sector_adj:
            log_prob += math.log(sector_adj[grade])
        for feature, value in metrics.items():
            if feature in LIKELIHOODS and value is not None:
                pdf = LIKELIHOODS[feature][grade](float(value))
                if pdf > 0:
                    log_prob += math.log(pdf)
                else:
                    log_prob += -50  # very small but not -inf
        posteriors[grade] = log_prob

    # Normalize (softmax)
    max_log = max(posteriors.values())
    exp_probs = {g: math.exp(lp - max_log) for g, lp in posteriors.items()}
    total = sum(exp_probs.values())
    normalized = {g: round(p / total, 4) for g, p in exp_probs.items()}

    # Most likely grade
    best_grade = max(normalized, key=normalized.get)
    confidence = normalized[best_grade]

    # OneFlow recommendation
    if best_grade in ("A", "B"):
        rec = "INVEST"
    elif best_grade == "C":
        rec = "WATCH"
    else:
        rec = "PASS"

    # Compute expected default probability (E + F grades)
    default_prob = round(normalized.get("E", 0) + normalized.get("F", 0), 4)

    return {
        "grade": best_grade,
        "confidence": confidence,
        "default_probability": default_prob,
        "recommendation": rec,
        "posterior_distribution": normalized,
        "input_metrics": metrics,
        "sector": sector,
    }


# === Monte Carlo simulation for DSCR confidence intervals ===
def monte_carlo_dscr(noi_mean: float, noi_std: float, debt_service: float,
                     n_simulations: int = 10000, seed: int = 42) -> dict:
    """Simulate DSCR distribution given NOI uncertainty.
    Returns: percentiles + probability of DSCR < 1.0 (default risk)."""
    random.seed(seed)
    dscrs = []
    for _ in range(n_simulations):
        sim_noi = random.gauss(noi_mean, noi_std)
        if debt_service > 0:
            dscrs.append(sim_noi / debt_service)

    dscrs.sort()
    n = len(dscrs)

    p5 = dscrs[int(n * 0.05)]
    p25 = dscrs[int(n * 0.25)]
    p50 = dscrs[int(n * 0.50)]
    p75 = dscrs[int(n * 0.75)]
    p95 = dscrs[int(n * 0.95)]

    default_count = sum(1 for d in dscrs if d < 1.0)
    tight_count = sum(1 for d in dscrs if 1.0 <= d < 1.25)

    return {
        "n_simulations": n_simulations,
        "noi_assumption": {"mean": noi_mean, "std": noi_std},
        "debt_service": debt_service,
        "dscr_percentiles": {
            "p5": round(p5, 3),
            "p25": round(p25, 3),
            "p50_median": round(p50, 3),
            "p75": round(p75, 3),
            "p95": round(p95, 3),
        },
        "probability_default_dscr_lt_1": round(default_count / n, 4),
        "probability_tight_dscr_1_to_1_25": round(tight_count / n, 4),
        "interpretation": (
            "DSCR safely above 1.25 in 95% scenarios — INVEST"
            if p5 >= 1.25 else
            "DSCR borderline in worst 5% — WATCH"
            if p5 >= 1.0 else
            "Significant default risk in tail scenarios — PASS or restructure"
        ),
    }


def main():
    p = argparse.ArgumentParser(description="OneFlow DD Bayesian risk scoring")
    p.add_argument("--metrics", nargs="+", help="Key=value pairs (dscr=1.32 ltv_pct=68 revenue_growth=0.15)")
    p.add_argument("--sector", help="Sector: real_estate|manufacturing|fintech|energy|retail|agriculture|tech_services")
    p.add_argument("--monte-carlo", action="store_true", help="Run DSCR Monte Carlo simulation")
    p.add_argument("--noi-mean", type=float, help="NOI mean for MC")
    p.add_argument("--noi-std", type=float, help="NOI std deviation for MC")
    p.add_argument("--debt-service", type=float, help="Annual debt service for MC")
    p.add_argument("--simulations", type=int, default=10000, help="MC simulation count")

    args = p.parse_args()

    if args.monte_carlo:
        if not all([args.noi_mean, args.noi_std, args.debt_service]):
            print("ERROR: --monte-carlo requires --noi-mean, --noi-std, --debt-service", file=__import__("sys").stderr)
            return
        result = monte_carlo_dscr(args.noi_mean, args.noi_std, args.debt_service, args.simulations)
        print(json.dumps(result, indent=2, ensure_ascii=False))
    elif args.metrics:
        metrics = {}
        for m in args.metrics:
            if "=" in m:
                k, v = m.split("=", 1)
                try:
                    metrics[k.strip()] = float(v.strip())
                except ValueError:
                    pass
        result = classify_emitent(metrics, sector=args.sector)
        print(json.dumps(result, indent=2, ensure_ascii=False))
    else:
        p.print_help()


if __name__ == "__main__":
    main()
