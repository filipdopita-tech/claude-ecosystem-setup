---
name: prd-spec
description: "Generuje strukturovaný PRD (Product Requirements Document) z popisu produktu/feature. PRD-first methodology z Skool intel: stop building bez specs. Pre-condition pro /saas-from-workflow, /implement, OneFlow Nabídky workspace projects. Trigger: /prd-spec <product_name|description>, 'napiš PRD pro X', 'spec dokument pro feature Y'."
argument-hint: "<product_name|description> [--type=saas|feature|tool|workflow] [--depth=lite|full]"
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Edit
  - WebSearch
metadata:
  source: "skool-intel cherry-pick 2026-04-28: chase-ai 'Claude Code: n8n Workflow to Deployed SaaS (PRD section)' + 'Claude Code Custom GPT' (PRD generator) + 'Stop Using The Ralph Loop Plugin' (PRD skill file)"
  filip-adaptace: "OneFlow context — emitent SaaS, klient nabídky, internal tools. Brand voice + cost-zero compliance built in."
---

# PRD Spec — Product Requirements Document Generator

**Cíl:** Vyrobit production-grade PRD za 15 min, ne 2 dny. Eliminuje scope creep, missed requirements, drift během implementace.

**Argument:** `$ARGUMENTS` — product name nebo description + flags.

## Why PRDs matter (Skool insight)

Z chase-ai-community: "Most Claude Code projects fail because there's no PRD. Claude implements first interpretation, then drift starts. PRD = single source of truth."

OneFlow parallel: bez PRD klient nabídka vede k 3-4 revizím + scope creep + missed milestones. PRD-first = 1 revize max, predictable delivery.

## PRD Templates (per type)

### Type: `saas` — Full SaaS product

```markdown
# PRD: {Product Name}

## 1. Executive Summary (2-3 sentences)
{Co produkt dělá, pro koho, jaký problém řeší.}

## 2. Problem Statement
- **Target customer:** {profile + size + role}
- **Current pain:** {jak to dnes řeší, co je painfullní — cost, time, errors}
- **Cost of inaction:** {co se stane když to neudělají, kvantifikuj}
- **Opportunity size:** {addressable market — TAM, SAM, SOM}

## 3. Solution
- **Core value prop** (1 sentence): "{Product} helps {customer} {achieve outcome} by {how}."
- **Top 3 features** (must-have for v1):
  1. {Feature} — {why critical}
  2. {Feature} — {why critical}
  3. {Feature} — {why critical}
- **Out of scope** (explicit, prevents creep):
  - {Feature X — explain why deferred}
  - {Feature Y — explain why deferred}

## 4. User Personas
- **Primary persona:** {role, demographics, motivations, frustrations}
- **Secondary persona:** {if applicable}

## 5. User Flows (3 critical)
1. **Sign up + onboarding**
   - Steps: {numbered}
   - Success criteria: {first value within X minutes}
2. **Core workflow** (the value)
   - Steps: {numbered}
   - Success criteria: {tangible output}
3. **Payment + upgrade**
   - Steps: {numbered}
   - Success criteria: {checkout completion}

## 6. Technical Architecture
- **Frontend:** {Next.js 14 App Router + Tailwind + shadcn — default}
- **Auth:** {Supabase | NextAuth — pick one + reason}
- **Backend:** {Next.js API routes | dedicated FastAPI — pick + reason}
- **Database:** {Supabase Postgres | PlanetScale — pick + reason}
- **Payment:** {Stripe — default}
- **Email:** {Resend free tier — default}
- **Deploy:** {Vercel — default per Filip access}
- **Analytics:** {Plausible — default per privacy}

## 7. Data Model
```sql
-- Tables (entities + relationships)
CREATE TABLE users (...);
CREATE TABLE {entity_1} (...);
CREATE TABLE {entity_2} (...);
```
**Foreign keys:** {map relationships}
**Indexes:** {hot path queries}

## 8. API Contracts
| Endpoint | Method | Auth | Purpose | Response |
|---|---|---|---|---|
| /api/{resource} | GET | Bearer | List | `{data: [...]}` |
| /api/{resource} | POST | Bearer | Create | `{id, ...}` |
| /api/{resource}/{id} | PUT | Bearer | Update | `{id, ...}` |
| /api/webhooks/stripe | POST | HMAC | Stripe events | `{received: true}` |

## 9. Success Metrics (post-launch)
- **Activation rate:** {target %} — signed up → first value within X min
- **Conversion rate:** {target %} — free → paid
- **MRR target:** Month 1: ${X} | Month 3: ${Y} | Month 6: ${Z}
- **Churn rate:** {target %} — monthly cancellations

## 10. Pricing
| Tier | Price | Features | Target customer |
|---|---|---|---|
| Free | $0/mo | {limit} | Trial / small users |
| Pro | $X/mo | Unlimited | SMB |
| Enterprise | Custom | + SLA + SSO | Large accounts |

## 11. Compliance + Risks
- **GDPR:** {data retention, right-to-delete, consent}
- **Czech regulatory:** {if FinTech — CNB, ECSP, AML per czech-regulatory.yaml}
- **Security:** {SPF/DKIM, encryption at rest, secrets management}
- **Risks:** {top 3 + mitigation per risk}

## 12. Roadmap
- **v1.0 (MVP):** {features 1-3, deadline X}
- **v1.1:** {next iteration, deadline +30d}
- **v2.0:** {major release, deadline +90d}

## 13. Brand Compliance (OneFlow specific)
- ✅ Monochrome palette (#0A0A0C / #F2F0ED)
- ✅ Inter Tight font only
- ✅ No vykřičníky v B2B copy
- ✅ "Dopita" / "Filip Dopita" sign-off in transactional emails
- ✅ Footer: "OneFlow s.r.o. © {year}"
- ✅ GDPR + cookie banner (minimal Plausible)

## 14. Out of Scope (explicit)
- {Feature explicitly deferred + reason}
- {Integration explicitly deferred + reason}

## 15. Open Questions
- {Question requiring Filip's decision before implementation}
```

