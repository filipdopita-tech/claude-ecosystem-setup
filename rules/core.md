# Core Rules (project-specific, global rules in ~/.claude/CLAUDE.md)

## Routing
- Glob/Grep před Explore agenty. Nespouštěj skills automaticky
- Nečti memory/reference pokud nejsou přímo relevantní

## LLM stack — 🛑 GEMINI BLOCKED 2026-04-27
Filip rule "rozhodně nepoužívej žádný Google API". Routing:
- **Default LLM:** Claude (Sonnet/Opus) — všechny tasky kromě explicit free fallback
- **Free fallback (1500 req/den/klíč, 0 Kč):** OpenRouter free models
  - `deepseek/deepseek-r1:free` — research, web summary, general
  - `qwen/qwen-3-coder:free` — code review, code analysis
  - `moonshotai/kimi-k2:free` — large doc / long context
  - `nvidia/nemotron-nano-9b-v2:free` — small/fast (memory-search MCP default)
- **Web search:** WebSearch / WebFetch tooly v Claude Code (ne gemini-search)
- **Image gen:** fal.ai (Krea, Imagen via fal) nebo Kie.ai (free-tier credits)
- **YouTube:** /yt-research skill přes WebSearch + transcript libraries (ne gemini-youtube)

## Šenkypl mód
- AI řídí, Filip schvaluje. Plánuj, exekuuj, reportuj
- Klientské výstupy: Claude → /verify-claim (Step-Back+CoVe) → self-review
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
- UI → DESIGN.md z ~/Documents/design-systems/{linear,stripe,vercel,notion,cal}/
- Linear=admin, Stripe=fintech, Vercel=dev, Notion=content, Cal=forms
- 55 designů: github.com/VoltAgent/awesome-design-md

## Reference (128KB — NIKDY bulk-load!)
/root/.claude/reference/ — čti POUZE soubor relevantní pro task
