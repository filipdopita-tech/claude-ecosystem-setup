# PROJECT.md
# Purpose: High-level, mostly static description of the project.
# Update cadence: rarely — only when mission, stack, or key stakeholders change.
# Read first before any task on this project.

---

## Name

[PROJECT_NAME]
# Example: Hyperframes

## Mission

[One to two sentences describing what this project does and why it exists.]
# Example: Hyperframes converts HTML/CSS designs into videos via HeyGen's API,
# enabling non-technical users to produce motion graphics without a video editor.

## Status

[ACTIVE | MAINTENANCE | SUNSET | PARKED]
# Example: ACTIVE

## Stakeholders

| Role            | Name / Handle         | Contact                  |
|-----------------|-----------------------|--------------------------|
| Owner           | [OWNER_NAME]          | [OWNER_EMAIL_OR_HANDLE]  |
| Tech Lead       | [TECH_LEAD_NAME]      | [TECH_LEAD_HANDLE]       |
| Primary User    | [USER_PERSONA]        | [USER_CONTACT]           |
# Example row: | Owner | Jane Doe | jane@example.com |

## Repository

URL: [REPO_URL]
# Example: https://github.com/lukasdlouhy/hyperframes
Default branch: [DEFAULT_BRANCH]
# Example: main

## Key Links

| Resource              | URL                                  |
|-----------------------|--------------------------------------|
| Production            | [PROD_URL]                           |
| Staging               | [STAGING_URL]                        |
| CI / CD               | [CI_URL]                             |
| Error monitoring      | [SENTRY_OR_SIMILAR_URL]              |
| Docs / Wiki           | [DOCS_URL]                           |
| Design files          | [FIGMA_OR_SIMILAR_URL]               |
# Remove rows that do not apply.

## Stack

| Layer         | Technology                    | Version / Notes              |
|---------------|-------------------------------|------------------------------|
| Language      | [LANGUAGE]                    | [VERSION]                    |
| Runtime       | [RUNTIME]                     | [VERSION]                    |
| Framework     | [FRAMEWORK]                   | [VERSION]                    |
| Database      | [DATABASE]                    | [VERSION]                    |
| Hosting       | [HOSTING_PROVIDER]            | [REGION_OR_PLAN]             |
| CI / CD       | [CI_SYSTEM]                   | [PIPELINE_NAME]              |
# Example rows:
# | Language | TypeScript | 5.4 |
# | Runtime  | Node.js    | 22  |
# | Framework| Next.js    | 14  |

## Glossary

| Term            | Definition                                                    |
|-----------------|---------------------------------------------------------------|
| [TERM_1]        | [DEFINITION_1]                                                |
| [TERM_2]        | [DEFINITION_2]                                                |
# Example:
# | HeyGen API | Third-party service used to render video from template JSON. |
# Add terms specific to this project's domain. Keep definitions one sentence.

## Architecture notes

[Optional: 2-5 bullet points on non-obvious architectural decisions or constraints.]
# Example:
# - All video render jobs are async; results are polled via webhook, not waited on.
# - HTML snapshots are taken with Puppeteer and passed as base64 to HeyGen.
