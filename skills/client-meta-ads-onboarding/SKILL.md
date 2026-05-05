---
name: client-meta-ads-onboarding
description: Onboarding nového klienta pro Meta Ads — 2 cesty (A=per-klient System User pro IHNED, B=OneFlow App Live mode pro permanent scaling). Replikuje proven Lachman pattern (2026-04-29). Trigger - "onboarduj klienta X na Meta Ads", "nový klient pro reklamy", "setup Meta Ads pro klienta", "klient mi dal admin v BM", "rozbal Meta Ads nabídku pro klienta".
allowed-tools:
  - Bash
  - Read
  - Write
  - WebFetch
---

# Client Meta Ads Onboarding (2-path architecture)

> **Cíl:** Onboarduj nového klienta pro Meta Ads tak, aby OneFlow měl plnou kontrolu, klient nedělal nic kromě 1-2 mikro-akcí, a setup byl 100% replikovatelný.
>
> **Outcome:** Programmatic campaign + adsety + ads PAUSED, ready k 1-click ACTIVATE.

---

## Decision Tree — Path A vs Path B

```
Je OneFlow App v Live mode (App Review approved)?
├─ ANO → použij Path B (OneFlow App token, 0 per-klient overhead)
└─ NE  → použij Path A (per-klient System User, 15 min Filip work) + paralelně submit App Review
```

| Dimenze | Path A | Path B |
|---|---|---|
| Per nový klient | 10-15 min Filip UI | 0 min |
| Klient akce | Add Filip BM admin | Add Filip BM admin |
| Token kustodie | 1 per klient (env files) | 1 (OneFlow App) |
| Ready do | 15 min | Po 1× App Review (1-7 dní), pak instant |
| Profesionalita | "agency hack" | "ověřená marketing platform" |
| App Review | Ne | **Ano (1× pro all clients)** |

**Filip 2026-04-29 explicit:** "Dá se to dělat tak, že dám full access své aplikaci OneFlow která už je ověřená?" → ANO, to je Path B.

**Současný status:** OneFlow App `1587515299033044` v Dev mode → App Review submission READY (`~/Documents/lachman-oneflow/APP-REVIEW-SUBMISSION-2026-04-29.md`). **Submit IHNED → Path B = default forward.**

---

## PATH B — OneFlow App Live mode (DEFINITIVE, target state)

### Pre-requisite: App Review approved (1× setup)

1. Filip submit App Review pro:
   - `ads_management` Advanced Access
   - `pages_manage_ads` Advanced Access
2. URL: https://developers.facebook.com/apps/1587515299033044/app-review/permissions/
3. Submission package: `~/Documents/lachman-oneflow/APP-REVIEW-SUBMISSION-2026-04-29.md` (use case + screencast script READY)
4. Wait: 1-7 dní Meta review

### Per-klient onboarding (po App Review approve)

**Klient akce (5 min):**
- Klient → BM Settings → People → Add Filip s Admin rolí
- Klient přidá payment method (postpaid karta OK)

**Filip akce (5 min):**
- Filip akceptuje BM admin invite
- Filip vygeneruje "User access token" pro OneFlow App s scopes:
  - URL: https://developers.facebook.com/tools/explorer/?app_id=1587515299033044
  - Scopes: ads_management + ads_read + pages_manage_ads + pages_show_list + pages_read_engagement + leads_retrieval + business_management
- Pošle token Claude: `<KLIENT>_OFA_TOKEN=EAA...`

**Claude akce (5 min, autonomous):**
- Save token → /root/.credentials/<klient>_meta.env
- Spustit `client_meta_ads_setup.py` s OneFlow App tokenem
- Vytváří kampaň + 3 adsety + Lead Form + 12-15 ads PAUSED

**Filip akce (10 sec):**
- 1-click activate kampaň/adsety/ads přes Ads Manager UI nebo curl

**Total: 15 min Filip + 5 min klient = 20 min onboarding nového klienta.**

⚠️ **User token expiruje za 60 dní** (i v Live mode App). Pro permanent token v Path B:
- Vytvoř System User v OneFlow BM (jednorázově, ne v klient BM!)
- Dej System Useru pages_manage_ads/ads_management permissions
- Klient sdílí Ad Account jako Partner s OneFlow BM (Settings → Partners)
- OneFlow System User pak může operovat v klient Ad Account přes Partner connection
- → kombinace Path B (App Review) + System User v OneFlow BM (ne v klient BM) = best of both

---

## PATH A — Per-klient System User (FALLBACK / IMMEDIATE)

> Použij když: (a) App Review ještě neschválen, (b) klient potřebuje IHNED <1 hod, (c) Path B nevhodný (klient nechce dát Filipa BM admin).

