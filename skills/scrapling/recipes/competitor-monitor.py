#!/usr/bin/env python3
"""
Competitor landing page daily monitor.

Snapshot konkurenční landing → diff proti včerejšímu → flagne změnu copy/CTA/pricing.

Usage:
    python competitor-monitor.py https://upvest.cz/ https://fingood.cz/ https://investika.cz/

Output:
    ~/Desktop/Codex/scrapling-runs/competitors/{domain}/YYYY-MM-DD.html  (raw)
    ~/Desktop/Codex/scrapling-runs/competitors/{domain}/YYYY-MM-DD.json  (parsed)
    ~/Desktop/Codex/scrapling-runs/competitors/{domain}/diff-YYYY-MM-DD.txt (vs yesterday)

Použij Filip's StealthyFetcher kvůli Cloudflare na některých CZ fintech.
"""

import sys
import json
import os
import datetime
import difflib
from pathlib import Path
from urllib.parse import urlparse

sys.path.insert(0, '/Users/filipdopita/.venvs/scrapling/lib/python3.14/site-packages')

from scrapling.fetchers import StealthyFetcher

OUT_BASE = Path.home() / "Desktop/Codex/scrapling-runs/competitors"
TODAY = datetime.date.today().isoformat()


def domain_of(url: str) -> str:
    return urlparse(url).netloc.replace("www.", "")


def snapshot(url: str) -> dict:
    """Fetch + extract key elements (hero, CTA, pricing, social proof)."""
    page = StealthyFetcher.fetch(url, headless=True, network_idle=True, timeout=30000)
    return {
        "url": url,
        "status": page.status,
        "fetched_at": datetime.datetime.now().isoformat(),
        "title": (page.css('title::text').get() or "").strip(),
        "meta_description": (page.css('meta[name="description"]::attr(content)').get() or "").strip(),
        "h1": [h.text.strip() for h in page.css('h1')],
        "h2": [h.text.strip() for h in page.css('h2')][:10],
        "ctas": [a.text.strip() for a in page.css('a.btn, button, a[class*="cta"]')][:15],
        "prices": [t.strip() for t in page.css('*::text').re(r'\d+[\s,]*(?:Kč|%|p\.a\.)')][:20],
        "html_length": len(page.body),
    }


def save_and_diff(url: str):
    domain = domain_of(url)
    out_dir = OUT_BASE / domain
    out_dir.mkdir(parents=True, exist_ok=True)

    snap = snapshot(url)
    snap_path = out_dir / f"{TODAY}.json"
    snap_path.write_text(json.dumps(snap, indent=2, ensure_ascii=False))

    # Diff vs latest previous snapshot
    prevs = sorted([p for p in out_dir.glob("*.json") if p.stem != TODAY])
    if prevs:
        prev = json.loads(prevs[-1].read_text())
        keys = ['title', 'meta_description', 'h1', 'h2', 'ctas', 'prices']
        diff_lines = []
        for k in keys:
            old = json.dumps(prev.get(k, []), ensure_ascii=False, indent=2)
            new = json.dumps(snap.get(k, []), ensure_ascii=False, indent=2)
            if old != new:
                diff_lines.append(f"=== {k} CHANGED ===")
                diff_lines.extend(difflib.unified_diff(
                    old.splitlines(), new.splitlines(),
                    fromfile=f"prev/{k}", tofile=f"today/{k}", lineterm=""
                ))
        if diff_lines:
            (out_dir / f"diff-{TODAY}.txt").write_text("\n".join(diff_lines))
            print(f"[{domain}] CHANGED — see diff-{TODAY}.txt")
        else:
            print(f"[{domain}] no changes")
    else:
        print(f"[{domain}] first snapshot")


def main():
    if len(sys.argv) < 2:
        print("usage: competitor-monitor.py <url> [<url> ...]", file=sys.stderr)
        sys.exit(1)
    for url in sys.argv[1:]:
        try:
            save_and_diff(url)
        except Exception as e:
            print(f"[{url}] ERROR: {type(e).__name__}: {e}", file=sys.stderr)


if __name__ == "__main__":
    main()
