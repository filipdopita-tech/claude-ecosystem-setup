---
description: "Morning briefing z OneFlow vaultu. Načte dnešní kontext, včerejší výstupy, aktivní projekty, calendar, otevřené tasky. Cherry-pick z obsidian-mind."
---

Spusť ranní standup pro Filipa nad OneFlow vault (`$OBSIDIAN_VAULT`).

## Workflow

1. **Read Vault Hub**: `~/Documents/OneFlow-Vault/00-Claude-Dashboard/Vault-OS-Hub.md` — current focus, North Star
2. **Today's daily ingest**: `~/Documents/OneFlow-Vault/08-Daily-Notes/{TODAY}-Ingest-Summary.md` (pokud existuje, jinak preceeding day)
3. **Active projects**: `ls ~/Documents/OneFlow-Vault/03-Projects/` + grep `status: active` ve frontmatteru top-level Index.md
4. **Včerejší vault aktivita**: `cd ~/Documents/OneFlow-Vault && git log --since="24 hours ago" --oneline --no-merges | head -20`
5. **Calendar dnes** (pokud `gws` CLI dostupný a Calendar scope aktivní):
   ```bash
   bash ~/scripts/automation/gws.sh calendar-today 2>/dev/null || echo "(Calendar scope neaktivní — skip)"
   ```
6. **Open todos**:
   - `cat ~/.claude/todos/*.json 2>/dev/null` (pokud todo persistence aktivní)
   - grep `- \[ \]` v dnešní/včerejší daily note
7. **Codex bridge state** dnes: `bash ~/scripts/automation/bridge-utilization-summary.sh today 2>/dev/null || echo "(no bridge calls today)"`
8. **Recent decisions** (last 7 dní): `tail -10 ~/.claude/logs/decisions.jsonl | jq -r '.decision' 2>/dev/null`
9. **Pending review queue**: `ls ~/.claude/review-queue/ 2>/dev/null | head -5`

## Output (concise, není deep dive)

```
🌅 Standup {TODAY}

VČERA
- <git activity 1-line summary>
- <commits z OneFlow projektů>
- <closed tasks z včerejší daily>

DNES — KONTEXT
- North Star focus: <z Vault-OS-Hub>
- Calendar: <events dnes>
- Pending: <open todos count + top 3>

ACTIVE PROJEKTY (status: active)
- <projekt 1> — <last update timestamp>
- <projekt 2> — <last update timestamp>
...

DOPORUČENÝ FOKUS DNES
- <priority 1> (matchne North Star + open todo)
- <priority 2>
- <priority 3>

PENDING REVIEW
- <review-queue items pokud nějaké>
- <decision log entries čekající na confirm>
```

## Pravidla
- **Concise**: max 30 řádků output, NE deep dive
- **Žádné halucinace** — pokud daily note neexistuje, řekni to (`[VERIFIED]/[UNCERTAIN]` markers per anti-hallucination.md)
- Čeština
- Pokud vault git log = 0 commits = explicit "Vault žádná aktivita 24h"
- Pokud calendar nedostupný = skip sekce, neprosit o přístup