### Princip

1. **Filip = admin v klientově BM** → může vytvořit System User token sám.
2. **System User token = bypass App Dev mode** (1885183) bez App Review.
3. **Token nikdy neexpiruje** → 0 maintenance overhead per token.
4. **Klient dělá max 2 věci:** (a) Add Filip jako BM admin, (b) Funding karty (postpaid OK).

---

## Pre-requisites (zjisti od klienta PŘED onboardingem)

```
□ Klient má Business Manager (ne Personal ad account)?
  → NE: Klient musí vytvořit BM (5 min) na business.facebook.com/create
□ Klient má Page (ne osobní profil)?
  → NE: Klient musí Page vytvořit nebo přepnout na Page
□ Klient má pixel/dataset?
  → NE: Filip vytvoří přes Events Manager (5 min)
□ Klient má payment method na BM?
  → NE: Klient přidá VISA/MC (postpaid OK, prepaid lepší pro budget cap)
□ Klient bude admin Page přes BM (ne separátně)?
  → BM = single source of truth
```

---

## Setup workflow (~30 min total Filip work, ~5 min klient work)

### Fáze 1: Klient → Filip admin v BM (5 min, jen 1× per klient)

Klient pošle Filipovi:
1. URL: https://business.facebook.com/settings/people?business_id=<KLIENT_BM_ID>
2. Add People → email Filipa → Admin role → klient potvrdí

**Filip akceptuje invite v emailu.** Po accept = full admin v BM.

**(Alternativní cesta: klient přidá Filipa přes business.facebook.com/settings/partners — Partner BM Connection. Funguje, ale komplikovanější pro permissions na ads.)**

### Fáze 2: Filip → vytvoř System User v klient BM (10 min)

Filip provede sám (návod identický pro každého klienta):

1. **Otevři BM Settings:**
   ```
   https://business.facebook.com/settings/system-users?business_id=<KLIENT_BM_ID>
   ```
   Top-right dropdown → vyber klientův BM.

2. **Add System User:**
   - Klikni **+ Add**
   - Name: `oneflow-marketing-su` (konvence — replikovatelné)
   - Role: **Admin**
   - Klikni **Create System User**

3. **Add Assets** (per asset, 3×):

   **3a) Ad Account:**
   - Asset Type: Ad Accounts
   - Select: `act_<CLIENT_AD_ACCOUNT>`
   - Permission: ✅ Manage ad account
   - Save Changes

   **3b) Page:**
   - Asset Type: Pages
   - Select: klientovu Page
   - Permissions: ✅ Manage Page + Create ads + Moderate + Insights
   - Save Changes

   **3c) Pixel/Dataset:**
   - Asset Type: Datasets
   - Select: klientův pixel
   - Permission: ✅ Manage Pixel
   - Save Changes

4. **Generate Token:**
   - Stále na user detail page → klikni **Generate New Token**
   - App: vyber jakoukoliv App pod klientovým BM (může být OneFlow App `1587515299033044`, nebo vlastní)
   - **Token Expiration:** **Never**
   - Permissions checkboxy:
     - ✅ `ads_management`
     - ✅ `ads_read`
     - ✅ `business_management`
     - ✅ `pages_manage_ads`
     - ✅ `pages_show_list`
     - ✅ `pages_read_engagement`
     - ✅ `pages_manage_metadata`
     - ✅ `leads_retrieval`
     - ✅ `read_insights`
     - ✅ `publish_video`
   - Klikni **Generate Token**
   - **ZKOPÍRUJ token** (vidíš jen 1×!) — vypadá jako `EAAxxx…` ~200+ znaků

### Fáze 3: Filip → Claude (1 min)

Filip pošle Claude v zabezpečené zprávě (Claude Code):

```
<KLIENT_NAME>_OWN_TOKEN=EAAXXXXXXXXXX...
```

Claude provede:
```bash
# 1. Save credentials
mkdir -p /root/.credentials
echo "<KLIENT_NAME>_OWN_TOKEN=<token>" >> /root/.credentials/<klient>_meta.env
chmod 600 /root/.credentials/<klient>_meta.env

# 2. Verify token (probe)
curl -sS "https://graph.facebook.com/v23.0/debug_token?input_token=<token>&access_token=<token>" | jq .

# 3. (volitelně) Smaž zprávu z chatu (Filip Claude Code → /clear)
```

### Fáze 4: Claude → programmatic setup (5 min, autonomně)

Claude spustí `client_meta_ads_setup.py` (template — copy + nahraď IDs):

