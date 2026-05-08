#!/usr/bin/env python3
"""Test suite pro recipes/. Spustit: python3 tests.py
Bez externí dependency — jen stdlib + import recipes ve stejné složce.
"""
import importlib.util
import os
import sys
import json
import csv
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))


def load(name: str):
    """Hot-load recipe module from disk (filename can have hyphens)."""
    path = os.path.join(HERE, f"{name}.py")
    spec = importlib.util.spec_from_file_location(name.replace("-", "_"), path)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


# -----------------------------------------------------------------------------
# Test framework (minimal, no pytest dependency)
# -----------------------------------------------------------------------------
PASS = 0
FAIL = 0
FAILURES = []


def assert_eq(actual, expected, msg):
    global PASS, FAIL
    if actual == expected:
        PASS += 1
        print(f"  ✓ {msg}")
    else:
        FAIL += 1
        FAILURES.append(f"{msg}: expected {expected!r}, got {actual!r}")
        print(f"  ✗ {msg}: expected {expected!r}, got {actual!r}")


def assert_close(actual, expected, tol, msg):
    global PASS, FAIL
    if abs(actual - expected) < tol:
        PASS += 1
        print(f"  ✓ {msg} (got {actual:.4f}, expected {expected:.4f} ± {tol})")
    else:
        FAIL += 1
        FAILURES.append(f"{msg}: expected {expected} ± {tol}, got {actual}")
        print(f"  ✗ {msg}: expected {expected} ± {tol}, got {actual}")


def assert_in(needle, haystack, msg):
    global PASS, FAIL
    if needle in haystack:
        PASS += 1
        print(f"  ✓ {msg}")
    else:
        FAIL += 1
        FAILURES.append(f"{msg}: {needle!r} not in {haystack!r}")
        print(f"  ✗ {msg}: {needle!r} not in {haystack!r}")


def assert_true(cond, msg):
    global PASS, FAIL
    if cond:
        PASS += 1
        print(f"  ✓ {msg}")
    else:
        FAIL += 1
        FAILURES.append(msg)
        print(f"  ✗ {msg}")


# -----------------------------------------------------------------------------
# TESTS: dd-financial.py
# -----------------------------------------------------------------------------
def test_dd_financial():
    print("\n=== dd-financial.py ===")
    m = load("dd-financial")

    # NPV: classic textbook example
    npv = m.present_value(0.10, [-1000, 500, 500, 500])
    assert_close(npv, 243.43, 0.5, "NPV @10% [-1000, 500x3]")

    # IRR: should converge near 10% for a known case
    irr = m.irr([-1000, 500, 500, 500])
    assert_close(irr, 0.234, 0.01, "IRR [-1000, 500x3] ~23.4%")

    # EMI formula
    emi_val = m.emi(100000, 0.06, 12)
    assert_close(emi_val, 8606.64, 1.0, "EMI 100k @6% / 12mo")

    # Simple interest
    si = m.simple_interest(1000, 0.05, 2)
    assert_eq(si, 100.0, "Simple interest 1000@5%/2yr = 100")

    # Compound interest
    ci = m.compound_interest(1000, 0.05, 2, 1)
    assert_close(ci, 1102.50, 0.01, "Compound 1000@5%/2yr annually = 1102.50")

    # Depreciation
    dep = m.straight_line_depreciation(100000, 10000, 5)
    assert_eq(dep, 18000.0, "SL deprec (100k - 10k) / 5yr = 18000")

    # SMA
    sma = m.sma([1, 2, 3, 4, 5], 3)
    assert_eq(sma, [2.0, 3.0, 4.0], "SMA window=3 of [1..5]")

    # DSCR
    d = m.dscr(1500000, 800000)
    assert_close(d["dscr"], 1.875, 0.001, "DSCR 1500k/800k")
    assert_eq(d["category"], "healthy", "DSCR healthy category")

    # LTV
    l = m.ltv(5000000, 8000000)
    assert_eq(l["ltv_pct"], 62.5, "LTV 5M/8M = 62.5%")
    assert_eq(l["category"], "standard", "LTV standard cat")

    # Quick screen
    screen = m.emitent_quick_screen({
        "noi": 1500000, "debt_service": 800000,
        "loan": 5000000, "asset_value": 8000000,
        "discount_rate": 0.08,
        "cashflows": [-5000000, 1100000, 1100000, 1100000, 1100000, 1100000],
    })
    assert_in(screen["grade"], "ABCDEF", "Screen returns valid A-F grade")
    assert_in(screen["recommendation"], ("INVEST", "WATCH", "PASS"), "Screen returns valid recommendation")
    assert_true(0 <= screen["score"] <= 9, "Score in range 0-9")


