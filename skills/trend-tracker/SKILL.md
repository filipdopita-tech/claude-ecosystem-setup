---
name: trend-tracker
description: "Daily trend monitoring pipeline pro OneFlow content pillars. Scrapuje YouTube + X + Reddit + web (CZ investiční scéna), AI analyzuje, ukládá denní content nápady do Obsidian Daily Note. Cron 08:00. Trigger: /trend-tracker (manual run), 'co je v trendu dnes', 'spusť trend tracker', 'denní investiční trendy'."
argument-hint: "[--niche=investice|ai|fundraising|all] [--sources=yt,x,reddit,web]"
user-invocable: true
allowed-tools:
  - Bash
  - Task
  - Read
  - Write
  - Edit
  - WebFetch
  - WebSearch
metadata:
  source: "skool-intel cherry-pick 2026-04-28: chase-ai-community 'The Automation That Built Me 175k Followers' (Muhammed Burhan, 8/10 score)"
  filip-adaptace: "Místo Airtable → Obsidian Daily Note (Filip's source of truth). Místo random niche → CZ investiční ekosystem. Cron Mac 08:00, ntfy push po dokončení."
---

# Trend Tracker — Daily CZ Investment Scene Monitor

**Cíl:** Každý den 08:00 ráno mít v Obsidian Daily Note přehled co je nového v CZ investiční / AI / fundraising scéně. Output = 5-10 content nápadů ready k použití pro IG/LinkedIn/podcast/newsletter.

## Sources (curated CZ + global investment focus)

### YouTube CZ kanály (yt-dlp + yt-research skill)
- BurzovniNoviny
- Patrik Hudec (Smartmania)
- Investplus (Petr Vlach)
- Forbes CZ (interviews)
- Ekonom (rozhovory)
- Czech Crunch (startup scéna)
- Štěpán Křeček (makroekonomie)

### X / Twitter accounts (via web scrape, ne paid API)
- @PatrikHudec, @Vlach_Investplus, @StepanKrecek
- @forbesCZ, @e15cz, @ihned_cz
- Global: @paulg, @sama, @balajis, @naval (AI + finance overlap)

### Reddit
- r/cz_investice (CZ retail)
- r/Czech (general CZ news)
- r/Investing (global retail)
- r/AI_Agents, r/ClaudeAI (tech/Claude trends)

### Web (RSS / scrape)
- e15.cz feed
- forbes.cz feed
- finmag.cz feed
- finexpert.cz feed
- tn.nova.cz/byznys feed

## Pipeline Architecture

```
┌──────────────────────────────────────────────┐
│ Cron 08:00 Mac (launchd plist)               │
└────────┬─────────────────────────────────────┘
         ▼
┌─────────────────────────────────────────────┐
│ 1. PARALLEL FETCH (4 subagenty Haiku)       │
│    - YT: yt-dlp last 24h per channel        │
│    - X: WebFetch nitter mirror per acct     │
│    - Reddit: WebFetch top/new per sub       │
│    - Web: RSS parse per source              │
└────────┬────────────────────────────────────┘
         ▼
┌─────────────────────────────────────────────┐
│ 2. DEDUP + SCORE (single Haiku call)        │
│    - Group by topic (semantic)              │
│    - Score 1-10: relevance × velocity       │
│    - Filter: drop <6 score                  │
└────────┬────────────────────────────────────┘
         ▼
┌─────────────────────────────────────────────┐
│ 3. CONTENT IDEATION (Sonnet 4.6 main)       │
│    Per top 10 trends:                       │
│    - 1 IG carousel angle (5 slides outline) │
│    - 1 LinkedIn post angle (300w)           │
│    - 1 podcast episode hook                 │
│    - 1 newsletter section idea              │
└────────┬────────────────────────────────────┘
         ▼
┌─────────────────────────────────────────────┐
│ 4. WRITE Obsidian Daily Note                │
│    Path: ~/Documents/OneFlow-Vault/         │
│      00-Daily/Trends-{YYYY-MM-DD}.md        │
└────────┬────────────────────────────────────┘
         ▼
┌─────────────────────────────────────────────┐
│ 5. NTFY push notification                   │
│    "🔥 Trend Tracker: 8 nápadů, 2 HOT"      │
└─────────────────────────────────────────────┘
```

