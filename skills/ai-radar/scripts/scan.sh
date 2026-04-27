#!/bin/bash
# ai-radar scan helper — volitelný one-shot sken 8 zdrojů paralelně
# Použití: bash ~/.claude/skills/ai-radar/scripts/scan.sh [days=7]
# Výstup: JSON array do stdout; jednotlivé zdroje do ~/.claude/ai-radar/cache/

set -euo pipefail
DAYS="${1:-7}"
# F-006: SINCE_ISO dropped (unused)
SINCE_DATE=$(date -v-${DAYS}d +%Y-%m-%d 2>/dev/null || date -d "-${DAYS} days" +%Y-%m-%d)
CACHE="$HOME/.claude/ai-radar/cache"
LATEST="$HOME/.claude/ai-radar/cache/latest"   # F-011: shared "latest" dir pro cache re-use
RUN_ID=$(date +%Y-%m-%d-%H%M)
mkdir -p "$CACHE" "$LATEST"

# Verify dependencies
command -v gh >/dev/null || { echo "gh CLI missing" >&2; exit 1; }
command -v curl >/dev/null || { echo "curl missing" >&2; exit 1; }
command -v jq >/dev/null || { echo "jq missing" >&2; exit 1; }

# F-017: gh auth preflight (warn, not fatal — skill může běžet s partial sources)
GH_OK=1
if ! gh auth status -h github.com 2>&1 | grep -q "Logged in"; then
  echo "[ai-radar] WARN: gh NOT authenticated — GitHub sources (trending, releases, MCP) budou empty. Run: gh auth login" >&2
  GH_OK=0
fi

UA="ai-radar/1.0 (Filip Dopita OneFlow; contact filipdopit@gmail.com)"
CACHE_TTL=3600   # F-011: 1h TTL (rychlý skip redundantních fetches ve stejný den)

# F-011: helper — mtime-based cache. Pokud latest file < CACHE_TTL, cp místo curl.
# $1=url, $2=run_id_dest, $3=latest_name (shared cache key)
fetch_with_cache() {
  local url="$1" dest="$2" latest_file="$LATEST/$3"
  if [ -f "$latest_file" ]; then
    local age=$(( $(date +%s) - $(stat -f %m "$latest_file" 2>/dev/null || stat -c %Y "$latest_file" 2>/dev/null || echo 0) ))
    if [ "$age" -lt "$CACHE_TTL" ] && [ -s "$latest_file" ]; then
      cp "$latest_file" "$dest"
      echo "[cache hit ${age}s] $(basename "$dest")" >&2
      return 0
    fi
  fi
  if curl -sL -A "$UA" --max-time 15 "$url" -o "$dest" 2>/dev/null && [ -s "$dest" ]; then
    cp "$dest" "$latest_file" 2>/dev/null || true
  else
    # Fetch selhal — fallback na poslední známý cache (stale-but-usable) nebo empty
    if [ -f "$latest_file" ]; then
      cp "$latest_file" "$dest"
      echo "[cache stale-fallback] $(basename "$dest")" >&2
    else
      echo "" > "$dest"
    fi
  fi
}

# 1. Anthropic release notes (Claude Code CHANGELOG — docs.claude.com redirects to GitHub)
fetch_anthropic() {
  # GitHub raw = zdroj pravdy (ověřeno curl -L 2026-04-21: docs.claude.com/en/release-notes/claude-code → github.com/anthropics/claude-code/CHANGELOG.md)
  fetch_with_cache "https://raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md" "$CACHE/${RUN_ID}-01-cc-changelog.md" "01-cc-changelog.md"
  # API release notes: best source = Anthropic docs sitemap (public)
  fetch_with_cache "https://docs.anthropic.com/en/release-notes/api" "$CACHE/${RUN_ID}-01-api-notes.html" "01-api-notes.html"
}

# 2. Claude Code releases
fetch_claude_code_releases() {
  gh api repos/anthropics/claude-code/releases --jq '.[0:5] | map({title: .name, url: .html_url, date: .published_at, body: .body, source: "claude-code-releases"})' > "$CACHE/${RUN_ID}-02-cc-releases.json" 2>/dev/null || echo "[]" > "$CACHE/${RUN_ID}-02-cc-releases.json"
}

# 3. OpenAI blog RSS (200 OK direct, cached)
fetch_openai() {
  fetch_with_cache "https://openai.com/news/rss.xml" "$CACHE/${RUN_ID}-03-openai.xml" "03-openai.xml"
}

# 4. Google AI blog RSS (redirectuje na /innovation-and-ai/technology/ai/rss/ — follow, cached)
fetch_google_ai() {
  fetch_with_cache "https://blog.google/technology/ai/rss/" "$CACHE/${RUN_ID}-04-google-ai.xml" "04-google-ai.xml"
}

