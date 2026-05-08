#!/usr/bin/env python3
"""
CZ B2B lead-gen scrape — firmy.cz / detail.cz / živnostník.cz public profile.

Usage:
    python lead-gen-cz-b2b.py icos.txt > leads.jsonl
    echo "08688286" | python lead-gen-cz-b2b.py - > leads.jsonl

Strategy:
    1. ARES (free, primary) — viz ares-batch-enrich.py
    2. Firmy.cz public listing — Scrapling Fetcher (TLS impersonation, no login)
    3. Detail.cz fallback — Scrapling Fetcher

Output JSONL: ico, name, website (best-guess), phone, email, sidlo
Combine with Apollo direct (paid) for international enrichment per knowledge-router.

POVINNÉ: respektuj robots.txt + 1.5s delay per domain. Firmy.cz tolerates ~10 req/min unauth.
"""

import sys
import json
import asyncio
import re
import urllib.parse
from pathlib import Path

sys.path.insert(0, '/Users/filipdopita/.venvs/scrapling/lib/python3.14/site-packages')

from scrapling.fetchers import AsyncFetcher

EMAIL_RE = re.compile(r"[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}")
PHONE_CZ_RE = re.compile(r"(?:\+420\s?)?\d{3}\s?\d{3}\s?\d{3}")
WEB_RE = re.compile(r"https?://(?:www\.)?[a-z0-9-]+\.(?:cz|com|eu|net|sk)")

ARES_URL = "https://ares.gov.cz/ekonomicke-subjekty-v-be/rest/ekonomicke-subjekty/{ico}"
FIRMY_SEARCH = "https://www.firmy.cz/?q={query}"


async def ares_basic(ico: str) -> dict | None:
    try:
        page = await AsyncFetcher.get(ARES_URL.format(ico=ico), timeout=10)
        if page.status == 200:
            d = json.loads(page.body)
            return {
                "obchodni_jmeno": d.get("obchodniJmeno"),
                "sidlo": d.get("sidlo", {}).get("textovaAdresa"),
                "dic": d.get("dic"),
            }
    except Exception:
        pass
    return None


async def firmy_lookup(name: str) -> dict:
    """Public firmy.cz listing — best-effort phone/email/web grab."""
    if not name:
        return {}
    q = urllib.parse.quote(name)
    page = await AsyncFetcher.get(FIRMY_SEARCH.format(query=q), timeout=15)
    if page.status != 200:
        return {"firmy_status": page.status}
    text = page.body.decode('utf-8', errors='ignore') if isinstance(page.body, bytes) else page.body
    return {
        "firmy_emails": list(set(EMAIL_RE.findall(text)))[:5],
        "firmy_phones": list(set(PHONE_CZ_RE.findall(text)))[:5],
        "firmy_webs": list(set(WEB_RE.findall(text)))[:5],
    }


async def enrich(ico: str) -> dict:
    rec = {"ico": ico}
    ares = await ares_basic(ico)
    if not ares:
        rec["status"] = "ARES_NOT_FOUND"
        return rec
    rec.update(ares)
    # Polite 1.5s gap before firmy.cz hit
    await asyncio.sleep(1.5)
    firmy = await firmy_lookup(ares["obchodni_jmeno"] or "")
    rec.update(firmy)
    rec["status"] = "OK"
    return rec


async def batch(icos: list[str], concurrency: int = 3):
    """Conservative concurrency=3 for firmy.cz politeness."""
    sem = asyncio.Semaphore(concurrency)

    async def bound(ico):
        async with sem:
            return await enrich(ico)

    return await asyncio.gather(*[bound(ico) for ico in icos])


def main():
    if len(sys.argv) < 2:
        print("usage: lead-gen-cz-b2b.py <file.txt|-> > leads.jsonl", file=sys.stderr)
        sys.exit(1)
    src = sys.argv[1]
    raw = sys.stdin.read() if src == "-" else Path(src).read_text()
    icos = [l.strip() for l in raw.splitlines() if l.strip() and l.strip().isdigit()]
    print(f"[lead-gen-cz] {len(icos)} IČOs, concurrency=3 (firmy.cz polite)", file=sys.stderr)
    results = asyncio.run(batch(icos))
    for r in results:
        print(json.dumps(r, ensure_ascii=False))
    ok = sum(1 for r in results if r.get("status") == "OK")
    print(f"[lead-gen-cz] OK={ok}/{len(results)}", file=sys.stderr)


if __name__ == "__main__":
    main()
