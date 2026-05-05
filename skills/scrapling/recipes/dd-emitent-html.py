#!/usr/bin/env python3
"""
DD emitent — stáhne emitent landing/IR page → markdown + extrakt klíčových údajů pro DD.

Output je ready-to-use vstup pro `/dd-emitent` skill nebo `dd-pipeline`.

Usage:
    python dd-emitent-html.py https://emitent.cz/ICO=08688286 > emitent.md
    python dd-emitent-html.py --json https://emitent.cz/ > emitent.json

Output (markdown mode):
    # {Title}
    URL: {url}
    Fetched: {timestamp}

    ## Key contacts
    - Email: ...
    - Phone: ...

    ## Financial signals (auto-extracted)
    - DSCR mentions: [...]
    - LTV mentions: [...]
    - Yield mentions: [...]

    ## Full content (markdown)
    {markdownified body}
"""

import sys
import re
import json
import datetime

sys.path.insert(0, '/Users/filipdopita/.venvs/scrapling/lib/python3.14/site-packages')

from scrapling.fetchers import Fetcher, StealthyFetcher

EMAIL_RE = re.compile(r"[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}")
PHONE_CZ_RE = re.compile(r"(\+420\s?)?\d{3}\s?\d{3}\s?\d{3}")
DSCR_RE = re.compile(r"DSCR[\s:]*\d+[.,]?\d*", re.IGNORECASE)
LTV_RE = re.compile(r"LTV[\s:]*\d+[.,]?\d*\s*%?", re.IGNORECASE)
YIELD_RE = re.compile(r"\d+[.,]?\d*\s*%\s*(p\.?a\.?|ročně|per annum)", re.IGNORECASE)


def fetch(url: str, stealth: bool = False):
    if stealth:
        return StealthyFetcher.fetch(url, headless=True, network_idle=True, timeout=30000)
    return Fetcher.get(url, timeout=20)


def extract(page) -> dict:
    text = page.get_all_text() if hasattr(page, 'get_all_text') else page.body.decode('utf-8', errors='ignore')
    return {
        "title": (page.css('title::text').get() or "").strip(),
        "meta_description": (page.css('meta[name="description"]::attr(content)').get() or "").strip(),
        "h1": [h.text.strip() for h in page.css('h1')],
        "h2": [h.text.strip() for h in page.css('h2')][:20],
        "emails": list(set(EMAIL_RE.findall(text)))[:10],
        "phones_cz": list(set(PHONE_CZ_RE.findall(text)))[:10],
        "dscr_mentions": DSCR_RE.findall(text)[:10],
        "ltv_mentions": LTV_RE.findall(text)[:10],
        "yield_mentions": YIELD_RE.findall(text)[:10],
        "links_external": [a for a in page.css('a::attr(href)').getall() if a and a.startswith('http')][:30],
    }


def to_markdown(url: str, data: dict, body_md: str) -> str:
    lines = [f"# {data['title'] or url}", ""]
    lines.append(f"URL: {url}")
    lines.append(f"Fetched: {datetime.datetime.now().isoformat()}")
    lines.append("")
    if data['meta_description']:
        lines += ["## Meta", data['meta_description'], ""]
    if data['emails'] or data['phones_cz']:
        lines.append("## Key contacts")
        for e in data['emails']:
            lines.append(f"- email: {e}")
        for p in data['phones_cz']:
            lines.append(f"- phone: {p}")
        lines.append("")
    if data['dscr_mentions'] or data['ltv_mentions'] or data['yield_mentions']:
        lines.append("## Financial signals (auto-extract)")
        for m in data['dscr_mentions']:
            lines.append(f"- DSCR: `{m}`")
        for m in data['ltv_mentions']:
            lines.append(f"- LTV: `{m}`")
        for m in data['yield_mentions']:
            lines.append(f"- Yield: `{m}`")
        lines.append("")
    lines += ["## Headings"]
    for h in data['h1']:
        lines.append(f"### H1: {h}")
    for h in data['h2']:
        lines.append(f"- H2: {h}")
    lines += ["", "## Full content (markdown)", "", body_md]
    return "\n".join(lines)


def main():
    args = sys.argv[1:]
    json_mode = "--json" in args
    stealth = "--stealth" in args
    args = [a for a in args if a not in ("--json", "--stealth")]
    if not args:
        print("usage: dd-emitent-html.py [--json] [--stealth] <url>", file=sys.stderr)
        sys.exit(1)
    url = args[0]
    page = fetch(url, stealth=stealth)
    data = extract(page)
    if json_mode:
        print(json.dumps(data, indent=2, ensure_ascii=False))
        return
    # Markdownify body
    try:
        from markdownify import markdownify as md
        body_md = md(page.body.decode('utf-8', errors='ignore'), heading_style='ATX')
    except Exception:
        body_md = "(markdownify failed; raw HTML omitted)"
    print(to_markdown(url, data, body_md))


if __name__ == "__main__":
    main()
