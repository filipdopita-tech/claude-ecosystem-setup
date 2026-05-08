---
description: "Weekly synthesis nad OneFlow vault: cross-day patterns, North Star alignment, drift detection, uncaptured wins, forward priorities. Cherry-pick z obsidian-mind."
---

Cross-session synthesis over past 7 days vault aktivity. Bridge mezi `/vault-eod` (daily) a quarterly review. Tohle je **ANALÝZA**, ne verifikace — najít patterns, surface drift, detect uncaptured work.

## Subagent (spawn paralelně se začátkem)

- **`vault-brag-spotter`** scope=week — uncaptured wins z posledních 7 dní

## Workflow

### 1. Gather week's activity (no Filip input needed)

```bash
cd ~/Documents/OneFlow-Vault
git log --since="7 days ago" --oneline --no-merges                    # vault commits
git log --since="7 days ago" --name-only --pretty=format: | sort -u | grep -v '^$' | head -50  # files touched
find . -name "*.md" -newer "$(date -v-7d +%Y-%m-%d).000000" 2>/dev/null | head -30  # new/edited last 7d
```

- `08-Daily-Notes/` — last 7 daily ingest summaries
- `03-Projects/*/Index.md` — status changes (compare git diff)
- `04-Security/incidents/` — new entries last 7d
- `~/.claude/logs/decisions.jsonl` — last 7d decisions
- `~/.claude/logs/bridge-utilization.jsonl` — Codex bridge ratio last 7d

### 2. North Star alignment

Read `00-Claude-Dashboard/Vault-OS-Hub.md` Current Focus + `~/.claude/projects/-Users-filipdopita/memory/MEMORY.md` Active Projects.

Compare actual activity (z step 1) vs stated focus:

- **Aligned work**: které focus items dostaly attention?
- **Drift**: práce co nematchuje žádný stated goal (NE nutně bad — ale flag)
- **Silent goals**: focus items s 0 commits, 0 note updates, 0 mentions
- **Emerging themes**: pattern návrhuje focus shift co není zapsaný

### 3. Cross-day patterns

Look across week's notes for:
- Recurring témata (same topic v multiple notes/days)
- Multiple incidents/issues touching same system (DD pipeline, Hermes, Postfix)
- Topics appearing v BOTH project notes AND klient communications (silné signály)
- Context evolution (decisions co se měnily, understanding co se prohluboval)

### 4. Uncaptured wins

Run `vault-brag-spotter` agent (paralelně), filter findings na last 7d.

Additionally check:
- Completed items v `03-Projects/<x>/` log v `06-Knowledge/Brag-Doc.md`?
- Klient feedback / pozitivní zprávy v inbox not captured?
- Incident contributions co stojí za brag entry?
- DD reports shipped (z dd-emitent runs)?
- Klient deliverables (checked v `03-Projects/klient-*/`)?
- Memory entries created (signál growing knowledge)?

### 5. Codex bridge utilization week

```bash
bash ~/scripts/automation/bridge-utilization-summary.sh week
# Expected: D≥5 healthy, D 2-4 light, D≤1+N≥3 warning
```

Pokud ratio <50% pro code work → flag underutilization.

### 6. Project velocity check

Pro každý active projekt v `03-Projects/`:
- Last touch: <7d? (active) / 7-30d? (stalling) / >30d? (zombie — suggest archive)
- Commits this week
- Index.md updated this week?

### 7. Forward look

- Blocked items / upcoming deadlines z active project notes
- North Star goals needing attention next week
- Scheduled meetings (calendar week ahead): `bash ~/scripts/automation/gws.sh calendar-week 2>/dev/null`
- Suggested priority ordering based on goals + momentum + gaps

### 8. Output (synthesis, ne file save default)

```
📊 Weekly Synthesis {DATE_RANGE}

THIS WEEK (3-5 bullets)
- <key activity 1>
- <key activity 2>
...

NORTH STAR CHECK
✅ On track: <list>
⚠️ Drifted: <list>
🔇 Silent: <list goals s 0 activity>
🌱 Emerging: <unstated themes>

PATTERNS
- <cross-day theme 1>
- <recurring issue>
- <evolution observed>

UNCAPTURED WINS (z brag-spotter)
- <win 1>: suggest add to Brag-Doc
- <win 2>: suggest add to Brag-Doc

PROJECT VELOCITY
| Projekt | Last touch | Commits 7d | Status |
|---------|-----------|-----------|--------|
| <proj>  | <date>    | <n>       | active/stalling/zombie |

CODEX BRIDGE
- D this week: <n> (target ≥5)
- N (nudges): <n>
- Ratio: <%>

NEXT WEEK SUGGESTED
- <priority 1> (matches focus + momentum)
- <priority 2> (clears blocker)
- <priority 3> (ships pending deliverable)

ACTIONS NABÍZENO
- Append wins to Brag-Doc?
- Update North Star focus?
- Save synthesis to `08-Daily-Notes/weekly-{date}.md`?
- /postmortem na zombie projekt?
```

## Pravidla
- **Transient default** — neukládám do file unless Filip explicit asks
- **Analytical tone** — status check, not celebration
- **Honest about drift** — value je v surfacing co se NEDĚJE, ne jen co
- Don't duplicate `/vault-standup` (daily, what's next) nebo `/vault-eod` (session quality). This is SYNTHESIS across days
- Light week = say so, don't pad
- Output max 80 řádků
