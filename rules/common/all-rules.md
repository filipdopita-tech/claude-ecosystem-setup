# Core Rules (compact)

## Code Style

- Immutability: NEVER mutate, always return new copies
- Files: 200-400 lines typical, 800 max. Many small > few large
- Functions: <50 lines, no deep nesting (>4 levels)
- Handle errors explicitly, validate at system boundaries

## Git

- Format: `<type>: <description>` (feat, fix, refactor, docs, test, chore, perf, ci)
- Always analyze full commit history for PRs

## Testing

- 80%+ coverage. TDD: RED → GREEN → REFACTOR
- Unit + Integration + E2E required

## Security

- No hardcoded secrets. Parameterized queries. Sanitize HTML
- CSRF protection. Rate limiting. Error messages don't leak data

## Performance

- Haiku: lightweight/frequent agents. Sonnet: main work. Opus: complex architecture
- Avoid last 20% of context window for complex tasks

## Patterns

- Repository pattern for data access
- Consistent API response envelope (success, data, error, metadata)
- Structured error: {isError, isRetryable, errorCategory, message}
- Circuit breaker for external calls: CLOSED → OPEN → HALF-OPEN

## Agents

- Parallel execution for independent tasks
- Max 4-5 tools per agent
- Fallback: primary → retry 3x → alternative → cached → alert

## Think-Before-Act (INTERNÍ — v thinking blocks, ne ve viditelném výstupu)

Treat every request as complex unless it's explicitly trivial.
PŘED prvním tool callem nebo odpovědí — INTERNĚ v thinking:
1. Jaký přístup a proč — včetně alternativ, které odmítám a proč
2. Hlavní riziko / neznámá + hidden constraints (perf, security, cost, compat, side effects)
3. Odpovídám na VŠECHNY detaily, nebo jen na nejnápadnější?
4. Consider tradeoffs — nepřijímej první plausibilní řešení bez kontroly
5. Falsify: proč by můj přístup mohl být ŠPATNĚ? Co by ho vyvrátilo?
6. Ambiguita? → ZASTAV a zeptej se PŘED kódováním, ne po chybě. Prezentuj interpretace, nevolej tiše.
7. Teprve pak akce

Výstup: ve viditelné odpovědi surfuj pouze key findings z tohoto reasoning (závěry, caveaty, edge cases). Ne popis procesu.

NEPOUŽÍVAT: triviální ops (grep, ls, mv, read), jednoznačné jednokrokové tasky

## Surgical Changes

**Dotkni se jen toho, co musíš. Uklízej jen svůj vlastní nepořádek.**

Při editaci existujícího kódu:
- Neupravuj adjacent code, komentáře ani formátování — i kdyby ti vadily
- Nerefaktoruj věci, které nejsou rozbité
- Matchuj existující styl, i kdyby sis to udělal jinak
- Vidíš unrelated dead code? Zmiň ho — nemaž ho

Pokud tvé změny zanechají sirotky:
- Odstraň importy/proměnné/funkce, které osiřely TVÝMI změnami
- Pre-existing dead code nemaz, pokud o to není požádáno

Test: každý změněný řádek musí přímo sledovat uživatelův request.

## Success Criteria pro multi-step tasky (mimo GSD)

Pro každý task s 3+ kroky napiš plán PŘED akcí:
```
1. [krok] → verify: [jak ověřit]
2. [krok] → verify: [jak ověřit]
3. [krok] → verify: [jak ověřit]
```
Silná kritéria = loop nezávisle. Slabá ("aby to fungovalo") = zpětný dotaz po každém kroku.

## UNIFY — Mandatory Phase Close-out

Před označením jakékoli GSD fáze nebo multi-step tasku jako hotové:
- Reconcile: co bylo naplánováno vs. co bylo skutečně provedeno (odchylky zdůvodni)
- Log: klíčová rozhodnutí učiněná během fáze (do STATE.md, CLAUDE.md, nebo inline)
- Zkontroluj: žádné orphan plans, žádné dangling threads, žádné otevřené TODO

Přeskočení UNIFY = fáze NENÍ hotová. Platí i pro ad-hoc multi-step tasky mimo GSD.

## Hooks

- PreToolUse: validation. PostToolUse: auto-format/checks. Stop: final verification
- Use TodoWrite for multi-step progress tracking
