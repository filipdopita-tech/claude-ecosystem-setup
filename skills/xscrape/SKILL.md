---
name: xscrape
description: "Extrahuj tweety, vlákna, profily a media z X.com. Trigger na 'stáhni tweet', 'vytáhni z X', 'xscrape', 'twitter scrape', X.com URL, 'co říká [user] na X'."
user_invocable: true
---

# X/Twitter Scraper

Extract tweets, profiles, threads, and media from X.com using Filip's authenticated session.

## Tools

- `node /root/social_poster/xscrape.mjs search "<query>" [--count N] [--json]` — Search tweets
- `node /root/social_poster/xscrape.mjs profile @<handle> [--json]` — User profile lookup
- `node /root/social_poster/xscrape.mjs tweets @<handle> [--count N] [--json]` — Recent tweets from user
- `node /root/social_poster/xscrape.mjs check` — Verify authentication

## Authentication

Cookies (AUTH_TOKEN, CT0) are stored in `/root/social_poster/.env`, extracted from Filip's Safari on Mac.

If cookies expire, re-extract:
```bash
ssh mac "cd $HOME/.claude/skills/last30days/scripts/lib/vendor/bird-search && /opt/homebrew/bin/node -e \"
import { resolveCredentials } from './lib/cookies.js';
const { cookies } = await resolveCredentials({});
console.log(JSON.stringify({ auth_token: cookies.authToken, ct0: cookies.ct0 }));
\""
```
Then update AUTH_TOKEN and CT0 in `/root/social_poster/.env`.

## Instructions

When the user triggers this skill:

1. Parse what they want:
   - **URL** (x.com/user/status/123) → extract tweet ID, fetch thread
   - **Profile request** ("co říká @levelsio") → `tweets @handle`
   - **Search** ("najdi tweety o AI agents") → `search "AI agents"`
   - **Creator analysis** ("analyzuj @handle") → profile + tweets + analyze

2. Run the appropriate xscrape command with `--json` for structured data.

3. Present results in a clean format:
   - For profiles: name, bio, follower count, recent tweet themes
   - For searches: top tweets with engagement, key takeaways
   - For creator analysis: posting patterns, content themes, engagement levels

4. Always use `--json` flag when processing data programmatically.

5. If auth fails (401/403), try re-extracting cookies from Mac Safari (see above).

## Examples

```bash
# Search for tweets about a topic
node /root/social_poster/xscrape.mjs search "saas founders" --count 20 --json

# Get someone's recent tweets
node /root/social_poster/xscrape.mjs tweets @levelsio --count 10 --json

# Quick profile check
node /root/social_poster/xscrape.mjs profile @YOUR_TWITTER_USERNAME --json
```
