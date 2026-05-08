---
name: agent-business-lifecycle
description: "5-fázový lifecycle pro AI agent klientskou práci: plan → build → deploy → price → sell. Source: Filipova Prompts.docx (5 sekvenčních agent-business promptů). Pre-condition pro každého nového agent klienta (OneFlow Cast posluchač, <klient> upsell, <projekt> custom DD, <klient>/<klient>-style workflow). Trigger: /agent-business-lifecycle <fáze|full>, 'klient chce AI agenta', 'mám novou agent zakázku', 'naceň agent service', 'klient nerozumí agent value', 'jak nasadit agenta klientovi'."
argument-hint: "<plan|build|deploy|price|sell|full> [klient_name|brief]"
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - WebSearch
  - Task
---

# Agent Business Lifecycle

End-to-end framework pro každého nového agent klienta. **Plan → Build → Deploy → Price → Sell** — 5 fází, každá s vlastním promptem, success criteria a check-out.

Pre-built ve Filipových `~/Downloads/Prompts.docx` (2026-04-28). Adaptováno pro CZ market, OneFlow voice, completion-mandate compliance.

## Když použít

- **Klient požádá o "AI agenta" / "automatizaci s AI"** → /agent-business-lifecycle full
- **Filip má nápad na agent product/service** → /agent-business-lifecycle plan (validace prvně!)
- **Existující agent build se rozsypal v produkci** → /agent-business-lifecycle build
- **Před deploy klientovi** → /agent-business-lifecycle deploy
- **Klient se ptá "kolik to stojí"** → /agent-business-lifecycle price
- **Klient nerozumí proč mu agent pomůže** → /agent-business-lifecycle sell

## Když nepoužít

- Interní automation pro Filipa (Conductor task, cron) — to není klientská práce
- Quick fix existujícího agenta (bug, edge case) — použij /agent-loop
- Hluboká architektura agenta — použij /agent-harness-construction
- Pure SaaS bez AI agent komponenty — použij /saas-from-workflow

## Argument routing

```
/agent-business-lifecycle plan    → Phase 1: validate problem + design workflow + select stack + define success
/agent-business-lifecycle build   → Phase 2: failure points + error handling + fallback + testing protocol
/agent-business-lifecycle deploy  → Phase 3: pre-deploy checklist + sequence + handoff doc + monitoring
/agent-business-lifecycle price   → Phase 4: ROI calc + outcome-based + 3-tier + conversation framework
/agent-business-lifecycle sell    → Phase 5: pain map + quantification + demo + closing
/agent-business-lifecycle full    → All 5 sequenced (interactive checkpoints between phases)
```

## Workflow (high-level)

1. Parse argument → vyber fázi (default = ask)
2. Načti odpovídající phase-N-*.md s detailním promptem
3. Načti `~/.claude/expertise/agent-business-lifecycle.yaml` pro CZ-specific reference (pricing ranges, common objections, ROI templates)
4. Použij prompt s rolí + task + steps + rules
5. Při fázi `full` po každé fázi checkpoint: ask Filipa pokračovat / pauznout / save state
6. Output: deliverable per fáze (Build-Ready Plan / Production-Ready Agent / Chaos-Free Go-Live / Pricing Conversation / Closing Call)

## Phase 1 — PLAN (validate před buildem)

Detail: [phase-1-plan.md](phase-1-plan.md)

**Role:** AI agent architect (built hundreds, knows planning failure = production failure)
**Output:** Problem Validation → Complete Workflow Map → Minimal Stack Selection → Success Criteria → Build-Ready Agent Plan
**Iron rule:** Test → "Could I hand this plan to another builder and have them build the exact same agent?"

**Auto-chain:** předpokládá `/oneflow-diagnose` GO verdict (pokud chybí, run first).

## Phase 2 — BUILD (production-ready, ne demo)

Detail: [phase-2-build.md](phase-2-build.md)

**Role:** Senior AI agent engineer (production systems, not demos)
**Output:** Failure Point Map → Error Handling Per Point → Fallback Logic → Pre-Deployment Testing Protocol → Production-Ready Agent
**Iron rule:** Test → "If worst possible input hit this agent right now, would it fail gracefully or catastrophically?"

**Auto-chain:** integruje `/agent-loop` engineering pattern + `/agent-harness-construction` action space design.

## Phase 3 — DEPLOY (chaos-free go-live)

Detail: [phase-3-deploy.md](phase-3-deploy.md)

**Role:** AI agent deployment specialist (closes gap between working & deployed)
**Output:** Pre-Deployment Checklist → Deployment Sequence → Client Handoff Document → Post-Deployment Monitoring → Chaos-Free Go-Live
**Iron rule:** Test → "If I got on a flight the moment this agent deployed, would it still be running when I landed?"

**Auto-chain:** integruje `/deploy-service` (VPS), `/setup-deploy` (config), `/canary-watch` (post-deploy monitoring).

## Phase 4 — PRICE (outcome-based, ne hodinovka)

Detail: [phase-4-price.md](phase-4-price.md)

**Role:** AI agent pricing strategist (outcome > hourly, makes ROI feel free)
**Output:** ROI Calculation → Outcome-Based Pricing Structure → Three-Tier Pricing → Pricing Conversation Framework → Clients Pay Without Negotiating
**Iron rule:** Test → "After hearing this pricing, would a rational client feel they are getting a bargain?"

