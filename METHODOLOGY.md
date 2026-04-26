# Methodology — How This Stack Thinks

This isn't an ad-hoc collection of skills. It's a **layered reasoning system** with explicit philosophy, encoded in rules that activate on every non-trivial task.

Five core methodological pillars:

---

## 1. Mythos Prompt Scaffold (epistemological framework)

**File**: `skills/mythos/SKILL.md` (also a standalone repo: [filipdopita-tech/mythos-skill](https://github.com/filipdopita-tech/mythos-skill))

**What it is**: A structured epistemology layer inspired by Anthropic's internal Mythos research. Always uses Opus 4.7 (xhigh effort), forces:

- **Falsification-first** — for every hypothesis, find the strongest counter-argument before accepting it
- **ACH (Analysis of Competing Hypotheses)** — score 3-5 hypotheses against evidence, not just confirm the first plausible one
- **Calibrated Bayesian confidence** — outputs include explicit confidence ranges (">80% certain X because Y, but breaks on Z"), never vague "maybe"
- **Steelman opposition** — before concluding, formulate the strongest opposing position and test if conclusion survives
- **Disclosure framework** — for security findings, formal patched/unpatched-hash/out-of-scope/authorized-pentest disclosure path

**When it activates:** complex tasks with stakes (financial, legal, security), production debugging without obvious cause, architectural decisions, strategic analysis.

**Why it matters**: Default LLM behavior is "first plausible answer." Mythos forces deliberate falsification before commitment. Reduces hallucination, surfaces edge cases, calibrates confidence.

---

## 2. Šenkypl Autopilot Mode (autonomy contract)

**File**: `rules/filip-autopilot.md`

**Core principle**: AI drives, user approves. Plan → execute → report. The user shouldn't have to babysit; the assistant decides on its own and only stops at hard-stop boundaries.

**Five-point self-eval gate** (run before asking ANY question):
1. Can I figure this out myself? (yes → don't ask)
2. Is there a best guess >60% confident? (yes → use it, don't ask)
3. Is the action reversible? (yes → just do it)
4. Is the cost of wrong choice < 30s flow break? (yes → just do it)
5. Is this a HARD-STOP? (no → don't ask)

**Hard-stop zones** (always ask first):
- Payments / financial costs
- Sending external messages (email, Slack, WhatsApp, SMS, Telegram)
- Irreversible destruction (DB drop, force-push to main, `rm -rf` on prod)

**Anti-sycophancy enforced**:
- Never start responses with "Excellent!", "Perfect!", "Great idea!", "Interesting question..."
- If user changes direction without new evidence — push back, don't just comply
- Disagree directly with reason: "This won't work because X" beats "Maybe consider..."
- Celebrate only real ships, hard problems solved, measurable metrics — not ideas/drafts/plans

**Why it matters**: Default LLM behavior is excessive checking and sycophantic agreement. This rule pushes the assistant to act decisively while protecting against catastrophic actions.

---

## 3. Boil-the-Ocean Quality Standard

**File**: `rules/quality-standard.md`

**Core principle**: Marginal cost of completeness with AI is near zero. So never artificially stop short of permanent solution when fix is in reach.

**Activates when:**
- Permanent fix exists, is in reach, no side effects → do it (don't workaround)
- Dangling thread will stay dangling forever without you → close it
- Complete solution = workaround + 10 minutes more → make it complete
- Tests/edge cases/docs are part of "done", not bonus

**Doesn't activate (avoid scope creep):**
- Unrelated "improvements"
- Architecture beyond task scope
- Things outside the user's explicit intent

**Disambiguator**: "Is this part of the permanent solution, or am I adding things?" If part → do. If adding → stop.

**Why it matters**: Default LLM behavior is "do what was asked, nothing more, nothing less." This rule overrides that when completeness cost ≈ 0, because anything less means future cleanup work for the user.

---

## 4. Prompt Completeness Iron Law

**File**: `rules/prompt-completeness.md`

**Core principle**: Every discrete point in a multi-point prompt MUST have a verifiable output. No silent skips.

**Mandatory protocol for any multi-point prompt:**
1. **Pre-action**: TodoWrite ALL points before first tool call (no skipping, even if trivial)
2. **In-action**: one in_progress at a time; blockers stay in_progress with explicit blocker note (never silent skip)
3. **Close-out**: re-read the original prompt (scroll up, not from memory) before final response, verify each point has output
4. **Failure mode**: if point can't be completed, response is "Done X/Y, missing Z because W" — never silent omission with declaration of "Done."

**Anti-patterns banned:**
- "Plán" = output (no — plan is only output for destructive ops, otherwise = result)
- "Po schválení" without explicit user approval to defer
- "Čeká na X" without verifying X is actually missing in memory/filesystem/API
- Silent cherry-picking the most obvious point and ignoring others

**Why it matters**: This rule was created after a real failure pattern (2026-04-19): user gave 4-point prompt, assistant did 1, silently deferred 3 with vague excuses. This is a hard blocker, not a hint.

---

## 5. Reasoning Depth Override (effort max)

**File**: `rules/reasoning-depth.md`

**Core principle**: Reasoning quality > brevity. Never sacrifice analytical correctness for word budget compliance.

**Default behavior:**
- Treat every request as complex unless explicitly trivial
- Internal think-step-by-step; surface only key findings (conclusions, caveats, edge cases) — not the process
- Falsification-first on every non-trivial conclusion
- Calibrated confidence (no vague "maybe", no fact-as-guess, no guess-as-fact)

**Auto full-depth mode** (no word budget):
- Task starts with `!!` or contains "full effort" / "kritické" / "fakt důležité"
- Financial, legal, or security impact
- Architectural or strategic decisions
- Debug with unclear cause
- Question where wrong answer is worse than no answer

**Why it matters**: Token efficiency is a secondary objective. When stakes are high, the assistant must produce deep, calibrated reasoning even at the cost of length. This rule explicitly overrides the brevity preference in such cases.

---

## How these compose

The 5 pillars stack on every non-trivial task:

```
User prompt arrives
        ↓
[Šenkypl] Self-eval gate: should I ask, or decide?
        ↓
[Prompt Completeness] TodoWrite all points if multi-point
        ↓
[Reasoning Depth] Internal think-step-by-step + falsification
        ↓
[Mythos] (if complex/stakes) ACH + steelman + Bayesian confidence
        ↓
[Boil the Ocean] Permanent fix in reach? Do it.
        ↓
Final response = key findings only (no preamble, no narration)
        ↓
[Prompt Completeness] Close-out re-read: every point has output?
        ↓
Ship
```

**The result**: a thinking pattern that's deliberate, falsification-first, autonomous within hard-stop boundaries, complete to user prompt, and calibrated in confidence — without the user having to specify all of this each time.

---

## Comparison to "vanilla" Claude Code

| Dimension | Vanilla Claude | This stack |
|---|---|---|
| Default reasoning depth | Surface; first plausible answer | Falsification-first, calibrated confidence |
| Multi-point prompts | Often cherry-picks obvious point | Iron law: TodoWrite all, close-out re-read |
| Autonomy | Asks frequently | Šenkypl 5-point gate; act unless hard-stop |
| Sycophancy | "Great question!" "Excellent!" | Banned; disagree with reason |
| Quality bar | "Done = task complete" | "Done = permanent solution; tests; no dangling threads" |
| Stakes recognition | Same depth for trivial and critical | Auto-detects financial/legal/security; full-depth mode |

**Net effect**: same model (Opus 4.7), substantially different operational behavior. The methodology is the differentiator, not the underlying LLM.
