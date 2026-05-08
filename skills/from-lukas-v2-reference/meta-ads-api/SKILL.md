---
name: meta-ads-api
description: Operational knowledge for Meta Marketing API / Facebook Graph API — token generation preconditions, creative enrichment endpoints, rate limits, App Review traps, common failure modes. Use BEFORE telling user to do Meta Business Manager / token / API tasks so you can predict approval blockers upfront instead of stepping through 5 sequential errors. Triggers on: meta_ads_*, Meta Business Manager, system user, ads_read, ads_management, Graph API, Marketing API, ad creative, ad enrichment.
last-updated: 2026-04-27
version: 1.0.0
---

# Meta Marketing API — Operational Knowledge

This skill exists because step-by-step guesswork through the Meta UI burns hours when preconditions aren't checked upfront. Always run the **Pre-Flight Checklist** below before instructing a user through token generation.

---

## ⚡ Pre-Flight Checklist (RUN FIRST)

Before telling the user "click X to generate token", verify ALL of these. If any is unknown, ASK — don't assume.

| # | Check | Question to user | Why it matters |
|---|-------|------------------|----------------|
| 1 | **App mode** | "Is your app in Live mode or Development?" | System users CAN'T generate tokens in Development. Required: **Live**. |
| 2 | **Privacy URL** | "Do you have a public Privacy Policy URL?" | Required to flip to Live. Don't invent URLs — ask. |
| 3 | **2-step token approval** | "In Business Settings → Security Center, is 2-step approval for token generation enabled?" | If yes, EVERY token request needs a 2nd admin to click approve. Blocks even `ads_read`. |
| 4 | **Business owner status** | "Are you the Business Manager owner / primary admin, or just an employee?" | Only owner can disable 2-step approval, claim apps to BM, run business verification. |
| 5 | **Existing system user age** | "When was the system user created?" | New ADMIN system users can't be created if existing admin <7 days old. Use Employee role instead — it works for ads_read. |
| 6 | **Asset assignment chain** | "Is the system user assigned to BOTH the App AND the Ad Account?" | Both required. App assignment alone gives token but no data access; ad account alone gives no token. |
| 7 | **App claimed by BM** | "Was the app created inside Business Manager, or imported from a personal account?" | If created externally, must be claimed (Business Settings → Apps → Add). Otherwise system user assignment doesn't work. |

**If user is NOT business owner AND 2-step approval is on AND no other admin available → recommend Cesta C immediately (Graph API Explorer User Token).** Don't waste time on system user path.

---

## 🚨 Token Generation — Why Each Path Fails

### Path A: System User token (production-grade, never expires)
**Requires:** App Live + system user assigned to App (Manage/Develop role) + system user assigned to Ad Account + 2nd admin approval IF Security Center has it enabled.

**Failure: "Nejsou k dispozici žádná oprávnění" in step 3 of dialog**
→ System user has no role in the selected app. Fix: Business Settings → Apps → [app] → Add People → System User → Develop App.

**Failure: "Kvůli bezpečnosti vaší firmy musí žádost schválit ještě další správce"**
→ Business Manager has 2-step approval enabled. Cannot bypass without owner action OR another admin clicking approve in Meta Business Suite app. Recommend Path C as workaround.

**Failure: "Tohoto systémového uživatele nelze vytvořit"** (when adding new admin system user)
→ Existing admin system user is <7 days old. Use **Employee** role instead — it can generate ads_read tokens without the 7-day cooldown.

### Path B: User Access Token from Login flow (60-day expiry, refreshable)
Production app flow with FB Login + OAuth callback. Heavy setup. Skip unless building auth UI.

### Path C: Graph API Explorer User Token (60 days, instant)
**Recommended workaround when Path A is blocked.**
1. https://developers.facebook.com/tools/explorer/
2. Application → select app
3. Get Token → User Access Token
4. Add permissions: `ads_read` (+ `ads_management` if creative writes needed)
5. Generate → autorize → copy
6. **Refresh after ~30 days** (tokens are refreshable when ≥24h old and <60d old)

Token works identically for read endpoints. Trade-off: expires in 60 days, needs manual refresh.

---

## 🎯 Permission Strategy (Minimum Viable Set)

For **read-only enrichment** (creative URLs, body text, video downloads):
- ✅ `ads_read` — REQUIRED
- ✅ `ads_management` — REQUIRED for some creative fields (Meta inconsistency: certain `creative{}` subfields need write scope to read)
- ❌ `business_management` — NOT needed for ad/creative reads. SKIP — it triggers 2-admin approval gate when other scopes wouldn't.

**Anti-pattern:** Adding `business_management` "just in case" — it's the most common reason token generation hits 2-admin approval block.

---

## 🔌 Creative Enrichment Endpoints (v22.0+)

### Get all ads in account (paginated)
```
GET /v22.0/act_{ad_account_id}/ads
  ?fields=id,name,status,adset_id,campaign_id,creative
  &limit=100
```
Paginate via `paging.cursors.after`. ~100 ads per page is safe.

