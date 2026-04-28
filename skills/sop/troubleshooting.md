# Troubleshooting Guide Template

---

## Template

```markdown
# Troubleshooting: {Služba / Název problému}

- **Server**: Flash / Alfa
- **Systemd unit**: {service}.service
- **Naposledy ověřeno**: {YYYY-MM-DD}

---

## Quick Diagnosis (< 1 min)

```bash
# Vždy začni tady — v tomto pořadí
systemctl status {service}
journalctl -u {service} -n 50 --no-pager
curl -s localhost:{port}/health
```

Co hledáš v logu:
- `FATAL` / `panic` / `OOM` → viz #crash
- `connection refused` / `dial tcp` → viz #connectivity
- `permission denied` → viz #permissions
- `no space left` → viz #disk
- Tichý log, service "active" ale neresponguje → viz #silent-failure

---

## Decision Tree

```
Service neresponguje?
│
├── systemctl status = ACTIVE
│   ├── curl health → 200?  → Problém je výš (Caddy/nginx/DNS)
│   ├── curl health → 500?  → Aplikační chyba → hledej stack trace v logu
│   ├── curl health → timeout? → Port bind fail nebo deadlock
│   └── Logy tiché?  → Silent failure → viz #silent-failure
│
├── systemctl status = FAILED
│   ├── ExitCode = OOM → viz #oom
│   ├── ExitCode = 1   → Chyba při startu → viz #startup-error
│   └── ExitCode = 143 → SIGTERM (monit / watchdog) → viz #watchdog
│
└── systemctl status = INACTIVE
    ├── enable-d?   → systemctl enable {service}; systemctl start {service}
    └── není enable → manuální start nebo nastavit autostart
```

---

## Known Issues

### startup-error {#startup-error}
**Symptom**: `systemctl status` ukazuje "failed", poslední log řádek je chyba při inicializaci.

**Diagnostika**:
```bash
journalctl -u {service} -n 30 --no-pager | tail -20
```

**Root cause**: Nejčastěji chybějící env var nebo nedostupná dependency.

**Fix**:
```bash
# Zkontroluj env
grep {REQUIRED_VAR} ~/.credentials/master.env

# Zkontroluj dependency
systemctl status {dependency-service}
```

---

### oom {#oom}
**Symptom**: `journalctl | grep -i kill` ukazuje OOM killer, service restartuje každých N minut.

**Diagnostika**:
```bash
journalctl -u {service} | grep -E "Killed|oom"
free -h
```

**Fix (dočasný)**:
```bash
systemctl restart {service}
```

**Fix (trvalý)**:
```bash
# Snižení worker count v configu
nano {config}   # worker_count: 4 → 2
systemctl restart {service}

# Nebo přidání memory limit do systemd unit
systemctl edit {service}
# přidej: MemoryMax=512M
systemctl daemon-reload && systemctl restart {service}
```
Verify: `free -h` + `systemctl status {service}` — bez OOM 5 min.

---

### connectivity {#connectivity}
**Symptom**: "connection refused", "dial tcp", "ECONNREFUSED"

**Diagnostika**:
```bash
# Poslouchá na správném portu?
ss -tlnp | grep {port}

# Je dependency nahoře?
systemctl status {dependency}
curl -s localhost:{dep-port}/health
```

**Fix**:
```bash
# Dependency nefunguje → oprav ji první
systemctl restart {dependency}
sleep 2
systemctl restart {service}
```
Verify: `curl -s localhost:{port}/health`

---

### permissions {#permissions}
**Symptom**: "permission denied" v logu, service se nespustí nebo nemůže číst soubor.

**Diagnostika**:
```bash
ls -la {problematic-path}
systemctl cat {service} | grep User=
```

**Fix**:
```bash
chown {service-user}:{service-group} {path}
# Nebo pro adresář rekurzivně:
chown -R {service-user} {dir}
systemctl restart {service}
```

---

### disk {#disk}
**Symptom**: "no space left on device", zápis do logu / DB selhal.

**Diagnostika**:
```bash
df -h
du -sh /var/log/* | sort -rh | head -10
```

**Fix**:
```bash
# Smazat staré logy
journalctl --vacuum-size=500M

# Smazat tmp artefakty
find /tmp -mtime +1 -delete

# Zkontrolovat Docker
docker system prune -f   # pokud Docker běží
```
Verify: `df -h /` — alespoň 10% volné místo.

---

### silent-failure {#silent-failure}
**Symptom**: `systemctl status` ukazuje "active (running)", ale service neresponguje na requesty. Logy bez errorů.

**Diagnostika**:
```bash
# Deadlock? CPU usage?
top -bn1 | grep {service}

# Connections?
ss -tnp | grep {port}

# Thread dump (Python)
kill -SIGUSR1 $(systemctl show {service} --property=MainPID | cut -d= -f2)
journalctl -u {service} -n 20
```

**Fix**:
```bash
# Vždy: hard restart
systemctl restart {service}
```
Pokud se opakuje → přidej health check do monit:
```
check program {service}-health with path "/usr/local/bin/{service}-check.sh"
  if status != 0 for 3 cycles then restart
```

---

## Escalation

Pokud žádný z výše uvedených postupů nefunguje do 15 minut:

```bash
# 1. Zachyť stav pro forensiku
journalctl -u {service} --since "1 hour ago" > /tmp/{service}-forensic-$(date +%Y%m%d-%H%M).log

# 2. ntfy alert
curl -d "🚨 {service} - escalace po 15 min" https://ntfy.oneflow.cz/alerts

# 3. Spusť /postmortem
```
```
