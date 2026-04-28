# Service Runbook Template

Použij tento template pro dokumentaci provozu existující služby na Flash nebo Alfa.

---

## Template

```markdown
# Runbook: {Název Služby}

- **Server**: Flash (<vps-private-ip>) / Alfa (WG .3)
- **Port**: {port} ({local/public/WG})
- **Systemd unit**: {service-name}.service
- **Monit**: ano/ne
- **Log**: `journalctl -u {service-name} -f`
- **Účel**: {jednověta}
- **Naposledy ověřeno**: {YYYY-MM-DD}

---

## Standardní operace

### Start / Stop / Restart
```bash
systemctl start {service}
systemctl stop {service}
systemctl restart {service}
systemctl status {service}
```

### Health check
```bash
curl -s localhost:{port}/health
# nebo
curl -s localhost:{port}/ping
journalctl -u {service} --since "5 min ago" --no-pager
```
Expect: HTTP 200, nebo prázdný stderr v logu.

### Reload konfigurace (bez downtime)
```bash
systemctl reload {service}
# pokud reload není podporován:
systemctl restart {service}   # způsobí krátký downtime
```

---

## Konfigurace

- **Config soubor**: {cesta nebo N/A}
- **Env / credentials**: `~/.credentials/master.env` (chmod 600)
- **Jak editovat**: `nano {config}` → uložit → reload/restart
- **Backup config před změnou**: `cp {config} {config}.bak.$(date +%Y%m%d)`

---

## Dependencies

Závisí na těchto službách (musí běžet dříve):
- {služba nebo N/A}

Na této službě závisí:
- {služba nebo N/A}

---

## Common Issues

| Symptom | Příčina | Fix |
|---|---|---|
| Service se nespustí | Chybný env var | `grep {VAR} ~/.credentials/master.env` → přidat |
| Connection refused na portu | Port bind selhal (conflict) | `ss -tlnp | grep {port}` → kill conflict |
| OOM killed | Leak nebo spike | `journalctl -u {service} | grep -i kill` → snížit worker count |
| {popis} | {root cause} | `{příkaz}` |

---

## Monit

```bash
# Zkontroluj monit status
monit status {service-name}

# Restartuj přes monit (respektuje cooldown)
monit restart {service-name}

# Pokud monit neresponguje
systemctl status monit
```

---

## Logs

```bash
# Posledních 50 řádků
journalctl -u {service} -n 50 --no-pager

# Live follow
journalctl -u {service} -f

# Od konkrétního času
journalctl -u {service} --since "2026-04-14 10:00:00"

# Pouze errory
journalctl -u {service} -p err -n 20
```

---

## Escalation

- Pokud fix nefunguje do 10 minut → spusť `/postmortem`
- ntfy alert: `curl -d "🚨 {service} DOWN" https://ntfy.oneflow.cz/alerts`
- Monit dashboard: http://<vps-private-ip>:2812 (nebo přes SSH tunnel)
```

---

## Onboarding SOP: Nastavení služby od nuly {#onboarding}

```markdown
# Onboarding SOP: {Název} na {Flash/Alfa}

## Prerequisites
- [ ] SSH přístup na cílový server
- [ ] Credentials v `~/.credentials/master.env`
- [ ] Domain/DNS nakonfigurován (pokud public)

## Definition of Done
{Co musí platit, aby byl setup kompletní — konkrétní test}

## Kroky

### 1. Příprava prostředí
```bash
# Naklonuj repo / stáhni artefakt
{příkaz}

# Vytvoř user (pokud potřeba)
useradd -r -s /bin/false {service-user}
```
Verify: `id {service-user}` vrátí uid.

### 2. Konfigurace
```bash
cp {config.example} {config}
nano {config}   # doplň dle master.env
```
Verify: `{service} --check-config` nebo dry-run.

### 3. Systemd unit
```bash
cat > /etc/systemd/system/{service}.service << 'EOF'
[Unit]
Description={popis}
After=network.target

[Service]
User={service-user}
EnvironmentFile=/root/.credentials/master.env
ExecStart={spouštěcí příkaz}
Restart=always
RestartSec=5
NoNewPrivileges=true

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable {service}
systemctl start {service}
```
Verify: `systemctl is-active {service}` vrátí "active".

### 4. Caddy / Nginx (pokud public)
```bash
# Přidej do /etc/caddy/Caddyfile nebo /etc/nginx/sites-available/
{hostname} {
    reverse_proxy localhost:{port}
}
systemctl reload caddy
```
Verify: `curl -s https://{hostname}/health`

### 5. Monit (pokud kritická služba)
```bash
cat > /etc/monit/conf.d/{service} << 'EOF'
check process {service} with pidfile /var/run/{service}.pid
  start program = "/bin/systemctl start {service}"
  stop program = "/bin/systemctl stop {service}"
  if 3 restarts within 5 cycles then alert
EOF
monit reload
```

### 6. Smoke test
```bash
curl -s localhost:{port}/health
journalctl -u {service} -n 20 --no-pager
```
```
