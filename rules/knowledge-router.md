# Knowledge Router (on-demand loading)

NIKDY nepreloaduj. Načti JEN když task vyžaduje doménu.

## Expertise YAML (preferovaný, structured)
| Task obsahuje | Načti |
|---|---|
| IG/social content | expertise/content-creation.yaml + [your_company]-brand.yaml |
| Investor/outreach/DD | expertise/investor-outreach.yaml + [your_company]-brand.yaml |
| Deploy/VPS/systemd | expertise/vps-infra.yaml |
| Kód/refactor/testing | expertise/code-patterns.yaml |
| [YOUR_COMPANY] brand/voice | expertise/[your_company]-brand.yaml |
| HTML, CSS, design, brand manuál, vizuál, web, landing page, nabídka, UI | expertise/design-visual.yaml + expertise/[your_company]-brand.yaml + rules/design-workflow.md |
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
| obsidian, [YOUR_COMPANY]-Vault, vault, search note, create note, find tag, .canvas, .base | skill: obsidian-cli + obsidian-markdown + obsidian-bases + json-canvas |
| shadcn, shadcn/ui, component, registry, button, card, dialog, theming | skill: shadcn |
| Next.js, Vercel, React, server components, app router, performance, RSC | skill: vercel-react-best-practices + nextjs-app-router-patterns + vercel-composition-patterns |
| Google Sheets, gws-sheets, append row, read spreadsheet, VPS Dashboard | skill: gws-sheets-read + gws-sheets-append + sheets-automation |
| Google Calendar, scheduling, meeting prep, agenda, attendees | skill: gws-workflow-meeting-prep + calendar-automation |
| email-to-task, gmail to tasks, convert email | skill: gws-workflow-email-to-task |
| Playwright, flaky test, page object model, browser test | skill: playwright-best-practices + e2e-testing-patterns |
| pytest, fixtures, mocking, Python testing | skill: python-testing-patterns |
| TypeScript types, generics, conditional types, mapped types, template literal | skill: typescript-advanced-types |
| Temporal, workflow orchestration, saga pattern, distributed system | skill: workflow-orchestration-patterns |
| web scraping, anti-bot, undocumented API, scraping pipeline | skill: web-scraping |
| investment memo, VC memo, PE memo, investment thesis, DD memorandum | skill: investment-memo (chain s dd-emitent) |
| pdf table extraction, pdfplumber, prospekt parsing | skill: pdf-extraction |
| data analysis, Excel insights, CSV visualization, spreadsheet report | skill: data-analysis |
| Remotion, video v Reactu, programmatic video | skill: remotion-best-practices |
| design audit, motion design, interaction polish, Emil Kowalski | skill: design-motion-principles + impeccable |
| defuddle, web clipper, clean markdown z webu | skill: defuddle |

## Coding Rules (behavioral, načti při editu/tvorbě kódu)
| Task obsahuje | Načti |
|---|---|
| Kód refactor, optimization, compaction, cleanup, token efficiency v kódu | rules/lean-engine.md |
| JS/TS/Python/Bash patterns, arrow fn, list comprehension, walrus, destructuring | rules/lean-engine.md |
| Subagent prompt tuning, compact agent output, agent report format | rules/lean-engine.md §3-4 |

## CARL Domain Rules (behavioral constraints, načti SPOLU s YAML)
| Task obsahuje | Načti |
|---|---|
| DD, emitent, DSCR, LTV, portfolio, investiční analýza | rules/domains/investment.md |
| Cold email, outbound sekvence, warm-up, deliverability, bounce | rules/domains/cold-email.md |
| CNB, ECSP, AML, GDPR, compliance, regulace, zákon | rules/domains/compliance.md |

CARL = behaviorální pravidla (mandatory checks, red lines). YAML = znalostní obsah. Používej oboje.

## Knowledge MD (fallback)
sales-psychology, programming, design, frontier-tech, pitch-deck-factory, ai-ml, marketing, finance, [your_name]-style-clone, legal-compliance, competitive-intel, cz-market-data, [your_name]-standards

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