## Implementation

### Setup (one-time)
```bash
mkdir -p ~/.claude/scripts/trend-tracker
mkdir -p ~/Documents/OneFlow-Vault/00-Daily

# Install yt-dlp pokud chybí
which yt-dlp || pip install yt-dlp

# Sources config
cat > ~/.claude/scripts/trend-tracker/sources.json <<'EOF'
{
  "youtube": {
    "burzovni-noviny": "https://www.youtube.com/@BurzovniNoviny",
    "patrik-hudec": "https://www.youtube.com/@PatrikHudec",
    "investplus": "https://www.youtube.com/@InvestplusCZ",
    "forbes-cz": "https://www.youtube.com/@ForbesCZ",
    "ekonom": "https://www.youtube.com/@ekonom"
  },
  "x_accounts": [
    "PatrikHudec", "Vlach_Investplus", "StepanKrecek",
    "forbesCZ", "e15cz", "paulg", "naval"
  ],
  "reddit_subs": ["cz_investice", "Czech", "Investing", "AI_Agents", "ClaudeAI"],
  "rss_feeds": [
    "https://www.e15.cz/rss",
    "https://forbes.cz/feed/",
    "https://finmag.penize.cz/rss",
    "https://www.finexpert.cz/rss/feeds.aspx"
  ]
}
EOF
```

### Run script (called by cron)
```bash
#!/bin/bash
# ~/.claude/scripts/trend-tracker/run.sh
set -euo pipefail

DATE=$(date +%Y-%m-%d)
LOG_DIR=~/.claude/scripts/trend-tracker/logs
mkdir -p "$LOG_DIR"
LOG="$LOG_DIR/run-$DATE.log"

# Step 1: Fetch via Claude Code with subagents
claude -p "Run trend-tracker pipeline for $DATE. Use ~/.claude/scripts/trend-tracker/sources.json. Output Obsidian Daily Note at ~/Documents/OneFlow-Vault/00-Daily/Trends-$DATE.md" \
  --bare \
  --system-prompt "You are trend-tracker pipeline. Use 4 parallel Haiku subagents for fetch, single Sonnet for ideation. Cost ZERO." \
  --output-format=stream-json \
  > "$LOG" 2>&1

# Step 2: ntfy notification
NOTE=~/Documents/OneFlow-Vault/00-Daily/Trends-$DATE.md
if [ -f "$NOTE" ]; then
  COUNT=$(grep -c "^## Idea" "$NOTE" || echo 0)
  HOT=$(grep -c "🔥" "$NOTE" || echo 0)
  curl -s -X POST "https://ntfy.oneflow.cz/Filip" \
    -H "Title: Trend Tracker $DATE" \
    -d "✅ $COUNT nápadů, $HOT 🔥. Note: Trends-$DATE.md"
else
  curl -s -X POST "https://ntfy.oneflow.cz/Filip" \
    -H "Title: Trend Tracker FAILED" \
    -H "Priority: high" \
    -d "❌ Note neexistuje. Log: $LOG"
fi
```

### Cron entry (Mac launchd)
```xml
<!-- ~/Library/LaunchAgents/com.oneflow.trend-tracker.plist -->
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.oneflow.trend-tracker</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/bash</string>
    <string>~/.claude/scripts/trend-tracker/run.sh</string>
  </array>
  <key>StartCalendarInterval</key>
  <dict>
    <key>Hour</key><integer>8</integer>
    <key>Minute</key><integer>0</integer>
  </dict>
  <key>StandardOutPath</key>
  <string>~/.claude/scripts/trend-tracker/logs/launchd.log</string>
  <key>StandardErrorPath</key>
  <string>~/.claude/scripts/trend-tracker/logs/launchd-err.log</string>
</dict>
</plist>
```

