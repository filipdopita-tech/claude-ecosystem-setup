# ACTIVE.md
# Purpose: What is being worked on RIGHT NOW.
# Update cadence: daily, or at the start/end of each Claude Code session.
# This is the most volatile doc — write freely, then tidy at end of session.
# Refer to ROADMAP.md for milestone context; refer to STATE.md for current env state.

---

## Last updated

[YYYY-MM-DD HH:MM TZ]
# Example: 2026-04-26 09:15 CEST

## Current task

[ONE_SENTENCE_DESCRIPTION_OF_WHAT_IS_BEING_WORKED_ON_RIGHT_NOW]
# Example: Implementing exponential back-off retry logic in the render job queue (M-01).

## Context

[2-4 SENTENCES: why this task, what triggered it, relevant background not in ROADMAP/STATE.]
# Example:
# HeyGen API returns 429 errors under moderate load. Retry logic is required before public
# launch. Approach agreed: exponential back-off with jitter, max 3 retries, dead-letter queue
# for permanently failed jobs.

## Blockers

- [BLOCKER_1]
- [BLOCKER_2]
# Example:
# - Waiting on HeyGen support to confirm rate limit headers are stable across API versions.
# Leave blank if none: "- none"

## Decisions pending

- [DECISION_1]: [OPTIONS_OR_CONTEXT]
- [DECISION_2]: [OPTIONS_OR_CONTEXT]
# Example:
# - Retry delay strategy: exponential vs fixed — leaning exponential; need to confirm with team.
# Leave blank if none: "- none"

## Next 3 actions

1. [ACTION_1]
2. [ACTION_2]
3. [ACTION_3]
# Example:
# 1. Write unit tests for retry queue (src/queue/retry.test.ts).
# 2. Deploy to staging and run load test (5 concurrent jobs, verify no 429s leak through).
# 3. Update STATE.md with staging result and open PR for review.

## Recently completed (this session)

- [COMPLETED_ITEM_1]
- [COMPLETED_ITEM_2]
# Example:
# - Scaffolded RetryQueue class with basic enqueue/dequeue logic.
# - Added HEYGEN_RETRY_MAX env var to STATE.md known variables.
