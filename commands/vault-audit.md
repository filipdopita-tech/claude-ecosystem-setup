---
description: "Deep structural audit OneFlow vault: indexes, frontmatter, broken links, orphans, status alignment, stale claims, Bases consistency. Cherry-pick z obsidian-mind om-vault-audit."
---

Deep audit OneFlow vault (`$OBSIDIAN_VAULT` = `/Users/filipdopita/Documents/OneFlow-Vault`). Fix what's clearly wrong, flag what needs Filipovo input.

**Kdy spustit**: po větší session, po reorganizaci, periodicky (1× měsíčně). Pro lehčí EOD check použij `/vault-eod`.

## Subagenty (spawn paralelně)

- **`vault-cross-linker`** — orphan detection, missing wikilinks, broken backlinks
- **`vault-brag-spotter`** scope=quarter — uncaptured wins + competency gaps

Spawn oba paralelně v jedné message přes Agent tool.

## Workflow

### 1. Folder structure check

Vault layout musí matchovat tvoje PARA strukturu:
- `00-Inbox/` — raw, unprocessed (flag pokud >50 souborů — review backlog)
- `00-Claude-Dashboard/` — only auto-generated dashboards (Vault-OS-Hub, Vault-Stats, Active-Agents, Briefing-*, Filip-User-Dossier)
- `03-Projects/<projekt>/` — every active project má vlastní složku, Index.md uvnitř
- `04-Security/` — security audits, incidents, hardening notes
- `06-Knowledge/` — MOC hubs, Patterns.md, Gotchas.md, Brag-Doc.md, Data-Science-Hub.md, Gateway-Protocol-Hub.md
- `08-Daily-Notes/` — only daily ingest summaries (cron output)
- `09-Agent-Memory/` — agent-side state (graphiti, conductor checkpoints)
- `11-Archive/` — completed projects, frozen at point-in-time
- Žádné nečekané soubory v root (allowed: `Home.md`, `README.md`)

### 2. Index validation

- `00-Claude-Dashboard/Vault-OS-Hub.md` — embedded queries platné? quick-links existují?
- `03-Projects/<projekt>/Index.md` — pokud chybí v projekt složce, FIX
- `06-Knowledge/<hub>.md` — embedded Bases referencují existující noty?
- `~/.claude/projects/-Users-filipdopita/memory/MEMORY.md` — pointry na soubory existují? (kritické — broken pointry rozbijí recall)

### 3. Frontmatter completeness

Pro každý typ noty (sample 10 z každé složky, pokud OK = full pass):

**Project notes** (`03-Projects/<x>/`):
- Required: `date`, `description`, `tags`, `status`
- `status` musí být: `active|paused|completed|archived`

**Klient notes** (`03-Projects/klient-<jmeno>/`):
- Required: `date`, `description`, `tags: [klient]`, `status`, `ico` (pokud B2B)

**Incident notes** (`04-Security/incidents/`):
- Required: `date`, `description`, `severity`, `status`, `tags: [incident]`
- Severity: `critical|high|medium|low`

**Brag entries** (`06-Knowledge/Brag-Doc.md` rows):
- Required: `date`, `impact`, `competency`, `evidence_link`

**Daily Notes** (`08-Daily-Notes/`):
- Required: `date`, `tags: [daily-ingest]`

### 4. Status / folder alignment

- `status: active` notes — všechny v `03-Projects/` (ne v Archive)?
- `status: completed` notes — flag pokud >30 dní v aktivní složce → suggest move do `11-Archive/<rok>/`
- `status: archived` notes — verify v `11-Archive/`

### 5. Broken links scan

```bash
cd ~/Documents/OneFlow-Vault
# Najdi všechny [[wikilinks]]
grep -rh -oE '\[\[[^]|]+(\|[^]]+)?\]\]' --include="*.md" | sed 's/\[\[//;s/\]\]//;s/|.*//' | sort -u > /tmp/all_wikilinks.txt
# Pro každý, check zda existuje cílová nota
while read link; do
  found=$(find . -name "${link}.md" 2>/dev/null | head -1)
  [ -z "$found" ] && echo "BROKEN: [[$link]]"
done < /tmp/all_wikilinks.txt | head -50
```

### 6. Orphan detection

- Noty s 0 incoming links: spawn `vault-cross-linker` subagent (paralelně s audit)
- Daily notes orphan: každá `08-Daily-Notes/{date}-Ingest-Summary.md` má být linked z předchozího den / Vault-OS-Hub Recent Activity?

### 7. Stale context check

- `00-Claude-Dashboard/Vault-OS-Hub.md` "Recent Context" — nějaké claim starší 30 dní?
- `~/.claude/projects/-Users-filipdopita/memory/MEMORY.md` Active Projects sekce — projekty v `03-Projects/` co tam nejsou listed? Naopak listed co už neexistují?
- `06-Knowledge/Patterns.md` / `Gotchas.md` — patterns co odporují recent rozhodnutím?

### 8. Mixed-context notes (Karpathy rule: 1 nota = 1 koncept)

Flag noty kde:
- 3+ nezávislé sekce
- Mix klient X a klient Y (rozdělit)
- Mix project work s personal observations

### 9. QMD index health

```bash
qmd info 2>/dev/null
# Kontrola: indexed count vs file count v vaultu
filecount=$(find ~/Documents/OneFlow-Vault -name "*.md" | wc -l)
indexed=$(qmd info | grep -i "indexed\|notes" | head -1)
```
Pokud delta >5% → suggest `qmd update`.

### 10. Hook + cron health

- `~/.claude/hooks/qmd-auto-refresh.sh` exists + executable?
- launchd `com.oneflow.vault-md-converter` running? `launchctl list | grep oneflow`
- Daily ingest cron 22:30 ran? Včerejší daily note exists?

### 11. Fix + Report

**Auto-fix (bez ptaní):**
- Missing frontmatter pole vyplnit z context (date z file mtime, status: active default)
- Duplicate tags v `tags:` array
- Broken wikilink na renamed note → opravit pokud rename detected v git history
- Stale dashboard timestamps

**Flag (vyžaduje Filipa):**
- Note v wrong folder (move = breaking, neauto-move)
- Mixed context notes (split = creative call)
- Stale claim v Vault-OS-Hub (Filip ví co je current)
- Broken wikilink bez clear target

**Output structure:**

```
🔍 Vault Audit {DATE}

VAULT SIZE
- Files: <count> (.md)
- QMD indexed: <count> ({delta}%)
- Vault size: <MB>

✅ FIXED ({count})
- <category>: <count> issues
  - <example>

⚠️ FLAGGED FOR FILIP ({count})
- <category>: <count>
  - <path>: <issue>
  - <path>: <issue>

💡 SUGGESTED ({count})
- <improvement>
- <new MOC hub idea>
- <skill candidate>

SUBAGENT FINDINGS
- vault-cross-linker: <summary>
- vault-brag-spotter: <summary>

VAULT HEALTH SCORE: <0-100>
```

## Pravidla
- NIKDY neudaž bez Filipova explicit OK
- Preserve existing frontmatter při edit (jen append/fix)
- Wrong folder → `git mv` ne `mv` (preserve history)
- MEMORY.md pointry kritické — fix immediately pokud broken
- Output max 100 řádků