# 5. GitHub trending (AI/LLM/agents)
fetch_github_trending() {
  gh api -X GET search/repositories \
    -f q="topic:llm created:>${SINCE_DATE} stars:>50" \
    -f sort=stars -f order=desc -f per_page=20 \
    --jq '.items | map({title: .full_name, url: .html_url, stars: .stargazers_count, desc: .description, created: .created_at, source: "github-trending-llm"})' > "$CACHE/${RUN_ID}-05a-gh-llm.json" 2>/dev/null || echo "[]" > "$CACHE/${RUN_ID}-05a-gh-llm.json"

  gh api -X GET search/repositories \
    -f q="topic:ai-agents created:>${SINCE_DATE} stars:>30" \
    -f sort=stars -f order=desc -f per_page=20 \
    --jq '.items | map({title: .full_name, url: .html_url, stars: .stargazers_count, desc: .description, created: .created_at, source: "github-trending-agents"})' > "$CACHE/${RUN_ID}-05b-gh-agents.json" 2>/dev/null || echo "[]" > "$CACHE/${RUN_ID}-05b-gh-agents.json"
}

# 6. Hacker News (Algolia, last 7 days, AI filter)
fetch_hn() {
  SINCE_EPOCH=$(date -v-${DAYS}d +%s 2>/dev/null || date -d "-${DAYS} days" +%s)
  curl -sL -A "$UA" --max-time 15 "https://hn.algolia.com/api/v1/search?tags=front_page&query=AI&numericFilters=created_at_i>${SINCE_EPOCH}&hitsPerPage=30" \
    | jq '.hits | map({title: .title, url: .url, hn_url: ("https://news.ycombinator.com/item?id=" + .objectID), points: .points, comments: .num_comments, date: .created_at, source: "hn"})' > "$CACHE/${RUN_ID}-06-hn.json" 2>/dev/null || echo "[]" > "$CACHE/${RUN_ID}-06-hn.json"
}

# 7. Reddit — Claude/LLM komunity (multi-subreddit)
fetch_reddit() {
  curl -sL -A "$UA" --max-time 15 "https://www.reddit.com/r/ClaudeAI+LocalLLaMA+ChatGPTCoding/top.json?t=week&limit=30" \
    | jq '.data.children | map({title: .data.title, url: ("https://reddit.com" + .data.permalink), external_url: .data.url, subreddit: .data.subreddit, score: .data.score, comments: .data.num_comments, source: "reddit"})' > "$CACHE/${RUN_ID}-07-reddit.json" 2>/dev/null || echo "[]" > "$CACHE/${RUN_ID}-07-reddit.json"
}

# 8. MCP registry (nové MCP servery)
fetch_mcp() {
  gh api -X GET search/repositories \
    -f q="topic:mcp created:>${SINCE_DATE}" \
    -f sort=stars -f order=desc -f per_page=15 \
    --jq '.items | map({title: .full_name, url: .html_url, stars: .stargazers_count, desc: .description, created: .created_at, source: "mcp-new"})' > "$CACHE/${RUN_ID}-08-mcp.json" 2>/dev/null || echo "[]" > "$CACHE/${RUN_ID}-08-mcp.json"
}

# Fire all in parallel
echo "[ai-radar] Scanning 8 sources for last ${DAYS} days (since ${SINCE_DATE})..." >&2
fetch_anthropic &
fetch_claude_code_releases &
fetch_openai &
fetch_google_ai &
fetch_github_trending &
fetch_hn &
fetch_reddit &
fetch_mcp &
wait

# Combine JSON sources
jq -s 'add' \
  "$CACHE/${RUN_ID}-02-cc-releases.json" \
  "$CACHE/${RUN_ID}-05a-gh-llm.json" \
  "$CACHE/${RUN_ID}-05b-gh-agents.json" \
  "$CACHE/${RUN_ID}-06-hn.json" \
  "$CACHE/${RUN_ID}-07-reddit.json" \
  "$CACHE/${RUN_ID}-08-mcp.json" \
  > "$CACHE/${RUN_ID}-combined.json" 2>/dev/null || echo "[]" > "$CACHE/${RUN_ID}-combined.json"

# F-008 + F-009 + F-019: parse 4 RSS/MD/HTML zdrojů + dedupe + emit health.json
# F-023: single-prefix logging (parse_feeds.py už sám tiskne bez [parse_feeds] prefix)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if command -v python3 >/dev/null && [ -f "$SCRIPT_DIR/parse_feeds.py" ]; then
  python3 "$SCRIPT_DIR/parse_feeds.py" "$RUN_ID" 2>&1 | sed 's/^/[ai-radar] /' >&2 || true
fi

COUNT=$(jq 'length' "$CACHE/${RUN_ID}-combined.json" 2>/dev/null || echo 0)
echo "[ai-radar] Combined findings (post-parse + dedupe): ${COUNT}" >&2
echo "[ai-radar] Cache dir: $CACHE (prefix: ${RUN_ID})" >&2

# Output cache path pro chain do SKILL workflow
echo "$CACHE/${RUN_ID}-combined.json"
