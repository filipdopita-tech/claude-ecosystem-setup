---
name: higgsfield-automation
description: Automated Higgsfield.ai image generation via reverse-engineered API. Bypasses UI silent-fail issues by direct POST to Clerk-authenticated endpoints. Use when building loops/batches that generate Nano Banana Pro / GPT Image 2 images, or when Higgsfield UI Generate button silently fails despite valid Ultimate plan. Triggers on "higgsfield", "nano banana", "higgsfield bot", "higgsfield loop", "higgsfield generation".
---

# Higgsfield Automation

Working reference code: **`~/Desktop/CLAUDE/higgsfield_loop/`**

Reverse-engineered Patchright + direct API integration for Higgsfield.ai image generation. Confirmed working end-to-end on 2026-04-27 with Nano Banana Pro on Ultimate plan, 68s per 2K image.

## Critical lessons learned (don't repeat these)

### 1. UI Generate button silently fails — DON'T use it
- Even with valid Ultimate plan + Unlimited toggle ON, `page.click('#hf:image-form-submit')` produces zero network requests
- Root cause: client-side validation reads stale `credits=2` cache from JS state, button silently disabled
- **Fix:** bypass UI entirely, POST directly to API

### 2. Auth is Clerk JWT in `__session` cookie
- Higgsfield uses Clerk for auth
- JWT is stored in cookie `__session` on domain `higgsfield.ai` (no leading dot)
- Cookie is NOT auto-sent to `fnf.higgsfield.ai` subdomain (different domain match)
- **Fix:** read cookie value, attach as `Authorization: Bearer {token}` header
- JWT decodes to: `email`, `workspace_id`, `sub` (user_id), `exp` (~60s lifetime)
- **Refresh strategy:** read fresh `__session` cookie before each request (Clerk auto-refreshes in background)

### 3. Two account confusion trap
- `audit_account.py` confirmed account identity via `/user` endpoint — always verify which Google account is logged in to Higgsfield BEFORE running automation
- User-friendly profile handles like `@blueprint_otter_1011` are auto-generated and don't reveal email
- Only `JWT.email` field is reliable

### 4. Profile login flow gotchas
- Patchright spawns Chromium fresh — Google "Make Chromium your own" popup appears
- User must click **"Use Chromium without an account"** (NOT "Continue as X")
- Then accept cookies (NOT reject) — session cookies are essential
- THEN click Higgsfield Login → Continue with Google

### 5. Confirmed working API pattern

**Submit:**
```
POST https://fnf.higgsfield.ai/jobs/nano-banana-2
Authorization: Bearer {JWT from __session cookie}
Content-Type: application/json

{
  "params": {
    "prompt": "...",
    "input_images": [],
    "width": 1792, "height": 2400,
    "batch_size": 1,
    "aspect_ratio": "3:4",
    "is_storyboard": false,
    "is_zoom_control": false,
    "use_unlim": true,
    "resolution": "2k"
  },
  "use_unlim": true,
  "use_seedream_bonus": false
}
```

Response: `{ jobs: [{ id: "uuid-job-id", ... }], ... }` — extract `jobs[0].id`

**Poll:**
```
GET https://fnf.higgsfield.ai/jobs/{job_id}
Authorization: Bearer {token}
```

Returns `{ status: "waiting"|"in_progress"|"completed", results: { raw: { url: "https://d8j0ntlcm91z4.cloudfront.net/..." } } }`

**Download:** CDN URL needs no auth, plain GET works.

### 6. List/history
```
GET https://fnf.higgsfield.ai/jobs?limit=50
Authorization: Bearer {token}
```
Returns `{ jobs: [...] }` — useful to recover images that were generated but not saved locally.

### 7. Available `job_set_type` enum (130+ types)
Discovered via `POST /jobs/v2/foo` returning enum validation error. Includes: `nano_banana_2`, `nano_banana_flash`, `nano_banana_2_upscale`, `gpt_image_2`, `imagegen_2_0`, `seedream_v5_lite`, `flux_2`, `kling3_0`, `veo3_1`, etc.

But **submit endpoint** uses URL pattern `/jobs/{type-with-hyphens}` (e.g. `/jobs/nano-banana-2`), NOT `/jobs/v2/{type-with-underscores}`.

### 8. Prompt construction (proven to work with Nano Banana Pro)
- 150-200 word coherent prompts with: subject + action + environment + named lighting + camera/lens + era/tradition + color palette
- NO "8K masterpiece" / "beautiful" / "ultra detailed" boilerplate (Nano Banana Pro guide specifically says strip)
- Era-based style anchors (Dutch Golden Age, Sebastião Salgado school) — NEVER living artist names
- Reference: `~/Desktop/CLAUDE/higgsfield_loop/curated_prompts.py` for 15 working examples

## Reference files in working repo

- `browser.py` — `HiggsfieldSession.submit_via_api(prompt)` + `get_session_token()` + polling logic
- `curated_prompts.py` — 15 hand-crafted 200-word prompts that work
- `prompt_generator.py` — cycles through curated prompts with iteration heuristics
- `main.py` — autonomous loop, JSONL logging, image download
- `audit_account.py` — verify plan/credits via API
- `outputs/sniff_real.json` — captured real POST request schema (gold reference)

## Better long-term path

For new projects, use **official Python SDK** `higgsfield-ai/higgsfield-client` (handles JWT refresh + rate limits properly) instead of reverse-engineering. But the SDK requires API key, while this skill works with personal Ultimate plan via browser session — useful when API access isn't available.