# -----------------------------------------------------------------------------
# TESTS: ares-fuzzy.py
# -----------------------------------------------------------------------------
def test_ares_fuzzy():
    print("\n=== ares-fuzzy.py ===")
    m = load("ares-fuzzy")

    # Levenshtein
    assert_eq(m.levenshtein_distance("kitten", "sitting"), 3, "Lev kitten→sitting = 3")
    assert_eq(m.levenshtein_distance("", ""), 0, "Lev empty = 0")
    assert_eq(m.levenshtein_distance("abc", "abc"), 0, "Lev identical = 0")

    # Damerau-Levenshtein (transposition handling)
    dam = m.damerau_levenshtein_distance("ca", "ac")
    assert_eq(dam, 1, "Damerau ca→ac = 1 (transposition)")

    # Jaro-Winkler
    jw = m.jaro_winkler_similarity("MARTHA", "MARHTA")
    assert_close(jw, 0.961, 0.01, "JW MARTHA~MARHTA")

    # Hamming
    assert_eq(m.hamming_distance("karolin", "kathrin"), 3, "Hamming karolin/kathrin = 3")

    # CZ normalization
    assert_eq(m.normalize_cz_company("ABC Holding s.r.o."), "abc holding", "Strip s.r.o.")
    assert_eq(m.normalize_cz_company("Petr Novák a.s."), "petr novak", "Strip diacritics + a.s.")
    assert_eq(m.normalize_cz_company("ČEZ a. s."), "cez", "Spaced legal form")

    # Fuzzy match
    r = m.fuzzy_match("ABC s.r.o.", "ABC, spol. s r.o.")
    assert_in(r["action"], ("DEDUP", "REVIEW"), "ABC variants should match (DEDUP or REVIEW)")
    assert_true(r["confidence"] > 0.7, "ABC variants confidence > 0.7")

    # Different companies should NOT dedup
    r2 = m.fuzzy_match("ABC s.r.o.", "XYZ a.s.")
    assert_eq(r2["action"], "UNIQUE", "ABC vs XYZ → UNIQUE")


# -----------------------------------------------------------------------------
# TESTS: contact-dedup.py
# -----------------------------------------------------------------------------
def test_contact_dedup():
    print("\n=== contact-dedup.py ===")
    m = load("contact-dedup")

    # Email normalization
    assert_eq(m.normalize_email("Jan.Novak@example.cz"), "jan.novak@example.cz", "Lowercase email")
    assert_eq(m.normalize_email("foo+work@gmail.com"), "foo@gmail.com", "Strip Gmail alias")
    assert_eq(m.normalize_email("john.doe@gmail.com"), "johndoe@gmail.com", "Strip Gmail dots")
    assert_eq(m.normalize_email("foo@googlemail.com"), "foo@gmail.com", "Canonical Gmail domain")

    # SHA-256 stability
    h1 = m.sha256_email("Foo@Example.com")
    h2 = m.sha256_email("foo@example.com")
    assert_eq(h1, h2, "SHA-256 deterministic after normalize")

    # Bloom filter
    bf = m.BloomFilter(expected_items=1000)
    bf.add("test@example.com")
    assert_true("test@example.com" in bf, "Bloom contains added item")
    # The probability is statistical; acceptable false positives
    assert_true(bf.count == 1, "Bloom counter incremented")

    # Typo detection
    assert_true(m.is_likely_typo("jan@x.cz", "jna@x.cz"), "jan→jna is typo")
    assert_true(not m.is_likely_typo("jan@x.cz", "jan@y.cz"), "Different domain ≠ typo")

    # End-to-end on fixture
    fixture = os.path.join(HERE, "fixtures", "sample-leads.csv")
    if os.path.exists(fixture):
        with open(fixture, encoding="utf-8") as f:
            rows = list(csv.DictReader(f))
        result = m.dedup(rows, "email", fuzzy=True)
        assert_true(result["total_input"] > 0, "Fixture loaded > 0 rows")
        assert_true(result["unique_count"] < result["total_input"], "Dedup removed some")
        assert_true(result["exact_duplicates"] >= 1, "Found ≥1 exact duplicate (jan.novak)")


