---
name: evolve-scan
description: On-demand post-session scan pro durable memory candidates a project-local skill candidates. Cherry-pick z holaboss-ai/holaOS post-run-evolve stage (5192★ MIT). 4 kategorie - command facts, business facts, procedures, blocker candidates. Threshold ≥0.82 confidence + ≥36 char evidence (heuristic). Output do ~/.claude/review-queue/evolve-<date>.md pro /apply-improvements review. Trigger /evolve-scan, "co se naučit z téhle session", "co uložit do paměti", "extrahuj decisions z chatu". Komplementární k /memory-audit (staleness) a /apply-improvements (queue processor) - tohle generuje kandidáty. NE konflikt s /evolve (instinct CLI z continuous-learning-v2).
---

# Evolve Scan — Post-Session Durable Candidate Extraction

## Princip (z holaOS post-run-evolve stage)

Po session vyextrahuj durable candidates - decisions, facts, procedures, blockers - které stojí za uložení. Kategorizuj. Apply confidence threshold. Output do review queue, ne přímo memory (žádný auto-write bez Filipova explicit OK).

## Kdy spustit

- **Po session s rozhodnutími** - Filip explicit "tohle si zapiš", "tohle je důležité pamatovat"
- **Po komplexní session** - 30+ min, 10+ tool calls, nové decisions
- **Po debug/incident session** - extracted lessons learned
- **Po klient call/meeting recap** - business facts (price, scope, timeline)
- **Nový workflow odhalen** - Filip 3+× řekl "vždycky to dělej takhle"

NEspouštěj:
- Po triviální Q&A (lookup, list, status check)
- Když Filip explicit "nepamatuj"
- Po session bez user-stated requirements

## 4 Kategorie (per holaOS evolve heuristic)

### 1. Command facts
Successful commands, file paths, API endpoints, configurations Filip reused with success.
- Bash command s success exit + Filip approval
- File path reference Filip used 2+× s success
- API call working configuration

### 2. Business facts
Decisions, prices, dates, contracts, klient details, project status.
- "Smlouva XYZ podepsána"
- "Cena pro klient ABC = 45k Kč"
- "Termín pro DD do 2026-MM-DD"
- "Email kontakt = X"

### 3. Procedures
Multi-step workflows successfully executed, replicable.
- "Pro deploy XYZ: 1) ssh, 2) systemctl, 3) verify"
- "Pro DD batch: ARES → fuzzy dedup → score → report"

### 4. Blocker candidates
Repeated denial/violation patterns - already handled by `~/scripts/automation/blocker-aggregator.sh` cron Mon-Fri 08:00. /evolve-scan pouze surface kontextu k existujícím blockerům.

## Confidence Heuristics (z holaOS thresholds)

Per holaOS:
- **Standard threshold**: confidence ≥ 0.82 AND evidence length ≥ 36 chars
- **Corroborated** (s heuristickým signálem): confidence ≥ 0.6 AND evidence ≥ 16 chars

Heuristic confidence (Claude self-eval, žádný separátní model):

| Signal | Confidence boost |
|---|---|
| Filip explicit "tohle si pamatuj" / "důležité" | +0.30 |
| Filip explicit potvrzení po draft ("ano", "přesně", "perfekt") | +0.20 |
| Tool call s exit 0 + Filip neopravil výstup | +0.15 |
| Numeric/datum/IČO/email konkrétní hodnota (ne odhad) | +0.15 |
| Recurrence — fact zmíněný 2+× v session | +0.20 |
| Filip explicit "to ne" / "nepamatuj" | -1.0 (DROP) |
| Spekulativní "možná" / "asi" / "[GUESS]" marker | -0.30 |
| Hallucination flag z hooks (hallucination-violations.jsonl) | DROP |

Base confidence 0.5. Final = clamp(base + Σboosts, 0, 1).

## Workflow

1. **Read current session transcript** - access via `~/.claude/projects/-Users-filipdopita/<session-uuid>/<session-uuid>.jsonl` nebo via prompt context
2. **Extract candidates** per 4 kategorie - scan user messages + assistant responses + tool results
3. **Score confidence** per heuristic table
4. **Filter** keep only confidence ≥ 0.82 OR (≥ 0.6 AND corroborated by heuristic)
5. **Classify scope**:
   - Cross-project (Filip preference, brand voice, system rule) → **suggest globální memory entry**
   - Project-specific (klient detail, project decision) → **suggest project AGENTS.md** (chain s /agents-md skill)
   - Workflow procedure → **suggest skill update or knowledge-router entry**
6. **Write candidates** do `~/.claude/review-queue/evolve-<YYYY-MM-DD>.md` strukturovaný format
7. **Report Filipovi** kolik kandidátů, klasifikace, příští krok = `/apply-improvements`

## Output template

`~/.claude/review-queue/evolve-<YYYY-MM-DD>.md`:

```markdown
# Evolve Candidates — <YYYY-MM-DD>

Source session: <session-id or topic>
Generated: <timestamp>
Confidence threshold: 0.82 (or 0.6 + corroborated)

## Command Facts (N)

### CF-1 — confidence 0.92
**Fact**: <konkrétní fact>
**Evidence**: <quote z session, ≥36 chars>
**Suggested location**: globální memory `<filename>.md` | project AGENTS.md | knowledge-router entry
**Suggested action**: APPEND | UPDATE existing `<file>` | NEW skill

## Business Facts (N)
...

## Procedures (N)
...

## Blocker Context (N)
> Pouze kontext - blocker candidates samotné jsou v blocker-*.md (cron aggregator)
...

## Action
Run `/apply-improvements` to triage tyto candidates. Filip schvaluje per item.
```

## Vztah k existujícím Filip patterns

| Existing | Doplňuje |
|---|---|
| `/apply-improvements` | /apply-improvements processuje queue. /evolve-scan generuje queue z session. |
| `/memory-audit` | memory-audit najde stale entries. /evolve-scan najde missing entries. |
| `blocker-aggregator.sh` cron | Aggregator detekuje recurring denials. /evolve-scan extrahuje fresh learnings z aktuální session. |
| `/dream` Anthropic AutoDream | dream konsoliduje existing memory. /evolve-scan navrhuje novou memory. |
| `/postmortem` | postmortem po incidentu (structured). /evolve-scan je general session-end (broader scope). |
| `/agents-md` (sister skill) | /evolve-scan navrhuje "patří do AGENTS.md" → /agents-md ho tam zapíše. Chain. |

## NIKDY

- NEZAPISUJ candidates přímo do memory bez /apply-improvements review
- NEHODNOŤ candidates které Filip explicit "nepamatuj"
- NEVYTVÁŘEJ duplicate entry pokud existing memory soubor pokrývá téma (grep MEMORY*.md před zápisem candidate)
- NEZAHRNUJ ephemeral context (session task progress, intermediate state) - jen durable facts/decisions/procedures

## Source

[holaboss-ai/holaOS](https://github.com/holaboss-ai/holaOS) `docs/runtime-post-run-evolve-stage.md` (5192★ MIT, fetched 2026-05-07).
Original implementation: `runtime/api-server/src/turn-memory-writeback.ts` + `evolve-skill-review.ts` + `evolve.ts`.

Adapted pro Filipův Claude Code stack:
- DROP background worker / Electron / state-store DB → use markdown queue (Filip pattern)
- DROP auto-promotion → preserve human-in-the-loop via /apply-improvements
- KEEP 4 categories (command/business/procedures/blocker)
- KEEP confidence thresholds (0.82 / 0.6+corroborated)
- KEEP draft → proposed → accepted → promoted lifecycle (via review queue)