```python
# Inputs:
# - <KLIENT_NAME>_OWN_TOKEN
# - CLIENT_AD_ACCOUNT
# - CLIENT_PAGE_ID
# - CLIENT_PIXEL_ID
# - VIDEO_FILE_PATHS (15× MP4 nebo cokoliv co klient natočil)
# - LEAD_FORM_FIELDS (default: full_name + email + phone)
# - DAILY_BUDGET_CZK (default: 400 = 12k/měs)
# - PERSONAS (default: 3 — INVESTOŘI, PODNIKATELÉ, BROAD)

# Output:
# - 1× Campaign LEADGEN PAUSED (FINANCIAL_PRODUCTS_SERVICES)
# - 3× Adset PAUSED (CBO LOWEST_COST_WITHOUT_CAP, ON_AD destination, LEAD_GENERATION)
# - 1× Lead Form (full_name + email + phone, custom intro/disclaimer)
# - 12-15× LEADGEN ad PAUSED, attached k Lead Form
# - 15× Page video uploaded, image_hash thumbnails generated
# - State JSON persisted: ~/Documents/<klient>-oneflow/campaign-state.json
```

Reference template (modificuj per klient): `~/Documents/lachman-oneflow/create_12_leadgen_ads.py`

### Fáze 5: Filip → 1-click activate (10 sec)

```bash
# Filip stiskne 1× → kampaň jde live
LACHMAN_OWN_TOKEN=$(cat /root/.credentials/<klient>_meta.env | cut -d= -f2)
curl -X POST "https://graph.facebook.com/v23.0/<CAMPAIGN_ID>" \
  -d "access_token=$LACHMAN_OWN_TOKEN" -d "status=ACTIVE"
# + 3× adsety + ~12 ads (programmatic loop)
```

(Nebo přes UI: Ads Manager → Filter campaign → Toggle ON. Stejný efekt.)

---

## Standard architecture (proven defaults)

| Komponenta | Default | Důvod |
|---|---|---|
| Campaign objective | OUTCOME_LEADS | Lead Form + ON_AD destination = nejlepší optimization signal |
| Special ad category | FINANCIAL_PRODUCTS_SERVICES | Compliance pro CZ finanční klienty (Lachman, OneFlow) |
| Bid strategy | LOWEST_COST_WITHOUT_CAP | CBO learning phase rychlejší |
| Adset destination_type | ON_AD | Native FB experience > redirect na website |
| Adset optimization_goal | LEAD_GENERATION | Pair s ON_AD |
| Daily budget total | 12 000 Kč/měs ÷ 30 = 400 Kč/d | Sweet spot pro mid-market CZ klienty |
| Adset split | 3× persona (INVESTOŘI / PODNIKATELÉ / BROAD) | Diversifikace bez přefragmentace |
| Lead Form fields | full_name + email + phone | Min friction pro telefon-first sales |
| Lead Form context | "Investování nese riziko ztráty kapitálu" + GDPR | Compliance |
| Ad placements | Automatic (FB+IG+Reels+Stories) | CBO si vybere kde performs |
| Targeting | Default broad CZ + age 18-65 | FINANCIAL_PRODUCTS_SERVICES blokuje custom age |
| Number of ads | 12-15 (po 4-5 per adset) | Sweet spot pro creative testing |
| Status na vytvoření | PAUSED | Filip review před live |

---

## Failure modes & remediations

| Symptom | Diagnosis | Fix |
|---|---|---|
| "You don't have permission to create System User" | Filip není admin v klientově BM | Klient musí Add People → Filip → Admin |
| Token Generate selže | App přes který scopes nepovolen | Vyber jinou App, nebo pouze `ads_management` + `pages_manage_ads` + `leads_retrieval` (minimum scope) |
| `1885183` (App Dev mode) | Používáš OneFlowApp na klient BM | Použij token z System User (žije pod klient BM, bypass) |
| `1885559` (attribution invalid) | Mixed adset objectives | Vyčisti — všechny adsety stejný optimization_goal |
| `1885760` (CBO uniformity) | LOWEST_COST_WITHOUT_CAP s mixed | Sjednoť bid_strategy + optimization_goal |
| `1443226` (missing thumbnail) | Creative bez image_hash | Fetch FB CDN thumbnail per video, upload jako image |
| `2061015` (missing URL) | ON_AD adset s WEBSITE destination | Nastav destination_type=ON_AD, vyhoď link_url |
| Token expired | App rotuje permissions | Filip regeneruje token (System User → Generate New Token) |
| Bounce/freeze adsety | Pixel events chybí | Verify pixel přes Events Manager → Test Events |
| Lead Form approval rejection | Disclaimer nedostatečný | Add `"Investování nese riziko ztráty kapitálu"` + odkaz na GDPR |

