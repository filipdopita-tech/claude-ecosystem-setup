# instagram-meta-api — Status: 🟢 LIVE (zero Filip action needed)

> **Update 2026-05-03 22:15 CEST:** Plně provozní. Filip má existující Meta App **"OneFlow Publisher"** (App ID `1239370548302204`) s page tokenem co má všech 18 IG scopes. `~/.credentials/instagram_meta.env` byl autonomně setupnut z Flash `META_ACCESS_TOKEN`. Všech 5 core commands ověřeno (validate_token / get_profile / publishing_limit / get_media / get_account_insights).

## Quick test

```bash
source ~/.credentials/instagram_meta.env
python3 ~/.claude/skills/instagram-meta-api/scripts/ig_api.py validate_token
python3 ~/.claude/skills/instagram-meta-api/scripts/ig_api.py get_profile
# → @oneflowcast, 201 followers, 108 posts, business account
```

## Pokud někdy potřebuješ NOVÝ Meta App (existing přestane fungovat / chceš dedicated app pro IG-only scopes):

## Minute 0–2: Pre-flight

```bash
# Verify skill exists + Python helper works
ls -la ~/.claude/skills/instagram-meta-api/
python3 ~/.claude/skills/instagram-meta-api/scripts/ig_api.py --help

# Confirm OneFlow IG account is Business or Creator (NOT Personal)
#   Open IG mobile app → Settings → Account → If "Switch to Personal Account"
#   appears, you are already Business/Creator. Done.
#   If "Switch to Business" appears → tap it → Category: "Financial Services".
```

## Minute 2–5: Create Meta Developer App

1. Open https://developers.facebook.com/apps and sign in with the Facebook account that **owns the OneFlow IG account** (or has admin access via a Page).
2. Click **Create App** → use case **"Other"** → app type **"Business"**.
3. Name: `OneFlow Instagram Integration` — Contact email: `dopita@oneflow.cz` — Business portfolio: select your OneFlow business or "Create new".
4. After creation, in the dashboard sidebar pick **"Add product"** → **"Instagram"** → Setup.
5. In Instagram product settings, choose **"Manage messaging & content on Instagram"**.

## Minute 5–8: App roles + Tester invite

1. Sidebar → **App roles** → **Roles** → **Add People** → choose **Instagram Tester** → enter your IG handle (e.g. `oneflow_cast`).
2. Open Instagram mobile app → Settings → Account → **Apps and Websites** → **Tester Invites** → accept the invite for "OneFlow Instagram Integration".

## Minute 8–11: Permissions + Privacy Policy / ToS

1. Sidebar → **Instagram** → **API setup with Instagram login** → enable scopes:
   - `instagram_business_basic` (REQUIRED — profile, follower count, basic media)
   - `instagram_business_manage_comments` (REQUIRED — comment-trigger funnels)
   - `instagram_business_manage_messages` (REQUIRED — DM automation)
   - `instagram_business_manage_insights` (RECOMMENDED — saves, watch time, retention)
   - `instagram_business_content_publish` (REQUIRED — publish_reel/carousel/story)
2. **Add the legal URLs** to App Settings → Basic — **už hotové, copy-paste:**
   - **Privacy Policy URL:** `https://filipdopita-tech.github.io/oneflow-legal/instagram-privacy.html`
   - **Terms of Service URL:** `https://filipdopita-tech.github.io/oneflow-legal/instagram-terms.html`
   - **User data deletion URL:** `https://filipdopita-tech.github.io/oneflow-legal/instagram-privacy.html#section-9` (Privacy Policy § 9 covers deletion)
   - Repo (pokud Filip chce upravit): https://github.com/filipdopita-tech/oneflow-legal
   - Source markdown: `~/.claude/skills/instagram-meta-api/references/legal/{PRIVACY-POLICY,TERMS-OF-SERVICE}-OneFlow-IG-App.md` → re-render přes `cd /tmp/oneflow-legal-html && python3 ~/.claude/scripts/legal-md2html.py` (pokud změníš md, aktualizuj repo).

## Minute 11–13: Generate long-lived access token

1. Still in Instagram product settings → **Generate access token** → log in as the OneFlow IG user → grant all requested scopes.
2. The dashboard shows a **short-lived** token (1 hour). Convert to long-lived (60 days) via:

```bash
SHORT_TOKEN="paste_short_token_here"
APP_ID="paste_app_id_from_dashboard"
APP_SECRET="paste_app_secret_from_dashboard"

curl -s "https://graph.facebook.com/v25.0/oauth/access_token?grant_type=fb_exchange_token&client_id=${APP_ID}&client_secret=${APP_SECRET}&fb_exchange_token=${SHORT_TOKEN}"
```

The response includes a `access_token` field — that is your **long-lived token** (~60 days TTL).

## Minute 13–14: Save credentials

```bash
cat > ~/.credentials/instagram_meta.env <<'EOF'
INSTAGRAM_APP_ID=paste_here
INSTAGRAM_APP_SECRET=paste_here
INSTAGRAM_ACCESS_TOKEN=paste_long_lived_token_here
INSTAGRAM_BUSINESS_ACCOUNT_ID=paste_here
EOF

chmod 600 ~/.credentials/instagram_meta.env
```

To find `INSTAGRAM_BUSINESS_ACCOUNT_ID`:

```bash
source ~/.credentials/instagram_meta.env
python3 ~/.claude/skills/instagram-meta-api/scripts/ig_api.py get_pages
# In the JSON output, look for "instagram_business_account.id"
```

Update the env file with the found ID, then re-source.

## Minute 14–15: Validation

```bash
source ~/.credentials/instagram_meta.env
python3 ~/.claude/skills/instagram-meta-api/scripts/ig_api.py validate_token
python3 ~/.claude/skills/instagram-meta-api/scripts/ig_api.py get_profile
python3 ~/.claude/skills/instagram-meta-api/scripts/ig_api.py publishing_limit
```

If all 3 commands return JSON without `error` field → setup complete.

## Reminders

- Long-lived token expires every ~60 days. Add a calendar reminder for day 50 to refresh:
  ```bash
  # On day 50, regenerate via dashboard → run the curl above → update env file
  ```
- Comment-trigger funnels require the IG account to be Business **or** Creator AND the Page must be linked.
- For Reel publishing, video must be MP4 H.264 / AAC, 9:16, ≤90s, ≤100MB. Use ffmpeg if needed.

## Post-setup auto-chain (workflow-routing.md handles automatically)

1. `ig-content-creator` writes copy + brand check
2. (optional) `of-design` produces visuals
3. `instagram-meta-api publish_carousel` ships
4. T+24h: `instagram-meta-api get_media_insights` saves to `~/Documents/OneFlow-Vault/03-Projects/oneflow-instagram/insights/`
5. `ig-creator-deep-dive` synthesizes
6. `content-repurpose` adapts winning post

## Troubleshooting

| Symptom | Fix |
|---|---|
| `validate_token` returns `error.code: 190` | Token expired — regenerate via dashboard |
| `publish_*` returns `error.code: 100` | Missing scope — re-grant via dashboard, regenerate token |
| `get_pages` returns empty array | OneFlow IG not linked to a Facebook Page — link via IG Settings → Business → Connect Page |
| `send_dm` returns `error.code: 10` | Recipient hasn't messaged us in last 24h (Meta 24-hour window rule) |

---

**Ready check:** all three of `validate_token`, `get_profile`, `publishing_limit` returning OK = HARD GATE cleared. Skill is now usable end-to-end.
