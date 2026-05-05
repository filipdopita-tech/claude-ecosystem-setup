# Meta Developer App Setup pro instagram-meta-api skill

**One-time setup, ~15 minut. Filipova manuální akce — Claude tě tím provede, ale klikat musíš ty.**

Plný PDF s screenshoty: `~/Desktop/Codex/research-briefings/2026-05-03/alex2learn-pdfs/instagramguide.pdf` (21 stran, alex2learn April 2026 first edition).

## Prerekvizity

- OneFlow IG account je **Business** nebo **Creator** (ne Personal). Switch v IG Settings pokud nutné.
- Facebook account (může být throwaway pokud Filip nechce použít osobní).

## 5 částí setup

### Part 01 — Create Meta Developer App
1. developers.facebook.com → green "Create App" button
2. App name = cokoliv ("oneflow-ig", "of-claude-bot")
3. App is for: **Other** (ostatní kategorie tě posílají do longer review)
4. Use case: **Manage messaging & content on Instagram** (jediný use case co dá všechny 3 perms)
5. Create App

### Part 02 — Add yourself as Instagram Tester
1. Left sidebar → **App roles** → **Roles**
2. Blue "Add People" button (top right)
3. Modal → scroll past Admin/Dev/Tester → pick **Instagram Tester** (highlighted blue)
4. Username: OneFlow IG handle (no @)
5. Add
6. Open IG app on phone → **Settings & privacy → Apps and websites → Tester invites** → Accept

### Part 03 — Wire up the Instagram API
1. Left sidebar → **Use cases** → click **Customize** on the "Manage messaging & content on Instagram" card
2. Left submenu → **API setup with Instagram login** (default — leave it)
3. Section "1. Add required messaging permissions" → enable all three:
   - `instagram_business_basic`
   - `instagram_manage_comments`
   - `instagram_business_manage_messages`
4. **Recommended add**: `instagram_business_manage_insights` (unlocks watch-time, reach, view-rate, save/share-rate per reel)
5. **Optional add**: `instagram_business_content_publish` (only if Filip chce programmatic publish; nutné pro publish_reel/publish_carousel calls)
6. Section "2. Generate access tokens" → blue **Add account** → IG login modal → use the OneFlow IG account → approve permissions

### Part 04 — Publish the app
1. Left sidebar → **Publish** → see what's missing
2. **Privacy Policy + Terms of Service** = required. Quickest path:
   - Open 2 new Google Docs
   - Tell Claude: "Write a basic Privacy Policy and Terms of Service for a personal app called [oneflow-ig] that uses the Instagram API to read my own analytics and DMs. Output as two markdown blocks I can paste into Google Docs."
   - Set sharing to "Anyone with the link can view"
   - Copy share URLs
3. **App settings → Basic**:
   - Privacy Policy URL → paste #1
   - Terms of Service URL → paste #2
   - Category: **Business and Pages**
   - App icon: 1024x1024 PNG (Claude can generate one if asked)
4. Save changes
5. Back to **Publish** → click publish button

### Part 05 — Save credentials
1. **App settings → Basic**:
   - **App ID** = visible top of page (15-16 digit number)
   - **App Secret** = click "Show" button. **Treat like password.**
2. Save to `~/.credentials/instagram_meta.env`:

```bash
# OneFlow IG Meta App credentials
# Created: 2026-XX-XX
# App: <name>
# Last token refresh: <date>

INSTAGRAM_APP_ID=<15-16 digit number>
INSTAGRAM_APP_SECRET=<from App settings → Basic → Show>

# Generated long-lived token via "Generate access tokens" on Customize page
# Lifetime: ~60 days. Refresh script: ~/.claude/skills/instagram-meta-api/scripts/refresh_token.py
INSTAGRAM_ACCESS_TOKEN=<long-lived token>

# Get this via: python3 scripts/ig_api.py get_pages (after first auth)
INSTAGRAM_BUSINESS_ACCOUNT_ID=<numeric ID>
```

```bash
chmod 600 ~/.credentials/instagram_meta.env
```

## Final checklist before talking to Claude

- [ ] App created at developers.facebook.com
- [ ] Use case: Manage messaging & content on Instagram
- [ ] OneFlow IG added as Instagram Tester
- [ ] Tester invite accepted in IG app
- [ ] All required permissions enabled (+ insights + content_publish if needed)
- [ ] Account connected via Add account in Part 03 step 6
- [ ] Privacy Policy + Terms of Service URLs filled
- [ ] App is **Published** (not Unpublished)
- [ ] App ID and App Secret saved to `~/.credentials/instagram_meta.env` (chmod 600)
- [ ] `~/.claude/skills/instagram-meta-api/scripts/ig_api.py validate_token` returns OK

## Common errors

| Error | Cause | Fix |
|---|---|---|
| "You're not a developer" | Tester invite not accepted yet | IG app → Settings → Apps and websites → Tester invites → Accept (sometimes 30s delay) |
| "Invalid OAuth access token" | Expired or wrong perms | Regenerate on Customize page |
| "App not active" | App is unpublished + token aged out | Finish Part 04 publish |
| "Doesn't support [metric]" | Wrong metric for media type | Use `views` for reels (not `plays`) |

## Token refresh

Long-lived token = ~60 days. Cron pro auto-refresh (volitelné):

```bash
# Add to ~/scripts/automation/refresh-ig-token.sh
0 3 1 * * /Users/filipdopita/.claude/skills/instagram-meta-api/scripts/refresh_token.py
```

(Refresh skript bude v scripts/ pokud budeš potřebovat.)

---

**Po dokončení setup**: testuj `validate_token` + `get_profile`. Pak můžeš spustit publish/insights commands.
