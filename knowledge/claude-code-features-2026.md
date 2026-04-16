# Claude Code Features 2026 (claude-code-best-practice)

Source: shanraisshan/claude-code-best-practice

## New Features (Q1-Q2 2026)

### Auto Mode
Claude decides when to ask for permission vs. act autonomously. Use `--auto` flag or set in settings.

### Channels
Route different task types to different models. Configure in `.claude/channels.json`.
- Example: research → Sonnet, code → Opus, summaries → Haiku

### Agent Teams
Spawn named persistent agents that maintain state across tasks. Use `--team` flag.

### Remote Control
Claude Code controllable via API/webhooks. Enables CI/CD integrations and external triggers.

### Voice Dictation
Dictate prompts via microphone. Shortcut: Shift+Cmd+V (Mac).

### No Flicker Mode
Reduces UI flashing during streaming. Useful for recording/demo sessions. `--no-flicker`.

### Routines
Pre-defined task sequences. Define in `.claude/routines.yml`. Run via `/routine <name>`.

### Ralph Wiggum Loop (Code Review Beta)
Automated iteration loop: generate → review → fix → verify.
Named after "Ralph Wiggum" pattern of naive-then-corrected execution.
Enable: `--ralph` or in settings. Best for: refactors, bug fixes, test coverage.

### Code Review Beta
Structured code review with severity levels (critical/major/minor).
Output format: REVIEW.md with findings classified by severity.

## Goal-Driven Execution (Karpathy Pattern)

For every multi-step task, define success criteria BEFORE starting:

```
1. [step] → verify: [how to check success]
2. [step] → verify: [how to check success]
```

Strong criteria = agents can loop independently.
Weak criteria ("aby to fungovalo") = require back-and-forth.

## Key Principles (Karpathy-skills, 4 principles)

1. **Specify the goal, not the method** — tell Claude WHAT, not HOW
2. **Verify, don't trust** — always define explicit verification steps
3. **Iterate in small loops** — short feedback cycles beat long autonomous runs
4. **Context is king** — more relevant context = fewer hallucinations

## Workflow Recommendations

- Use `/checkpoint` (gstack) before risky operations
- Use `/review` (gstack) after AI-generated code before shipping
- Ralph loop best for: 100+ line refactors, bug hunts, coverage gaps
- Channels: never mix research+execution in one agent call
