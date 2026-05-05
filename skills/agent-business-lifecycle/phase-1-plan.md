# Phase 1 — PLAN YOUR AGENT BEFORE YOU BUILD

## Source prompt (Filipova originální verze, ~/Downloads/Prompts.docx)

```xml
<role>Act as an AI agent architect who has planned, built, and deployed hundreds of agents — and knows that every agent that fails in production failed because the planning was wrong before a single line of code was written.</role>

<task>Build a complete agent plan before I write a single prompt, connect a single tool, or pitch a single client — covering the problem, the workflow, the stack, and the success criteria.</task>

<steps>
1. Ask for the problem I want the agent to solve, the client it serves, and the outcome I want to deliver before starting
2. Validate the problem — is this a task an agent can actually automate or a task that still needs human judgment
3. Map the complete workflow — every step the agent takes from trigger to output
4. Select the minimal stack — the tools, APIs, and models needed and nothing more
5. Define success criteria — exactly what the agent must do consistently before it is ready to deploy
</steps>

<rules>
- Problem must be agent-solvable before any planning continues — validate first, build second
- Workflow must be mapped step by step — no vague "the agent handles it" sections
- Stack must be minimal — every unnecessary tool is a failure point
- Success criteria must be specific and measurable — not "it works well"
- Test: could I hand this plan to another builder and have them build the exact same agent
</rules>

<output>Problem Validation → Complete Workflow Map → Minimal Stack Selection → Success Criteria → Build-Ready Agent Plan</output>
```

## CZ adaptation (Filipova execution layer)

### Krok 1 — Problem Discovery (vykání novému klientovi)

Polož 3 calibrated questions:

1. **Co konkrétně chcete, aby agent dělal?** (forcing function — donutí klienta zúžit scope)
2. **Pro koho je výsledek?** (klient agent → end user pipeline)
3. **Jak dnes ten výsledek vzniká bez agenta?** (manuální baseline pro pozdější ROI calc)

Anti-pattern: nedávat klientovi ani zmínku o LLM, prompt, Claude, OpenAI. Až po Phase 5 sales call.

### Krok 2 — Problem Validation (GO / PIVOT / NO-GO gate)

Aplikuj 6-bod validation:

| Otázka | GO | PIVOT | NO-GO |
|---|---|---|---|
| Je vstup deterministicky strukturovaný? | ANO | Polostrukturovaný | Volný text bez patternu |
| Existuje correct/wrong feedback signál? | ANO | Slabý | Pure subjective taste |
| Je objem dat 50+ instancí/měs? | ANO | 10-50 | <10 (nestoji za to) |
| Je akceptovatelná cena 5+ s/instance? | ANO | 1-5s | <1s (latency-critical) |
| Změní se workflow častěji než agent dokáže adaptovat? | NE | Občas | ANO |
| Vyžaduje legal/medical/finanční accountability? | NE | Částečně | ANO (= human required) |

**Verdict logic:** 5+ GO → BUILD. 3-4 GO → PIVOT scope (zúžit, vyřadit edge cases). <3 GO → NO-GO, sděl klientovi proč.

### Krok 3 — Workflow Map (mermaid + plain CZ)

Mapuj end-to-end:
```
TRIGGER (co spustí agenta) →
INPUT (co dostane) →
STEP 1, 2, 3... (každý krok = 1 agent action) →
OUTPUT (deliverable formát) →
HANDOFF (komu/kam jde výsledek)
```

**Iron rule:** žádný "agent handles it" segment. Každý krok = jedna konkrétní operace.

Pro Filipa: použij mermaid syntax, exportuj jako PNG do `~/Documents/oneflow-agents/{client_slug}/01-workflow.png` přes `~/.claude/scripts/render_mermaid.sh` (pokud existuje, jinak ASCII).

### Krok 4 — Minimal Stack Selection

**Default OneFlow stack (start zde, justify každé deviation):**

| Vrstva | Default | Když odchýlit |
|---|---|---|
| LLM | Claude Sonnet 4.6 | Opus 4.7 jen pokud reasoning komplexní + finanční stakes; Haiku 4.5 pro classify-only |
| Orchestrace | Conductor (VPS Flash) | Custom Next.js když klient chce vlastní UI |
| Storage | SQLite (Flash) → PostgreSQL když 1M+ rows | Supabase pokud klient chce vlastní cloud |
| Auth | NextAuth (klient projekt) nebo none (interní) | Supabase Auth pro multi-tenant |
| Frontend | None (CLI/cron) → minimal Next.js když UI nutné | Plný React app jen když klient zaplatí extra |
| Deploy | VPS Flash systemd | Vercel pro static UI, Railway pro non-VPS klient |
| Monitoring | ntfy + monit | Sentry pro multi-user produkty |
| MCP servers | jen ty, které agent reálně volá | nikdy "for future" |

**Cost discipline:** Žádné Google API (per cost-zero-tolerance.md). Pokud klient žádá Vertex AI → nabídni Anthropic via OpenRouter nebo direct.

### Krok 5 — Success Criteria (SMART, measurable)

Pro každý agent definuj 4 metriky:

1. **Accuracy threshold** — % správných výstupů na test sadě (např. "95% klasifikace shoduje se s human reviewerem")
2. **Latency budget** — max čas per instance (např. "≤30s end-to-end")
3. **Cost ceiling** — max Kč/instance (např. "≤2 Kč LLM cost per run")
4. **Failure mode coverage** — list edge cases, které MUSÍ být zachyceny (graceful degrade, ne crash)

**Test gate před přechodem na Phase 2:**
> "Could I hand this plan to another builder and have them build the exact same agent?"

Pokud NE → vraťte se ke Krok 3 a doplň missing detail.

## Výstupní formát (deliverable)

Sav do `~/Documents/oneflow-agents/{client_slug}/01-plan.md`:

```markdown
# Agent Plan: {Client Name} — {Agent Name}

**Date:** YYYY-MM-DD
**Status:** PLAN VALIDATED → READY FOR PHASE 2 BUILD

## 1. Problem Discovery
[3 questions answered]

## 2. Problem Validation
[6-bod table + verdict]

## 3. Workflow Map
[Mermaid diagram + plain CZ description]

## 4. Stack Selection
[Defaults + justifications for deviations]

## 5. Success Criteria
- Accuracy: ≥X%
- Latency: ≤Ys
- Cost: ≤Z Kč/run
- Failure modes covered: [list]

## Hand-off Test
[Yes/No: Could another builder reproduce this exact agent? If No → fix what.]
```

## Auto-chain do Phase 2

Po PASS testu → run `/agent-business-lifecycle build {client_slug}` automaticky (pokud `full` mode).
