# CLAUDE.md Size Discipline — Keep It Lean

A CLAUDE.md file is loaded on every session start in its scope. Every line costs tokens on every call. Bloat compounds across all sessions in that project.

## Hard Caps

- **Project root `CLAUDE.md`:** under 150 lines / ~2 KB.
- **Nested module `CLAUDE.md`:** under 50 lines.
- **`~/.claude/CLAUDE.md` (global):** under 100 lines.
- **Individual rules in `lukasdlouhy-claude-ecosystem/rules/*.md`:** under 80 lines each.

If a file exceeds the cap, it must be split or compacted, not allowed to grow.

## What Belongs Inside

A CLAUDE.md should be a *manifest* — pointers to where context lives, not the context itself.

Belongs inside:
- The 5–10 commands the project uses daily (`npm test`, `bun run dev`, etc.).
- File/directory map for non-obvious layouts.
- Project-specific conventions Claude cannot infer from code.
- Pointers to other docs (`See @docs/architecture.md for X`).

Does NOT belong inside:
- Generic coding style (lives in user-global `~/.claude/CLAUDE.md` or rules/).
- Long architecture explanations (live in dedicated docs, referenced via `@`).
- Historical context, changelogs, decision logs (lives in ADRs or git history).
- Anything duplicated from another CLAUDE.md in scope.

## Split Strategies When It Grows

Order of preference:

1. **Extract to ADR-style docs.** One decision per file in `docs/adr/` or similar. Reference inline with `@docs/adr/0042-data-layer.md`. Claude pulls only what it needs.
2. **Push down into nested CLAUDE.md.** Module-specific rules go in that module's directory.
3. **Push up into rules/.** Cross-project patterns go to `~/Desktop/lukasdlouhy-claude-ecosystem/rules/`.
4. **Delete.** Most growth is stale notes that no longer apply.

## Why

Cherny (Claude Code creator) keeps his at ~100 lines. Public showcase repos that exceed 300 lines report reduced adoption and maintenance issues. The token cost is paid on every single message — bloat is not a one-time tax.
