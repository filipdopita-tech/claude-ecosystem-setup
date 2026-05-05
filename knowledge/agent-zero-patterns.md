# AGENT-ZERO Operational Patterns (Distilled)

> Source: msitarzewski/AGENT-ZERO (200★ MIT). Distilled patterns relevantní pro Filipův ekosystém. Original 35KB → 8KB lean.
> Adaptace: 2026-05-03

## Why Adopt These Patterns

AGENT-ZERO is an "operational framework for high-quality AI-assisted development". Většina jeho patterns už pokrývá Filipův ekosystém (memory, completion-mandate, prompt-completeness, lean-engine). Tento dokument extrahuje **5 patterns** které doplňují / posilují existující stack.

---

## Pattern 1: Reuse Validation Checklist (Before Creating Files)

**Synergie s**: `~/.claude/rules/common/all-rules.md` § Surgical Changes + lean-engine.md

Před vytvořením nového souboru projdi:

```markdown
- [ ] Searched: [search terms] → found: [list files]
- [ ] Analyzed extension:
  - [ ] `existing/file1.ext` - Cannot extend: [specific technical reason]
  - [ ] `existing/file2.ext` - Cannot extend: [specific technical reason]
- [ ] Checked patterns: similar v existujícím codebase
- [ ] Justification: New file needed because [exhaustive reasoning]
```

