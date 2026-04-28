---
description: Full marketing + performance audit of a landing page — copy strategy and technical
argument-hint: "<url>"
allowed-tools: Agent, WebFetch, Bash
---

# /audit-page

Run a dual-track audit of the landing page at $ARGUMENTS.

URL=$ARGUMENTS

If $ARGUMENTS is empty or does not start with http, stop and tell the user:
"Provide a full URL starting with http:// or https://"

## Step 1 — Fetch raw page content

Use WebFetch to retrieve the page at $ARGUMENTS.
Store the raw HTML/text for passing to both subagents.
If the fetch fails (non-200 or timeout), stop and report the error.

## Step 2 — Spawn two parallel audit agents

Launch both agents simultaneously (do not wait for one before starting the other).

### Agent A — copy-strategist

Spawn Agent with subagent_type "copy-strategist" and this prompt:

---
You are a direct-response copy strategist. Audit the following landing page content.

URL: $ARGUMENTS
PAGE CONTENT:
<raw page text from Step 1>

Produce a structured audit covering:
1. Headline clarity (score 1-10, reason, suggested rewrite)
2. Value proposition specificity (score 1-10, reason, suggested copy)
3. Social proof presence and credibility (score 1-10, observations)
4. CTA strength and placement (score 1-10, suggested improvements)
5. Objection handling gaps (list up to 5 missing objection responses)
6. Reading level and tone fit for inferred audience (brief assessment)

Format each section as: ## Section Name | Score X/10 \n Findings \n Fix

Return only the audit, no preamble.
---

### Agent B — perf-auditor

Spawn Agent with subagent_type "perf-auditor" and this prompt:

---
You are a web performance and technical SEO auditor. Audit the following landing page.

URL: $ARGUMENTS
PAGE CONTENT:
<raw page text from Step 1>

Produce a structured audit covering:
1. Page title and meta description (present/missing, length, keyword relevance)
2. Heading hierarchy (H1 count, H2/H3 structure, keyword usage)
3. Image alt text coverage (estimate from content)
4. Schema markup presence (JSON-LD, OG tags, Twitter cards)
5. Identified render-blocking signals (inline scripts, large CSS in head)
6. Mobile-friendliness signals (viewport meta, tap-target language)
7. Core Web Vitals risk factors inferred from markup

Format each section as: ## Section Name | Status: PASS / WARN / FAIL \n Findings \n Fix

Return only the audit, no preamble.
---

## Step 3 — Merge into prioritized fix list

Wait for both agents to return. Then produce a unified output:

### Marketing Audit
<Agent A output verbatim>

### Technical Audit
<Agent B output verbatim>

### Prioritized Fix List

Combine all FIX items from both audits. Sort by impact tier:
- P1 — Fix immediately (blocks conversion or indexing)
- P2 — Fix this sprint (significant uplift)
- P3 — Nice to have (marginal gains)

Print as a numbered list: `N. [P1|P2|P3] <fix description>`

No score inflation. If both audits surface the same issue, list it once at the higher priority.
