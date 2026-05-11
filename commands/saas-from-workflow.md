---
name: saas-from-workflow
description: "Konvertuje existující automation/workflow do plně nasazené SaaS aplikace (frontend + backend + auth + Stripe + deploy). Pattern z chase-ai 'n8n Workflow to Deployed SaaS'. Pro: OneFlow nabídky workspace produkty, klient deliverables nad 100k Kč, productized services. Trigger: /saas-from-workflow <workflow_path|description>, 'udělej z toho SaaS', 'productize tento workflow', 'nasaď to jako produkt'."
argument-hint: "<workflow_json|description> [--auth=supabase|nextauth] [--payment=stripe|none] [--deploy=vercel]"
user-invocable: true
allowed-tools:
  - Bash
  - Task
  - Read
  - Write
  - Edit
  - Grep
  - WebFetch
metadata:
  source: "skool-intel cherry-pick 2026-04-28: chase-ai 'Claude Code: n8n Workflow to Deployed SaaS' + 'Turn n8n Workflows into AI Saas Products' + cc-strategic 'Why I Stopped Creating AI Workflows'"
  filip-adaptace: "Místo n8n workflow → libovolná Conductor automation / Bash script / OneFlow workspace tool. Default stack Next.js + Supabase + Stripe + Vercel."
---

# SaaS From Workflow — Productize Any Automation

**Cíl:** Vzít rozumný automation workflow (n8n JSON / Conductor script / Bash pipeline / OneFlow workspace tool) a vyrobit z něj **plně nasazenou SaaS** s frontendem, auth, payments a deployem za <2 dny.

**Argument:** `$ARGUMENTS` — workflow path NEBO popis workflowu + flags.

## Why this exists

Skool insight (chase-ai "Why I Stopped Creating AI Workflows"): n8n workflow je **prototyp**, ne produkt. Customer chce klikací app, ne JSON file. Pattern shift:

```
DRIVE: n8n/Conductor workflow → JSON file → Manual ops → No revenue
NEW:   Same workflow → Claude Code → Next.js app → Auth + Stripe → Recurring revenue
```

**Filip's parallel:** OneFlow Nabídky workspace, Social Publisher, Conductor, Meta Ads platform — všechno produkty, ne workflows. Tento skill formalizuje pattern.

## Pipeline (5 fází, ~12-16 hodin total)

### Phase 1: PRD (Product Requirements Document) — 60-90 min

```markdown
# PRD: {Product Name}

## Problem
- Kdo má tento problém? (target customer profile)
- Jak ho dnes řeší? (alternatives)
- Co je painfullní? (cost, time, error rate)

## Solution
- Core value prop (1 sentence)
- Top 3 features (must-have for v1)
- Out of scope (explicit, prevents scope creep)

## Architecture
- Frontend: Next.js 14 App Router + Tailwind + shadcn
- Auth: Supabase NEBO NextAuth (volba per use case)
- Backend: Next.js API routes + Supabase Postgres
- Payment: Stripe (subscription nebo one-time)
- Deploy: Vercel + Supabase Cloud

## Data model
- Tables (entities + relationships)
- API endpoints (REST nebo tRPC)

## User flows (3 critical)
- Sign up + onboarding
- Core workflow (the value)
- Payment + upgrade

## Success metrics (post-launch)
- Activation rate (signed up → first value)
- Conversion rate (free → paid)
- MRR target month 1, 3, 6
```

**Save to:** `~/Documents/saas-projects/{slug}/PRD.md`

### Phase 2: Architecture + Scaffold — 30-45 min

```bash
SLUG=$(echo "$PRODUCT_NAME" | tr 'A-Z' 'a-z' | tr -cd 'a-z0-9-')
PROJECT="$HOME/Documents/saas-projects/$SLUG"
mkdir -p "$PROJECT" && cd "$PROJECT"

# Next.js + TypeScript + Tailwind
npx create-next-app@latest . \
  --typescript --tailwind --app --no-src-dir \
  --import-alias "@/*" --use-npm

# shadcn/ui
npx shadcn-ui@latest init -d
npx shadcn-ui@latest add button card dialog input form toast

# Supabase (auth + DB)
npm install @supabase/supabase-js @supabase/ssr

# Stripe
npm install stripe @stripe/stripe-js

# Initial supabase project (create dashboard.supabase.com)
# Supabase CLI link
supabase init
supabase link --project-ref ${SUPABASE_PROJECT_REF}
```

### Phase 3: Implementation — 6-10 hodin (rozdělit na waves)

**Wave 1 — Auth + DB (paralelně 2 subagenty)**
- Subagent A: Supabase migrations (users, profiles, settings tables)
- Subagent B: Auth flows (sign up, sign in, password reset, OAuth)

**Wave 2 — Core workflow (single agent, full context)**
- Implementuj core value workflow přímo (nejde paralelizovat — flow má state)
- Tests pro happy path

**Wave 3 — Payment + Subscription (paralelně 2 subagenty)**
- Subagent C: Stripe Checkout integration + webhook handler
- Subagent D: Pricing page + upgrade flow UI

**Wave 4 — Polish (paralelně 3 subagenty)**
- Subagent E: Email notifications (Resend nebo Supabase)
- Subagent F: Analytics (PostHog nebo Plausible — both free tier)
- Subagent G: Error tracking (Sentry free tier)

### Phase 4: Pre-Deploy Gate — 30 min

Use `/agent-loop` review pattern:

```
investigate: gsd-code-reviewer subagent
review: security-auditor subagent (auth + Stripe + injection)
pickup: apply fixes if any
```

