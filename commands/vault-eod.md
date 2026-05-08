---
description: "End-of-day wrap-up nad OneFlow vault. Co se dnes udělalo, kvalita not, co flag pro zítra, suggest improvements. Cherry-pick z obsidian-mind om-wrap-up."
---

End-of-day ritual nad OneFlow vault (`$OBSIDIAN_VAULT`). READ + VERIFY pass, ne creation pass.

## Workflow

### 1. Co se dnes udělalo

- `cd ~/Documents/OneFlow-Vault && git log --since="midnight" --oneline --no-merges`
- `cd ~/Documents/OneFlow-Vault && git diff --stat HEAD@{midnight} 2>/dev/null` (které soubory)
- Conversation scan: které soubory byly v session created/edited
- Memory entries created/updated v `~/.claude/projects/-Users-filipdopita/memory/`
- Codex bridge runs dnes: `bash ~/scripts/automation/bridge-utilization-summary.sh today`

### 2. Quality check všech today's notes

Pro každou notu vytvořenou/editovanou dnes:
- Frontmatter complete? (`date`, `description`, `tags`, type-specific fields)
- Aspoň 1 wikilink na jinou notu?
- Správná složka? (`03-Projects/active/` vs `03-Projects/archive/` vs `04-Security/incidents/`)
- Description accurate (~150 chars)?
- Status field correct?
- Pokud klient note: linkuje [[OneFlow]] + [[Filip]]?

### 3. Index consistency

- `03-Projects/<projekt>/Index.md` — nové noty linkované?
- `00-Claude-Dashboard/Vault-OS-Hub.md` — recent context aktualizovaný?
- `06-Knowledge/Brag-Doc.md` — dnes dokončené wins zachycené? **Spawn `vault-brag-spotter` subagent** s scope=today
- `~/.claude/projects/-Users-filipdopita/memory/MEMORY.md` — major projects updated?

### 4. Orphan check

- Nové noty bez incoming links? (`grep -r "\[\[<note_name>\]\]" ~/Documents/OneFlow-Vault/`)
- Daily ingest dnes existuje? Pokud ne → flag (cron měl běžet 22:30)

### 5. Status alignment

- `status: active` noty v 03-Projects skutečně aktivní? (last touched <14 dní)
- `status: completed` noty pořád v active složce? → suggest archive

### 6. Patterns / Gotchas / Decisions discovered today

Pokud session odhalila:
- **Nový pattern** → suggest append do `06-Knowledge/Patterns.md`
- **Nová gotcha** → suggest append do `06-Knowledge/Gotchas.md`
- **Decision >1h impact** → suggest `~/.claude/logs/decisions.jsonl` entry (skill `/decision`)
- **Memory worthy** → suggest memory entry s frontmatter

### 7. Improvement signals

Friction dnes:
- Něco šlo manuálně, co mohl být skill?
- Repetitivní pattern → kandidát na new skill?
- Frustrating workflow → kandidát na hook/automation?
- Codex bridge ratio dnes <50% pro code work? → flag underutilization

### 8. Tomorrow prep

- Pending z dnes co nedoběhlo
- Calendar zítra: `bash ~/scripts/automation/gws.sh calendar-today 2>/dev/null` (pokud accessible)
- Top 1-2 priority based on North Star + dnešní momentum

## Output

```
🌒 EOD Wrap {TODAY}

DNES HOTOVO
- <git commits N>
- <notes created M, updated K>
- <bridge calls L>

QUALITY GATE
✅ <count> notes passed quality check
⚠️ <count> issues flagged: <list with paths>

INDEXES
✅ Updated: <list>
⚠️ Stale: <list>

PATTERNS / DECISIONS DISCOVERED
- <each with suggested capture target>

ORPHANS / FIXES NEEDED
- <list>

IMPROVEMENT SIGNALS
- <skill suggestions>
- <hook suggestions>

ZÍTRA
- <pending z dnes>
- <calendar key events>
- <suggested top 2 priorities>
```

## Pravidla
- **READ + VERIFY**, ne mass-create. Drobné fixy OK (broken links, missing frontmatter).
- Honest report — pokud je vault v lousy state, řekni to (per anti-hallucination)
- Neflag ko každou starou notu — fokus na DNEŠEK
- Spawn `vault-brag-spotter` agent paralelně pokud session měla >1 win signal
- Output max 50 řádků, ne sloupec textu