### Get creative for one ad
```
GET /v22.0/{ad_id}
  ?fields=name,adset_id,campaign_id,creative{
    id,
    image_url,
    image_hash,
    video_id,
    thumbnail_url,
    body,
    title,
    call_to_action_type,
    object_story_spec{
      page_id,
      video_data{video_id,image_url,title,message,call_to_action},
      link_data{image_hash,link,message,name,description,call_to_action,child_attachments}
    }
  }
```
**Carousel ads:** data is in `object_story_spec.link_data.child_attachments[]`, not top-level.
**Video ads:** `video_id` from creative → fetch video object separately (see below).

### Get video source URL (mp4)
```
GET /v22.0/{video_id}
  ?fields=source,permalink_url,picture,length
```
`source` is signed CDN URL (mp4). **Expires** after some hours — re-fetch when downloading.

### Get insights (spend/impressions per creative)
```
GET /v22.0/{ad_id}/insights
  ?fields=spend,impressions,clicks,ctr,cpm,cpc,actions
  &date_preset=last_30d
```
Insights API ≠ Ads API. Use Insights for metrics, Ads for creative.

---

## 📉 Rate Limits

**Read header on every response:** `X-Business-Use-Case-Usage`
```json
{ "business_id": { "type": "ads_management", "call_count": 45, "total_cputime": 23, "total_time": 18, "estimated_time_to_regain_access": 0 } }
```
- `call_count` is % (0-100) of hourly bucket consumed
- At 80%+, back off
- At 100%, all requests fail until `estimated_time_to_regain_access` seconds elapse
- No burst credit — wait it out

**Practical pacing:** 200ms sleep between calls + retry-on-429 with exponential backoff (2s, 4s, 8s) covers most workloads. For >10k ad fetches use BUC-aware throttling.

---

## ⚠️ Subtle Failure Modes

1. **API version sunset.** Meta deprecates versions every 2 quarters. v22.0 is current as of 2026-04. Pin version in URL; don't use bare `/graph.facebook.com/{id}`.

2. **Token "stops working" overnight.** Common causes: user changed FB password, 2FA toggled, Business Manager admin role changed, app secret rotated. Token Debugger (developers.facebook.com/tools/debug/accesstoken) shows reason.

3. **`ads_read` returns empty array.** Account has no ads in that period; OR token's BM doesn't own the ad account; OR using account ID without `act_` prefix.

4. **Creative `image_url` 403 on download.** Some image URLs require User-Agent header (use `Mozilla/5.0 ...`). Or the URL has expired — re-fetch creative.

5. **Video `source` URL expires fast.** Don't store mp4 URLs in DB — store `video_id` and fetch source on demand.

6. **Timezone trap.** All metrics are in **ad account's timezone**, locked at account creation. Joining with internal data in UTC = silent off-by-one-day errors.

7. **Currency trap.** Same as timezone — locked. Spend is in account currency, not normalized.

8. **Insights API has 72h finalization lag.** Don't reconcile yesterday's spend at 9am; conversions may still attribute back. Wait 3 days for "final" numbers.

9. **No webhook for creative changes.** You MUST poll. Meta has webhooks for ad account changes (budget, status) but not creative updates.

10. **Carousel and video transcripts are NOT in the API.** For transcripts, download the mp4 yourself + run Whisper. Meta does not expose audio transcription.

---

## 🛠️ Decision Tree When User Hits a Wall

```
User wants ads_read token
├── Are they Business Manager owner?
│   ├── YES → Try System User path (Path A)
│   │   ├── Step 1: Check app is Live (if not, flip + privacy URL)
│   │   ├── Step 2: Disable 2-step in Security Center
│   │   ├── Step 3: Assign system user to App + Ad Account
│   │   └── Step 4: Generate token (ads_read + ads_management ONLY)
│   └── NO → Skip A. Go directly to Path C (Graph API Explorer User Token)
│       └── 60-day expiry, refresh in 30 days, works identically for reads
└── If 2-step blocks Path A mid-flow → fall back to Path C (don't wait days for approval)
```

**Do NOT** loop user through clicking 5 dialogs hoping one works. Diagnose precondition first.

---

## 🔗 Authoritative References

- [Authorization](https://developers.facebook.com/docs/marketing-api/get-started/authorization/)
- [Rate Limiting & BUC headers](https://developers.facebook.com/docs/marketing-api/overview/rate-limiting/)
- [Versions / Deprecation](https://developers.facebook.com/docs/marketing-api/versions/)
- [Long-Lived Token Refresh](https://developers.facebook.com/docs/facebook-login/guides/access-tokens/get-long-lived/)
- [Token Debugger](https://developers.facebook.com/tools/debug/accesstoken/)
- [Graph API Explorer](https://developers.facebook.com/tools/explorer/)
- [System Users docs](https://developers.facebook.com/docs/business-management-apis/system-users/)
- [Ad Creative Reference](https://developers.facebook.com/docs/marketing-api/reference/ad-creative/)

---

## 💡 Heuristics for the Assistant

- **Always ask precondition #3 (2-step approval) and #4 (owner status) BEFORE walking through the token UI.** Two minutes of asking saves an hour of failed clicks.
- **Default to Path C** when user is not BM owner. System user path is for production automation owned by the BM admin.
- **Never recommend `business_management` scope** unless user explicitly needs to read BM-level metadata. It's the #1 cause of 2-admin approval gates.
- **Don't invent URLs** (privacy policy, terms). Ask the user for their actual deployed URL.
- **When token works, suggest storing in `.env.local` AND `vercel env add` in same step** — the most common "it broke in production" cause is forgetting Vercel env.
