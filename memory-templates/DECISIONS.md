---
description: |
  Architectural and strategic decisions with rationale. When a decision was made,
  why, and what alternatives were rejected. Prevents relitigating the same choices.
---

# Decisions

Record decisions that have lasting consequences. Use this file to avoid
re-explaining context to Claude and to avoid second-guessing past choices.

## Format

```
### [Short decision title]
- **Date:** YYYY-MM-DD
- **Context:** Why the decision was needed.
- **Decision:** What was chosen.
- **Alternatives rejected:** What else was considered and why it lost.
- **Consequences:** What this choice constrains going forward.
- **Review trigger:** When to revisit (or "never revisit" if settled).
```

---

## Architecture

### [FILL decision title]
- **Date:** [FILL]
- **Context:** [FILL]
- **Decision:** [FILL]
- **Alternatives rejected:** [FILL]
- **Consequences:** [FILL]
- **Review trigger:** [FILL]

---

## Infrastructure

### [FILL decision title]
- **Date:** [FILL]
- **Context:** [FILL]
- **Decision:** [FILL]
- **Alternatives rejected:** [FILL]
- **Consequences:** [FILL]
- **Review trigger:** [FILL]

---

## Tooling

### [FILL decision title]
- **Date:** [FILL]
- **Context:** [FILL]
- **Decision:** [FILL]
- **Alternatives rejected:** [FILL]
- **Consequences:** [FILL]
- **Review trigger:** [FILL]

---

## Cost & Model Routing

### Sonnet as workspace default (not Opus)
- **Date:** 2026-04-24
- **Context:** Opus sessions for research work were burning $10-50/session.
- **Decision:** claude-sonnet-4-6 set as workspace default. Opus only on explicit request.
- **Alternatives rejected:** Haiku default — insufficient judgment for complex edits.
- **Consequences:** Some implementation tasks may need explicit Opus escalation.
- **Review trigger:** If Sonnet 4.x pricing drops to near Haiku levels.

---

*Template version: 1.0*
