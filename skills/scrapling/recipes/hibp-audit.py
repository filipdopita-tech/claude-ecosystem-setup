#!/usr/bin/env python3
"""
HIBP audit — public breach list scrape pro defensive monitoring vlastních domén.

NE per-account check (vyžaduje paid API key $3.50/mo per cost-zero-tolerance.md).
ANO public breach list scrape — HIBP publikuje seznam všech breachů jako public endpoint.

Use case: monthly auto-scan, kdy se objeví breach obsahující @oneflow.cz / @email.cz /
gmail.com domény → Filip dostane ntfy alert s recommendation rotate creds.

Run mode 1: bezhlavé (cron/launchd) — JSON na stdout, exit 0
    ~/.venvs/scrapling/bin/python hibp-audit.py

Run mode 2: filtruj per-domain
    ~/.venvs/scrapling/bin/python hibp-audit.py oneflow.cz email.cz gmail.com

Run mode 3: notify-mode (cron-friendly, ntfy ping pokud nový breach)
    ~/.venvs/scrapling/bin/python hibp-audit.py --notify

Output:
    - stdout JSON: relevant breaches list
    - state file: ~/.claude/logs/hibp-state.json (last seen breach IDs)
    - ntfy ping pokud --notify a najde new breach not in state file
"""

import sys
import os
import json
import datetime
from pathlib import Path

# Scrapling venv specific path
sys.path.insert(0, '/Users/filipdopita/.venvs/scrapling/lib/python3.14/site-packages')

try:
    from scrapling.fetchers import Fetcher
except ImportError:
    print("ERROR: scrapling not in path. Run: ~/.venvs/scrapling/bin/python hibp-audit.py", file=sys.stderr)
    sys.exit(1)

# HIBP public list endpoint (no auth required)
HIBP_BREACHES_URL = "https://haveibeenpwned.com/api/v3/breaches"

# Filip's monitor scope (defaults — overridable via CLI args)
DEFAULT_DOMAINS = [
    "oneflow.cz",
    "email.cz",
    "gmail.com",
    "oneflow-team.cz",
    "helponeflow.cz",
    "of-fund.cz",
    "hala-tower.cz",
    "patricny-park.cz",
    "nebulee.cz",
]

STATE_FILE = Path.home() / ".claude/logs/hibp-state.json"
STATE_FILE.parent.mkdir(parents=True, exist_ok=True)


def fetch_breaches() -> list[dict]:
    """Stáhne public breach list z HIBP. No auth required."""
    page = Fetcher.get(HIBP_BREACHES_URL, timeout=30, headers={
        "User-Agent": "OneFlow-HIBP-Defensive-Monitor",
        "Accept": "application/json",
    })
    if page.status != 200:
        print(f"ERROR: HIBP returned {page.status}", file=sys.stderr)
        return []
    try:
        return json.loads(page.body)
    except (json.JSONDecodeError, AttributeError):
        try:
            return json.loads(str(page))
        except Exception as e:
            print(f"ERROR: failed to parse HIBP response: {e}", file=sys.stderr)
            return []


def filter_relevant(breaches: list[dict], domains: list[str]) -> list[dict]:
    """Filter breaches affecting Filip's domains."""
    relevant = []
    domain_set = {d.lower() for d in domains}
    for breach in breaches:
        breach_domain = breach.get("Domain", "").lower()
        if breach_domain in domain_set:
            relevant.append(breach)
            continue
        # Fallback: partial match (e.g. "subdomain.oneflow.cz")
        for d in domain_set:
            if breach_domain and d in breach_domain:
                relevant.append(breach)
                break
    return relevant


def load_state() -> dict:
    if STATE_FILE.exists():
        try:
            return json.loads(STATE_FILE.read_text())
        except Exception:
            pass
    return {"seen_ids": [], "last_run": None}


def save_state(state: dict):
    state["last_run"] = datetime.datetime.now().isoformat()
    STATE_FILE.write_text(json.dumps(state, indent=2, ensure_ascii=False))


def ntfy_alert(new_breaches: list[dict]):
    """Single ntfy ping pokud --notify a najde new breach."""
    if not new_breaches:
        return
    titles = ", ".join(b.get("Name", "?") for b in new_breaches[:3])
    msg = f"HIBP: {len(new_breaches)} new breach(es) affecting Filip domains: {titles}"
    try:
        import urllib.request
        req = urllib.request.Request(
            "https://ntfy.oneflow.cz/Filip",
            data=msg.encode(),
            headers={
                "Title": "HIBP defensive monitor",
                "Tags": "warning,lock",
                "Priority": "high",
            },
        )
        urllib.request.urlopen(req, timeout=10).read()
    except Exception as e:
        print(f"WARN: ntfy ping failed: {e}", file=sys.stderr)


def main():
    args = sys.argv[1:]
    notify = "--notify" in args
    domains_args = [a for a in args if not a.startswith("--")]
    domains = domains_args if domains_args else DEFAULT_DOMAINS

    print(f"[hibp-audit] fetching HIBP breach list, filter domains: {domains}", file=sys.stderr)
    breaches = fetch_breaches()
    print(f"[hibp-audit] total breaches in HIBP: {len(breaches)}", file=sys.stderr)

    relevant = filter_relevant(breaches, domains)
    print(f"[hibp-audit] relevant for Filip domains: {len(relevant)}", file=sys.stderr)

    state = load_state()
    seen = set(state.get("seen_ids", []))
    new = [b for b in relevant if b.get("Name") not in seen]

    if notify and new:
        ntfy_alert(new)
        print(f"[hibp-audit] ntfy alerted on {len(new)} new breach(es)", file=sys.stderr)

    # Update state with current
    state["seen_ids"] = sorted({b.get("Name") for b in relevant if b.get("Name")})
    save_state(state)

    output = {
        "scanned_at": datetime.datetime.now().isoformat(),
        "domains_monitored": domains,
        "total_breaches_in_hibp": len(breaches),
        "relevant_count": len(relevant),
        "new_since_last_run": len(new),
        "relevant_breaches": [
            {
                "name": b.get("Name"),
                "title": b.get("Title"),
                "domain": b.get("Domain"),
                "breach_date": b.get("BreachDate"),
                "added_date": b.get("AddedDate"),
                "pwn_count": b.get("PwnCount"),
                "data_classes": b.get("DataClasses"),
                "is_verified": b.get("IsVerified"),
                "is_sensitive": b.get("IsSensitive"),
                "description": (b.get("Description") or "")[:200],
            }
            for b in relevant
        ],
    }
    print(json.dumps(output, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()
