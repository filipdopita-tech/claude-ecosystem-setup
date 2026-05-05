#!/usr/bin/env python3
# === Adapted from TheAlgorithms/Python (MIT License) ===
# Building blocks: Python/financial/{present_value, interest, equated_monthly_installments,
#                  straight_line_depreciation, simple_moving_average, exponential_moving_average}.py
# Combined into a single OneFlow DD financial toolkit.
#
# Usage:
#   python3 dd-financial.py --npv --discount 0.08 --cashflows -1000000 250000 250000 250000 250000 250000
#   python3 dd-financial.py --irr --cashflows -1000000 250000 250000 250000 250000 250000
#   python3 dd-financial.py --amortization --principal 5000000 --rate 0.06 --months 60
#   python3 dd-financial.py --interest --type compound --p 100000 --r 0.05 --t 5
#   python3 dd-financial.py --depreciation --cost 500000 --salvage 50000 --life 5
#   python3 dd-financial.py --ema --window 20 --data 100 102 105 103 108 110 115
#   python3 dd-financial.py --dscr --noi 1500000 --debt-service 800000
#   python3 dd-financial.py --ltv --loan 5000000 --value 8000000

import argparse
import sys
import json


def present_value(discount_rate: float, cash_flows: list[float]) -> float:
    """NPV = sum(cf_t / (1+r)^t) — t starts at 0."""
    if discount_rate < 0:
        raise ValueError("Discount rate cannot be negative")
    if not cash_flows:
        raise ValueError("Cash flows list cannot be empty")
    return round(sum(cf / (1 + discount_rate) ** i for i, cf in enumerate(cash_flows)), 2)


def irr(cash_flows: list[float], guess: float = 0.1, tol: float = 1e-6, max_iter: int = 200) -> float:
    """IRR via Newton-Raphson on present_value(rate, cashflows) = 0.
    No standalone IRR in TheAlgorithms — built on present_value building block."""
    rate = guess
    for _ in range(max_iter):
        npv = sum(cf / (1 + rate) ** i for i, cf in enumerate(cash_flows))
        d_npv = sum(-i * cf / (1 + rate) ** (i + 1) for i, cf in enumerate(cash_flows))
        if abs(d_npv) < 1e-12:
            break
        new_rate = rate - npv / d_npv
        if abs(new_rate - rate) < tol:
            return round(new_rate, 6)
        rate = new_rate
    return round(rate, 6)


def emi(principal: float, annual_rate: float, months: int) -> float:
    """Equated Monthly Installment formula."""
    if principal <= 0 or months <= 0:
        raise ValueError("principal and months must be positive")
    if annual_rate == 0:
        return round(principal / months, 2)
    r = annual_rate / 12
    return round(principal * r * (1 + r) ** months / ((1 + r) ** months - 1), 2)


def amortization_schedule(principal: float, annual_rate: float, months: int) -> list[dict]:
    """Full amortization table — month, payment, principal, interest, balance."""
    monthly_payment = emi(principal, annual_rate, months)
    r = annual_rate / 12
    balance = principal
    schedule = []
    for m in range(1, months + 1):
        interest_part = round(balance * r, 2)
        principal_part = round(monthly_payment - interest_part, 2)
        balance = round(balance - principal_part, 2)
        schedule.append({
            "month": m,
            "payment": monthly_payment,
            "principal": principal_part,
            "interest": interest_part,
            "balance": max(balance, 0.0),
        })
    return schedule


def simple_interest(principal: float, rate: float, time_years: float) -> float:
    return round(principal * rate * time_years, 2)


def compound_interest(principal: float, rate: float, time_years: float, n_compounds_per_year: int = 1) -> float:
    """A = P(1 + r/n)^(nt) — returns total amount, subtract P for interest only."""
    return round(principal * (1 + rate / n_compounds_per_year) ** (n_compounds_per_year * time_years), 2)


def straight_line_depreciation(cost: float, salvage: float, useful_life_years: int) -> float:
    """Annual depreciation = (Cost − Salvage) / Useful Life."""
    if useful_life_years <= 0:
        raise ValueError("useful_life_years must be > 0")
    return round((cost - salvage) / useful_life_years, 2)


def sma(data: list[float], window: int) -> list[float]:
    """Simple Moving Average — useful for yield/price trend smoothing."""
    if window > len(data):
        raise ValueError("window cannot exceed data length")
    return [round(sum(data[i:i + window]) / window, 4) for i in range(len(data) - window + 1)]


def ema(data: list[float], window: int) -> list[float]:
    """Exponential Moving Average — recent values weighted more heavily."""
    if window > len(data):
        raise ValueError("window cannot exceed data length")
    alpha = 2 / (window + 1)
    result = [data[0]]
    for x in data[1:]:
        result.append(round(alpha * x + (1 - alpha) * result[-1], 4))
    return result


# === OneFlow DD-specific metrics (built on top of financial primitives) ===

def dscr(noi: float, debt_service: float) -> dict:
    """Debt Service Coverage Ratio — primary credit metric for ECSP emitenti.
    DSCR > 1.25 = healthy, 1.0–1.25 = tight, <1.0 = default risk."""
    if debt_service <= 0:
        return {"dscr": float("inf"), "category": "no_debt", "ok": True}
    ratio = round(noi / debt_service, 3)
    if ratio >= 1.25:
        cat = "healthy"
    elif ratio >= 1.0:
        cat = "tight"
    else:
        cat = "default_risk"
    return {"dscr": ratio, "category": cat, "ok": ratio >= 1.25, "noi": noi, "debt_service": debt_service}