Manual checklist:
- [ ] All env vars set in Vercel dashboard (NEXT_PUBLIC_* + secrets)
- [ ] Supabase RLS policies enabled per table
- [ ] Stripe webhook secret in Vercel env
- [ ] Lighthouse > 90 (perf + a11y + SEO)
- [ ] No secrets in git (.env in gitignore)
- [ ] Brand voice check pokud klient-facing copy (oneflow-brand-voice-check OpenSpace)

### Phase 5: Deploy + Launch — 15 min

```bash
cd "$PROJECT"
vercel --prod --yes  # Filip má Vercel access

# Custom domain (optional)
vercel domains add ${PRODUCT_NAME}.oneflow.cz
vercel alias set ${VERCEL_URL} ${PRODUCT_NAME}.oneflow.cz

# Production URL → notification
ntfy send "Filip" "🚀 SaaS: ${PRODUCT_NAME} ready → https://${PRODUCT_NAME}.oneflow.cz"
```

## Tech Stack Defaults (per Filip's existing setup)

| Layer | Default | Alternative | Reason |
|---|---|---|---|
| Frontend | Next.js 14 App Router | Remix | Filip má Vercel + Next expertise |
| Styling | Tailwind + shadcn | CSS modules | Per `expertise/frontend-ui.yaml` |
| Auth | Supabase Auth | NextAuth.js | Built-in, less boilerplate |
| DB | Supabase Postgres | PlanetScale | Bundled with auth |
| Payment | Stripe | LemonSqueezy | Filip's existing reference |
| Email | Resend | Postmark | Free tier 100/day |
| Analytics | Plausible | PostHog | Privacy + simple |
| Error tracking | Sentry | Logtail | Free tier sufficient |
| Deploy | Vercel | Cloudflare Pages | Filip's Vercel access ready |

## OneFlow Brand Defaults

- Color palette: monochrome #0A0A0C / #F2F0ED (per `oneflow-brand-manual-2026.md`)
- Font: Inter Tight only
- No emojis in UI (max 1-2 per page)
- No Czech "vykřičníky" v B2B copy
- Footer: "OneFlow s.r.o. © {year}" + GDPR disclaimer
- Cookie banner: minimal (Plausible doesn't need consent)

## Anti-Patterns (NIKDY)

- **Skip PRD phase** — implementation drift, scope creep, missed requirements
- **Implementuj všechno serially** — wave architecture exists pro reason
- **Deploy bez security audit** — auth + Stripe injection risks
- **Custom auth roll-your-own** — use Supabase/NextAuth, ne reimplementuj OAuth
- **Hardcoded API keys v kódu** — vždy env vars, nikdy commit
- **Skip Stripe webhook signing verification** — payments fraud risk
- **Marketing copy bez brand voice check** — oneflow-brand-voice-check OpenSpace mandatory pre-deploy

## Use Case Library (OneFlow specific examples)

### Example 1: ARES Lookup Tool → SaaS
- Workflow: ARES API call + enrichment + export
- SaaS: oneflow-ares-lookup.com — 50 lookups/měsíc free, 500 paid
- Stripe: $19/měsíc subscription
- Build time: ~12 hodin

### Example 2: DD Pre-Screen → SaaS (zatim klient-facing not ready)
- Workflow: oneflow-dscr-screener + oneflow-ltv-screener (OpenSpace)
- SaaS: pre-screen.oneflow.cz — input ICO, get GO/REVIEW/RED
- Stripe: $49/screen one-time nebo $99/měsíc unlimited
- Build time: ~16 hodin

### Example 3: Cold Email Compliance Checker → SaaS
- Workflow: oneflow-deliverability-check + oneflow-brand-voice-check
- SaaS: email-check.oneflow.cz — input draft, get SEND/HOLD/FIX
- Stripe: $9/checking-pack 50 calls
- Build time: ~10 hodin

## Cost Discipline

- Vercel: free hobby tier (sufficient for MVP, $20/mo Pro pokud >100GB bandwidth)
- Supabase: free tier 500MB DB, 1GB storage, 2GB bandwidth (sufficient pro <1000 users)
- Stripe: 2.9% + $0.30 per transaction (only on actual revenue)
- Resend: 100 emails/day free
- Plausible: $9/mo cheapest paid (eval pokud free analytics needed)
- Sentry: 5k errors/mo free
- **Total fixed cost MVP: $0/měsíc** (revenue-aligned scaling)

## Integrace s ostatními skills

- `/site-builder` — pre-step for landing page bez auth/payment
- `/copyweb` — pixel-perfect base layout copy
- `/feature` — komplementární skill pro spec dokumentaci
- `/agent-loop` — Phase 4 pre-deploy review
- `/qa` + `/browse` — post-deploy validation
- `/ship-checker` — final pre-launch gate

## Verification After Deploy

```bash
# Health check
curl -s "https://${PRODUCT}.oneflow.cz/api/health" | jq .

# Lighthouse
npx lighthouse "https://${PRODUCT}.oneflow.cz" --only-categories=performance,accessibility,seo

# Auth flow
# Manual: sign up + sign in + sign out

# Payment flow (test mode first)
# Manual: subscribe via Stripe test card 4242424242424242

# Email delivery
# Manual: trigger welcome email + verify in Resend dashboard
```

## Reference

- Source insights: chase-ai "Claude Code: n8n to SaaS" + "Turn n8n Workflows into AI Saas Products" + cc-strategic "Why I Stopped Creating AI Workflows"
- Existing patterns: OneFlow Nabídky workspace, Social Publisher (per `project_oneflow_nabidky_workflow.md`)
- Stack: `~/.claude/expertise/frontend-ui.yaml` + `~/.claude/expertise/oneflow-brand.yaml`
