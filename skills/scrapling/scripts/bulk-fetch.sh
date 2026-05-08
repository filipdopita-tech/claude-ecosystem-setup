#!/usr/bin/env bash
# bulk-fetch.sh — async batch GET; stdin or file list
# Usage:
#   bulk-fetch.sh urls.txt > out.jsonl
#   echo "https://a.cz" | bulk-fetch.sh - > out.jsonl
set -euo pipefail

SRC="${1:?usage: bulk-fetch.sh <file|->}"
VENV="/Users/filipdopita/.venvs/scrapling"

if [ "$SRC" = "-" ]; then
    URLS=$(cat -)
else
    URLS=$(cat "$SRC")
fi

echo "$URLS" | "$VENV/bin/python" - <<'PY'
import sys, json, asyncio
from scrapling.fetchers import AsyncFetcher

urls = [line.strip() for line in sys.stdin.read().splitlines() if line.strip() and not line.startswith("#")]
print(f"[bulk-fetch] {len(urls)} URLs, concurrency=10", file=sys.stderr)

async def one(url):
    try:
        page = await AsyncFetcher.get(url, timeout=20)
        return {
            "url": url, "status": page.status, "bytes": len(page.body),
            "title": (page.css('title::text').get() or "").strip()[:200],
        }
    except Exception as e:
        return {"url": url, "status": "ERROR", "error": f"{type(e).__name__}: {e}"}

async def batch():
    sem = asyncio.Semaphore(10)
    async def bound(u):
        async with sem:
            return await one(u)
    return await asyncio.gather(*[bound(u) for u in urls])

results = asyncio.run(batch())
for r in results:
    print(json.dumps(r, ensure_ascii=False))
ok = sum(1 for r in results if isinstance(r['status'], int) and r['status'] == 200)
print(f"[bulk-fetch] OK={ok}/{len(results)}", file=sys.stderr)
PY
