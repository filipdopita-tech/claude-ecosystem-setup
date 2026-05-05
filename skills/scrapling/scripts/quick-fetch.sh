#!/usr/bin/env bash
# quick-fetch.sh — Fetcher.get wrapper, stdout=body, stderr=metadata
# Usage: quick-fetch.sh <url> [--text|--json]
set -euo pipefail

URL="${1:?usage: quick-fetch.sh <url> [--text|--json]}"
MODE="${2:---html}"
VENV="/Users/filipdopita/.venvs/scrapling"
OUT_DIR="$HOME/Desktop/Codex/scrapling-runs"
mkdir -p "$OUT_DIR"
TS=$(date +%Y%m%d-%H%M%S)
SAFE_NAME=$(echo "$URL" | sed 's#https\?://##;s#/#_#g;s#[^a-zA-Z0-9._-]#_#g' | head -c 80)
OUT_FILE="$OUT_DIR/${TS}_${SAFE_NAME}.html"

"$VENV/bin/python" - "$URL" "$MODE" "$OUT_FILE" <<'PY'
import sys, json, time
from scrapling.fetchers import Fetcher
url, mode, out = sys.argv[1], sys.argv[2], sys.argv[3]
t0 = time.time()
page = Fetcher.get(url, timeout=20)
el = time.time() - t0
print(f"[quick-fetch] HTTP {page.status} | {el:.2f}s | {len(page.body)} bytes -> {out}", file=sys.stderr)
body = page.body if isinstance(page.body, bytes) else page.body.encode()
with open(out, "wb") as f:
    f.write(body)
if mode == "--text":
    text = page.get_all_text() if hasattr(page, 'get_all_text') else body.decode('utf-8', errors='ignore')
    print(text)
elif mode == "--json":
    print(json.dumps({
        "url": url, "status": page.status, "elapsed_s": round(el, 3),
        "title": (page.css('title::text').get() or "").strip(),
        "meta_description": (page.css('meta[name="description"]::attr(content)').get() or "").strip(),
        "h1": [h.text.strip() for h in page.css('h1')][:5],
        "saved_to": out,
    }, ensure_ascii=False, indent=2))
else:
    sys.stdout.buffer.write(body)
PY
