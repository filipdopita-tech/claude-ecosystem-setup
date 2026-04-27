# COST ZERO TOLERANCE — Google API & Paid Services

## HARDCORE RULE (NO EXCEPTIONS)

**NIKDY negeneruj náklady na Google API, Google Cloud nebo jakékoli placené Google služby bez PŘEDCHOZÍHO explicitního schválení Filipem.**

Toto pravidlo **PŘEPISUJE** ostatní rules. Zero tolerance.

**Incident historie:**
- 2026-04-17: CZK 1 019,73 overdue, Visa 9591 declined
- 2026-04-24: CZK 3 000 (~$125) Solar+Maps Platform via `nemakej-solar-outbound` pipeline

**Po 2. incidentu (2026-04-24) jsou aktivní HARD GUARDS na úrovni systému** — viz sekce "System Guards" níže. Pokud guard blokuje legitimní call, eskaluj Filipovi, nezkoušej obejít.

---

## Mandatory PRE-CALL Checks (Google APIs)

Před jakýmkoli Google API callem:
```
□ Je to 100% free tier s jistou kvótou? ANO → OK
□ Je to paid/pay-as-you-go? ANO → HALT, eskaluj
□ Vytvářím billable resource (VM, bucket, dataset, Vertex job)? ANO → HALT
□ Mám písemné Filipovo schválení s cenovou hranicí? NE → HALT
□ Může překročit free tier a auto-switch na paid? ANO → HALT
```

**Při JAKÉKOLI nejistotě → HALT + eskaluj.** Raději zbytečná otázka než nevyžádaný billing.

---

## POVOLENO (bez eskalace, free tier only)

- Gemini API — **jen přes `gemini --model gemini-2.5-flash`**, max 1500 req/den (free tier limit). Nad to STOP, ne retry, ne paid upgrade
- Gmail API / Google Drive / Calendar / People / Docs / Sheets — osobní OAuth free quota
- YouTube Data API read — do 10 000 units/den (monitor, nad to STOP)

---

## HARD STOP (vždy eskaluj, nikdy auto)

Všechny Google Cloud placené služby:
- Vertex AI (Gemini přes Vertex, Imagen, ostatní modely)
- Compute Engine, Cloud Run, Cloud Functions, App Engine
- Cloud Storage, BigQuery, Firestore, Cloud SQL
- Speech-to-Text, Text-to-Speech, Translation, Document AI
- Google Maps Platform
- Google Ads API
- Jakákoli "pay as you go" nebo "per-usage" služba
- Vytváření jakýchkoli nových GCP projektů s billing linked

---

## Při detekci neočekávaného billing

1. **HALT** — zastav všechny běžící Google API calls/scripty
2. **Isolate** — identifikuj zdroj (console.cloud.google.com → Billing → Reports → group by service)
3. **Disable** — pause/disable dotčenou službu (NE mazat bez schválení)
4. **Preserve** — zachovej logy (transakce, API volání)
5. **Escalate** — Filipovi: co to stojí, odkud to jde, jak to zastavit

---

## System Guards (ACTIVE od 2026-04-25)

### 1. PreToolUse hook na Claude Code Bash
- Soubor: `~/.claude/hooks/google-api-guard.sh`
- Konfigurace: `~/.claude/settings.json` → `hooks.PreToolUse[Bash]`
- Blokuje regex match na: `solar|maps|aiplatform|documentai|speech|texttospeech|translate|vision|cloudbilling|run|cloudfunctions|sqladmin|firestore|bigquery|compute|videointelligence|naturallanguage|dialogflow|automl).googleapis.com`
- Blokuje gcloud commands: `compute|run|functions|sql|storage (mb|cp|buckets)|bigquery|firestore|projects create|services enable <paid>|alpha billing`
- Override path: `GCP_GUARD_OVERRIDE=1 <command>` (loguje se do `~/.claude/logs/gcp-guard-overrides.log`)
- Test: `echo '{"tool_name":"Bash","tool_input":{"command":"curl https://solar.googleapis.com/..."}}' | ~/.claude/hooks/google-api-guard.sh`

### 2. Daily monitoring
- Cron na Macu: `0 8 * * * ~/scripts/automation/google-api-status.sh`
- Kontroluje: paid keys v env (Mac+VPS), nemakej-solar source state, paid API URLs v VPS logách za 24h
- Alerty: ntfy `https://ntfy.example.com/your-topic` při detekci paid endpoint nebo paid key
- Log: `~/.claude/logs/google-api-status.log`

### 3. Source code lockdown
- `nemakej-solar-outbound/` přejmenovaný na `_DISABLED_nemakej-solar-outbound_2026_04_24/` (Mac)
- `/root/workspace/nemakej-solar/` → `_DISABLED_nemakej-solar_2026_04_24/` (VPS Flash)
- `.DISABLED_DO_NOT_RUN` marker file v každé disabled složce
- Status check ve google-api-status.sh nastaví ALERT pokud original název znovu vznikne

### 4. Env cleanup
- `GOOGLE_SOLAR_KEY` smazán z `/root/.credentials/master.env` (VPS) — backup `master.env.bak.<ts>`
- `~/.claude/mcp-keys.env` (Mac) — žádné paid Google keys (verified clean 2026-04-25)
- Zůstává: 5× `GEMINI_API_KEY*` (free tier AI Studio), Drive/Gmail/Calendar/Sheets OAuth tokens (free quota)

---

## Co potřebuje Filip udělat manuálně (ACTION REQUIRED)

Tyto akce vyžadují perms, které nemám:

1. **Cloud Budget Alert $1** na OneFlow s.r.o. billing (`01F816-7D5746-4DEB7C`)
   URL: https://console.cloud.google.com/billing/01F816-7D5746-4DEB7C/budgets
   
2. **Verify v GCP konzoli** že Solar API + 32 Maps Platform APIs jsou stále DISABLED
   Project: `gen-lang-client-0656817314` (ClaudeCodeV3)
   URL: https://console.cloud.google.com/apis/dashboard?project=gen-lang-client-0656817314

3. **Zvážit smazání ClaudeCodeV3 projektu úplně** pokud Gemini key není potřeba
   (Gemini přes AI Studio key je separátní, projekt je ne nutný)

4. **Audit `oneflow-social-490512`** — jiný GCP projekt, ownership = OneFlow s.r.o., možná zdroj jiných nákladů
   URL: https://console.cloud.google.com/billing/01F816-7D5746-4DEB7C/reports

---

## Reference
- Billing account: **OneFlow s.r.o. — ID 01F816-7D5746-4DEB7C**
- Primary card: Visa ****9591 (expires 03/29) — DECLINED 2026-04-17
- Incident logy:
  - 2026-04-17: CZK 1 019,73 overdue za období Apr 1–16, 2026
  - 2026-04-24: CZK 3 000 (Solar API + Geocoding via nemakej-solar-outbound)
- Memory: `incident_gcp_cost_2026_04_24.md`, `gcp_hard_guards_2026_04_25.md`

**Platí retroaktivně: při jakémkoli Google API callu v session si projdi tento checklist. Prohřešek = reportovat Filipovi.**
