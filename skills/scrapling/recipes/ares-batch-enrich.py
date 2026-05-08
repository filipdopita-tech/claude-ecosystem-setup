#!/usr/bin/env python3
"""
ARES batch enrichment via Scrapling.

Usage:
    /Users/filipdopita/.venvs/scrapling/bin/python ares-batch-enrich.py icos.txt > out.jsonl
    echo "08688286" | /Users/filipdopita/.venvs/scrapling/bin/python ares-batch-enrich.py - > out.jsonl

Input: file or stdin with one IČO per line.
Output: JSONL — one record per IČO with ARES data + status.

Concurrency: 10 parallel requests (ARES tolerates this; do NOT raise above 20).
Free, no API key. Replaces hand-rolled requests + retry boilerplate.
"""

import sys
import json
import asyncio
import re
from pathlib import Path

# Ensure venv import works when called via shebang too
sys.path.insert(0, '/Users/filipdopita/.venvs/scrapling/lib/python3.14/site-packages')

from scrapling.fetchers import AsyncFetcher

ARES_URL = "https://ares.gov.cz/ekonomicke-subjekty-v-be/rest/ekonomicke-subjekty/{ico}"
ICO_RE = re.compile(r"^\d{8}$")


def _assemble_address(sidlo: dict) -> str:
    """Assemble single-line address from ARES sidlo components."""
    if not isinstance(sidlo, dict):
        return ""
    ulice = sidlo.get("nazevUlice") or ""
    cd = sidlo.get("cisloDomovni") or ""
    co = sidlo.get("cisloOrientacni") or ""
    cislo = f"{cd}/{co}" if cd and co else (str(cd) or str(co))
    obec = sidlo.get("nazevObce") or ""
    psc = sidlo.get("psc") or ""
    parts = [f"{ulice} {cislo}".strip(), f"{psc} {obec}".strip()]
    return ", ".join([p for p in parts if p])


# ARES právní forma codes (https://www.czso.cz/csu/czso/klasifikace-pravnich-forem)
PRAVNI_FORMA = {
    "100": "Fyzická osoba", "101": "Fyzická osoba podnikající",
    "111": "Veřejná obchodní společnost", "112": "Komanditní společnost",
    "113": "Společnost s ručením omezeným", "121": "Akciová společnost",
    "205": "Družstvo", "301": "Státní podnik", "325": "Organizační složka státu",
    "331": "Příspěvková organizace", "421": "Pobočka zahraniční právnické osoby",
    "601": "Vysoká škola", "701": "Sdružení",
    "706": "Spolek", "751": "Zájmové sdružení právnických osob",
    "801": "Obec", "802": "Kraj", "925": "Politická strana",
}


async def fetch_one(ico: str) -> dict:
    if not ICO_RE.match(ico):
        return {"ico": ico, "status": "INVALID_FORMAT", "error": "expected 8 digits"}
    try:
        page = await AsyncFetcher.get(ARES_URL.format(ico=ico), timeout=15)
        if page.status == 200:
            data = json.loads(page.body)
            pf_code = data.get("pravniForma")
            return {
                "ico": ico,
                "status": "OK",
                "obchodni_jmeno": data.get("obchodniJmeno"),
                "dic": data.get("dic"),
                "sidlo": _assemble_address(data.get("sidlo")),
                "pravni_forma_kod": pf_code,
                "pravni_forma_nazev": PRAVNI_FORMA.get(str(pf_code), f"Code {pf_code}"),
                "datum_vzniku": data.get("datumVzniku"),
                "datum_aktualizace": data.get("datumAktualizace"),
                "raw": data,
            }
        elif page.status == 404:
            return {"ico": ico, "status": "NOT_FOUND"}
        else:
            return {"ico": ico, "status": f"HTTP_{page.status}"}
    except Exception as e:
        return {"ico": ico, "status": "ERROR", "error": f"{type(e).__name__}: {e}"}


async def batch(icos: list[str], concurrency: int = 10):
    sem = asyncio.Semaphore(concurrency)

    async def bound(ico):
        async with sem:
            return await fetch_one(ico)

    return await asyncio.gather(*[bound(ico) for ico in icos])


def main():
    if len(sys.argv) < 2:
        print("usage: ares-batch-enrich.py <file.txt|-> > out.jsonl", file=sys.stderr)
        sys.exit(1)
    src = sys.argv[1]
    raw = sys.stdin.read() if src == "-" else Path(src).read_text()
    icos = [line.strip() for line in raw.splitlines() if line.strip() and not line.startswith("#")]
    print(f"[ares-batch] {len(icos)} IČOs, concurrency=10", file=sys.stderr)
    results = asyncio.run(batch(icos))
    for r in results:
        print(json.dumps(r, ensure_ascii=False))
    ok = sum(1 for r in results if r["status"] == "OK")
    print(f"[ares-batch] OK={ok}/{len(results)}", file=sys.stderr)


if __name__ == "__main__":
    main()
