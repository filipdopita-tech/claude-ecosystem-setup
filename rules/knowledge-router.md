# Knowledge Router (on-demand loading)

NIKDY nepreloaduj. Načti JEN když task vyžaduje doménu.

## Expertise YAML (preferovaný, structured)
| Task obsahuje | Načti |
|---|---|
| IG/social content | expertise/content-creation.yaml + [your-service].yaml |
| Investor/outreach/DD | expertise/investor-outreach.yaml + [your-service].yaml |
| Deploy/VPS/systemd | expertise/vps-infra.yaml |
| Kód/refactor/testing | expertise/code-patterns.yaml |
| [YOUR_COMPANY] brand/voice | expertise/[your-service].yaml |
| HTML, CSS, design, brand manuál, vizuál, web, landing page, nabídka, UI | expertise/design-visual.yaml + expertise/[your-service].yaml |
| React, Next.js, shadcn, Tailwind, mapcn, component library, web app, frontend | expertise/frontend-ui.yaml |
| GitHub repo hodnocení, je to good library, podívej se na repo, GitHub URL | expertise/frontend-ui.yaml + knowledge/code/github-recon.md |
| CNB, ECSP, dluhopisy, AML, emise, regulace, zákon, compliance, GDPR | expertise/czech-regulatory.yaml |
| Deliverability, spam, SPF, DKIM, DMARC, Proofpoint, blacklist, MX, bounce | expertise/email-deliverability.yaml |
| GHL, GoHighLevel, CRM, pipeline, tagy, webhook, kontakty, lead | expertise/crm-ghl.yaml |
| ARES, Apollo, Hunter, scraper, enrichment, SMTP verify, ISIR, CUZK, email waterfall | expertise/data-enrichment.yaml |
| Cold email, sekvence, reply psychology, Cialdini, A/B test outreach, Schwartz | expertise/outbound-sales-science.yaml |
| LinkedIn, Voyager API, Playwright, Dubai pipeline, bridge, automation | expertise/linkedin-automation.yaml |
| Graphiti, KG, knowledge graph, graphiti_search, graphiti_add, KuzuDB, temporal | expertise/knowledge-graph-ops.yaml |
| Konkurence, competitor, scrape IG profil, hook pattern, co dělá X, inspirace pro hook | skill: competitor-intel |
| SEO, AEO, GEO, AI citace, Perplexity, ChatGPT visibility, schema markup, E-E-A-T, structured data | skill: seo-audit |

## CARL Domain Rules (behavioral constraints, načti SPOLU s YAML)
| Task obsahuje | Načti |
|---|---|
| DD, emitent, DSCR, LTV, portfolio, investiční analýza | rules/domains/investment.md |
| Cold email, outbound sekvence, warm-up, deliverability, bounce | rules/domains/cold-email.md |
| CNB, ECSP, AML, GDPR, compliance, regulace, zákon | rules/domains/compliance.md |

CARL = behaviorální pravidla (mandatory checks, red lines). YAML = znalostní obsah. Používej oboje.

## Knowledge MD (fallback)
sales-psychology, programming, design, frontier-tech, pitch-deck-factory, ai-ml, marketing, finance, filip-style-clone, legal-compliance, competitive-intel, cz-market-data, dopita-standards

## Code Standards (knowledge/code/)
agents, code-review, coding-style, development-workflow, git-workflow, github-recon, hooks, patterns, performance, python-rules, security, testing

Cesty: `~/.claude/expertise/*.yaml` a `~/.claude/knowledge/*.md`
YAML > MD při konfliktu.

## MONITORING — Technologie ke sledování (Q3/Q4 2026)

| Technologie | Status | Akce |
|---|---|---|
| Claude Managed Agents | beta (header `anthropic-beta: managed-agents-2026-04-01`) | Eval jako Conductor replacement Q3 2026 |
| A2A Protocol (Google) | spec Q4 2026 | Až finální → update MCP servery (`handle_task_delegation()`) |
| Computer Use v Claude Code | ~3 měsíce do prod | Relevantní pro IG Analyzer workflow |
| Hermes Agent (self-improving) | experimental | Eval pro Paseo daemon integration |
| Mistral Medium 3 | open weights, EU compliance | Conductor LLM pool candidate (GDPR) |
