# Deployment & Recovery Playbook Template

---

## Deployment Playbook Template

```markdown
# Deployment Playbook: {Název / Verze}

- **Server**: Flash / Alfa
- **Služba**: {service-name}
- **Typ**: nový deploy / update / migrace / rollback
- **Naposledy použit**: {YYYY-MM-DD}
- **Odhadovaný downtime**: {X min / žádný}

---

## Prerequisites

- [ ] SSH přístup na cílový server funguje
- [ ] Credentials v `~/.credentials/master.env` aktuální
- [ ] Záloha config před deploymentem: `cp {config} {config}.bak.$(date +%Y%m%d)`
- [ ] {další podmínka specifická pro tuto službu}

## Definition of Done

{Konkrétní test, který potvrdí úspěšný deployment}
Příklad: `curl -s https://{hostname}/health` vrátí HTTP 200 s `{"status":"ok"}`

---

## Kroky

### 1. Záloha
```bash
# Config
cp {config} {config}.bak.$(date +%Y%m%d)

# Data (pokud potřeba)
sqlite3 {db.sqlite} ".backup {db.bak.$(date +%Y%m%d)}"
```
Verify: `ls -la {config}.bak.*`

### 2. Stáhni novou verzi
```bash
cd {project-dir}
git pull origin main
# nebo
wget -O {binary} {url}
```
Verify: `git log --oneline -3` nebo `{binary} --version`

### 3. Instalace dependencies
```bash
pip install -r requirements.txt --upgrade
# nebo
npm ci --production
```
Verify: bez error výstupu

### 4. Aplikuj migrace (pokud potřeba)
> ⚠️ Záloha DB provedena v kroku 1. Migrace jsou nevratné.
```bash
{migration-command}
```
Verify: `{check-migration-command}`

### 5. Restart služby
```bash
systemctl restart {service}
sleep 3
systemctl status {service}
```
Verify: `systemctl is-active {service}` vrátí "active"

### 6. Smoke test
```bash
curl -s localhost:{port}/health
journalctl -u {service} -n 20 --no-pager | grep -i error
```
Verify: žádný ERROR v logu, health endpoint 200.

---

## Rollback

Pokud deployment selhal nebo smoke test failuje:

```bash
# 1. Stop služby
systemctl stop {service}

# 2. Obnov config
cp {config}.bak.$(date +%Y%m%d) {config}

# 3. Vrať kód
cd {project-dir}
git checkout {předchozí-commit-nebo-tag}

# 4. Start
systemctl start {service}
systemctl status {service}
```
Verify: smoke test z kroku 6 prochází.

---

## Post-Deployment

- [ ] Zkontroluj logy 5 minut po deployi: `journalctl -u {service} -f`
- [ ] Monit status: `monit status {service-name}`
- [ ] Smazej zálohy starší 7 dní: `find {dir} -name "*.bak.*" -mtime +7 -delete`
```

---

## Recovery Playbook Template {#recovery}

```markdown
# Recovery Playbook: {Scénář / Název}

- **Server**: Flash / Alfa
- **Závažnost**: low / medium / high / critical
- **Naposledy testován**: {YYYY-MM-DD nebo "netestováno"}

---

## Symptomy

Tento playbook spusť, když:
- {symptom 1: co vidíš v terminálu / alerty}
- {symptom 2}

---

## Triage (< 2 min)

```bash
# 1. Zjisti co padá
systemctl --failed

# 2. Poslední errory
journalctl -p err --since "30 min ago" --no-pager | head -30

# 3. Zdroje systému
free -h && df -h / && uptime
```

Výsledek triage → zvolte scénář:

---

## Scénář A: {popis — nejčastější případ}

```bash
# Postup
{příkazy}
```
Verify: `{ověřovací příkaz}`

---

## Scénář B: {popis — alternativní případ}

> ⚠️ Tento scénář způsobí downtime ~X minut.

```bash
{příkazy}
```
Verify: `{ověřovací příkaz}`

---

## Scénář C: Kompletní obnova ze zálohy

```bash
# 1. Stop všeho závislého
systemctl stop {dependent-services}

# 2. Záloha aktuálního stavu (pro forensiku)
cp -r {data-dir} /tmp/forensic-backup-$(date +%Y%m%d-%H%M)

# 3. Obnov zálohu
cp {backup-source} {target}

# 4. Start
systemctl start {services}
```
Verify: smoke test + monit status.

---

## Post-Recovery

```bash
# Ověř všechny závislé služby
for svc in {service1} {service2} {service3}; do
  systemctl is-active $svc && echo "$svc OK" || echo "$svc FAIL"
done

# Zkontroluj disk po obnově
df -h
```

- [ ] Spusť `/postmortem` pro zdokumentování incidentu
- [ ] Zkontroluj, zda monit opět hlídá: `monit status`
- [ ] ntfy notifikace o obnově: `curl -d "✅ {service} obnovena" https://ntfy.example.com/alerts`
```
