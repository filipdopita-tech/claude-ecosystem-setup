# Verify Before Done — Prove It Works

A task is not done until there is evidence it works. "I wrote the code" is not evidence. "The test passed / the page renders / the diff is clean" is.

This complements `quality-standard.md` (which sets the bar for completeness) by adding the verification artifact.

## What Counts As Evidence

In rough order of strength:

1. A test that exercised the change passed.
2. The feature was used in a browser/CLI and the expected output was observed.
3. A type checker or linter passed against the changed code.
4. A diff was reviewed and matches the planned changes.

For UI/frontend changes, evidence #2 is required — type checking and tests verify code correctness, not feature correctness. If the UI cannot be tested in this session, say so explicitly rather than claiming success.

## Required For

- Bug fixes — show the bug is gone, not just that the code "looks right."
- New features — exercise the happy path at minimum.
- Refactors that change behavior contract — run the existing test suite.
- Anything user-visible.

## Skip For

- Pure formatting / rename / comment edits.
- Documentation changes.
- Edits where the test suite or type checker covers the change automatically and was already run.

## What "Done" Looks Like In The Reply

End-of-task summary names the evidence. Not "implemented X" but "implemented X — `npm test` passes, verified in browser at /foo." If verification was skipped, say which step was skipped and why.

## Why

Half-verified work creates rework. The user pays in attention every time a "done" task turns out to be broken. Verification is cheap relative to the cost of finding the failure later in production or in a follow-up session.
