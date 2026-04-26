# Cost Discipline — Multi-Layer Defense

Most Claude setups treat "cost discipline" as a single rule in CLAUDE.md ("don't generate costs without approval"). That's necessary but **not sufficient** — LLMs forget rules under pressure or when mid-task.

This stack runs **4 independent defense layers**, each capable of stopping a cost-generating action:

---

## Why this exists (the real incidents)

This is not theoretical. This stack was hardened after **two real billing incidents** in April 2026:

| Date | What happened | Cost |
|---|---|---|
| 2026-04-17 | Overdue billing on Google Cloud, Visa declined | CZK 1,019.73 |
| 2026-04-24 | Solar API + 32 Maps Platform APIs auto-billed via `nemakej-solar-outbound` pipeline | CZK 3,000 (~$125) |

**Root cause** in both cases: rule was in place, but a single layer (LLM compliance) wasn't enough. So 4-layer defense was implemented after incident #2.

---

## Layer 1 — Rule (`rules/cost-zero-tolerance.md`)

**File**: 5.6K explicit rule loaded into every session via CLAUDE.md.

**Mandatory pre-call checklist** before any Google API call:
```
□ Is this 100% free tier with hard quota? YES → OK
□ Is this paid/pay-as-you-go? YES → HALT, escalate
□ Am I creating a billable resource (VM, bucket, dataset)? YES → HALT
□ Do I have written approval with price ceiling? NO → HALT
□ Could this exceed free tier and auto-switch to paid? YES → HALT
```

**Allowed without escalation** (free tier only):
- Gemini API via `gemini --model gemini-2.5-flash` (1500 req/day cap)
- Gmail / Drive / Calendar / People / Docs / Sheets (personal OAuth quota)
- YouTube Data API read (10,000 units/day, monitored)

**Hard stop** (always escalate):
- Vertex AI, Compute Engine, Cloud Run, Cloud Storage, BigQuery, Maps Platform
- Any "pay as you go" or per-usage service
- New GCP projects with billing linked

---

## Layer 2 — Hook (`hooks/google-api-guard.sh`)

**File**: 5.7K PreToolUse Bash hook.

**Activation**: Every Bash command Claude tries to run is intercepted.

**Blocking regex matches:**
```
solar|maps|aiplatform|documentai|speech|texttospeech|translate|vision|
cloudbilling|run|cloudfunctions|sqladmin|firestore|bigquery|compute|
videointelligence|naturallanguage|dialogflow|automl
).googleapis.com
```

Plus blocked gcloud subcommands:
```
gcloud (compute|run|functions|sql|storage (mb|cp|buckets)|bigquery|
        firestore|projects create|services enable <paid>|alpha billing)
```

**Override path**: `GCP_GUARD_OVERRIDE=1 <command>` (logged to `~/.claude/logs/gcp-guard-overrides.log`)

**Test**:
```bash
echo '{"tool_name":"Bash","tool_input":{"command":"curl https://solar.googleapis.com/..."}}' | \
  ~/.claude/hooks/google-api-guard.sh
# → BLOCKED
```

This catches the LLM even when it forgets the rule mid-task.

---

## Layer 3 — Cron monitor (`scripts/automation/google-api-status.sh`)

**Schedule**: Every hour at :15 (`15 * * * *`)

**Checks:**
- Paid API keys present in `~/.claude/mcp-keys.env` (Mac) or `/root/.credentials/master.env` (VPS)
- `nemakej-solar-outbound` directory state (must remain `_DISABLED_*`)
- Paid API URLs in VPS logs over last 24 hours
- Billing-linked GCP projects (alerts if any project flips to billingEnabled=true)

**Alerts**: ntfy push to `https://ntfy.oneflow.cz/Filip` on detection.

**Log**: `~/.claude/logs/google-api-status.log`

**Why hourly:** an LLM running off-hours (cron-triggered batch jobs) could trigger a paid API. The monitor catches it within 60 minutes, well before billing cycle close.

---

## Layer 4 — Source code lockdown

**Disabled directories** (after incident #2):
```
~/Documents/_DISABLED_nemakej-solar-outbound_2026_04_24/   (Mac)
/root/workspace/_DISABLED_nemakej-solar_2026_04_24/        (VPS Flash)
```

Each contains `.DISABLED_DO_NOT_RUN` marker file. Layer 3 monitor alerts immediately if the original directory name reappears (= someone tried to revive the pipeline).

**Env cleanup**: `GOOGLE_SOLAR_KEY` deleted from `master.env` (backed up first). `~/.claude/mcp-keys.env` audited; only free-tier keys remain (5× `GEMINI_API_KEY*`, OAuth tokens for Drive/Gmail/Calendar/Sheets).

---

## What this looks like in practice

**Scenario**: LLM, mid-task, decides it needs geocoding data and tries:
```bash
curl https://maps.googleapis.com/maps/api/geocode/json?address=Praha&key=AIza...
```

| Layer | Outcome |
|---|---|
| Layer 1 (rule) | LLM should self-halt — but might forget under pressure |
| Layer 2 (hook) | **BLOCKS** — `maps.googleapis.com` matches deny regex, exit 2, command never runs |
| Layer 3 (cron) | Would have caught it within 60 min if it slipped through (e.g., variable URL substitution) |
| Layer 4 (source) | The source pipeline (`nemakej-solar`) is renamed `_DISABLED_` and Layer 3 alerts on attempted rename-back |

**Defense in depth**: each layer is independent. Only ALL FOUR failing simultaneously would result in unbilled action — and Layer 3's cron would still catch it in the same billing cycle.

---

## Manual actions still required (humans-only)

These need permissions Claude doesn't have:

1. **Cloud Budget Alert at $1** on OneFlow s.r.o. billing account (`01F816-7D5746-4DEB7C`)
2. **Periodic verify in GCP Console** that paid APIs are still DISABLED on `gen-lang-client-0656817314`
3. **Consider deletion** of unused GCP projects (Gemini AI Studio key is independent of any project)

Layer 1 documents these explicitly under "ACTION REQUIRED."

---

## Adapting this for your stack

**The pattern transfers** to any cost-generating external service:

| Service | Layer 1 (rule) | Layer 2 (hook regex) | Layer 3 (cron monitor) |
|---|---|---|---|
| OpenAI API | "no GPT-4 without approval" | block `api.openai.com` in dangerous contexts | hourly token usage check |
| AWS | "no `aws ec2 run-instances`" | block billable verbs (`run-instances`, `create-bucket`) | hourly Cost Explorer poll |
| Anthropic API | "respect rate limits" | block `api.anthropic.com` from background jobs | usage dashboard scrape |
| Stripe | "no live mode in dev" | block `live_*` keys in non-prod env | webhook for charge events |

**Key insight**: rule alone fails. Hook alone fails (LLM can construct unusual URLs). Monitor alone fails (60-min lag). Source lockdown alone fails (LLM can re-create directory). **All four together = robust.**

---

## Score impact

This is why "cost discipline" is rated 8.5+/10 here, not 7/10:
- Single-rule setups get 7/10 (the rule is necessary but the LLM can violate)
- Hook-only setups get 7.5/10 (catches direct calls but not novel URL constructions)
- This 4-layer setup gets 9.5+/10 (defense in depth, real incident response, public documentation)
- 10/10 would require a fifth layer: pre-commit secret scan (also implemented, see [`hooks/gitleaks-guard.sh`](hooks/) for the analogous pattern on credential leaks)