# -----------------------------------------------------------------------------
# TESTS: dd-bayesian-risk.py
# -----------------------------------------------------------------------------
def test_dd_bayesian():
    print("\n=== dd-bayesian-risk.py ===")
    m = load("dd-bayesian-risk")

    # Gaussian PDF
    pdf_at_mean = m.gaussian_pdf(0, 0, 1)
    assert_close(pdf_at_mean, 0.3989, 0.001, "Gaussian PDF(0,0,1) ~0.3989")

    # Healthy emitent → A or B
    healthy = m.classify_emitent({"dscr": 2.0, "ltv_pct": 40, "revenue_growth": 0.30})
    assert_in(healthy["grade"], ("A", "B"), "Healthy → A or B")
    assert_in(healthy["recommendation"], ("INVEST",), "Healthy → INVEST")

    # Distressed → D/E/F
    distressed = m.classify_emitent({"dscr": 0.7, "ltv_pct": 92, "revenue_growth": -0.30})
    assert_in(distressed["grade"], ("D", "E", "F"), "Distressed → D/E/F")
    assert_eq(distressed["recommendation"], "PASS", "Distressed → PASS")

    # Posterior sums to ~1
    total = sum(distressed["posterior_distribution"].values())
    assert_close(total, 1.0, 0.001, "Posterior distribution sums to 1.0")

    # Monte Carlo
    mc = m.monte_carlo_dscr(1500000, 200000, 1000000, n_simulations=2000, seed=42)
    assert_true(mc["dscr_percentiles"]["p50_median"] > 1.4, "MC median DSCR > 1.4")
    assert_true(0 <= mc["probability_default_dscr_lt_1"] <= 1, "MC default prob in [0,1]")
    assert_true(mc["dscr_percentiles"]["p5"] < mc["dscr_percentiles"]["p95"], "P5 < P95")


# -----------------------------------------------------------------------------
# TESTS: scraping-graph.py
# -----------------------------------------------------------------------------
def test_scraping_graph():
    print("\n=== scraping-graph.py ===")
    m = load("scraping-graph")

    # Test graph
    g = {"A": ["B", "C"], "B": ["D"], "C": ["D"], "D": []}

    # BFS
    bfs_r = m.bfs(g, "A", max_depth=3)
    assert_eq(bfs_r["nodes_discovered"], 4, "BFS discovers all 4 nodes")
    assert_eq(bfs_r["order"][0], "A", "BFS starts at A")

    # DFS
    dfs_r = m.dfs(g, "A", max_depth=3)
    assert_eq(dfs_r["nodes_discovered"], 4, "DFS discovers all 4 nodes")

    # Cycle detection — no cycles in this DAG
    cycles = m.detect_cycles(g)
    assert_eq(cycles["has_cycles"], False, "DAG has no cycles")

    # Cycle detection — explicit cycle
    cyclic = {"A": ["B"], "B": ["C"], "C": ["A"]}
    cycle_r = m.detect_cycles(cyclic)
    assert_eq(cycle_r["has_cycles"], True, "A→B→C→A detected as cycle")

    # Connected components
    disconnected = {"A": ["B"], "B": [], "C": ["D"], "D": []}
    comp = m.connected_components(disconnected)
    assert_eq(comp["component_count"], 2, "Two disconnected components")


# -----------------------------------------------------------------------------
# RUN
# -----------------------------------------------------------------------------
def main():
    print("=" * 70)
    print("algorithm-recall recipes — Test Suite")
    print("=" * 70)

    test_dd_financial()
    test_ares_fuzzy()
    test_contact_dedup()
    test_dd_bayesian()
    test_scraping_graph()

    print()
    print("=" * 70)
    print(f"RESULTS: {PASS} PASS, {FAIL} FAIL")
    print("=" * 70)

    if FAIL > 0:
        print("\nFailures:")
        for f in FAILURES:
            print(f"  - {f}")
        sys.exit(1)
    else:
        print("\n✅ All tests pass.")
        sys.exit(0)


if __name__ == "__main__":
    main()