def ltv(loan_amount: float, asset_value: float) -> dict:
    """Loan-to-Value Ratio — collateral metric for asset-backed emitenti.
    LTV < 60% = conservative, 60–80% = standard, >80% = aggressive."""
    if asset_value <= 0:
        raise ValueError("asset_value must be > 0")
    ratio = round(loan_amount / asset_value, 3)
    pct = round(ratio * 100, 1)
    if pct < 60:
        cat = "conservative"
    elif pct < 80:
        cat = "standard"
    else:
        cat = "aggressive"
    return {"ltv": ratio, "ltv_pct": pct, "category": cat, "ok": pct < 80, "loan": loan_amount, "value": asset_value}


def emitent_quick_screen(emi_data: dict) -> dict:
    """Combined DD quick-screen — DSCR + LTV + NPV signal.
    emi_data: {noi, debt_service, loan, asset_value, discount_rate, cashflows}
    Returns A-F grade per OneFlow DD rubric."""
    dscr_r = dscr(emi_data["noi"], emi_data["debt_service"])
    ltv_r = ltv(emi_data["loan"], emi_data["asset_value"])
    npv = present_value(emi_data.get("discount_rate", 0.08), emi_data.get("cashflows", []))

    score = 0
    if dscr_r["dscr"] >= 1.5: score += 3
    elif dscr_r["dscr"] >= 1.25: score += 2
    elif dscr_r["dscr"] >= 1.0: score += 1
    if ltv_r["ltv_pct"] < 50: score += 3
    elif ltv_r["ltv_pct"] < 70: score += 2
    elif ltv_r["ltv_pct"] < 80: score += 1
    if npv > 0: score += 2
    if npv > emi_data.get("loan", 0) * 0.2: score += 1

    grade_map = {9: "A", 8: "A", 7: "B", 6: "B", 5: "C", 4: "C", 3: "D", 2: "D", 1: "E", 0: "F"}
    grade = grade_map.get(score, "F")

    return {
        "grade": grade,
        "score": score,
        "max_score": 9,
        "dscr": dscr_r,
        "ltv": ltv_r,
        "npv": npv,
        "recommendation": "INVEST" if grade in ("A", "B") else ("WATCH" if grade == "C" else "PASS"),
    }


def main():
    p = argparse.ArgumentParser(description="OneFlow DD financial toolkit")
    p.add_argument("--npv", action="store_true")
    p.add_argument("--irr", action="store_true")
    p.add_argument("--amortization", action="store_true")
    p.add_argument("--interest", action="store_true")
    p.add_argument("--depreciation", action="store_true")
    p.add_argument("--sma", action="store_true")
    p.add_argument("--ema", action="store_true")
    p.add_argument("--dscr", action="store_true")
    p.add_argument("--ltv", action="store_true")
    p.add_argument("--screen", action="store_true", help="Full emitent quick-screen (needs --json with all params)")

    p.add_argument("--discount", type=float, default=0.08)
    p.add_argument("--cashflows", nargs="+", type=float)
    p.add_argument("--principal", type=float)
    p.add_argument("--rate", type=float)
    p.add_argument("--months", type=int)
    p.add_argument("--type", choices=["simple", "compound"])
    p.add_argument("--p", type=float)
    p.add_argument("--r", type=float)
    p.add_argument("--t", type=float)
    p.add_argument("--n", type=int, default=1)
    p.add_argument("--cost", type=float)
    p.add_argument("--salvage", type=float)
    p.add_argument("--life", type=int)
    p.add_argument("--window", type=int)
    p.add_argument("--data", nargs="+", type=float)
    p.add_argument("--noi", type=float)
    p.add_argument("--debt-service", type=float, dest="debt_service")
    p.add_argument("--loan", type=float)
    p.add_argument("--value", type=float)
    p.add_argument("--json", type=str, help="JSON file with screen params")

    args = p.parse_args()

    if args.npv:
        print(json.dumps({"npv": present_value(args.discount, args.cashflows)}, indent=2))
    elif args.irr:
        print(json.dumps({"irr": irr(args.cashflows), "irr_pct": round(irr(args.cashflows) * 100, 2)}, indent=2))
    elif args.amortization:
        sched = amortization_schedule(args.principal, args.rate, args.months)
        print(json.dumps({"emi": sched[0]["payment"], "total_interest": round(sum(s["interest"] for s in sched), 2),
                          "schedule": sched[:6] + (["..."] if len(sched) > 6 else []) + [sched[-1]]}, indent=2))
    elif args.interest:
        if args.type == "simple":
            print(json.dumps({"simple_interest": simple_interest(args.p, args.r, args.t)}, indent=2))
        else:
            total = compound_interest(args.p, args.r, args.t, args.n)
            print(json.dumps({"total_amount": total, "interest_only": round(total - args.p, 2)}, indent=2))
    elif args.depreciation:
        print(json.dumps({"annual_depreciation": straight_line_depreciation(args.cost, args.salvage, args.life)}, indent=2))
    elif args.sma:
        print(json.dumps({"sma": sma(args.data, args.window)}, indent=2))
    elif args.ema:
        print(json.dumps({"ema": ema(args.data, args.window)}, indent=2))
    elif args.dscr:
        print(json.dumps(dscr(args.noi, args.debt_service), indent=2))
    elif args.ltv:
        print(json.dumps(ltv(args.loan, args.value), indent=2))
    elif args.screen:
        if args.json:
            with open(args.json) as f:
                data = json.load(f)
        else:
            data = {
                "noi": args.noi or 0,
                "debt_service": args.debt_service or 0,
                "loan": args.loan or 0,
                "asset_value": args.value or 1,
                "discount_rate": args.discount,
                "cashflows": args.cashflows or [],
            }
        print(json.dumps(emitent_quick_screen(data), indent=2, ensure_ascii=False))
    else:
        p.print_help()
        sys.exit(1)


if __name__ == "__main__":
    main()
