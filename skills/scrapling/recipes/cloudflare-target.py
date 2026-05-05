#!/usr/bin/env python3
"""
Single-URL Cloudflare bypass.

Pro stránky chráněné Cloudflare Turnstile (justice.cz advanced search,
některé fintech sites, AML registry portály).

Usage:
    python cloudflare-target.py https://justice.cz/...
    python cloudflare-target.py --selector '.results' https://protected.cz/

Output: stdout = full HTML (or only selector match if --selector).
Browser overhead ~25-40s per URL — pro batch scrape použij bulk_stealthy_fetch.
"""

import sys
import argparse

sys.path.insert(0, '/Users/filipdopita/.venvs/scrapling/lib/python3.14/site-packages')

from scrapling.fetchers import StealthyFetcher


def main():
    p = argparse.ArgumentParser()
    p.add_argument("url")
    p.add_argument("--selector", help="CSS selector — output only matched HTML")
    p.add_argument("--text", action="store_true", help="Output text only (strip HTML)")
    p.add_argument("--screenshot", help="Save PNG screenshot to path")
    p.add_argument("--no-cf-solve", action="store_true", help="Skip Cloudflare solve")
    p.add_argument("--timeout", type=int, default=45, help="Timeout seconds")
    args = p.parse_args()

    page = StealthyFetcher.fetch(
        args.url,
        headless=True,
        network_idle=True,
        solve_cloudflare=not args.no_cf_solve,
        timeout=args.timeout * 1000,
    )

    print(f"[stealth] HTTP {page.status}, body {len(page.body)} bytes", file=sys.stderr)

    if args.screenshot:
        # StealthyFetcher returns Response; screenshot needs DynamicFetcher session
        # Documented limitation — use mcp__scrapling__screenshot instead
        print(f"[stealth] screenshot via Python is session-bound; use MCP `screenshot` tool", file=sys.stderr)

    if args.selector:
        elems = page.css(args.selector)
        for e in elems:
            print(e.html_content if hasattr(e, 'html_content') else str(e))
    elif args.text:
        text = page.get_all_text() if hasattr(page, 'get_all_text') else page.body.decode('utf-8', errors='ignore')
        print(text)
    else:
        sys.stdout.buffer.write(page.body if isinstance(page.body, bytes) else page.body.encode())


if __name__ == "__main__":
    main()
