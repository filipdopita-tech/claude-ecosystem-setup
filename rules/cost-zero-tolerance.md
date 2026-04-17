# COST ZERO TOLERANCE — Google API & Paid Services

## HARDCORE RULE (NO EXCEPTIONS)

**NEVER generate costs on Google API, Google Cloud, or any paid Google service without PRIOR explicit approval from the user.**

This rule **OVERRIDES** other rules. Zero tolerance. One runaway bill is one too many.

---

## Mandatory PRE-CALL Checks (Google APIs)

Before any Google API call:
```
□ Is this 100% free tier with guaranteed quota? YES → OK
□ Is this paid / pay-as-you-go? YES → HALT, escalate
□ Am I creating a billable resource (VM, bucket, dataset, Vertex job)? YES → HALT
□ Do I have written user approval with a price cap? NO → HALT
□ Can this exceed the free tier and auto-switch to paid? YES → HALT
```

**At ANY uncertainty → HALT + escalate.** A wasted question is always cheaper than an unsolicited bill.

---

## ALLOWED (no escalation, free tier only)

- **Gemini API** — only via `gemini --model gemini-2.5-flash`, max 1500 req/day (free tier limit). Beyond that: STOP. No retry, no paid upgrade.
- **Gmail API / Google Drive / Calendar / People / Docs / Sheets** — personal OAuth free quota.
- **YouTube Data API read** — up to 10,000 units/day (monitor; above that: STOP).

---

## HARD STOP (always escalate, never auto)

All Google Cloud paid services:
- Vertex AI (Gemini via Vertex, Imagen, other models)
- Compute Engine, Cloud Run, Cloud Functions, App Engine
- Cloud Storage, BigQuery, Firestore, Cloud SQL
- Speech-to-Text, Text-to-Speech, Translation, Document AI
- Google Maps Platform
- Google Ads API
- Any "pay as you go" or "per-usage" service
- Creating any new GCP project with billing linked

---

## On Detecting Unexpected Billing

1. **HALT** — stop all running Google API calls/scripts
2. **Isolate** — identify the source (console.cloud.google.com → Billing → Reports → group by service)
3. **Disable** — pause/disable the affected service (do NOT delete without approval)
4. **Preserve** — keep logs (transactions, API calls)
5. **Escalate** — notify the user: what it costs, where it comes from, how to stop it

---

## Preventive Guards (recommended deployment)

- **Google Cloud Budget Alert**: set a low threshold (e.g. $1) on your billing account
- **`GOOGLE_APPLICATION_CREDENTIALS`** should only be available for clearly identified free-tier operations
- **Separate Gemini API keys**: if your primary key is linked to billing, keep a separate free-tier-only key (AI Studio) for routine work
- **IAM separation**: service accounts that can create paid resources should NOT be used for routine automation

---

## Customization

Replace the placeholders below with your own billing context when adopting this rule:

```
Billing account: [YOUR_BILLING_ACCOUNT_ID]
Primary card: [YOUR_CARD_REFERENCE] (expires [EXPIRY])
Budget alert threshold: [YOUR_THRESHOLD]
Escalation channel: [USER_NOTIFICATION_METHOD — e.g. ntfy, email, Slack]
```

**This rule applies retroactively: at any Google API call during a session, walk through the checklist above. Violations must be reported to the user.**
