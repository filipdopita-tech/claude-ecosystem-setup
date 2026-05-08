#!/usr/bin/env bash
# stealth-fetch.sh — StealthyFetcher with Cloudflare bypass
# Usage: stealth-fetch.sh <url> [--no-cf-solve] [--text|--json]
set -euo pipefail

URL="${1:?usage: stealth-fetch.sh <url> [--no-cf-solve] [--text|--json]}"
shift
ARGS="$*"
VENV="/Users/filipdopita/.venvs/scrapling"
OUT_DIR="$HOME/Desktop/Codex/scrapling-runs"
mkdir -p "$OUT_DIR"
TS=$(date +%Y%m%d-%H%M%S)
SAFE_NAME=$(echo "$URL" | sed 's#https\?://##;s#/#_#g;s#[^a-zA-Z0-9._-]#_#g' | head -c 80)
OUT_FILE="$OUT_DIR/${TS}_stealth_${SAFE_NAME}.html"

"$VENV/bin/python" - "$URL" "$ARGS" "$OUT_FILE" <<'PY'
import sys, json, time
from scrapling.fetchers import StealthyFetcher
url, args, out = sys.argv[1], sys.argv[2], sys.argv[3]
solve_cf = "--no-cf-solve" not in args
t0 = time.time()
page = StealthyFetcher.fetch(url, headless=True, network_idle=True,
                              solve_cloudflare=solve_cf, timeout=45000)
el = time.time() - t0
print(f"[stealth-fetch] HTTP {page.status} | {el:.2f}s | {len(page.body)} bytes | cf_solve={solve_cf} -> {out}", file=sys.stderr)
body = page.body if isinstance(page.body, bytes) else page.body.encode()
with open(out, "wb") as f:
    f.write(body)
if "--text" in args:
    text = page.get_all_text() if hasattr(page, 'get_all_text') else body.decode('utf-8', errors='ignore')
    print(text)
elif "--json" in args:
    print(json.dumps({
        "url": url, "status": page.status, "elapsed_s": round(el, 3),
        "cf_solved": solve_cf,
        "title": (page.css('title::text').get() or "").strip(),
        "h1": [h.text.strip() for h in page.css('h1')][:5],
        "saved_to": out,
    }, ensure_ascii=False, indent=2))
else:
    sys.stdout.buffer.write(body)
PY
