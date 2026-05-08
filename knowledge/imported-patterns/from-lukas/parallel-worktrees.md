# Parallel Worktrees — Multi-Stream Claude Code

When working on multiple independent features or experiments, run separate Claude Code sessions on separate `git worktree` checkouts rather than queueing them in a single session.

This is operational discipline, not a coding rule — but it changes how work flows.

## When To Use

- Multiple unrelated features in flight (frontend tweak + backend refactor + content task).
- Long-running task that does not need attention (a render, a migration, a scrape) running alongside active work.
- Trying two implementation strategies for the same problem without stepping on each other.

## When NOT To Use

- Single linear feature where context flows from step to step.
- Tightly-coupled changes across the same files.
- When the cognitive overhead of tracking N sessions exceeds the parallelism benefit (rule of thumb: > 5 active sessions for one person becomes lossy).

## How

```bash
git worktree add ../project-feature-x feature-x
cd ../project-feature-x
claude
```

Each worktree gets its own working directory, branch, and Claude session. They share the underlying `.git/` so commits are visible across worktrees.

## Cleanup

When a feature is shipped or abandoned:

```bash
git worktree remove ../project-feature-x
```

Stale worktrees pile up if not cleaned. Periodically run `git worktree list` and prune.

## Notes

- Cherny advocates 3–5 parallel sessions as the productivity sweet spot. Reddit/HN power users push 10–15 but report attention bottlenecks.
- Each session has its own context window — they do not share memory of decisions. Use the global memory system or commit messages for cross-session communication.
- For long unsupervised runs (Litt's "background agent" pattern), worktrees + a `Stop` hook + desktop notification works well.

## Why

Sequential context-switching inside one Claude session burns tokens (re-establishing context every switch) and creates state confusion. Worktrees give true isolation at the cost of disk space (cheap) and a few seconds of setup (negligible vs. session re-context cost).
