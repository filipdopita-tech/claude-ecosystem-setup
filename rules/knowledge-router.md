# Knowledge Router (on-demand loading)

NIKDY nepreloaduj. Načti JEN když task vyžaduje doménu.

## Expertise YAML (preferovaný, structured)
| Task obsahuje | Načti |
|---|---|
| IG/social content | expertise/content-creation.yaml + oneflow-brand.yaml |
| Investor/outreach/DD | expertise/investor-outreach.yaml + oneflow-brand.yaml |
| Deploy/VPS/systemd | expertise/vps-infra.yaml |
| Kód/refactor/testing | expertise/code-patterns.yaml |
| OneFlow brand/voice | expertise/oneflow-brand.yaml |
| HTML, CSS, design, brand manuál, vizuál, web, landing page, nabídka, UI | expertise/design-visual.yaml + expertise/oneflow-brand.yaml + rules/design-workflow.md |
| React, Next.js, shadcn, Tailwind, mapcn, component library, web app, frontend | expertise/frontend-ui.yaml |
| GitHub repo hodnocení, je to good library, podívej se na repo, GitHub URL | expertise/frontend-ui.yaml + knowledge/code/github-recon.md |
| CNB, ECSP, dluhopisy, AML, emise, regulace, zákon, compliance, GDPR | expertise/czech-regulatory.yaml |
| Deliverability, spam, SPF, DKIM, DMARC, Proofpoint, blacklist, MX, bounce | expertise/email-deliverability.yaml |
| GHL, GoHighLevel, CRM, pipeline, tagy, webhook, kontakty, lead | expertise/crm-ghl.yaml |
| ARES, Apollo, Hunter, scraper, enrichment, SMTP verify, ISIR, CUZK, email waterfall | expertise/data-enrichment.yaml |
| Cold email, sekvence, reply psychology, Cialdini, A/B test outreach, Schwartz | expertise/outbound-sales-science.yaml |
| LinkedIn, Voyager API, Playwright, Dubai pipeline, bridge, automation | expertise/linkedin-automation.yaml |
| Graphiti, KG, knowledge graph, graphiti_search, graphiti_add, KuzuDB, temporal | expertise/knowledge-graph-ops.yaml |
| prompt engineering, prompt design, cache optimization, eval-driven, falsification, anti-sycophancy, calibrated confidence, Anthropic cache, multi-turn agent | expertise/prompt-engineering.yaml |
| Konkurence, competitor, scrape IG profil, hook pattern, co dělá X, inspirace pro hook | skill: competitor-intel |
| SEO, AEO, GEO, AI citace, Perplexity, ChatGPT visibility, schema markup, E-E-A-T, structured data | skill: seo-audit |
| obsidian, OneFlow-Vault, vault, search note, create note, find tag, .canvas, .base | skill: obsidian-cli + obsidian-markdown + obsidian-bases + json-canvas |
| Skool intel patterns, top insights z Skool komunit, cross-community distillation, Mr Kattani, Charles cc-strategic | knowledge/skool-intel-distillation.md + memory/project_skool_intel_implementation_2026_04_28.md |
| n8n, Zapier, Make, Pipedream, "buduji workflow", "automation pipeline", "stack rozhodnutí pro workflow" | rules/n8n-vs-claude-code.md + memory/project_conductor.md |
| agent loop, investigate review pickup, decomposition subagentu, multi-step debugging s reviewem, chain of agents pro DD/refactor/outreach | skill: agent-loop + expertise/agent-loop-engineering.yaml |
| NotebookLM research, YouTube research, zero-RAG agent, prospekt PDF + YT research, podcast prep, market intel přes NotebookLM | skill: notebooklm-research + knowledge/research-via-notebooklm.md |
| site builder, landing page z business name, emitent landing, klient nabídka stránka, programmatic SEO pages, ARES + Vercel deploy | skill: site-builder |
| trend tracker, daily content nápady, YT+X+Reddit+web monitoring, denní investiční trendy CZ, content pipeline pro IG/LinkedIn | skill: trend-tracker |
| browser network tab access, Chrome DevTools MCP, scrape přes network introspekce, ARES via traffic analysis | mcp: chrome-devtools (npx chrome-devtools-mcp@latest) |
| Apollo Apify deprecated, lead-gen scraper alternatives, Apollo official scraper paid | expertise/data-enrichment.yaml § apollo (po 2026-09 DEPRECATION block) + knowledge/skool-intel-distillation.md § Pattern 8 |
| batch DD, 50+ emitenti najednou, agentic RAG nad SQL, halucinace v DD finanční metriky, portfolio review, sector benchmarking | skill: dd-batch-sql + memory/project_scraping_engine.md |
| productize workflow do SaaS, n8n → Next.js + Stripe, Conductor automation → klikací app, OneFlow internal tool → recurring revenue | skill: saas-from-workflow + expertise/prd-driven-saas.yaml |
| PRD, product requirements document, spec dokument, "napiš PRD pro X", before implementation | skill: prd-spec + expertise/prd-driven-saas.yaml |
| OneFlow cold outreach kampaň 100-1000 leadů, ARES + LinkedIn + Hunter waterfall, Cialdini Voss CTA, Apollo direct (ne Apify), CZ ICP | skill: cold-outreach-v3 (NOT cold-email which is generic English) |
| AI employees mental model, pipeline + parallel + sub agents archetypes, "hire" Claude pro task, agent team architecture | expertise/agent-employees.yaml + skill: dispatching-parallel-agents |
| macOS screen capture, automated screenshots, visual QA pro AI agents, vision question answering nad screenshots | CLI: peekaboo (brew install steipete/tap/peekaboo, /opt/homebrew/bin/peekaboo) |
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