**Auto-chain:** Tier-anchoring pattern + CZ market data z expertise YAML (běžné CZ ceny pro AI agent services 50-300k Kč/měs retainer, 30-150k Kč/build).

## Phase 5 — SELL (pain-first, ne tech-first)

Detail: [phase-5-sell.md](phase-5-sell.md)

**Role:** AI agent sales strategist (clients sell themselves)
**Output:** Client Pain Map → Pain Quantification Conversation → Demonstration Sequence → Closing Framework → Client Signs Without Being Pushed
**Iron rule:** Test → "After this sales conversation, would the client feel stupid for not automating sooner?"

**Auto-chain:** integruje Voss calibrated questions + Cialdini reciprocity (z `~/.claude/expertise/outbound-sales-science.yaml`), OneFlow brand voice (z `oneflow-all.md`).

## Full lifecycle (`full` mode)

Při `/agent-business-lifecycle full`:

```
Phase 1 (PLAN)
   ↓ [checkpoint: pokračovat? save plan?]
Phase 2 (BUILD)
   ↓ [checkpoint: agent built? testing complete?]
Phase 3 (DEPLOY)
   ↓ [checkpoint: client ready? monitoring active?]
Phase 4 (PRICE)
   ↓ [checkpoint: pricing accepted by Filip? offer prepared?]
Phase 5 (SELL)
   ↓ [output: ready to close]
```

Mezi fázemi: persist state do `~/Documents/oneflow-agents/{client_slug}/lifecycle.md` aby se dalo pauznout a pokračovat v novém session.

## Integration s ekosystémem

| Existing skill / rule | Vztah |
|---|---|
| `/oneflow-diagnose` | Pre-condition pro Phase 1 (GO verdict před buildem) |
| `/prd-spec` | Phase 1 deliverable lze konvertovat na PRD pro implementaci |
| `/saas-from-workflow` | Phase 2 build → Phase 3 deploy = SaaS produkt route |
| `/agent-loop`, `/agent-harness-construction` | Engineering reference pro Phase 2 |
| `/deploy-service`, `/setup-deploy` | Phase 3 ops (VPS systemd) |
| `/pricing-strategy` | Phase 4 reference (general pricing) |
| `/cold-outreach-v3`, `/closer` | Phase 5 outreach execution po sales call |
| `~/.claude/expertise/outbound-sales-science.yaml` | Phase 5 Voss/Cialdini frameworks |
| `~/.claude/expertise/prd-driven-saas.yaml` | Phase 2-3 productization reference |
| `~/.claude/rules/oneflow-all.md` | Voice/banned words (POVINNÉ pro client-facing copy) |
| `~/.claude/rules/completion-mandate.md` | Iron rule (no "po schválení" mid-phase) |

## Output formáty

Per fázi vytvoř soubor v `~/Documents/oneflow-agents/{client_slug}/`:

- `01-plan.md` — Build-Ready Plan
- `02-build.md` — Production-Ready Agent (+ test protocol)
- `03-deploy.md` — Go-Live Doc + Client Handoff
- `04-pricing.md` — 3-tier pricing + conversation script
- `05-sales-call.md` — Pain Map + Demo + Closing script

Plus master `lifecycle.md` se sledováním stav per fáze.

## CZ adaptace

- **Phase 1**: validation otázky CZ-first (klient zaplatí v Kč, hodina manuální práce v CZ benchmark 600-1500 Kč)
- **Phase 4 pricing tiers**: CZ ranges (build 30-150k Kč, retainer 15-100k Kč/měs, success fee 5-15%)
- **Phase 5 sales**: Voss calibrated questions in CZ ("Co by muselo platit, abyste...")
- **All phases**: vykání new clients, žádné AI patterns, žádné banned words (oneflow-all.md)

## Anti-patterns

❌ Skip Phase 1 a jít rovnou na build ("klient si přeje features")
❌ Phase 2 bez explicit failure point map (= demo, ne production)
❌ Phase 3 bez monitoring planu (= chaos discovery)
❌ Phase 4 hourly rate (= unscalable, race to bottom)
❌ Phase 5 leading s technologií ("máme LLM agenta, který...")
❌ Run full mode bez checkpoint mezi fázemi (Filip chce kontrolu)

## Test (pre-deploy skill)

```
/agent-business-lifecycle plan "test client: e-shop chce AI agenta na customer support"
```

Expected output: 5 sekcí (Problem Validation, Workflow Map, Stack, Success Criteria, Build-Ready Plan), all CZ, OneFlow voice, žádné banned words.

## Maintenance

- Source prompts: `~/Downloads/Prompts.docx` (Filipova originální verze)
- Když Filip uzná novou fázi (např. "Maintain"), append jako Phase 6 + new file
- Když CZ pricing data zastará → update expertise YAML
- Když Voss/Cialdini frameworky se změní v `outbound-sales-science.yaml` → re-link

## Reference

- Source: `~/Downloads/Prompts.docx` (5 prompts, 2026-04-28)
- Expertise: `~/.claude/expertise/agent-business-lifecycle.yaml`
- Memory: `project_agent_business_lifecycle_2026_04_28.md`
- Chain recipe: `~/.claude/skills/chains/CHAINS.md` § AGENT-CLIENT-FULL
