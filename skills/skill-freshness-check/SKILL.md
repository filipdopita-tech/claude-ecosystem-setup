---
name: skill-freshness-check
description: Use to audit skill staleness — finds skills with outdated `last-updated`, references to deprecated tools, or version pins that have moved. Triggers on "audit skill freshness", "stale skills", "skill maintenance", "what skills need updates".
allowed-tools: [Read, Bash, Grep]
last-updated: 2026-04-27
version: 1.0.0
---

# Skill Freshness Check

Audit all skills and agents for staleness. Produces a table: skill | last-updated | age (days) | status | suggested action.

## Thresholds

- **FRESH**: < 180 days since `last-updated`
- **STALE**: 180–364 days
- **ROTTING**: 365+ days

## Step 1 — Collect last-updated fields

```bash
cd /path/to/ecosystem

# Extract last-updated from frontmatter for all skills
for f in skills/*/SKILL.md skills/imported/*/SKILL.md; do
  lu=$(grep "^last-updated:" "$f" 2>/dev/null | head -1 | awk '{print $2}')
  echo "${lu:-MISSING} $f"
done | sort
```

## Step 2 — Compute age and status

```python
import os, re
from datetime import date, datetime

BASE = os.path.expanduser("~/Desktop/lukasdlouhy-claude-ecosystem")
TODAY = date.today()
STALE_DAYS = 180
ROTTING_DAYS = 365

skill_files = []
for root, dirs, files in os.walk(os.path.join(BASE, "skills")):
    for f in files:
        if f == "SKILL.md":
            skill_files.append(os.path.join(root, f))

rows = []
for fp in sorted(skill_files):
    with open(fp) as fh:
        content = fh.read()
    name = fp.split("/skills/")[1].replace("/SKILL.md", "")
    m = re.search(r"^last-updated:\s*(.+)$", content, re.MULTILINE)
    if m:
        lu = m.group(1).strip()
        try:
            lu_date = datetime.strptime(lu, "%Y-%m-%d").date()
            age = (TODAY - lu_date).days
        except ValueError:
            lu, age = lu, -1
    else:
        lu, age = "MISSING", -1

    if age < 0:
        status = "UNKNOWN"
    elif age < STALE_DAYS:
        status = "FRESH"
    elif age < ROTTING_DAYS:
        status = "STALE"
    else:
        status = "ROTTING"

    rows.append((name, lu, age, status))

# Print table
print(f"{'Skill':<45} {'last-updated':<14} {'Age':>5} {'Status':<10} Suggested Action")
print("-" * 110)
for name, lu, age, status in rows:
    if status == "FRESH":
        action = "No action"
    elif status == "STALE":
        action = "Review and update content"
    elif status == "ROTTING":
        action = "Prioritize refactor or deprecate"
    else:
        action = "Add last-updated field"
    print(f"{name:<45} {lu:<14} {age:>5} {status:<10} {action}")
```

## Step 3 — Tool version spot-checks (best-effort)

For skills referencing specific tool versions, check currency:

```bash
# shadcn-ui — check current version
grep -r "shadcn" skills/shadcn-ui/SKILL.md | grep -i "version\|@\|v[0-9]" | head -5

# motion-react — check version references
grep -E "version|framer-motion|motion" skills/motion-react/SKILL.md | head -5

# gsap — check version references in all gsap skills
grep -E "gsap|@3\.|@4\." skills/gsap-timeline-design/SKILL.md skills/imported/gsap-*/SKILL.md | head -10

# remotion — check version references
grep -E "version|remotion|@[0-9]" skills/remotion-best-practices/SKILL.md | head -5
```

Note: For definitive version checks, cross-reference with `npm info <package> version` or the package's GitHub releases page. This is flagged as TODO for skills with hard-coded version numbers.

## Step 4 — Output table

The Python script in Step 2 produces the full table. Pipe through `column -t` for aligned output if running in terminal.

## Quick one-liner (age only, no Python)

```bash
cd ~/Desktop/lukasdlouhy-claude-ecosystem
for f in skills/*/SKILL.md skills/imported/*/SKILL.md; do
  lu=$(grep "^last-updated:" "$f" 2>/dev/null | awk '{print $2}')
  if [ -n "$lu" ]; then
    age=$(( ( $(date +%s) - $(date -j -f "%Y-%m-%d" "$lu" +%s 2>/dev/null || echo $(date +%s)) ) / 86400 ))
    echo "$age days | $f"
  else
    echo "MISSING  | $f"
  fi
done | sort -n
```

## Skills flagged for tool-version review

These skills reference specific tool versions and need manual cross-check on each update cycle:

| Skill | Tool | Check |
|---|---|---|
| shadcn-ui | shadcn/ui | `npm info shadcn-ui version` |
| motion-react | motion/react | `npm info motion version` |
| gsap-timeline-design | GSAP | gsap.com/docs |
| imported/gsap-* | GSAP | gsap.com/docs |
| remotion-best-practices | Remotion | `npm info remotion version` |
| meta-ads-api | Meta Graph API | developers.facebook.com/docs |
| posthog-analytics | PostHog | posthog.com/docs |
| rum-monitoring | Vercel Speed Insights | vercel.com/docs |