### Type: `feature` — Single feature within existing product

Lighter template (10 sections vs 15):
1. Executive summary
2. Problem (within product context)
3. Solution (1 paragraph)
4. User flow (1-2 critical)
5. Tech approach (changes to existing architecture)
6. Data model changes (migrations needed)
7. API contract changes
8. Success metric (1-2 specific)
9. Risks
10. Out of scope

### Type: `tool` — Internal tool (no UI, CLI/API)

Different template (8 sections):
1. Executive summary
2. Problem (operational pain)
3. Solution (CLI args + behavior)
4. Input/Output spec
5. Dependencies (libs, services)
6. Failure modes + handling
7. Success metric (time saved per use)
8. Out of scope

### Type: `workflow` — n8n / Conductor / cron job

Lightest (6 sections):
1. Trigger (cron / webhook / manual)
2. Steps (numbered)
3. Inputs / Outputs per step
4. Failure handling per step
5. Notification (success / failure)
6. Out of scope

### Depth: `lite` vs `full`

- **`lite`** — sections 1, 2, 3, 5, 9 only (executive PRD, ~500 words)
- **`full`** — all sections (~2000-3000 words, default)

## Generation Process

```bash
PRODUCT="$1"
TYPE="${2:-saas}"
DEPTH="${3:-full}"

SLUG=$(echo "$PRODUCT" | tr 'A-Z' 'a-z' | tr -cd 'a-z0-9-')
OUTPUT="$HOME/Documents/saas-projects/$SLUG/PRD.md"
mkdir -p "$(dirname "$OUTPUT")"

# Step 1: Initial draft (Claude main thread, full context)
# Use template per $TYPE + $DEPTH, fill in based on product description

# Step 2: Web search pro market context (optional)
# - Competitor research (similar products?)
# - Pricing benchmarks (industry standard?)
# - Regulation lookup (if FinTech)

# Step 3: Internal review (Claude self-critique)
# - Are out-of-scope items explicit?
# - Are success metrics quantifiable?
# - Are user flows numbered and testable?
# - Are risks paired with mitigations?

# Step 4: Write PRD.md
# Step 5: Generate companion files:
#   - PRD-CHANGELOG.md (version history)
#   - DECISIONS.md (key decisions + rationale)
#   - QUESTIONS.md (open questions for Filip)
```

## Quality Checklist (před handoff k implementaci)

Před označením PRD za "ready for implementation":

```
□ Executive summary ≤3 sentences (forced clarity)
□ Top 3 features explicit (ne 10+ — forces prioritization)
□ Out of scope explicit (≥3 items — prevents creep)
□ Success metrics quantifiable (no "improve UX")
□ User flows numbered (not narrative)
□ Tech stack picked (no "TBD" — decisions made)
□ Risks paired with mitigations (each risk has plan)
□ Brand compliance section present (OneFlow specific)
□ No banned phrases ("inovativní", "synergie", "win-win")
□ Open Questions section explicit (vs implicit assumptions)
```

## Anti-Patterns (NIKDY)

- **Skipping out-of-scope section** — implementation drift inevitable
- **Vague success metrics** ("improve UX", "better performance") — un-measurable
- **More than 5 must-have features** — scope creep, late delivery
- **Tech stack TBD** — should be decided in PRD, ne mid-implementation
- **No brand compliance section** — UI drifts from OneFlow standards
- **Skipping risks** — production surprises
- **Long narratives místo bullet structure** — un-scannable, un-actionable
- **PRD nikdy verzionovaný** — drift mezi PRD a code

## Integrace s ostatními skills

- `/saas-from-workflow` — consumes PRD as Phase 1 input
- `/implement` — consumes PRD as authoritative spec
- `/feature` — alternative entry point pro single features
- `/site-builder` — landing page can be derived from PRD
- `/agent-loop` — wrap PRD generation s review subagent for high-stakes

## Verification

```bash
# Test PRD generation
~/.claude/skills/prd-spec/test.sh "OneFlow ARES Lookup Tool" --type=saas --depth=full

# Verify
cat ~/Documents/saas-projects/oneflow-ares-lookup-tool/PRD.md
# Expected: 15-section PRD, ~2500 words, all checklist items present
```

## Reference

- Source: skool-intel/chase-ai "PRD section" + "Custom GPT for PRD generation"
- OneFlow patterns: `~/.claude/projects/<your-project-id>/memory/project_oneflow_nabidky_workflow.md`
- Stack defaults: `~/.claude/expertise/frontend-ui.yaml`
- Brand: `~/.claude/expertise/oneflow-brand.yaml`