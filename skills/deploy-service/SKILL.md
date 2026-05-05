---
name: deploy-service
description: "Deploy nové služby na VPS (Flash/Alfa). Systemd + Monit + Fluent Bit + Caddy + ntfy alert. Trigger: 'nasaď službu', 'deploy na VPS', 'nový service', 'přidej na server'."
compatibility: Requires SSH access to VPS Flash (10.77.0.1) and/or Alfa (89.221.212.203) via WireGuard.
metadata:
  requires-env: SSH_KEY
  allowed-hosts:
    - 10.77.0.1
    - 89.221.212.203
  version: "1.0"
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Grep
  - Glob
---

# /deploy-service — VPS Service Deployment Playbook

## Kdy použít
- Nasazení nové služby/API/bota na VPS
- Uživatel řekne "nasaď na VPS", "deploy", "spusť na serveru"
- Migrace služby mezi VPS

## POSTUP

### Krok 1: Routing — kam nasadit?
Přečti `~/.claude/rules/ecosystem-map.md` a rozhodní:

| Kritérium | Flash (Contabo) | Alfa (Wedos) |
|---|---|---|
| Potřebuje českou IP | - | ANO |
| Email/SMTP | - | ANO |
| Claude Code / AI workload | ANO | - |
| Scraping (proxy) | ANO | - |
| Web facing (oneflow.cz) | - | ANO |
| Obecný backend/API | ANO | - |
| Výpočetně náročné | ANO (12GB RAM) | NE (5.8GB) |

### Krok 2: Připrav službu
```bash
# 1. Vytvoř adresář
ssh [target] "mkdir -p /home/claude/[service-name]"

# 2. Zkopíruj kód
scp -r ./src [target]:/home/claude/[service-name]/

# 3. Nainstaluj dependence
ssh [target] "cd /home/claude/[service-name] && pip install -r requirements.txt"
# NEBO
ssh [target] "cd /home/claude/[service-name] && npm install --production"

# 4. Env soubor — NIKDY hardcoded secrets
ssh [target] "cat >> /home/claude/[service-name]/.env << 'EOF'
# Načti z master.env co potřebuješ
EOF"
```

### Krok 3: Systemd unit
```bash
ssh [target] "cat > /etc/systemd/system/[service-name].service << 'EOF'
[Unit]
Description=[Service Name] — [popis]
After=network.target
Wants=network-online.target

[Service]
Type=simple
User=claude
Group=claude
WorkingDirectory=/home/claude/[service-name]
ExecStart=[příkaz]
Restart=always
RestartSec=5
StartLimitBurst=5
StartLimitIntervalSec=60
EnvironmentFile=/home/claude/[service-name]/.env
StandardOutput=journal
StandardError=journal
SyslogIdentifier=[service-name]

[Install]
WantedBy=multi-user.target
EOF"

ssh [target] "systemctl daemon-reload && systemctl enable [service-name] && systemctl start [service-name]"
```

### Krok 4: Monit monitoring
```bash
ssh [target] "cat > /etc/monit/conf.d/[service-name] << 'EOF'
check process [service-name] matching \"[process-pattern]\"
    start program = \"/usr/bin/systemctl start [service-name]\"
    stop program = \"/usr/bin/systemctl stop [service-name]\"
    if not exist then restart
    if cpu > 80% for 5 cycles then alert
    if memory > 200 MB then alert
    if 3 restarts within 5 cycles then timeout
EOF"

ssh [target] "monit reload"
```

### Krok 5: Fluent Bit logging (pokud na Flash)
```bash
ssh root@10.77.0.1 "cat >> /etc/fluent-bit/parsers-custom.conf << 'EOF'
[PARSER]
    Name   [service-name]_parser
    Format regex
    Regex  ^(?<log>.*)$
    Time_Key time
    Time_Format %Y-%m-%d %H:%M:%S
EOF"

# Přidej input + output do hlavního configu
```

### Krok 6: Caddy reverse proxy (pokud web-facing)
```bash
# Pouze na Alfa pro *.oneflow.cz
ssh root@89.221.212.203 "cat >> /etc/caddy/Caddyfile << 'EOF'

[subdomain].oneflow.cz {
    reverse_proxy localhost:[port]
    log {
        output file /var/log/caddy/[service-name].log
    }
}
EOF"

ssh root@89.221.212.203 "caddy reload --config /etc/caddy/Caddyfile"
```
Na Flash: Caddy na portu 80/443, podobný postup.

### Krok 7: Health check + ntfy alert
```bash
# Test
ssh [target] "curl -s localhost:[port]/health || echo 'NO HEALTH ENDPOINT'"

# ntfy notifikace o nasazení
ssh [target] "curl -s -d '[service-name] deployed successfully on [target]' ntfy.sh/[topic]"
```

### Krok 8: Aktualizuj ecosystem-map
Po úspěšném nasazení uprav:
- `~/.claude/rules/ecosystem-map.md` — přidej službu do tabulky
- `~/.claude/projects/-Users-filipdopita/memory/project_vps_new_services.md` — zaloguj

### Krok 9: Ověření
```bash
# Systemd status
ssh [target] "systemctl status [service-name]"

# Monit status
ssh [target] "monit status [service-name]"

# Logs
ssh [target] "journalctl -u [service-name] -n 20 --no-pager"

# Port listening
ssh [target] "ss -tlnp | grep [port]"
```

### Checklist před dokončením
- [ ] Systemd unit s Restart=always
- [ ] Monit config přidán a ověřen
- [ ] Žádné hardcoded secrets (vše v .env)
- [ ] Health endpoint existuje (/health nebo ekvivalent)
- [ ] Ecosystem-map aktualizován
- [ ] Fluent Bit (Flash) nebo log file (Alfa) nakonfigurován
- [ ] ntfy notifikace odeslána
- [ ] Port dokumentován v ecosystem-map tabulce

## Error Handling

| Situace | Akce |
|---|---|
| SSH connection refused | Ověř WireGuard (`wg show`), zkus ping 10.77.0.1 |
| Systemd unit failed | `journalctl -u [service] -n 50 --no-pager`, oprav a `systemctl restart` |
| Port already in use | `ss -tlnp \| grep [port]`, identifikuj konflikt, přeřaď port |
| Monit: does not exist | `monit reload`, pokud přetrvává zkontroluj syntax `/etc/monit/conf.d/` |
| Permission denied | `chown -R claude:claude /home/claude/[service]`, zkontroluj User= v unit |
| OOM kill | Zkontroluj `dmesg \| grep -i oom`, přidej MemoryLimit= do unit |

## Common Mistakes

1. **Neházkuj porty.** Vždy zkontroluj ecosystem-map.md jestli port není obsazený.
2. **Nekopíruj secrets přes scp.** Credentials patří do master.env na cílovém VPS, ne do zdrojového kódu.
3. **Nespouštěj službu bez Monit watcheru.** Každý service MUSÍ mít monit config.
4. **Nezapomeň na bind adresu.** Interní služby = 127.0.0.1, WG služby = 10.77.0.x, veřejné = 0.0.0.0.
5. **Netestuj jen start.** Ověř i restart (`systemctl restart`) a recovery po kill (`kill -9`).