**Application**:
- Před každým novým agent file (~/.claude/agents/*.md) — search existing
- Před novým skill (~/.claude/skills/*) — check umbrellas
- Před novým memory entry — check existing v MEMORY.md
- Před novou rule file — extend existing nebo append?

**Anti-pattern**: vytvořit `agency-financial-analyst.md` aniž bych zkontroloval že už neexistuje `dd-emitent` skill který pokrývá podobný scope. (V tomto případě komplementární, ne duplikát — verified.)

---

## Pattern 2: State Machine pro Non-GSD Tasks

**Synergie s**: GSD phases (Discuss → Plan → Execute → Verify → Ship)

```
PLAN → BUILD → DIFF → QA → APPROVAL → APPLY → DOCS
  ↑      ↑______↓______↓___[fail/changes]_____↓
  └──────────[major changes]─────────────────┘
```

**Substates**: `CODING` (building), `WAITING_TOOL` (permissions), `RUNNING` (QA), `IDLE`

**Application v Filipově ekosystému**:
- Pro non-GSD multi-step task (např. nový agent install, infra change, klient deliverable)
- Pre-implementation: PLAN s reuse analysis + integration points
- Implementation: BUILD v branch, NEVER apply main directly
- Pre-ship: DIFF show changes + rationale s file:line citations
- QA: tests + linter + build verification
- APPROVAL: user gate (Filip)
- APPLY: deploy to main + create docs
- DOCS: update memory, router, MEMORY.md index

**Mapping na existing Filip workflow**:
- PLAN ≈ `/plan` skill nebo Plan Mode (shift+tab 2x)
- BUILD ≈ implementation v worktree / branch
- DIFF ≈ `git diff` + commit message draft
- QA ≈ `agency-evidence-collector` + `agency-reality-checker`
- APPROVAL ≈ Filip explicit "ok" (mimo HARD-STOP zóny default = autonomous)
- APPLY ≈ atomic commit + push
- DOCS ≈ memory entry + MEMORY.md update

---

## Pattern 3: Continuous State Persistence (Anti-Compaction)

**Synergie s**: `~/.claude/rules/context-hygiene.md` (compaction limit pravidla)

**Klíčový insight**: Compaction může nastat **kdykoli** bez warning. State persistence musí být **continuous**, ne deferred to "before compaction".

### Při každém state transition zapsat:

1. **State machine position**: aktuální fáze + substate + working context → `activeContext.md` nebo memory entry
2. **Task progress**: append status do TodoWrite + memory `[IN-PROGRESS]` tag
3. **Decisions**: append architectural decisions → `~/.claude/logs/decisions.jsonl` (existing pattern)
4. **Loose context**: explicit information které existuje pouze v conversation (Filip preferences, verbal requirements, pending questions) → memory entry

### Po compaction (recovery):

1. Re-enter Session Startup s **Fast Track** mode (memory už updated)
2. Confirm state z MEMORY.md + last memory entry
3. Resume from saved state, ne restart task
4. Log "COMPACTION RECOVERY: Resumed [STATE] for [task]"

**Application**: Filipův ekosystém už má memory + decisions.jsonl, ale chybí explicit "state at transition" pattern. Adopt v multi-hour tasks (DD report, klient deliverable, complex agent install).

---

## Pattern 4: Stall Detection (3-Strike Rule)

**Synergie s**: `~/.claude/rules/common/all-rules.md` § Debug Iron Law (3-strike rule already present)

### Build/QA Stall Signals

- **2 identical diffs**: STALL DETECTED → request user input
- **3rd test failure**: STALL DETECTED → re-analyze approach, ne další iteration
- **3 hypotheses tested without converging**: STALL DETECTED → demand observability data

### Retry Protocol

```
1st fail: Analyze output, minimal fix, re-test
2nd fail: Re-analyze approach, check environment, fix, re-test
3rd fail: STALL DETECTED → request Filip input or agent swap
```

**Application**: Adopt v `agency-incident-commander` time-boxing + GSD execute-phase wave retries + scraper pipeline retry logic.

---

## Pattern 5: Operational Log (Append-Only JSONL)

**Synergie s**: `~/.claude/logs/decisions.jsonl` (existing) + evolution-event-log skill

### Log struktura

```jsonl
{"timestamp":"2026-05-03T10:30:00Z","session_id":"uuid","mode":"standard","mb_version":"2026-05"}
{"timestamp":"2026-05-03T10:35:00Z","session_id":"uuid","event":"state_transition","from":"PLAN","to":"BUILD"}
{"timestamp":"2026-05-03T11:00:00Z","session_id":"uuid","event":"approval_requested","state":"APPROVAL"}
{"timestamp":"2026-05-03T11:15:00Z","session_id":"uuid","event":"stall_detected","retry_count":3}
{"timestamp":"2026-05-03T11:30:00Z","session_id":"uuid","event":"applied","files_changed":12}
```

**Application v Filipově ekosystému**:
- Existing: `~/.claude/logs/decisions.jsonl` (architectural decisions)
- Add: `~/.claude/logs/agent-state-transitions.jsonl` pro multi-step tasks
- Use pro retro analysis (weekly-retro.sh launchd Sun 09:00 — already configured)

---

## Cross-Reference s Filipovým Existing Stack

| AGENT-ZERO Pattern | Already In Filip Stack | Adoption Action |
|---|---|---|
| Four Sacred Rules | partial: lean-engine + Surgical Changes | DOCUMENTED — already covered |
| Reuse Validation Checklist | partial: implicit v Surgical Changes | ADOPT — formalize as pre-create check |
| State Machine PLAN→BUILD→... | partial: GSD phases | ADOPT — extend pro non-GSD multi-step |
| Continuous State Persistence | partial: memory + decisions.jsonl | EXTEND — add state transitions log |
| Stall Detection 3-strike | YES: Debug Iron Law | ALIGN — use stejnou terminologii |
| Operational Log JSONL | YES: decisions.jsonl | EXTEND — add agent-state-transitions.jsonl |
| Memory Bank Structure | YES: MEMORY.md + memory/ | DOCUMENTED — already covered |
| Compaction Recovery | partial: /resume-session, /checkpoint | EXTEND — add Fast Track mode |
| Approval Gates | partial: hard-stop-zone.md | DOCUMENTED — already covered |
| Citations file:line | YES: standard practice | DOCUMENTED — already covered |

---

## Integration Plan

### Phase 1: Document (Done — this file)
- ✓ Distill 5 highest-value patterns
- ✓ Cross-reference s existing stack

### Phase 2: Adopt formal Reuse Validation
- Before vytvoření nového agent/skill/rule file → run checklist mentally
- Add to `~/.claude/rules/lean-engine.md` Section 6 (Reuse Validation)

### Phase 3: Extend memory s state transitions log
- Create `~/.claude/logs/agent-state-transitions.jsonl`
- Wire pre-write hook (auto-append state transitions)
- Weekly retro analysis přes weekly-retro.sh

### Phase 4: Adopt State Machine pro multi-step non-GSD
- New skill nebo agent? → PLAN → BUILD → DIFF → QA → APPLY → DOCS
- Memory entry per state transition
- Stall detection at 3rd retry

---

## Citation

Adapted from: msitarzewski/AGENT-ZERO v2.2 (2026-03-04), 200★ MIT license, Operational framework for AI-assisted software development. Original 34.3KB → distilled 8KB lean. Cross-referenced s Filipův 2026-05-03 ekosystém state.
