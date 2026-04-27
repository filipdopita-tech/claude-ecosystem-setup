# Memory Templates

Instructions for setting up your Claude Code memory directory using the three-layer pattern.

## Three-Layer Memory Pattern

Memory is organized in three layers, read in order:

**Layer 1 — Index (MEMORY.md)**
The only file Claude reads on every session start. Pure table of contents: one line per topic file, no content. Under 50 lines. Loaded once, cached cheaply.

**Layer 2 — Topic files**
Domain content split by concern: profile, cost discipline, brand voice, per-project knowledge, learnings, conventions, decisions, mistakes. Claude reads a topic file only when the current task is relevant to that domain. A task about video rendering reads `project_hyperframes.md`. A task about cost routing reads `feedback_cost.md`. Everything else stays out of the context window.

**Layer 3 — Project memory**
Per-project files (e.g., `project_hyperframes.md`) contain stack, repo, focus areas, known issues. One file per project. Fetched only when working on that project.

### Why this matters

A flat MEMORY.md with all content inline bloats every session. A 200-line file read at session start costs ~200 tokens on every turn across the full session. At Sonnet rates, a 20-turn session with 200 extra tokens per turn = 4 000 tokens extra = ~$0.06 — small per session, material across hundreds. The index pattern keeps the warm path cheap and the full knowledge available on demand.

---

## Quick Start

1. **Copy templates to your memory directory:**
   ```bash
   cp *.template ~/path/to/your/memory/
   ```

2. **Remove `.template` suffix:**
   ```bash
   cd ~/path/to/your/memory/
   for f in *.template; do mv "$f" "${f%.template}"; done
   ```

3. **Fill in placeholders:** Replace `[FILL ...]` sections with real information.

4. **Link from main MEMORY.md:** Update the index to match the files you have.

---

## Files

| File | Layer | Purpose | Lines |
|------|-------|---------|-------|
| `MEMORY.md.template` | 1 — Index | Pure table of contents, no content | ~35 |
| `user_profile.md.template` | 2 — Topic | Role, stack, communication style | ~55 |
| `feedback_cost.md.template` | 2 — Topic | Token budget and model routing rules | ~65 |
| `user_brand.md.template` | 2 — Topic | Tone, vocabulary, brand voice | ~60 |
| `LEARNINGS.md.template` | 2 — Topic | Discovered patterns, gotchas, things that work | ~50 |
| `CONVENTIONS.md.template` | 2 — Topic | Coding and workflow conventions | ~45 |
| `DECISIONS.md.template` | 2 — Topic | Architectural decisions with rationale | ~55 |
| `MISTAKES.md.template` | 2 — Topic | Anti-patterns from past failures | ~45 |
| `project_template.md` | 3 — Project | Template for per-project memory | ~85 |
| `README.md` | Meta | This file | ~120 |

---

## How Claude Uses These Files

Claude Code reads `MEMORY.md` at session start (via `~/.claude/projects/*/memory/MEMORY.md`). It sees only the index. When a task is relevant to a domain, Claude follows the link and reads that topic file.

### Routing examples

| Task | Files read |
|------|-----------|
| Debugging a render bug | `project_hyperframes.md` |
| Answering a question about cost routing | `feedback_cost.md` |
| Writing copy for a landing page | `user_brand.md` |
| Starting a new unfamiliar task | `LEARNINGS.md` + `CONVENTIONS.md` |
| Revisiting an architecture decision | `DECISIONS.md` |
| Avoiding a known failure mode | `MISTAKES.md` |

---

## Maintenance

**After any session that discovers something new:** Add an entry to `LEARNINGS.md`. Format: `[YYYY-MM-DD] context: what was discovered.`

**After any architectural decision:** Add to `DECISIONS.md`. Include alternatives rejected.

**After anything goes wrong:** Add to `MISTAKES.md`. Be specific about cost (time, money, data). Include the prevention rule.

**Never put content in MEMORY.md.** If you are tempted to add a fact directly to the index, create a topic file instead and link to it.

---

## Adding a New Project

1. Copy `project_template.md` to `project_[name].md`.
2. Fill in all `[FILL]` placeholders.
3. Add a line to the `## Projects` section of `MEMORY.md`.

---

*Instructions version: 2.0 — three-layer pattern*
