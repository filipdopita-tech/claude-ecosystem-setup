# Phase 2 — BUILD YOUR AGENT WITHOUT BREAKING IT

## Source prompt (Filipova originální verze)

```xml
<role>Act as a senior AI agent engineer who builds production-ready agents — not demos that work once and break in front of clients, but systems that run reliably, handle edge cases, and fail gracefully when something unexpected happens.</role>

<task>Build my agent correctly the first time — with proper error handling, fallback logic, and testing protocols that prevent every embarrassing failure mode before the client ever sees it.</task>

<steps>
1. Ask for my agent's workflow, current build status, and the tools and models I'm using before starting
2. Identify every failure point in the current build — where the agent breaks, halts, or produces wrong outputs
3. Design error handling for each failure point — what the agent does when things go wrong
4. Build the fallback logic — the human handoff or safe default for every edge case
5. Deliver a pre-deployment testing protocol — the exact tests to run before showing a client
</steps>

<rules>
- Every failure point must be identified before deployment — never discover them in front of clients
- Error handling must be specific per failure type — not a generic catch-all
- Fallback logic must be human-readable — the client must understand what happened when it fails
- Testing protocol must cover happy path, edge cases, and complete failure scenarios
- Test: if the worst possible input hit this agent right now would it fail gracefully or catastrophically
</rules>

<output>Failure Point Map → Error Handling Per Point → Fallback Logic → Pre-Deployment Testing Protocol → Production-Ready Agent</output>
```

## CZ adaptation

### Krok 1 — Build Status Check

Načti Phase 1 deliverable (`01-plan.md`) + ověř:
- Workflow Map ✓
- Stack Selection ✓
- Success Criteria ✓
- Existující build (pokud je): file paths + last commit + běží/neběží

Pokud Phase 1 chybí → STOP, run Phase 1 first. Žádný "skip plan" shortcut.

### Krok 2 — Failure Point Map

Pro každý workflow step z Phase 1, identifikuj 7 failure modes:

| # | Failure mode | Příklad |
|---|---|---|
| 1 | **Input malformed** | Klient pošle PDF místo TXT, header missing, encoding issue |
| 2 | **Input empty/null** | Trigger s prázdným payload |
| 3 | **External API down** | OpenAI 503, ARES timeout, Apify rate limit |
| 4 | **External API rate-limited** | 429 odpověď |
| 5 | **LLM hallucination** | Agent vyrobí fake údaj (IČO, jméno, číslo) |
| 6 | **Cost overrun** | Single instance přečerpá budget (např. retry loop) |
| 7 | **Race condition** | 2× spuštění současně, lock missing |

Mapa do tabulky: `failure_id | step | mode | likelihood (H/M/L) | impact (H/M/L) | priority`

**Priority logic:** H/H = MUST FIX, H/M nebo M/H = SHOULD FIX, ostatní = NICE TO HAVE.

### Krok 3 — Error Handling per Point

Pro každý MUST/SHOULD failure napiš handler. Žádný generic try/catch.

**Pattern templates:**

```python
# Input malformed
def parse_input(raw):
    try:
        return validate_schema(raw)
    except SchemaError as e:
        log("input_malformed", agent_id, raw_id, e)
        notify_human("Input failed validation", payload=raw)
        return None  # Triggers fallback flow, ne crash

# External API rate-limited
@retry(max=3, backoff=exponential, jitter=True)
def call_external():
    r = requests.get(url)
    if r.status_code == 429:
        sleep(int(r.headers.get('Retry-After', 60)))
        raise RetryableError
    return r

# LLM hallucination
def verify_factual(claim, source):
    # Re-prompt s explicit "answer ONLY from source" + schema
    # Pokud confidence < 0.85 → flag for human review
    ...
```

### Krok 4 — Fallback Logic

Každý failure má 2 fallback paths:

1. **Safe default** — co agent dělá automaticky (např. retry s backoff, vrátit cached, vrátit None s flagem)
2. **Human handoff** — kdy eskaluje (notification + payload + suggested fix)

**Iron rule:** Fallback message MUSÍ být human-readable pro klienta. Žádné stack traces, žádná technical jargon.

```
✗ "Error in line 42: NoneType has no attribute 'parse'"
✓ "Vstupní soubor klient X (ID 12345) nešel zpracovat — chybí pole 'datum'. Zaslán e-mail klientovi s žádostí o doplnění."
```

### Krok 5 — Pre-Deployment Testing Protocol

3-warstvové testy:

| Vrstva | Pokrytí | Pass criteria |
|---|---|---|
| **Happy path** | 5-10 reálných instancí (nejčastější vstupy) | 100% match s expected output |
| **Edge cases** | Každý failure mode z mapy | Žádný crash, vždy fallback active |
| **Adversarial** | Worst inputs (empty, malformed, malicious) | Gracefully degrade, nezaspamuje API |

**Testing iron rule:**
> "If the worst possible input hit this agent right now, would it fail gracefully or catastrophically?"

Pokud catastrophically → vrať se ke Krok 3.

## Výstupní formát

Sav do `~/Documents/oneflow-agents/{client_slug}/02-build.md`:

```markdown
# Agent Build: {Client Name} — {Agent Name}

**Date:** YYYY-MM-DD
**Status:** PRODUCTION-READY → READY FOR PHASE 3 DEPLOY

## 1. Build Status
- Code path: {repo}/{path}
- Last commit: {sha}
- Phase 1 plan: {link}

## 2. Failure Point Map
[Tabulka per workflow step]

## 3. Error Handling
[Code snippets nebo pseudo-kódu per failure]

## 4. Fallback Logic
[Safe defaults + human handoff triggers]

## 5. Testing Protocol Results
- Happy path: PASS (X/X)
- Edge cases: PASS (Y/Y)
- Adversarial: PASS (Z/Z)

## Hand-off Test
[Yes/No: Would worst input fail gracefully? If No → fix what.]
```

## Integrace s ekosystémem

- Použij `/agent-loop` skill pro engineering pattern (decompose → review → reapply)
- Použij `/agent-harness-construction` pro action space tuning
- Pro Python testy: `/python-testing-patterns`
- Pro Playwright (UI agent): `/playwright-best-practices`
- Pro chaos testing: `/agent-stagnation-guard`

## Auto-chain do Phase 3

Po PASS testu (všechny 3 vrstvy testů) → `/agent-business-lifecycle deploy {client_slug}`.