Load: `launchctl load ~/Library/LaunchAgents/com.oneflow.trend-tracker.plist`

## Output Format (Obsidian Daily Note)

```markdown
# Trends — 2026-04-28

> Sources: 5 YT kanálů, 7 X accounts, 5 Reddit subs, 5 RSS feeds. Hodnota: 8 nápadů, 2 🔥 HOT.

## Idea 1 [🔥 9/10] CNB nové ECSP guidelines (effective 5/2026)
- **Source:** e15.cz, BurzovniNoviny YT
- **Trend velocity:** 14 articles/24h
- **OneFlow angle:** "Co znamená nový ECSP regime pro emitenty <1M EUR" — IG carousel + LinkedIn long-form
- **Hook:** "ECSP právě vytvořilo 2 kategorie emitentů. Většina malých s.r.o. neví, do které spadají."
- **Carousel outline:**
  1. Stará pravidla vs. nová (vizuál tabulka)
  2. Která emise spadá kam (decision tree)
  3. Co musíš udělat do 5/2026
  4. Penalty za missed compliance
  5. CTA: "Posílám checklist v DM"

## Idea 2 [🔥 8/10] AI-generated UGC ads breakthrough (Sora 2 + Nano Banana Pro)
...

## Idea 3 [7/10] Patrik Hudec dluhopisová analýza Q2 2026
...

## Raw data summary
- YT: 23 nových videí (deduped na 8 témat)
- X: 47 zmínek "investice CZ" (filtered 12 unique)
- Reddit: 6 hot threads
- Web: 18 articles
- Compute time: 4m23s, cost: 0 Kč (4× Haiku + 1× Sonnet free tier)
```

## Cost Discipline

- **YouTube fetch**: yt-dlp lokální (free, no API)
- **X**: Nitter mirrors (free, no Twitter API)
- **Reddit**: WebFetch JSON endpoints (free, no API)
- **RSS**: standard feeds (free)
- **LLM**: 4× Haiku ($0.0001/run) + 1× Sonnet ($0.003/run) = **<$0.01/day**
- **Žádné Google API** (cost-zero compliance per ~/.claude/rules/cost-zero-tolerance.md)
- **Žádný Gemini** (banned 2026-04-27)

## Anti-Patterns

- **Twitter API key použití** — banned (paid). Použij Nitter scrape.
- **Google APIs (YouTube Data API v3)** — banned. Použij yt-dlp.
- **Gemini calls** — banned. Použij Sonnet 4.6.
- **Daily volume >100 sources** — overhead > benefit. Curated 22 sources.
- **No dedup** — same trend across 5 sources = 1 idea, ne 5.

## Niche switcher

```bash
/trend-tracker --niche=investice  # default
/trend-tracker --niche=ai         # AI/Claude/agentic ekosystem
/trend-tracker --niche=fundraising  # startup capital, VC, ECSP
/trend-tracker --niche=all        # combined
```

Per-niche config files: `~/.claude/scripts/trend-tracker/sources-{niche}.json`

## Integrace s ostatními skills

- `/yt-research` — používá interně pro YT fetch
- `/ig-content-creator` — Idea → konkrétní carousel/reel script
- `/repurpose` — 1 idea → 9 formátů (FB, LI, IG, newsletter, ...)
- `/captionme` — finální caption pro post
- `/last30days` — fallback hlubší research na 1 specific topic

## Verification

Manual run pro test:
```bash
~/.claude/scripts/trend-tracker/run.sh
# Check: ls ~/Documents/OneFlow-Vault/00-Daily/Trends-$(date +%Y-%m-%d).md
# Check: ntfy received
# Check: log /tmp/trend-tracker-*.log
```

## Reference

- Source: skool-intel/chase-ai-community (Muhammed Burhan, "175k followers automation")
- OneFlow content strategy: `~/.claude/expertise/content-creation.yaml`
- Brand voice: `~/.claude/expertise/oneflow-brand.yaml`
