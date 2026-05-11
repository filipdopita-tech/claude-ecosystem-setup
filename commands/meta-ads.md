---
name: meta-ads
description: OneFlow Meta Ads conversational platform. Spouští, listuje, optimalizuje Facebook/Instagram reklamy přes Marketing API. Trigger: /meta-ads + akce v přirozeném jazyce. Případy užití - "spust kampaň", "list active campaigns", "yesterday spend", "vytvoř audience", "create lead form", "pause kampaň X", "report za poslední týden".
allowed-tools:
  - Bash
  - Read
  - Write
  - WebFetch
---

# OneFlow Meta Ads

Klient pro Meta Marketing API přes oneflow-api system user. Implementuje 8-phase ULTRAPLAN z `~/Documents/oneflow-meta-ads/`. Vše routuje na VPS Flash, kde běží `/root/oneflow-meta-ads/venv` s facebook-business 25.0.1 SDK.

## Defaults (z plánu)
- Daily budget cap: 5000 CZK/day napříč všemi kampaněmi
- Default objective: `OUTCOME_LEADS`
- Geo: CZ-only
- Auto-launch threshold: do 50 CZK/day = auto launch, nad 50 CZK = vyžaduje Filip approve
- Strike escalation: okamžitý halt při Strike 2/3
- Pixel: `1393303199032669`
- Ad Account: `act_1904878676706256`
- Page: `593007390561591`
- IG: `17841475523157725`

## Aktivace

Když uživatel napíše `/meta-ads <command>`, postupuj takto:

1. **Parse intent** z příkazu — primární operace v sazbě:
   - `spust|launch|create kampaň <name>` → CREATE_CAMPAIGN
   - `list|seznam|všechny kampaně` → LIST
   - `pause|paušni <id|name>` → PAUSE
   - `delete|smaž <id>` → DELETE (require yes confirmation)
   - `audience|publikum create <name>` → CREATE_AUDIENCE
   - `lead form create <name>` → CREATE_LEAD_FORM
   - `insights|report|spend <since>` → INSIGHTS
   - `optimizer dry-run|apply` → OPTIMIZER
   - `account info|stav účtu` → ACCOUNT_INFO

2. **Extract entities:**
   - Drive URL (regex `drive.google.com/...`)
   - Budget (regex `\d+\s*(CZK|Kč)?(/den|/day)?`)
   - Objective (LEADS | TRAFFIC | CONVERSIONS)
   - Audience description (free text after "cílovka:" nebo "targeting:")
   - Date range (last7days | yesterday | this_month)

3. **Confirm** s Filipem před create operations:
   ```
   Vytvořím kampaň:
     Name: <name>
     Budget: <X> CZK/day  [auto-launch protože ≤50 CZK | čeká approve protože >50 CZK]
     Objective: <obj>
     Audience: <description>
     Creative: <Drive URL nebo "fallback templated">
   
   Pokračovat? (yes/no)
   ```

4. **Execute** přes VPS Flash:
   ```bash
   ssh vps-dev "cd /root/oneflow-meta-ads && ./venv/bin/python _scripts/cli/oneflow_ads.py <command>"
   ```

5. **Report** výsledek + shortlinky pro debug:
   - Campaign ID
   - Audit log entry timestamp
   - ntfy digest schedule (next 06:00)
   - Quality strike count

## Hlavní příkazy → bash mapping

| User intent | Bash command |
|---|---|
| `/meta-ads list` | `oneflow_ads.py list-campaigns` |
| `/meta-ads list active` | `oneflow_ads.py list-campaigns --status ACTIVE` |
| `/meta-ads spust kampaň "X" 200/den z Drive [URL]` | viz workflow níže |
| `/meta-ads pause <id>` | `oneflow_ads.py pause-campaign <id>` |
| `/meta-ads insights yesterday` | `oneflow_ads.py insights --period yesterday --level account` |
| `/meta-ads optimizer dry-run` | `meta_ads_optimizer.py --dry-run` |
| `/meta-ads audience list` | `meta_ads_audiences.py --list` |
| `/meta-ads account` | `oneflow_ads.py account-info` |
| `/meta-ads guard status` | `meta_ads_guard.py --check-quality` |

## Workflow: "Spust kampaň"

```
1. Parse: name, budget, objective, audience, creative (Drive URL nebo local path)

2. IF Drive URL:
     ssh vps-dev "./venv/bin/python _scripts/drive_to_meta_creatives.py --folder <URL>"
     → returns {videos: [{id}], images: [{hash}]}
     IF empty (Drive OAuth missing): hlas Filipovi "Drive nedostupný — pošli soubory přes scp nebo dej local path"

3. AI copy generation:
     ssh vps-dev "./venv/bin/python _scripts/meta_ads_copy_generator.py --product '<name>' --objective leads --audience '<desc>' --n 5"
     → returns 5 variants, sort by score, pick top 2

4. Create campaign:
     POST campaign (PAUSED) → ID_CAMPAIGN
     POST adset s targeting (CZ, age range, interests pokud detected) → ID_ADSET
     POST creative s top variant → ID_CREATIVE
     POST ad → ID_AD

5. Confirm s Filipem:
     "Vše PAUSED. Spustit? (yes/no)"
     IF yes AND budget ≤ auto_launch_threshold:
       activate (status ACTIVE)
     ELSE IF yes AND budget > auto_launch_threshold:
       activate
     ELSE: leave PAUSED, return ID

6. Audit log entry → /var/log/oneflow-meta-ads/audit.jsonl
7. Report Filipovi: ID, link na Ads Manager, ntfy digest schedule
```

## Risk gates

- **NIKDY** neaktivuj kampaň BEZ Filipova explicit "yes"
- **NIKDY** neporušuj `~/.claude/rules/fb-scrape-safety.md` (ne headless logins)
- **VŽDY** PAUSED status default
- **VŽDY** zkontroluj BUC threshold před writes (`meta_ads_guard.py`)
- **VŽDY** AI labeling pokud creative je AI-gen
- **VŽDY** invest disclaimer pro investiční ads (ČNB compliance)

## Když Filip řekne "nech to být" / "abort"

Pokud rozdělaná creation pipeline:
1. Cleanup: delete created entities (campaign + adset + creative + ad)
2. Audit log entry: `op=cleanup_aborted`
3. Confirm Filipovi: "Smazáno. 0 spent."

## Reference docs

- ULTRAPLAN: `~/Documents/oneflow-meta-ads/ULTRAPLAN.md`
- Risk Checklist: `~/Documents/oneflow-meta-ads/RISK-CHECKLIST.md`
- Architecture: `~/Documents/oneflow-meta-ads/_docs/architecture.md`
- Runbooks: `~/Documents/oneflow-meta-ads/_runbooks/`
- VPS scripts: `/root/oneflow-meta-ads/_scripts/`
- Audit log: `/var/log/oneflow-meta-ads/audit.jsonl`

## Escalation triggers (vždy hlas Filipovi)

- Account Quality strike 1+ detected
- BUC ≥85% utilization
- Account balance < 1000 CZK
- Daily spend exceeds Filip's cap
- Token revoked / permission missing
- Meta API error 100+ on creation flow

— Dopita
