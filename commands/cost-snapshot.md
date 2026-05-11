---
name: cost-snapshot
description: |
  Estimate spend for the current Claude Code session by reading transcript size,
  model used, and tool call counts. Use when user asks about costs, token burn,
  "how much did this cost", or when running a /retro.
allowed-tools: [Bash, Read]
last-updated: 2026-04-27
version: 1.0.0
---

# Cost Snapshot Skill

Observability skill for estimating token spend and burn rate during Claude Code sessions.

## When to Use

Trigger this skill when the user:
- Asks "how much did this cost?"
- Mentions token burn or budget concern
- Runs `/retro` or end-of-session review
- Wants cost visibility before committing to expensive work

## How It Works

### 1. Find Active Transcript
Look for the most recent transcript in `~/.claude/sessions/` or similar:
```bash
ls -t ~/.claude/sessions/*.json | head -1
```

If that path doesn't exist, check `~/.claude/transcripts/` or query the harness state.

### 2. Extract Metrics
From the transcript JSON, extract:
- **Model used** (e.g., `haiku-4.5`, `sonnet-4.6`, `opus-4.7`)
- **Message count** — total back-and-forth turns
- **Tool invocations** — how many Bash, Read, Write calls
- **File sizes** — estimate via file paths if output was large

### 3. Estimate Token Count
Use this formula: **word_count × 1.3 = approximate token count**

Count words in:
- All user messages (transcript)
- All assistant responses
- All tool input/output

Multiply by 1.3 to account for JSON parsing, metadata, formatting.

### 4. Calculate Cost

Use these approximate rates (as of 2026-04-26):

| Model | Input Rate | Output Rate |
|-------|-----------|-------------|
| Haiku 4.5 | $0.80 / MTok | $4.00 / MTok |
| Sonnet 4.6 | $3.00 / MTok | $15.00 / MTok |
| Opus 4.7 | $15.00 / MTok | $75.00 / MTok |

**Formula:**
```
spend = (input_tokens / 1_000_000 × input_rate) + (output_tokens / 1_000_000 × output_rate)
```

Assume **input:output ratio of 1:2** for typical sessions (you write little, Claude writes more).

### 5. Report Findings

Output a table showing:
- **Model used** and proportion of total spend
- **Input tokens** (estimated)
- **Output tokens** (estimated)
- **Total spend** (USD)
- **Per-message cost** (total spend ÷ message count)
- **Cost reduction suggestions** (if applicable)

### Example Output

```
Session Cost Snapshot
=====================

Model     | Input   | Output  | Subtotal
----------|---------|---------|----------
Haiku     | 8,000   | 15,000  | $0.08
Sonnet    | 24,000  | 52,000  | $0.95
TOTAL     | 32,000  | 67,000  | $1.03

Per-message cost: $0.026
Average tokens/message: 397

Suggestions:
- Used Sonnet for 65% of spend. For next multi-file exploration, delegate to Haiku.
- Tool output (Bash, Read) consumed ~18% of tokens. Consider compressing JSON in next session.
```

## Implementation Notes

- **Approximate only** — Token counts are estimates (±10% margin).
- **No precision needed** — Reporting to nearest cent is sufficient.
- **Silent failures** — If transcript file is missing or unparseable, report "unable to estimate" and exit cleanly.
- **Historical context** — Optionally compare to previous session (if memory tracks it).

## References

- Anthropic docs: https://docs.anthropic.com/pricing
- Token counter: Use word_count × 1.3 as standard approximation
- Transcript location: `~/.claude/sessions/` (or check `Claude` menu → "Show Transcripts")

---

*Skill version: 1.0*
