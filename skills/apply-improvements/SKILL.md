---
name: apply-improvements
description: Review queue processor. Čte ~/.claude/review-queue/ s čekajícími memory/rule/skill návrhy z weekly batch, prezentuje Filipovi k schválení, aplikuje batch. Self-Eval Gate pro auto-changes — žádná modifikace bez explicitního OK.
triggers:
  - apply improvements
  - review memory improvements
  - weekly memory review
  - self-improve review
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - AskUserQuestion
---

# /apply-improvements — Review Queue Processor

## Kdy to použít

- Pondělí po memory-improvement-batch.sh (cron 08:00)
- Ad-hoc když Filip chce projít čekající změny
- Po notifikaci ntfy "Memory improvement ({week})"

## Guardrail (kritické)

**Žádná auto-aplikace bez Filipova OK.**
- Review queue = staging area
- Filip projde každý návrh
- Approved → aplikuj | Rejected → move do archive | Deferred → ponech
- Batch apply = jedna Filipova potvrzovací zpráva na 1-5 entries

## Workflow

### 1. Load queue

```bash
ls -la ~/.claude/review-queue/*.md 2>/dev/null | head
```

Pokud empty: "Žádné čekající návrhy. Baseline OK." END.

### 2. Parse & classify

Pro každý soubor v review queue extrahuj 3 kategorie:
- **A. New feedback memories** (feedback_*.md entries)
- **B. Anomalies** (informativní, no-op default)
- **C. Rule updates** (změny v ~/.claude/rules/)

### 3. Prezentuj Filipovi

Shrnutí v tabulce:
```
| # | Kategorie | Návrh | Action |
|---|-----------|-------|--------|
| 1 | feedback  | feedback_X.md | [create/update/skip] |
| 2 | rule      | rules/Y.md:Z  | [edit/skip] |
```

Pak čekej na Filipův pokyn: "aplikuj 1,2" nebo "aplikuj vše" nebo "skip 2, aplikuj zbytek".

### 4. Apply (po explicit OK)

- Feedback memory: Write do `~/.claude/projects/<your-project-id>/memory/feedback_*.md` + append do `MEMORY.md` index
- Rule update: Edit do `~/.claude/rules/*.md` (surgical, jen navrhnuté řádky)
- Anomaly: log do `~/.claude/logs/anomalies-$WEEK.jsonl`, no-op default

### 5. Archive

Po apply přesun source do `~/.claude/review-queue/_archive/YYYY-MM-applied.md`.

### 6. Summary

```
✓ Applied: N změn (seznam)
✓ Skipped: M (seznam)
→ Archive: ~/.claude/review-queue/_archive/...
```

## Anti-patterns (NEDĚLAT)

- ✗ Auto-apply bez Filipova OK (kritický red line)
- ✗ Modifikovat `~/.claude/rules/prompt-completeness.md` nebo `cost-zero-tolerance.md` — too load-bearing
- ✗ Duplicate entry (checkni grep existing memory před create)
- ✗ Refactor celého souboru pokud návrh je jen add řádek

## Integrace

- Vstup: `~/.claude/review-queue/*.md` (z memory-improvement-batch.sh v2)
- Výstup: `~/.claude/projects/<your-project-id>/memory/feedback_*.md` + `MEMORY.md` + `~/.claude/rules/*.md`
- Archive: `~/.claude/review-queue/_archive/`
- Log: `~/.claude/logs/apply-improvements.log`

## Cost

- 0 API calls (vše je čtení + editace filů + Filipův input)
- Filipův čas: ~2-5 minut/týden

## Rollback

Každá změna je atomicky přidaná řádek/soubor.
- Feedback memory: `rm ~/.claude/projects/<your-project-id>/memory/feedback_NEW.md` + remove řádek z MEMORY.md
- Rule update: git revert v `~/.claude/rules/` pokud je git; jinak manual

## Notes

- Spouští se manuálně Filipem (`/apply-improvements`)
- Týdenní cron NEPUSTÍ apply — jen generuje queue
- Weekly reminder se Filip dozví přes ntfy