## Completion Mandate (HARDCORE behavioral, načti VŽDY pro task s akčním slovesem)
| Task obsahuje | Načti |
|---|---|
| Filipův pokyn s imperativem (udělej, sprav, vytvoř, nasaď, oprav, scrape, deploy, atd.) | rules/completion-mandate.md + memory/feedback_completion_mandate.md |
| Scraping/data task se zdrojem ≥100 záznamů | rules/completion-mandate.md (scope ≥50% pravidlo) |
| Cokoli kde mi přijde napsat "to nejde", "potřebuji vaše schválení", "po schválení", "doporučuji udělat", "navrhuji", "nemám přístup" | rules/completion-mandate.md (zakázané fráze) |
| Auto-trigger na blocking phrases | hooks/completion-blocking-words-guard.sh blokuje exit 2 (3+ Tier 1 + >500 chars) |
| Override legitimate edge case | env COMPLETION_OVERRIDE=1 |

## Power Skill Stack (40+ slash commands tier system, S/A/B/C/D/E/F)
| Task obsahuje | Načti |
|---|---|
| High-stakes výstup (DD report, investor memo, klientský deliverable >50k Kč, ad creative >5k Kč budget) | rules/power-skills-stack.md + skills/chains/CHAINS.md |
| Filip phrase: "fakt důležité", "kritické", "rozcupuj", "tear apart", "stuck", "deep dive", "max detail", "viral", "ghostwrite" | rules/power-skills-stack.md (auto-trigger mapping) |
| Strategic decision (pivot, big bet, new service, hiring) | skills/chains/CHAINS.md → STRATEGIC-DECISION recipe |
| Cold email/DM na c-suite/celebrity/podcast guest | skills/chains/CHAINS.md → COLD-EMAIL-MAX recipe |
| Content pillar launch / hero post / viral attempt | skills/chains/CHAINS.md → CONTENT-VIRAL recipe |
| Investor pitch / podcast outreach / sales letter high-stakes | skills/chains/CHAINS.md → INVESTOR-PITCH recipe |
| Comprehensive research / market intel / competitive map | skills/chains/CHAINS.md → DEEP-RESEARCH recipe |
| Pre-deploy / pre-send final gate | skills/chains/CHAINS.md → SHIP-GATE recipe |

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
