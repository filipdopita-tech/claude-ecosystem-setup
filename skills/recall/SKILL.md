---
name: recall
description: Fast cascading memory retrieval. Use when user asks "co jsme řešili o X", "vzpomínáš na Y", "pamatuješ jak jsme dělali Z", or you need historical context before action. Cascades cheap-to-expensive — grep MEMORY*.md → memory/*.md → memory-search MCP → Obsidian search → graphiti. Stop on first quality hit. Token-cheap by design.
allowed-tools: Bash, Read, Grep, Glob
---

# /recall — Cascading Memory Retrieval

Quickly find historical context bez bulk-loading whole memory directory. Cascades from cheapest (grep) to most expensive (semantic search), stopping on first quality match.

## When to invoke

- User asks "co jsme řešili o X" / "pamatuješ Y" / "už jsme to dělali"
- You're about to act and need to check past decisions/feedback
- User mentions project/incident/contact bez detailů (Tereza, Šulc, Musil, Conductor, etc.)
- Before implementing — search "feedback X" + "incident Y" pro relevant constraints

## Skip when

- Triviální op (grep, ls, mv) - just do it
- Task is purely about current code (ne historical)
- User already provides full context

## Cascading Protocol (top-down, stop on hit)

### Layer 1 — Grep MEMORY index files (cheapest, ~50ms, 0 tokens)

```bash
grep -i "<term>" ~/.claude/projects/<your-project-id>/memory/MEMORY.md \
                ~/.claude/projects/<your-project-id>/memory/MEMORY-INDEX-EXTRA.md \
                ~/.claude/projects/<your-project-id>/memory/MEMORY-AUTO-INDEX.md
```

If hit → Read pointed file. **STOP** if quality match found.

### Layer 2 — Grep memory directory (cheap, ~200ms)

```bash
grep -ril "<term>" ~/.claude/projects/<your-project-id>/memory/ | head -10
```

Read top hits with `Read` (offset+limit if >200 lines). **STOP** on quality match.

### Layer 3 — Memory Search MCP (LLM-based semantic, 5-8s, 0 Kč via OpenRouter free)

```
mcp__memory-search__search_memory({query: "<term context>", limit: 5})
```

Returns FULL content of top-N most relevant files (semantic, ne keyword). Only use if Layers 1-2 miss but topic feels in-memory.

### Layer 4 — Obsidian vault search (4GB content, ~2s)

```
mcp__obsidian-oneflow-vault__search-vault({query: "<term>"})
```

Use when topic is broader than Claude memory (notes, research, raw inputs).

### Layer 5 — Graphiti knowledge graph (semantic, OneFlow domain)

```
mcp__graphiti-oneflow__graphiti_search({query: "<term>", limit: 5})
```

Use when query is relational ("kdo zná X", "vztah X→Y", "kdy proběhlo X").

### Layer 6 — Session history grep (last resort)

```bash
grep -rli "<term>" ~/Documents/claude-history/ 2>/dev/null | head -5
grep -rli "<term>" ~/Documents/OneFlow-Vault/10a-Claude-History/ 2>/dev/null | head -5
```

## Output format

After finding match, summarize 3 things:

```
**Found:** <source file path>
**Context:** <1-3 sentence summary>
**Status:** <ACTIVE/CLOSED/PARKED/SUPERSEDED>
**Detail:** Read file via Read tool if user wants more.
```

If NOT found across all layers:
```
**Recall MISS:** "<term>" not in MEMORY/Obsidian/graphiti.
This either: (a) genuinely first time discussing, (b) was archived/pruned, (c) different terminology.
Try: rephrasing, broader term, or "/recall <related>".
```

## Examples

### Example 1: "co jsme řešili kolem Tereza Tulcová?"
1. Layer 1 grep "Tereza" → 4 hits v MEMORY.md (FB scrape, DYI, IG, Validation, Outreach v4)
2. Read latest (project_tereza_tulcova_validation_2026_04_27.md)
3. Output: "Found: Tereza pipeline, 24 VERIFIED, TOP 7 ready, outreach v4 v Google Doc. Detail: file."
**Token cost:** ~2KB (grep output + 1 file read).

### Example 2: "pamatuješ jak fungoval Conductor?"
1. Layer 1 grep "Conductor" → hit (project_conductor.md)
2. Read it.
3. Output: "Found: autonomní orchestr daemon na Flash, file queue. Active. Detail: file."
**Token cost:** ~1.5KB.

### Example 3: "měli jsme nějakou diskuzi o Patrick Winston?"
1. Layer 1 grep "Winston" → hit (winston_framework_implementation_2026_04_25.md)
2. Read.
3. Output: "Found: Winston framework, /winston-deck skill, CZ adaptation. Detail: file."
**Token cost:** ~1KB.

### Example 4: "co Schluntz říkal o agent design?"
1. Layer 1 grep "Schluntz" → MISS in MEMORY indexů
2. Layer 2 grep memory dir → MISS (likely 3rd-party reference)
3. Layer 3 memory-search MCP → returns relevant patterns
4. Output based on Layer 3 hit, or Recall MISS

## Anti-patterns

- ❌ Skipping cascade — going straight to MCP without grep first (10× more expensive)
- ❌ Reading whole memory directory ("just to be safe") — that's the bug we're fixing
- ❌ Asking user for context that's findable in memory
- ❌ Multiple parallel MCP calls without trying grep first

## Token budget

| Layer | Typical cost | When to escalate |
|-------|-------------|------------------|
| 1 (grep MEMORY*) | 0-200 tokens | Always start here |
| 2 (grep memory/) | 200-1500 tokens | If Layer 1 ambiguous |
| 3 (memory-search MCP) | 1500-5000 tokens | If grep misses keyword but topic feels familiar |
| 4 (Obsidian) | 1500-5000 tokens | Topic is broader than Claude memory |
| 5 (graphiti) | 2000-4000 tokens | Relational query (kdo, kdy, vztah) |
| 6 (session history) | 5000-15000 tokens | Last resort, scrape transcripts |

**Default budget:** 5000 tokens. If exceeded, report current best match + ask user to narrow.

## Why this exists

Filip's frustration 2026-04-27: "říkáš mi to znovu a znovu". Root cause: MEMORY.md was over 24KB cap, last entries got cut from context every turn. Fix: compact MEMORY.md + this cascading retrieval skill.

Without /recall: agent reads whole memory directory speculatively (50KB+ tokens) or asks user (frustrating).
With /recall: agent grep-greps in 200 tokens, finds answer, moves on.
