---
description: Simplify and refine recently written code — run after completing a task
argument-hint: [file or directory to simplify]
---

Spusť jako subagent s modelem sonnet:

Review the code changed in this session ($ARGUMENTS or git diff HEAD~1):

1. **Remove** dead code, commented-out blocks, TODO stubs
2. **Simplify** overly complex logic (>4 nesting levels → extract function)
3. **Deduplicate** repeated patterns (3+ similar lines → helper)
4. **Verify** immutability — no mutation of inputs
5. **Check** function length (>50 lines → split)

Rules:
- NEVYSVĚTLUJ co děláš — jen oprav
- Neměň public API, jen internals
- Pokud je kód OK, řekni "LGTM — no simplifications needed"
- Max 1 soubor najednou
