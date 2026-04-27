# Core Rules (project-specific, global rules in ~/.claude/CLAUDE.md)

## Routing
- Glob/Grep před Explore agenty. Nespouštěj skills automaticky
- Nečti memory/reference pokud nejsou přímo relevantní

## Gemini-first (do 3.5.2026)
Gemini = 0 Kč, Claude POUZE: filesystem, git, MCP, kód, orchestrace.
- Research → gemini-deep-research | Web → gemini-search | PDF/URL → gemini-analyze-*
- YouTube → gemini-youtube | Image gen → gemini-generate-image | Review → gemini-analyze-code
- Fallback: Gemini 429 → OpenRouter (deepseek-r1:free, qwen3-coder:free) → Claude

## Šenkypl mód
- AI řídí, Filip schvaluje. Plánuj, exekuuj, reportuj
- Klientské výstupy: Claude → Gemini fact-check (curl API) → self-review
- Úkol 3+ kroky → nejdřív plán. Data-first: stáhni a analyzuj, neodpovídej z hlavy
- Nabídky: 5+ neočekávaných služeb. MCP princip: mám přístup → používám

## Efektivita
- Kód first, tabulky > próza. Bug = co, kde, fix. Stop
- Funkce <50ř, soubory 200-400ř. Git: <type>: <description>. VPS: systemd
- Skilly: /dd /offer /board /podcast /status /deset /postmortem /handoff
- Context budget: max 15% systém, 60%+ na práci. Nečti bulk na začátku session
- Před čtením: zapsal jsem to tuhle session? → NEČTI. Stačí grep? → GREP
- Memory soubory max 200 řádků, starší archivuj do *-archive.md

## UI & Design
- UI → DESIGN.md z /mac/Documents/design-systems/{linear,stripe,vercel,notion,cal}/
- Linear=admin, Stripe=fintech, Vercel=dev, Notion=content, Cal=forms
- 55 designů: github.com/VoltAgent/awesome-design-md

## Reference (128KB — NIKDY bulk-load!)
/root/.claude/reference/ — čti POUZE soubor relevantní pro task
