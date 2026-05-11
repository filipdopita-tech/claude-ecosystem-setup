---
name: instagram-meta-api
description: Direct Meta Graph API v25.0 wrapper pro OneFlow Instagram Business účet. Publish reels/posts/stories/carousels, fetch insights (watch-time, reach, save-rate, hook performance), manage comments, send DMs — všechno z terminálu bez Meta UI. Use when user wants to publish content programmatically, pull reel analytics nad rámec ig-creator-deep-dive (read-only), automate comment-trigger DM funnels ("comment WORD to get X"), or schedule posts. Requires one-time Meta Developer App setup (viz references/setup-meta-app.md).
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# instagram-meta-api — Direct Meta Graph API CLI pro OneFlow IG

## Kdy použít

- Publish OneFlow IG content programmatically (carousel/reel/story/post)
- Pull deep insights (watch-time, retention, save/share rate per reel) — víc než `ig-creator-deep-dive` (free režim, omezený scope)
- Auto-DM commenters on trigger keyword ("comment BRAIN" funnels)
- Bulk comment management (delete spam, post replies)
- Send/manage DMs from terminal
- Schedule posts via cron (compose locally → push at scheduled time)

## Kdy NEPOUŽÍT

- Chce jen analýzu cizího profilu → `instagram-analyzer` (free, no auth)
- Chce vytvořit content copy → `ig-content-creator` (write only, no publish)
- Chce competitive intel → `competitor-intel`
- Chce deep-dive na vlastním kreátorovi (read) → `ig-creator-deep-dive`
- Filip jen chce naplánovat publish → manual via Buffer/Later (rychlejší pro single posts)

## Vztah k existujícím skills

| Skill | Scope | Auth |
|---|---|---|
| `instagram-analyzer` | analyze ANY profile (read-only) | none |
| `ig-creator-deep-dive` | own profile metrics (free tier scope) | none |
| `ig-content-creator` | write copy in OneFlow voice | none |
| **`instagram-meta-api`** | **publish + DM + insights na OWN account** | **Meta App tokens** |
| `competitor-intel` | scrape competitor IG/YT | none |

Tento skill complementarizuje — nereplikuje. `ig-content-creator` napíše copy, `instagram-meta-api` ji publishne. `ig-creator-deep-dive` dá free-tier analytics, `instagram-meta-api` jde hlouběji (insights API requires `instagram_business_manage_insights` permission).

## Setup (POVINNÉ before first use)

**HARD GATE: Meta Developer App musí být setup PŘED použitím skill.**

Postup je v `references/setup-meta-app.md` (převzato z alex2learn.com/instagramguide PDF, April 2026 edition). 15 minut, one-time. Vyžaduje:

1. Meta Developer App created at developers.facebook.com
2. Use case: "Manage messaging & content on Instagram"
3. OneFlow IG account added as Instagram Tester + invite accepted
4. Permissions enabled: `instagram_business_basic`, `instagram_manage_comments`, `instagram_business_manage_messages` + (recommended) `instagram_business_manage_insights` + `instagram_business_content_publish`
5. Account connected via "Add account" in step 8 of guide
6. Privacy Policy + Terms of Service URLs filled (Google Doc s "Anyone with link can view" funguje)
7. App **Published** (ne Unpublished) — jinak token caps out
8. App ID + App Secret copied

Po dokončení setup → save credentials do `~/.credentials/instagram_meta.env` (chmod 600):

```bash
INSTAGRAM_APP_ID=<15-16 digit number>
INSTAGRAM_APP_SECRET=<from App settings → Basic, click "Show">
INSTAGRAM_ACCESS_TOKEN=<long-lived token, generated via "Generate access tokens">
INSTAGRAM_BUSINESS_ACCOUNT_ID=<from get_pages call after auth>
```

## Použití

**Vždy nejprve source credentials:**
```bash
source ~/.credentials/instagram_meta.env
```

Pak invoke Python wrapper na 16 commands:

