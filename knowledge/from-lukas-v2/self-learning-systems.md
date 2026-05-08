# Self-Learning Systems

Sources: Adam Kropáček / claude-ecosystem-adam (homunculus pattern, April 2026) + Lukáš Dlouhý / lukasdlouhy-claude-ecosystem (lessons-loop.md, lessons-loop rule)

---

## Overview

Two complementary patterns for extracting durable knowledge from Claude sessions:

| Layer | System | Scope | Automation Level |
|-------|--------|-------|-----------------|
| Project | Lukáš's lessons-loop | Project-specific corrections, gotchas | Manual (Claude writes on correction) |
| Ecosystem | Adam's homunculus loop | Cross-session patterns, bash habits, file hotness | Automated detection → human promotion gate |

Neither auto-promotes to production. Both require human judgment before a pattern becomes permanent. The key insight: **detection is cheap; promotion is the bottleneck that must stay human-controlled.**

---

## Pattern 1: Lukáš's Lessons-Loop (Active)

**Rule location:** `lukasdlouhy-claude-ecosystem/rules/lessons-loop.md`
**Output:** `tasks/lessons.md` in each project

### Trigger Conditions
Write a lesson when:
- User corrected Claude's approach ("no, not that — do X instead")
- User confirmed a non-obvious choice was right
- A fix revealed a constraint not previously documented (build quirk, API gotcha, deploy constraint)

Do NOT write when:
- Trivial typo or formatting fix
- Pattern already in project CLAUDE.md or code comments
- Generic Claude Code behavior (goes to `~/.claude/CLAUDE.md` instead)

### Format
```markdown
## YYYY-MM-DD — short title
**What happened:** one sentence.
**Lesson:** the rule extracted from this.
**Why:** the reason — incident, preference, constraint.
```

### Reading Protocol
- Read `tasks/lessons.md` once at session start in a project
- Do not re-read mid-session (context hygiene)
- Consolidate into project CLAUDE.md when file exceeds ~50 entries; prune originals

### Limitation
Passive: only captures corrections that occur in active sessions. Cannot detect patterns across sessions (e.g., "you've typed this bash command 12 times across 8 sessions").

---

## Pattern 2: Adam's Homunculus Loop (To-Implement)

**Source:** `homunculus/instincts/` + `learning-detector.py` + `memory-staleness.py`
**Status for Lukáš:** not yet implemented; estimated ~120 lines of new Python

### Three Detection Mechanisms

**1. Repeated Bash Commands**
- Threshold: same pattern fires 3+ times across sessions
- Signal: candidate for alias or new skill
- Detection: parse `~/.claude/projects/*/` JSONL session files; extract Bash tool calls; group by normalized command pattern (strip variable arguments)
- Output: pending learning queue entry with frequency count + example invocations

**2. Hot Files**
- Threshold: same file accessed or modified 3+ times within a session (excluding config/build artifacts)
- Signal: memory candidate — file likely contains context Claude needs but re-reads expensively
- Detection: Read/Edit tool calls in session JSONL; count by file path; exclude `.claude/`, `node_modules/`, `dist/`
- Output: pending queue entry with access count + file path

**3. Failure Recovery**
- Threshold: tool call fails → retry with modified input succeeds within same session
- Signal: workaround discovered; should be documented to avoid re-discovery
- Detection: consecutive tool calls where first has non-zero exit code + second has zero exit code with modified parameters
- Output: pending queue entry with before/after diff of the tool input

### Learning Queue State Machine

```
pending → promoted → in-use
                 ↘ discarded
```

- **pending:** detected by automated script; awaiting human review
- **promoted:** human approved; converted to alias, rule, or skill
- **discarded:** human rejected; archived to prevent re-detection of same pattern
- **in-use:** promoted items that have been active for >30 days (eligible for staleness check)

**Critical design:** does NOT auto-promote. Human reviews pending queue weekly (via weekly report) and decides per entry.

---

## Memory Staleness Detection (Adam's Pattern)

**Script:** `scripts/memory-staleness.py`
**Run:** weekly (add to weekly report cron or run standalone)

### Staleness Flags (OR logic — any one triggers)
1. File modification time > 90 days
2. `last_verified` YAML front-matter field > 90 days ago
3. Entry contains `TODO:verify` tag

### Behavior
- Does NOT delete anything
- Generates `Memory-Staleness.md` report listing: file path, age, staleness reason
- User decides per entry: update `last_verified` date, or remove the entry

### 90-Day Decay Rationale
- APIs change; tool syntax drifts; project constraints become obsolete
- 90 days is the point where a memory entry is more likely to mislead than to help
- Entries that survive repeated 90-day cycles without needing update are either fundamental (keep) or wrong (should have been caught)

