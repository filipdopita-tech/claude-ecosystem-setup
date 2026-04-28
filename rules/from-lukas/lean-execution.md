---
name: lean-execution
description: Three execution patterns that save 15-40% tokens per session. Mandatory when not in plan/teaching mode. Extends CLAUDE.md model-routing rules with concrete operational discipline.
---

# Lean Execution

Three patterns that compound. Each alone saves marginal tokens. Together they cut typical-session cost by 15-40%.

## Pattern 1: Chain bash commands

When two or more bash steps are sequential and don't depend on intermediate output for decision-making, chain them with `&&`.

**Why:** Each tool call carries overhead — description tokens, return formatting, hook firings, context-roundtrip. Three sequential calls = 3× overhead. One chained call = 1× overhead.

**Allowed:**
```bash
mkdir -p /path && cd /path && touch file && echo "hi" > file
```

**Required separation (don't chain):**
- When the next step needs a decision based on the previous output's content
- When intermediate output is large and only the final result matters (use `>/dev/null` to suppress noise)
- When commands have wildly different failure semantics (one OK to fail, one not)

**Anti-pattern:**
```
Bash: mkdir x
Bash: cd x
Bash: touch y
Bash: echo hi > y
```
4 calls = ~600 tokens of overhead. Should be 1 call.

**Save target:** 20-40% of bash overhead in heavy-tool sessions.

## Pattern 2: Read with offset/limit

Default to targeted Read, not full-file Read.

**Required:**
- For files > 200 lines: grep first to locate, then Read with offset+limit window of 30-100 lines around the match.
- Never read the same file twice in a session unless contents changed (file_history hook tracks this — check before re-reading).
- For massive files (>1000 lines): NEVER read full file. Always grep+window.

**Anti-pattern:** "Let me read the whole file to find that function" — wastes ~3-10x tokens vs grep+window.

**Allowed without offset/limit:**
- Files known to be < 200 lines (config, small skills, small JSON)
- When you genuinely need the whole file (rewriting it, full audit)

**Save target:** 30-50% of Read tokens in exploration-heavy sessions.

## Pattern 3: Delegate research to Haiku

Per `~/.claude/CLAUDE.md`. Reinforced here:

**Always delegate to Haiku subagent:**
- WebFetch / WebSearch / any Firecrawl / scraping MCP
- Multi-file grep across an unknown codebase
- "Find me all places where X is used"
- "What does this library do" (lookup tasks)
- Mechanical counting / listing across many files

**Always delegate to Sonnet subagent:**
- Multi-file code review with judgment
- Architectural plan from messy requirements
- Synthesis across multiple research outputs

**Stay on main thread:**
- Implementation / editing of known files
- Single targeted Read with known path
- Single targeted grep with known pattern

**Why:** Web/multi-file output is large. Pulling it into Opus/Sonnet main context costs 5-25× more than the same work on Haiku. The model-routing-guard hook in PreToolUse Agent emits an advisory when this is violated — heed it.

**Save target:** 50-80% on research-heavy sessions when correctly routed.

## Compound effect

A heavy session that uses all three patterns vs none:

| Pattern | Standalone savings | Compound contribution |
|---|---|---|
| Chain bash | 20-40% of bash overhead | High in build/setup tasks |
| Read offset/limit | 30-50% of Read tokens | High in exploration |
| Haiku delegation | 50-80% on research turns | Catastrophic when violated |

Real-world session running all three: **~25-45% lower spend** vs the same work done sloppily.

## Anti-patterns to never do

- Long-form bash narration before chained commands ("Now I'll create the directory, then change into it, then…") — both wastes tokens AND splits into multiple calls.
- "Let me read the entire file to be safe" on a 2000-line file when grep would do.
- Calling WebFetch directly from main Opus thread because "it's just one fetch" — one fetch is 5000 tokens of HTML at premium pricing.
- Skipping Haiku delegation when research is needed because "the main thread already has the context" — context-loading from results is the expensive part, not the routing.

## Enforcement

- The model-routing-guard hook (PreToolUse Agent) catches Haiku-rule violations.
- Lean-execution patterns 1 and 2 are not hook-enforced — Claude follows them or doesn't. Output style `silent` reinforces them; `terse` partially.
- Skill `cost-aware-research` activates pattern 3 explicitly when keyword-matched.

## Activation

Always-on rule. Reference at task start by reading this file once per fresh session if working on a multi-tool task.
