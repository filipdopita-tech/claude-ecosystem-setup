---
name: writing
description: Umbrella for skill authoring AND marketing copywriting. Use --skills flag when creating/editing/verifying Claude skills before deployment. Use --copy flag when writing marketing copy for homepage, landing pages, pricing pages, feature pages, about pages, or product pages — including value props, headlines, CTAs, hero sections. Triggers include "write copy for", "create new skill", "improve this copy", "skill SKILL.md", "rewrite this page", "marketing copy", "headline help", "CTA copy", "value proposition", "tagline", "subheadline", "hero section copy", "above the fold", "this copy is weak", "make this more compelling", "verify skill works". For email copy → cold-email. For popup → popup-cro. For existing copy edits → copy-editing.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Grep
  - Glob
metadata:
  version: 1.0.0
  merged_from:
    - writing-skills (W3.4 2026-05-02)
    - copywriting (W3.4 2026-05-02)
---

# /writing — Skill Authoring + Marketing Copy Umbrella

Two domains, lazy-loaded:

## Routing

| Invocation | Reference file | Use case |
|---|---|---|
| `/writing --skills` (or skill-related triggers) | `reference/skills.md` | Create/edit/verify Claude skills, SKILL.md structure, CSO description optimization, TDD mapping for skills |
| `/writing --copy` (or copy-related triggers) | `reference/copy.md` | Marketing copy: homepage, landing, pricing, feature, about pages — headlines, CTAs, value props, hero sections |

## What You Must Do When Invoked

### Step 1 — Detect domain

If user mentions: skill, SKILL.md, skill creation, skill verification, skill structure, CSO description → load `reference/skills.md`.

If user mentions: copy, marketing, headline, hero, CTA, landing page, value prop, tagline, subheadline → load `reference/copy.md`.

If both/ambiguous → ask Filip which domain (this is one of HARD-STOP edge cases — strategic ambiguity, no auto-default). For OneFlow tasks default to `--copy` (CZ B2B marketing).

### Step 2 — Apply domain logic from reference file

Each reference file is the original full skill body. Read it once, follow its workflow.

### Step 3 — OneFlow voice (when --copy)

Both domains respect OneFlow voice rules from `~/.claude/rules/oneflow-all.md`:
- CZ direct, no apology, no exclamations
- Sign "Dopita"
- Banned words list (inovativní, revoluční, komplexní řešení, win-win, atd.)
- AI patterns to remove (5/10 lists, "Furthermore", em-dash abuse)

### Step 4 — Quality check

For `--copy`: run `evalopt` chain if output is final/customer-facing (per workflow-routing.md).
For `--skills`: verify SKILL.md frontmatter + CSO description before commit.
