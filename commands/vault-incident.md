---
description: "Strukturovaný incident capture do OneFlow vault. Timeline + analýza + brag-doc tie-in. Pro VPS outage, scraper crash, klient deploy fail, security incident. Cherry-pick z obsidian-mind."
---

Capture incident do OneFlow vault (`$OBSIDIAN_VAULT/04-Security/incidents/`). Strukturovaný protokol s timeline, analýzou, brag tie-in.

**Liší se od `/postmortem`**: postmortem = textový dokument s prevencí. vault-incident = vault note s frontmatter, wikilinks, base-friendly fields, propojené na brag doc + memory.

## Usage

```
/vault-incident <stručný název>
[opcionálně: paste logs, ntfy alerts, screenshots, console output]
```

## Subagenty (paralelně)

- **`vault-cross-linker`** — najdi missing wikilinks na involved services/people/projects
- **`agency-incident-commander`** (existující agent) — strukturní analýza incidentu pro production scope

Spawn paralelně přes Agent tool.

## Workflow

### 1. Gather raw data

Z context Filipova promptu + automaticky:
- ntfy alerts last 24h: `tail -50 ~/.claude/logs/ntfy-*.log 2>/dev/null`
- systemd journals na Flash (pokud incident = service): `ssh root@10.77.0.1 "journalctl -u <service> --since '2 hours ago' | tail -100"`
- Recent decisions: `tail -10 ~/.claude/logs/decisions.jsonl`
- Git log incident-relevant repos: 24h history
- Postfix log (pokud email-related): `ssh root@10.77.0.1 "tail -100 /var/log/mail.log"`

### 2. Identify scope

Klasifikuj severity:
- **critical** — Filip's primary services down (oneflow.cz, conductor, <email> email send)
- **high** — secondary services (Hermes daemon, scraper pipeline, Cal.com), klient deploy down
- **medium** — partial degradation, retry-able failure, performance regression
- **low** — informational, audit finding

### 3. Build timeline

Reconstruction s timestamps (ISO8601 + CET):
- First detected (ntfy alert / systemctl status / Filip noticed)
- Investigation milestones (hypothesis tested, root cause identified)
- Fix attempts (each with verdict)
- Resolution (verified fix)
- Cleanup (post-incident actions)

### 4. Create incident note

Path: `$OBSIDIAN_VAULT/04-Security/incidents/{YYYY-MM-DD}-{slug}.md`

```yaml
---
date: YYYY-MM-DD
description: "<150 chars hook>"
severity: critical|high|medium|low
status: investigating|mitigated|resolved|post-mortem-pending
service: <postfix|conductor|hermes|scraper|oneflow.cz|asr|...>
detection: ntfy|filip|monitoring|client_report
duration_minutes: <number>
ico: <pokud klient incident>
tags: [incident, <service>, <severity>]
related_incidents: [[<predchozi-incident>]]
---
```

Sections:
- **Context** — co se stalo, proč relevantní pro OneFlow
- **Detection** — jak Filip/system zjistil
- **Timeline** — table s timestamps, events, attribution
- **Root Cause** — technické vysvětlení (no blame, jen mechanismus)
- **Resolution** — fix kroky, commit refs, deployment
- **Impact** — služby ovlivněné, klienti ovlivnění, finanční dopad odhad, reputační risk
- **Detection gap** — pokud Filip zjistil před monitoring → flag pro alert improvement
- **Pattern check** — recurring? cross-ref `06-Knowledge/Patterns.md` + similar incidents
- **Action items** — table s owner + due date + status
- **Brag entry** (pokud Filip vyřešil — append do `06-Knowledge/Brag-Doc.md`)
- **Related** — wikilinks na services, projects, decisions

### 5. Update related vault assets

- `04-Security/incidents/Index.md` — přidat row (pokud neexistuje, vytvoř)
- `06-Knowledge/Patterns.md` — pokud incident odhalil pattern
- `06-Knowledge/Gotchas.md` — pokud incident byl quirky/non-obvious
- `~/.claude/logs/decisions.jsonl` — append rozhodnutí učiněná během incidentu
- `~/.claude/projects/-Users-filipdopita/memory/` — memory entry pokud lessons learned worth retaining

### 6. Memory + dashboard sync

- `00-Claude-Dashboard/Active-Agents.md` — pokud incident souvisí s agents (Hermes/Conductor/KARIMO crash), update sekci
- `~/Documents/OneFlow-Vault/00-Claude-Dashboard/Vault-OS-Hub.md` — Recent Context add line

### 7. Postmortem decision gate

Pokud severity ∈ {critical, high} OR duration >2h:
- Auto-suggest: "Spustit `/postmortem` pro kompletní analýzu prevence?"

### 8. Notify

- ntfy push: `curl -d "Incident captured: <slug>, severity=<X>" https://ntfy.oneflow.cz/Filip 2>/dev/null`
- Pokud klient incident → flag pro klient comms (NEPOSÍLAT, jen flag — per HARD-STOP zóna)

## Output

```
🚨 Incident captured: <slug>

PATH: 04-Security/incidents/{date}-{slug}.md
SEVERITY: <X>
DURATION: <minutes>
STATUS: <state>

ROOT CAUSE (1-line)
<summary>

ACTION ITEMS (<count>)
- <owner> | <action> | <due>

UPDATED
- <list of vault assets updated>

NEXT
- /postmortem <slug>  (suggested pro critical/high)
- vault-cross-linker findings: <summary>
```

## Pravidla
- **Zachovej přesné timestamps** — incident timeline potřebuje precision
- **Attribute everything** — kdo/co řekl, kdo/co udělal
- **No blame v public docs** — používej service names, ne osoby (klientské incidenty)
- **Honest analysis v vault note** — interní vault note může obsahovat strategickou reflexi
- Secrets/credentials NIKDY do vault note (per security-hardening.md)
- Incident souvisí s payment/destruction → HARD-STOP zone, eskaluj Filipovi
