---
name: last30days
version: "2.9.6"
description: "Deep research engine covering the last 30 days across 10+ sources - Reddit, X/Twitter, YouTube, TikTok, Instagram, Hacker News, Polymarket, and the web. AI synthesizes findings into grounded, cited reports."
argument-hint: 'last30 AI video tools, last30 best project management tools'
allowed-tools: Bash, Read, Write, AskUserQuestion, WebSearch
homepage: https://github.com/mvanhorn/last30days-skill
repository: https://github.com/mvanhorn/last30days-skill
author: mvanhorn
license: MIT
user-invocable: true
metadata:
  openclaw:
    emoji: "📰"
    requires:
      env:
        - SCRAPECREATORS_API_KEY
      optionalEnv:
        - OPENAI_API_KEY
        - XAI_API_KEY
        - OPENROUTER_API_KEY
        - PARALLEL_API_KEY
        - BRAVE_API_KEY
        - APIFY_API_TOKEN
        - AUTH_TOKEN
        - CT0
        - BSKY_HANDLE
        - BSKY_APP_PASSWORD
        - TRUTHSOCIAL_TOKEN
      bins:
        - node
        - python3
    primaryEnv: SCRAPECREATORS_API_KEY
    files:
      - "scripts/*"
    homepage: https://github.com/mvanhorn/last30days-skill
    tags:
      - research
      - deep-research
      - reddit
      - x
      - twitter
      - youtube
      - tiktok
      - instagram
      - hackernews
      - polymarket
      - bluesky
      - truthsocial
      - trends
      - recency
      - news
      - citations
      - multi-source
      - social-media
      - analysis
      - web-search
      - ai-skill
      - clawhub
---

# last30days — Research Any Topic from the Last 30 Days

Research ANY topic across Reddit, X, YouTube, Hacker News, Polymarket, Bluesky, web — surface real discussions, recommendations, bets, debates from past 30 days. AI synthesizes findings into grounded, cited reports.

## Permissions overview

Reads public web/platform data, optionally saves briefings to `~/Documents/Last30Days/`. X/Twitter uses optional `AUTH_TOKEN`/`CT0` env. Bluesky uses optional `BSKY_HANDLE`/`BSKY_APP_PASSWORD` (create at bsky.app/settings/app-passwords). All credential usage documented in `reference/output.md` § Security.

## Routing (lazy-load)

Read the relevant reference file ONLY when its phase triggers:

| Phase | Reference file |
|---|---|
| First-run setup, API key check, intent parsing, X handle resolve, agent mode | `reference/setup.md` |
| Research execution (script + WebSearch + Judge synthesis) | `reference/research.md` |
| Output formatting (recommendations/comparison/expert mode/security) | `reference/output.md` |

## What You Must Do When Invoked

### Step 1 — Setup gate (first run or missing keys)

Read `reference/setup.md` if `~/.last30days-config.json` missing OR user query implies handle resolution.

### Step 2 — Parse user intent (always)

Read `reference/setup.md` § CRITICAL Parse User Intent. Determine `QUERY_TYPE`: RECOMMENDATIONS / COMPARISON / GENERIC.

### Step 3 — Run research

Read `reference/research.md`. Execute script + parallel WebSearch + Judge synthesis.

### Step 4 — Format output by QUERY_TYPE

Read `reference/output.md`. Format per query type, then enter expert mode for follow-ups.

### Step 5 — Stay in expert mode

After each prompt: see `reference/output.md` § AFTER EACH PROMPT.