```bash
# Account
python3 ~/.claude/skills/instagram-meta-api/scripts/ig_api.py validate_token
python3 ~/.claude/skills/instagram-meta-api/scripts/ig_api.py get_profile
python3 ~/.claude/skills/instagram-meta-api/scripts/ig_api.py publishing_limit

# Insights (deep — víc než free tier)
python3 ~/.claude/skills/instagram-meta-api/scripts/ig_api.py get_account_insights --period day --metrics impressions,reach,profile_views
python3 ~/.claude/skills/instagram-meta-api/scripts/ig_api.py get_media_insights --media-id <ID>
python3 ~/.claude/skills/instagram-meta-api/scripts/ig_api.py get_media --limit 20

# Publish (single image/video/reel/story/carousel)
python3 ~/.claude/skills/instagram-meta-api/scripts/ig_api.py create_container --image-url "https://..." --caption "..." --alt-text "..."
python3 ~/.claude/skills/instagram-meta-api/scripts/ig_api.py publish_media --container-id <ID>
python3 ~/.claude/skills/instagram-meta-api/scripts/ig_api.py publish_reel --video-url "https://..." --caption "..." --thumb-offset 2000
python3 ~/.claude/skills/instagram-meta-api/scripts/ig_api.py publish_story --image-url "https://..."
python3 ~/.claude/skills/instagram-meta-api/scripts/ig_api.py publish_carousel --media-urls "url1,url2,video:url3" --caption "..."

# Comments + DMs
python3 ~/.claude/skills/instagram-meta-api/scripts/ig_api.py get_conversations --limit 10
python3 ~/.claude/skills/instagram-meta-api/scripts/ig_api.py send_dm --recipient-id <USER_ID> --message "..."
```

**Pattern pro komplet content workflow s OneFlow brand:**
```
1. ig-content-creator → vytvoří copy + carousel images (OneFlow brand)
2. of-design → finalizuje vizuál pokud potřeba
3. instagram-meta-api → upload do CDN/Drive, get URL, publish_carousel
4. (po 24h) instagram-meta-api get_media_insights → metriky
5. ig-creator-deep-dive → kontextualizace metrik
6. content-repurpose → adaptace winning postu pro LinkedIn/X/newsletter
```

## Limitace (z Meta API spec)

- **Image format**: JPEG only (no PNG/MPO/JPS)
- **Rate limit**: 100 API-published posts per 24h
- **Carousel**: 2-10 items, cropped to first item aspect ratio
- **Container expiry**: 24h publishing window from creation
- **DMs**: 24h reply window, 1000 char max, **Advanced Access required** (separate Meta review)
- **Insights**: requires 100+ followers, 90-day data retention, `instagram_business_manage_insights` permission
- **Token expiry**: long-lived ~60 days; setup `refresh_token` cron pokud Filip chce auto-renew

## Troubleshooting (z guide)

| Error | Cause | Fix |
|---|---|---|
| "You're not a developer" | Tester invite not accepted | Open IG app → Settings → Apps and websites → Tester invites → Accept |
| "Invalid OAuth access token" | Token expired or wrong perms | Regenerate via `Generate access tokens` on Customize page |
| "App not active" | App is unpublished + token aged | Finish Publish step (Privacy Policy + ToS + categories) |
| "Doesn't support [metric] for this media product type" | Wrong metric for media type | Use `views` for reels; check IG Graph API docs per media type |

## OneFlow brand chain (auto-trigger by workflow-routing)

Když Filip publishe IG content přes tento skill, auto-chain:
1. **Pre-publish gate**: pokud copy nebyl psaný přes `ig-content-creator` → spawn `ig-content-creator` s OneFlow brand check
2. **Post-publish (T+24h)**: cron → `get_media_insights` → save do `~/Documents/OneFlow-Vault/03-Projects/oneflow-instagram/insights/{YYYY-MM-DD}-{post-id}.md`
3. **Weekly digest (Sunday)**: aggregate insights → `ig-creator-deep-dive` retro → memory entry

## Reference

- Setup walkthrough (full PDF screenshots): `~/Desktop/Codex/research-briefings/2026-05-03/alex2learn-pdfs/instagramguide.pdf`
- Setup checklist: `references/setup-meta-app.md`
- Meta Graph API docs: https://developers.facebook.com/docs/instagram-platform/instagram-graph-api
- Original Python pattern: github.com/moboutrig/instagram-claude-skill (MIT)
- Source guide: alex2learn.com/instagramguide
