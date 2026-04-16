# Context Hygiene

## Context Decay
- Po 10+ zprávách re-read soubory před editem
- Re-read soubor před Edit pokud čten 3+ zpráv zpět
- Soubory >500 řádků: offset+limit, ne celé. Grep -C před plným Read

## Prompt Cache (5-min TTL, 81% cost savings)
- NEMODIFIKUJ CLAUDE.md, rules, tool definitions mid-session (rozbije cache)
- Statický obsah nahoře, dynamický na konci zpráv
- Stejný model celou session. Session idle <270s = cache teplá
- Nečti soubor co jsi právě napsal (víš co je v něm)

## Search & Refactor
- Glob/Grep přímo > Agent spawn (agent = nový kontext = tokeny)
- Rename checklist: calls, types, strings, imports, exports, tests (6 grep kroků)
- Multi-file refactor >5 souborů: fáze po 5, verify+commit mezi nimi

## Session Management
- Clear at 60k tokens nebo po major task completion. Nečekej na limity
- Pro multi-step: zapiš progress do .md, /clear, pokračuj z .md souboru
- /compact po 10 zprávách jen jako fallback. Preferuj /clear + context file

## Token Velocity (doplněk k CLAUDE_AUTOCOMPACT_PCT_OVERRIDE=50)
- Auto-compact se spouští při 50% budget (env) — to je absolutní práh
- Velocity signal je jiný: pokud průměrný turn konzumuje >5k tokenů za 3+ turns po sobě → compact/clear preemptivně, nečekej na 50%
- Příznaky high velocity: velké tool outputs (logy >200 řádků, git diff, JSON), mnoho paralelních agentů, rekurzivní čtení
- Fix high velocity: RTK prefix pro Bash výstupy, Gemini pro batch/logy, offset+limit místo full file read

## Output
- Žádný preamble/recap. Tables > prose. Diffs > full rewrites
- Ghost token hygiene: /context-budget po instalaci nového skillu/MCP
- Sub-agent escalation: Sonnet selhal? Eskaluj Opus s kontextem selhání
