#!/usr/bin/env python3
"""Benchmark suite pro recipes/. Měří per-operation čas + ops/sec.
Spustit: python3 benchmark.py
"""
import importlib.util
import os
import time
import random
import string

HERE = os.path.dirname(os.path.abspath(__file__))


def load(name):
    spec = importlib.util.spec_from_file_location(name.replace("-", "_"), os.path.join(HERE, f"{name}.py"))
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def bench(label, fn, iterations):
    """Time a callable. Print ms/op + ops/sec."""
    start = time.perf_counter()
    for _ in range(iterations):
        fn()
    elapsed = time.perf_counter() - start
    ms_per_op = (elapsed / iterations) * 1000
    ops_per_sec = iterations / elapsed if elapsed > 0 else float("inf")
    print(f"  {label:50s} {ms_per_op:>9.4f} ms/op   {ops_per_sec:>12,.0f} ops/sec   ({iterations:,} iters)")


def random_company(n=15):
    forms = ["s.r.o.", "a.s.", "spol. s r.o.", ""]
    return "".join(random.choices(string.ascii_letters, k=n)) + " " + random.choice(forms)


def random_email():
    user = "".join(random.choices(string.ascii_lowercase, k=8))
    return f"{user}@example.cz"


def main():
    print("=" * 78)
    print("algorithm-recall recipes — Benchmark suite")
    print("=" * 78)
    random.seed(42)

    # ---------- dd-financial ----------
    print("\n## dd-financial.py")
    fin = load("dd-financial")
    cashflows = [-1000000] + [250000] * 10
    bench("present_value (NPV, 11 cashflows)", lambda: fin.present_value(0.08, cashflows), 100_000)
    bench("irr (Newton-Raphson, 11 cashflows)", lambda: fin.irr(cashflows), 10_000)
    bench("emi (EMI formula)", lambda: fin.emi(5000000, 0.06, 60), 100_000)
    bench("amortization_schedule (60 months)", lambda: fin.amortization_schedule(5000000, 0.06, 60), 1_000)
    bench("dscr + ltv combo", lambda: (fin.dscr(1500000, 800000), fin.ltv(5000000, 8000000)), 100_000)
    screen_data = {
        "noi": 1500000, "debt_service": 800000, "loan": 5000000, "asset_value": 8000000,
        "discount_rate": 0.08, "cashflows": cashflows,
    }
    bench("emitent_quick_screen (full A-F grade)", lambda: fin.emitent_quick_screen(screen_data), 10_000)

    # ---------- ares-fuzzy ----------
    print("\n## ares-fuzzy.py")
    af = load("ares-fuzzy")
    pair_short = ("ABC s.r.o.", "ABC, spol. s r.o.")
    pair_long = ("Petr Novák Holdings International a.s.", "Petr Novak Hlds Intl AS")
    bench("levenshtein (short, 6 char)", lambda: af.levenshtein_distance("kitten", "sitting"), 100_000)
    bench("levenshtein (long, 30 char)", lambda: af.levenshtein_distance(pair_long[0], pair_long[1]), 10_000)
    bench("damerau_levenshtein (long)", lambda: af.damerau_levenshtein_distance(pair_long[0], pair_long[1]), 1_000)
    bench("jaro_winkler (long)", lambda: af.jaro_winkler_similarity(pair_long[0], pair_long[1]), 100_000)
    bench("normalize_cz_company (full pipeline)", lambda: af.normalize_cz_company("Petr Novák Holding spol. s r.o."), 10_000)
    bench("fuzzy_match (full ensemble + normalize)", lambda: af.fuzzy_match(*pair_short), 10_000)

    # Batch dedup scaling
    rows_100 = [{"name": random_company()} for _ in range(100)]
    rows_500 = [{"name": random_company()} for _ in range(500)]
    bench("batch_dedup (100 rows)", lambda: af.batch_dedup(rows_100, "name", 0.92), 10)
    bench("batch_dedup (500 rows)", lambda: af.batch_dedup(rows_500, "name", 0.92), 1)

    # ---------- contact-dedup ----------
    print("\n## contact-dedup.py")
    cd = load("contact-dedup")
    bench("normalize_email", lambda: cd.normalize_email("Foo.Bar+work@Gmail.com"), 100_000)
    bench("sha256_email", lambda: cd.sha256_email("test@example.cz"), 100_000)
    bench("levenshtein (typo check)", lambda: cd.levenshtein("jan", "jna"), 100_000)
    bench("is_likely_typo", lambda: cd.is_likely_typo("jan@x.cz", "jna@x.cz"), 100_000)

    # Bloom filter
    bf = cd.BloomFilter(expected_items=10_000)
    test_emails = [random_email() for _ in range(1000)]
    for e in test_emails:
        bf.add(e)
    bench("BloomFilter __contains__ (10k cap)", lambda: ("test@example.cz" in bf), 100_000)
    bench("BloomFilter add (10k cap)", lambda: bf.add(random_email()), 10_000)

    # End-to-end dedup at scale
    leads_1000 = [{"email": random_email() if random.random() > 0.1 else test_emails[0]} for _ in range(1000)]
    bench("dedup 1000 leads (exact only)", lambda: cd.dedup(leads_1000, "email", fuzzy=False), 10)
    bench("dedup 1000 leads (fuzzy mode)", lambda: cd.dedup(leads_1000, "email", fuzzy=True), 1)

    # ---------- dd-bayesian-risk ----------
    print("\n## dd-bayesian-risk.py")
    br = load("dd-bayesian-risk")
    bench("gaussian_pdf", lambda: br.gaussian_pdf(1.5, 1.25, 0.15), 100_000)
    bench("classify_emitent (3 features)", lambda: br.classify_emitent({"dscr": 1.32, "ltv_pct": 68, "revenue_growth": 0.15}, sector="real_estate"), 10_000)
    bench("monte_carlo_dscr (1k sims)", lambda: br.monte_carlo_dscr(1500000, 200000, 1000000, n_simulations=1000, seed=42), 100)
    bench("monte_carlo_dscr (10k sims)", lambda: br.monte_carlo_dscr(1500000, 200000, 1000000, n_simulations=10_000, seed=42), 10)

    # ---------- scraping-graph ----------
    print("\n## scraping-graph.py")
    sg = load("scraping-graph")
    # Synthetic graph: 100 nodes, ~3 edges per node
    nodes = [f"n{i}" for i in range(100)]
    g = {n: random.sample(nodes, 3) for n in nodes}
    bench("bfs (100 nodes, depth 5)", lambda: sg.bfs(g, "n0", max_depth=5), 1_000)
    bench("dfs (100 nodes, depth 5)", lambda: sg.dfs(g, "n0", max_depth=5), 1_000)
    bench("detect_cycles (100 nodes)", lambda: sg.detect_cycles(g), 100)
    bench("connected_components (100 nodes)", lambda: sg.connected_components(g), 1_000)

    print()
    print("=" * 78)
    print("✅ Benchmark complete. Use these baselines for regression detection.")
    print("=" * 78)


if __name__ == "__main__":
    main()
