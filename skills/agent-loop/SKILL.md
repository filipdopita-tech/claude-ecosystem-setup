---
name: agent-loop
description: "Engineering agent loops pattern — postupné decomposition úkolu na investigate → review → pickup subagent chains. Pro: bug fixing, DD validace, investor research, multi-step rozhodovací úkoly. Trigger: /agent-loop <task>, 'rozjeď agent loop pro X', 'agentní řešení pro Y', 'rozdělit na subagenty s reviewem'."
argument-hint: "<task description>"
user-invocable: true
allowed-tools:
  - Bash
  - Task
  - Read
  - Write
  - Edit
  - TodoWrite
metadata:
  source: "skool-intel cherry-pick 2026-04-28: claude-code-architects 'Egnineering Agent Loops and Workflows' (15 komentářů, 21 likes)"
  filip-adaptace: "Pro OneFlow context: aplikováno na DD validace, Tereza pipeline, investor outreach review."
---

# Agent Loop — Decomposition + Self-Review Pattern

**Cíl:** Eliminovat lazy work / assumptions / gaps tím, že každý subagent má **explicit reviewera**, a teprve potom main agent přijme výsledek.

**Argument:** `$ARGUMENTS` — popis taskového kontextu (1-3 věty).

## Why this exists

Pattern ze Skool (claude-code-architects, Grant Charge): "Agent loops are workflows that stick together and feedback forwards *and* backwards. They are designed to catch lazy work/assumptions/gaps."

**Bez loop:** Claude jednou udělá → 70% kvalita → ship → bug found → Filip opravuje.
**S loop:** Claude udělá → reviewer subagent najde gaps → opraví → 95% kvalita → ship.

ROI: investice 2× tokenů na review = ušetření 5-20× tokenů na opravách + reputační dopad.

## Pattern Architecture

```
┌──────────────────┐
│ User: task X     │
└────────┬─────────┘
         ▼
┌──────────────────────────┐
│ Main Claude:             │
│ describe X to itself     │  ← Step 1: forced articulation
│ verify understanding     │
└────────┬─────────────────┘
         ▼
┌──────────────────────────┐
│ Subagent /investigate    │  ← Step 2: deep work
│ (Sonnet/Opus, full ctx)  │
└────────┬─────────────────┘
         ▼ (output)
┌──────────────────────────┐
│ Subagent /review-X       │  ← Step 3: independent review
│ (different agent type,   │
│  fresh context)          │
└────────┬─────────────────┘
         ▼ (PASS / FIXES needed)
   ┌─────┴─────┐
   ▼ FAIL     ▼ PASS
   ↑          │
   └──────────┴───→ /pickup-X (final action)
```

## When to use

| Task signature | Use loop? | Reason |
|---|---|---|
| Bug fix s reprodukcí | ✅ ANO | investigate root cause → review fix → apply |
| DD report >5 stran | ✅ ANO | research → factcheck → write |
| Investor outreach copy | ✅ ANO | draft → brand+deliverability check → send |
| Klient nabídka >50k Kč | ✅ ANO | scope → red-team → polish |
| Refactor přes 5+ souborů | ✅ ANO | plan → impact analysis → execute |
| Quick grep / lookup | ❌ NE | overhead > benefit |
| Read 1 soubor | ❌ NE | trivial |
| Single message Filipovi | ❌ NE | ne worth tokens |

## Templates (3 hotové loops)

### Loop A — Bug Investigation (DEBUG)
```bash
TASK="$ARGUMENTS"

# Step 1: Articulate
echo "Bug context: $TASK" > /tmp/loop-bug-context.md

# Step 2: Investigate subagent
# (use Agent tool with subagent_type=gsd-debugger or general-purpose)
# Prompt:
# "Investigate bug: $TASK
#  1. Reproduce deterministically
#  2. Trace data flow (no guessing)
#  3. Form hypothesis with evidence
#  4. Output: {root_cause, affected_files, proposed_fix, test_strategy}"

# Step 3: Review subagent (FRESH context, different agent)
# Prompt:
# "Review investigation: <output from step 2>
#  - Is reproduction deterministic?
#  - Is root cause supported by evidence (not symptom)?
#  - Does proposed_fix have blast radius >5 files? If yes, FLAG.
#  - Output: {verdict: PASS|REVISE, gaps: [...], proceed: bool}"

# Step 4: Pickup (apply fix only if review PASS)
# If review REVISE → loop back to step 2 with reviewer's gaps as context.
```

