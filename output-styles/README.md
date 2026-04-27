# Output Styles

Configure Claude's response style for your task. Activate with `/output-style <name>`.

| Style | Use When | Activate |
|-------|----------|----------|
| **terse** | Need fast, code-first answers. No preamble. Minimal prose. | `/output-style terse` |
| **research** | Auditing, investigating, or gathering facts. Need sources & confidence labels. | `/output-style research` |
| **teaching** | Learning a concept. Need clear explanation with WHY→HOW→WHAT structure. | `/output-style teaching` |

## Quick reference

- **terse**: 3–5 sentences max. Code blocks first. No emoji. No summaries.
- **research**: Every claim cited `[url]` with confidence `[HIGH/MEDIUM/LOW]`. Separate facts from inference. End with "What I did NOT verify".
- **teaching**: Lead with WHY (motivation), then HOW (mechanism), then WHAT (definition). Confirm understanding with a targeted question.

## Default behavior

Without an active output style, Claude uses conversational defaults: explanatory preambles, summaries, and balanced prose.

---

*For Lukáš Dlouhý's Claude Code ecosystem.*
