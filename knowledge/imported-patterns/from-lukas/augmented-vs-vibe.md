# Augmented vs Vibe — Match Discipline To Stakes

Two distinct modes of AI-assisted coding. Pick the right one per task; do not mix them on the same artifact.

## Vibe Mode

Hand the model the goal, accept its output without reading every line. Iterate on behavior, not on code.

**Use for:**
- Throwaway scripts, one-off scrapers, prototypes.
- Personal tools where you are the only user.
- Creative content generation (copy, video scripts, draft posts).
- Leaf-node features: isolated modules with no downstream dependencies.

**Required guardrails even in vibe mode:**
- A way to verify behavior (browser check, sample run, test).
- The change is reversible — git committed, branch isolated.
- Failure is non-catastrophic (no production data, no shared state).

## Augmented Mode

Use the model as a co-author. You read the diff, you approve the design, you maintain test coverage and code quality.

**Use for:**
- Anything in production paths or shared with users.
- Core architecture, data schemas, API contracts.
- Anything touching auth, payments, security, or persistence.
- Refactors that change behavior contracts.
- Code that another person will maintain.

**Required practices:**
- Plan first (`plan-first.md`).
- Verify before done (`verify-before-done.md`).
- Read the diff before committing.
- Tests for the changed behavior.

## The Switch Rule

**Never start in vibe mode and silently escalate to production.** If a vibe-coded prototype starts being used for real, stop, audit it in augmented mode (re-read all the code, write tests, harden), and only then keep going.

The opposite drift — augmented coding sliding into rubber-stamping — is also failure. If you find yourself approving diffs without reading them on a production path, you have left augmented mode without noticing.

## Why

Beck's distinction: "vibe coding" ignores quality and feeds errors back to AI; "augmented coding" maintains standards while using AI as a co-author. The cost of mixing them is invisible until something breaks in production. Naming the mode forces the choice.
