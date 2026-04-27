# STATE.md
# Purpose: Current snapshot of the project — what is deployed, what is broken, what is live.
# Update cadence: weekly, or after any deployment / incident.
# Run /sync-state to auto-refresh git-derived fields.

---

## Last updated

[YYYY-MM-DD HH:MM TZ]
# Example: 2026-04-26 14:30 CEST

## Deployed version

[VERSION_TAG_OR_COMMIT_SHA]
# Example: v1.4.2 (or git sha: a3f9c12)
# Auto-filled by /sync-state via: git describe --tags --abbrev=0

## Production URL

[PROD_URL]
# Example: https://hyperframes.app

## Last deployment

Date: [DEPLOYMENT_DATE]
By: [DEPLOYER_NAME_OR_HANDLE]
Method: [DEPLOYMENT_METHOD]
# Example: Date: 2026-04-25 | By: Lukas | Method: Vercel auto-deploy on push to main

## Current sprint

Sprint: [SPRINT_ID_OR_NAME]
Dates: [SPRINT_START] — [SPRINT_END]
Goal: [SPRINT_GOAL_ONE_SENTENCE]
# Example: Sprint 7 | 2026-04-21 — 2026-05-02 | Ship retry logic and webhook delivery.

## Active branches

<!-- Auto-filled by /sync-state via: git branch -r -->

| Branch                 | Author         | Status          | PR / Notes                      |
|------------------------|----------------|-----------------|---------------------------------|
| [BRANCH_NAME]          | [AUTHOR]       | [STATUS]        | [PR_URL_OR_NOTES]               |
# Example:
# | feat/retry-logic | Lukas | In review | https://github.com/org/repo/pull/42 |

## Open pull requests

<!-- Auto-filled by /sync-state via: gh pr list --json -->

| PR #  | Title                              | Author         | Status         |
|-------|------------------------------------|----------------|----------------|
| [NUM] | [PR_TITLE]                         | [AUTHOR]       | [STATUS]       |
# Example:
# | 42 | Add retry logic for failed renders | Lukas Dlouhy | REVIEW_REQUIRED |

## Last incident

Date: [INCIDENT_DATE]
Severity: [P1/P2/P3/NONE]
Summary: [ONE_LINE_SUMMARY]
Resolution: [RESOLUTION_OR_LINK_TO_POSTMORTEM]
# Example: Date: 2026-04-10 | Severity: P2 | HeyGen webhook timeouts caused 15% job failure.
# Resolution: Increased timeout from 5 s to 30 s; jobs reprocessed manually. No data loss.

## Known issues

| ID    | Severity  | Description                                       | Workaround                       |
|-------|-----------|---------------------------------------------------|----------------------------------|
| KI-01 | [SEV]     | [DESCRIPTION]                                     | [WORKAROUND_OR_NONE]             |
# Example:
# | KI-01 | LOW | Upload fails for HTML files > 5 MB | Split HTML into smaller fragments. |

## Environment variables

<!-- List names only — never values. Describes what must be set for the app to run. -->

| Variable               | Required | Notes                                            |
|------------------------|----------|--------------------------------------------------|
| [ENV_VAR_NAME]         | YES / NO | [PURPOSE]                                        |
# Example:
# | HEYGEN_API_KEY | YES | HeyGen render API authentication.               |