### Application to Lukáš
Current memory files (`~/.claude/projects/-Users-lukasdlouhy/memory/`) have no staleness tracking. Any entry older than 90 days (check `last_modified` on MEMORY.md sub-files) should be verified before relying on it in a session.

---

## Weekly Aggregation Report (Adam's Pattern)

**Script:** `scripts/weekly-report.py`
**Output:** `Obsidian Vault/00-Claude-Dashboard/Weekly-Report.md` (or equivalent location)
**Window:** 7-day rolling

### Metrics Generated

**Cache Performance**
- Prompt cache hit rate (read tokens / creation tokens)
- Total token consumption for the week
- File re-read ratio (flags context hygiene violations)

**Learning Pipeline Status**
- Pending queue count (new detections awaiting review)
- Promoted this week (new aliases/rules/skills added)
- Discarded this week

**Context Health**
- Top 5 noisiest tools by token output volume
- Files read more than 3 times per session on average (bloat candidates)

**Script Health**
- cache-audit.py: last run + success/fail
- memory-staleness.py: last run + entries flagged
- learning-detector.py: last run + new detections

### Why Weekly Not Per-Session
Single-session data is noisy. A pattern that appears once might be situational. Weekly aggregation reveals:
- Bash commands that recur across 5 different sessions (definite alias candidate)
- Files that are hot in every session touching a module (definite memory candidate)
- Cache hit rate trend (declining hit rate = CLAUDE.md or file structure is changing too frequently)

---

## Unified Implementation Plan for Lukáš

Priority order based on implementation cost vs. impact:

### Phase 1: Staleness Detection (80 lines, immediate value)
Create `scripts/memory-staleness.py`:
- Input: all `.md` files in `~/.claude/projects/*/memory/`
- Check: file mtime > 90 days OR contains `TODO:verify`
- Output: printed report with age + file path
- Run manually weekly until Phase 3 automates it
- No dependencies beyond stdlib (os, datetime, pathlib)

### Phase 2: Cache Audit (100 lines, cost visibility)
Create `scripts/cache-audit.py`:
- Input: `~/.claude/projects/*/` JSONL session files (past 14 days)
- Extract: cache_read_input_tokens vs. cache_creation_input_tokens per session
- Calculate: hit rate % = read / (read + creation)
- Output: per-session breakdown + 14-day average
- Green: >60% hit rate. Yellow: 30–60%. Red: <30% (CLAUDE.md may be changing too often)

### Phase 3: Learning Detector (120 lines, pattern capture)
Create `scripts/learning-detector.py`:
- Input: same JSONL session files
- Detect repeated bash commands (threshold: 3+), hot files (3+ reads/session), failure recovery pairs
- Output: `tasks/learning-queue.md` with pending entries
- Include: command/file, frequency count, example context, suggested alias or skill name

### Phase 4: Weekly Report (150 lines, consolidation)
Create `scripts/weekly-report.py`:
- Aggregate outputs from Phase 1–3
- Add context health metrics (top noisy tools from JSONL)
- Output: `tasks/weekly-report-YYYY-WW.md`
- Run via cron: `0 9 * * 1` (Monday 09:00)

### Phase 5: Human Promotion Gate
Weekly review of `tasks/learning-queue.md`:
- Promoted → converted to alias in `.bashrc` or new skill in `~/.claude/skills/`
- Discarded → move entry to `tasks/learning-archive.md` with reason
- Defer → leave in queue with a note for next week

---

## Key Thresholds Reference

| Signal | Threshold | Action |
|--------|-----------|--------|
| Bash command recurrence | 3+ times | Add to learning queue as alias candidate |
| File access per session | 3+ times | Add to learning queue as memory candidate |
| Memory entry age | 90 days | Flag for verification |
| Cache hit rate | <30% | Investigate CLAUDE.md change frequency |
| Cache hit rate | >60% | Healthy; no action |
| Learning queue size | >20 pending | Promote or discard before adding more |

---

## Design Principles (Both Systems)

1. **Detection is automated; promotion is human.** No pattern becomes permanent without explicit review.
2. **Corrections are the highest-signal input.** When a user corrects Claude mid-session, that correction contains more information than 100 successful executions.
3. **Staleness is the enemy of memory.** An outdated memory entry that confidently gives wrong information is worse than no memory at all.
4. **Weekly cadence beats continuous.** Real patterns emerge over multiple sessions; per-session noise obscures them.
5. **Archive, don't delete.** Discarded patterns go to archive. If a pattern recurs after being discarded, that's a strong signal it should actually be promoted.
