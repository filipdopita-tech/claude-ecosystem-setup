---
name: sop
description: "Creates operational documentation for [YOUR_COMPANY] ecosystem: service runbooks, deployment playbooks, troubleshooting guides, recovery procedures. Trigger: /sop, 'napiš runbook', 'zdokumentuj postup', 'playbook pro X', 'co dělat když X spadne', 'jak nasadit X'."
---

# /sop — SOP Creator ([YOUR_COMPANY])

## Kdy aktivovat
- Uživatel napíše `/sop`
- "napiš runbook / playbook / troubleshooting guide"
- "zdokumentuj postup pro X"
- "co dělat když X spadne / přestane fungovat"
- "jak nasadit / obnovit X"
- Po `/postmortem` — nabídni auto-suggest

## Typy dokumentů

| Typ | Kdy | Template |
|---|---|---|
| **Service Runbook** | Provoz existující služby, denní ops | viz runbook.md |
| **Deployment Playbook** | Nový deploy, update, migrace | viz playbook.md |
| **Recovery Playbook** | Disaster recovery, obnova po výpadku | viz playbook.md#recovery |
| **Troubleshooting Guide** | Diagnostika opakujícího se problému | viz troubleshooting.md |
| **Onboarding SOP** | Nastavení od nuly (nový VPS, nová doména) | viz runbook.md#onboarding |

## Postup

### 1. Identifikuj typ + kontext

Zjisti ze zprávy:
- Typ dokumentu (pokud neřekl → zeptej se jednou, jednou větou)
- Název služby / procesu
- Server: VPS-PRIMARY (YOUR_VPS_IP) nebo VPS-SECONDARY (WG .3 / CZ IP)

### 2. Načti kontext ekosystému

```
Přečti ~/.claude/knowledge/ecosystem-detail.md
```
Port, server a účel pro zmíněnou službu jsou tam. Nekombinuj z paměti.

Pokud jde o specifický skript, přečti ho:
```bash
ls /mac/scripts/
cat /mac/scripts/{relevant}.py
```

Pro systemd unit:
```bash
ssh mac 'cat /etc/systemd/system/{service}.service 2>/dev/null || systemctl cat {service}'
```

### 3. Načti příslušný template

- Service Runbook → přečti runbook.md
- Deployment / Recovery → přečti playbook.md
- Troubleshooting → přečti troubleshooting.md

### 4. Generuj dokument

Pravidla generování:
- **Action-first kroky**: sloveso na prvním místě (`Spusť`, `Ověř`, `Zkontroluj`)
- **Konkrétní příkazy**: ne "restartuj" → `systemctl restart kb-api`
- **Warning PŘED krokem**: pokud krok může způsobit downtime
- **Verify za každým blokem**: jak poznat, že krok fungoval
- **Max 25 kroků** v jedné sekci — při více rozděl do fází
- **Credentials nikdy inline** — odkaz: `~/.credentials/master.env`
- **Porty a adresy z ecosystem-detail.md**, ne z paměti

### 5. Ulož dokument

```bash
# VPS operace (service runbooks, playbooks)
mkdir -p ~/.claude/knowledge/sops/
cat > ~/.claude/knowledge/sops/{slug}.md << 'EOF'
{obsah}
EOF

# Kritické recovery docs — ulož na obě místa
cp ~/.claude/knowledge/sops/{slug}.md /mac/Documents/[YOUR_VAULT]/SOPs/{slug}.md
```

Při uložení: echo "Saved to ~/.claude/knowledge/sops/{slug}.md" + nabídni otevření.

### 6. Aktualizuj index

Přidej do `~/.claude/knowledge/sops/INDEX.md`:
```
| {slug} | {typ} | {datum} | {jednořádkový popis} |
```

Pokud INDEX.md neexistuje, vytvoř ho.

## Pravidla

- Nikdy nevymýšlej příkazy — ověř ze skutečných konfiguračních souborů
- Pokud neznáš konkrétní příkaz pro danou službu, napiš placeholder `{DOPLNIT}`
- Každý runbook musí obsahovat sekci "Common Issues" s alespoň 1 known issue
- Recovery playbook musí mít "Triage < 2 min" sekci
- Po vygenerování nabídni: `/postmortem` (pokud dokument vznikl z incidentu)