---

## Bezpečnost & token rotation

- **Token na disku:** `/root/.credentials/<klient>_meta.env` — chmod 600, root-only.
- **Backup:** Nikdy do gitu, nikdy do Mac /Documents (sync risk). Mountnuto SSHFS read-only z Mac perspektivy.
- **Rotation cadence:** "Never" expiry → 0 maintenance. Pokud klient revoke (account compromise), Filip regeneruje a Claude updatne env file.
- **Audit:** Měsíčně audit přes `https://business.facebook.com/settings/system-users` — kontrola že System User stále existuje + má correct assets.

---

## Replication checklist (per nový klient)

```
□ Klient má BM, Page, pixel, payment? (Pre-requisites)
□ Klient přidal Filipa jako admin v BM
□ Filip vytvořil System User `oneflow-marketing-su` (jméno konvence)
□ Filip Add Assets: ad_account + page + pixel
□ Filip Generate Token (Never, 10 scopes)
□ Filip předal token Claude přes secure channel
□ Claude saved /root/.credentials/<klient>_meta.env (chmod 600)
□ Claude probe debug_token PASS
□ Claude vytvořil Campaign + 3 Adsety + Lead Form + 12-15 Ads PAUSED
□ Claude verify přes audit script (14-dim PASS rate >85%)
□ Filip review v Ads Manager (status PAUSED, copy, targeting, budget)
□ Filip 1-click ACTIVATE (campaign + adsety + ads)
□ Monitor: weekly summary email (reach, CPL, top creatives)
```

---

## Future-proof maintenance

**Per měsíc:**
- Spend report (Ads Manager → Performance → CSV export)
- Top performing 3 ads → repurpose pro broader scaling
- Bottom performing 3 ads → pause (kanibalizace pozornosti)
- Lead quality check (CRM/GHL: jak konvertují Form fills → BankID start → contract?)

**Per kvartál:**
- Token health check (debug_token call)
- Asset audit (Ad Account / Page / Pixel stále attached?)
- Compliance review (CZ regulační změny → update disclaimer?)

---

## Reference (Lachman EasyFunding case study)

První úspěšná aplikace tohoto patternu:
- **Klient:** Tomáš Lachman (EasyFunding s.r.o.)
- **BM ID:** 298000769529236
- **Ad Account:** act_1484045569832316
- **Page:** 141650492356043
- **Pixel:** 1494347519061079
- **Setup date:** 2026-04-29
- **Campaign:** LACHMAN-EF-LEADGEN-V2-2026Q2 (id: 120246179198800624)
- **Budget:** 400 CZK/d (12k Kč/měs)
- **Ads:** 12 LEADGEN attached na Lead Form 1882415553173795
- **Time to setup:** ~6 hodin (debug + 10 API bypass attempts) → cca 30 min při replikaci s tímto skillem

**Files (template):**
- `~/Documents/lachman-oneflow/create_12_leadgen_ads.py` — programmatic creator
- `~/Documents/lachman-oneflow/100-AUDIT-2026-04-29.sh` — 14-dim audit
- `~/Documents/lachman-oneflow/campaign-state.json` — state schema

---

## Anti-patterns (NIKDY)

- ❌ Posílat klientovi Filipovy Safari cookies (FB safety, viz `fb-scrape-safety.md`)
- ❌ Použít headless Playwright pro klientovo přihlášení (account block risk)
- ❌ Vytvořit kampaň ACTIVE od start (vždy PAUSED → Filip review → activate)
- ❌ Mixovat optimization_goals napříč adsety s CBO (uniformity rule)
- ❌ Přidávat custom age targeting v FINANCIAL_PRODUCTS_SERVICES (auto-reject)
- ❌ Linkovat external URL v ON_AD adset (URL spec mismatch)
- ❌ Skip System User → forcovat OneFlowApp na partner BM = 1885183 wall

---

## Cost & ROI forecast (typical mid-market CZ klient)

| Tier | Budget | Expected outcome |
|---|---|---|
| Test (M1) | 5–10k Kč | 10-30 form fills, hledání CPL baseline |
| Scale (M2-M3) | 12-20k Kč | 30-80 form fills/měs, CPL 250-400 Kč |
| Mature (M4+) | 25-50k Kč | 80-200 form fills/měs, CPL 200-350 Kč, ROAS 3-5× |

**OneFlow retainer fee** (suggested): 8-15k Kč/měs (setup + manage + report).

**Total client cost** (M2): ~20-35k Kč/měs (12-20k ad spend + 8-15k OneFlow fee).

---

— Dopita