### Loop B — DD Emitent Validation
```bash
EMITENT="$ARGUMENTS"

# Step 1: Articulate scope
# "DD task: emitent $EMITENT, full A-F scoring, ARES + ISIR + DSCR + LTV + UBO"

# Step 2: Research subagent
# Spawn: dd-emitent skill (existing)
# Output: draft DD report

# Step 3: Review subagent (RED-TEAM mode)
# Prompt: "Red-team this DD report. Find:
#  - Halucinované finanční metriky (cross-check ARES bulk + ISIR API)
#  - Missing risk dimensions (per ~/.claude/expertise/czech-regulatory.yaml)
#  - Unsupported claims (každé číslo musí mít source citation)
#  - Output: {fixes: [...], severity: P0|P1|P2|P3, ship_ready: bool}"

# Step 4: Pickup → /evalopt loop pokud score < 85, jinak ship
```

### Loop C — Investor Outreach (HIGH STAKES)
```bash
PROSPECT="$ARGUMENTS"

# Step 1: Articulate
# "Outreach: $PROSPECT, channel: email/LinkedIn/WA, goal: meeting"

# Step 2: Draft subagent
# Spawn: outreach-oneflow skill
# Output: draft message s personalization

# Step 3: Review subagent (TRIPLE CHECK)
#   3a. Brand voice check (oneflow-brand-voice-check OpenSpace)
#   3b. Deliverability check (oneflow-deliverability-check OpenSpace)
#   3c. Cialdini framework check (per outbound-sales-science.yaml)
# Output: {verdict, fixes, send_ready}

# Step 4: Pickup (HUMAN APPROVAL pro send — HARD-STOP zóna)
# → vrať Filipovi draft + verdict, NE auto-send
```

## Auto-detect: Use loop, skip loop, or escalate?

```bash
# Heuristics
COMPLEXITY=$(estimate_complexity "$TASK")  # 1-10 score

if [[ $COMPLEXITY -ge 6 ]]; then
  use_loop=true
elif [[ $COMPLEXITY -ge 4 && stakes_high ]]; then
  use_loop=true
elif [[ $COMPLEXITY -le 3 ]]; then
  use_loop=false  # direct execution
fi

# stakes_high = task obsahuje keywords: investor|client|deploy prod|>10k Kč|legal|security
```

## Subagent type matrix

| Step | Recommended agent | Model | Reason |
|---|---|---|---|
| Investigate | `general-purpose` or `gsd-phase-researcher` | Opus 4.7 | Quality > cost |
| Review | `gsd-code-reviewer` or `eval-judge` | Sonnet 4.6 | Independent + fresh |
| Pickup | `gsd-executor` or main thread | Sonnet 4.6 | Apply only |

**RULE:** Investigate ≠ Review (must be different agent_type pro fresh context).

## Anti-Patterns

- **Same agent for investigate AND review** — bias compromised, ne fresh context
- **Skip review** — defeats whole purpose, lazy work survives
- **>3 loop iterations** — pokud po 3× revize stále FAIL → eskaluj Filipovi (architektura asi špatná, ne kód)
- **Loop pro trivial task** — overhead 30s+ za nothing
- **Auto-send/auto-deploy bez Filipova svolení** — HARD-STOP zóna respekt

## Integrace s existujícími skills

- `/gsd-debug` — agent loop pro debugging je nativní v GSD
- `/dd-emitent` — extend o review subagent
- `/evalopt` — review-loop pro copy/content
- `/redteam` + `/sentinel` — kombinace pro pre-ship gate
- `/challenge` — Tier A power skill pro single-pass review (rychlejší než full loop)

## Output Format

```json
{
  "task": "<original arguments>",
  "loop_type": "debug|dd|outreach|custom",
  "iterations": 1,
  "investigate_agent": "general-purpose",
  "review_agent": "eval-judge",
  "verdict": "PASS|REVISE|ESCALATE",
  "final_output": "...",
  "tokens_used": {"investigate": 5400, "review": 2100, "total": 7500},
  "time_seconds": 45
}
```

## Reference

- Source: skool-intel/claude-code-architects (Grant Charge, 2026-04-26)
- Pattern detail: `~/.claude/knowledge/code/agents.md`
- Existing implementations: `agent-harness-construction` skill, `gsd-debugger` agent, `eval-judge` agent
