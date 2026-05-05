---
name: security-self-audit
description: "Defensivní bezpečnostní audit vlastní VPS infrastruktury. Port scan, SSL, SSH hardening, UFW, fail2ban, bind adresy, file permissions, SUID binaries, zombie procesy. Výstup: strukturovaný PASS/WARN/FAIL report s remediací. Trigger: '/cso', 'bezpečnostní audit', 'security audit VPS', 'zkontroluj bezpečnost serveru'."
version: 1.0.0
author: Filip Dopita
tags: [security, audit, vps, defensive, hardening]
compatibility: Requires SSH root access to Flash and Alfa VPS via WireGuard. Nmap must be installed locally.
metadata:
  requires-env: SSH_KEY
  allowed-hosts:
    - 10.77.0.1
    - 89.221.212.203
    - 173.212.220.67
  version: "1.1"
allowed-tools:
  - Bash
  - Read
  - Write
  - Grep
  - Glob
---

# /cso — Chief Security Officer: VPS Self-Audit

## Kdy spustit
- Uživatel napíše `/cso` nebo `/security-self-audit`
- Po každém deploy nové služby
- Po security incidentu nebo podezřelé aktivitě
- Měsíční rutinní audit (doporučeno: každý 1. v měsíci)
- Před/po změně firewall pravidel

## Scope

Audit se spouští na **obou VPS**:
- **Flash** (Contabo): `ssh root@10.77.0.1`
- **Alfa** (Wedos): `ssh root@89.221.212.203`

Pokud uživatel specifikuje jen jeden server, audituj jen ten. Default = oba.

---

## FÁZE 1: Sběr dat (paralelně)

Spusť všechny data-collection příkazy **zároveň** přes SSH — nečekej na výsledky postupně.

### 1.1 Port scan (nmap)
```bash
# Z pohledu externího útočníka — co vidí internet
nmap -sS -sV --open -T4 -p- --min-rate 1000 [TARGET_IP] 2>/dev/null
# Rychlejší varianta pro rutinní audit
nmap -sV --open -T4 -p 1-65535 --min-rate 2000 [TARGET_IP] 2>/dev/null | grep -E "open|filtered"
```

Očekávané porty:
- Flash: 22 (SSH), 80 (Caddy), 443 (Caddy), 51820 (WireGuard)
- Alfa: 22 (SSH), 25 (SMTP), 80, 143 (IMAP), 443, 993 (IMAPS), 2586 (ntfy), 45876 (Beszel), 18810 (wa-bridge)

Jakýkoli NEČEKANÝ otevřený port = FAIL.

### 1.2 SSL/TLS certifikáty
```bash
# Pro každou doménu
echo | openssl s_client -connect [domain]:443 -servername [domain] 2>/dev/null | openssl x509 -noout -dates -subject -issuer 2>/dev/null
# Alternativně
curl -vI https://[domain] 2>&1 | grep -E "expire|SSL|TLS|issuer|subject"
```

Domény k prověření: `oneflow.cz`, `mail.oneflow-team.cz`, plus hlavní Caddy endpointy.

Kontroluj:
- Expiry < 30 dní = WARN
- Expiry < 7 dní = FAIL
- Self-signed cert = FAIL (kromě interních)
- TLS verze < 1.2 = FAIL

### 1.3 SSH hardening
```bash
ssh [TARGET] "grep -E '^(PermitRootLogin|PasswordAuthentication|MaxAuthTries|PubkeyAuthentication|ChallengeResponseAuthentication|X11Forwarding|AllowTcpForwarding|Protocol)' /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf 2>/dev/null"
```

Požadované hodnoty:
| Direktiva | Požadovaná hodnota | Jiná = |
|---|---|---|
| PermitRootLogin | `prohibit-password` nebo `no` | FAIL |
| PasswordAuthentication | `no` | FAIL |
| MaxAuthTries | `<= 3` | WARN |
| PubkeyAuthentication | `yes` | WARN |
| X11Forwarding | `no` | WARN |
| Protocol | `2` nebo neuvedeno (default 2) | FAIL |

### 1.4 UFW audit
```bash
ssh [TARGET] "ufw status verbose 2>/dev/null && iptables -L INPUT -n --line-numbers 2>/dev/null | head -40"
```

Kontroluj:
- UFW aktivní = PASS
- UFW inactive = FAIL
- Default policy DENY incoming = PASS
- Default policy ALLOW incoming = FAIL
- Pravidlo `allow from anywhere to any port X` kde X je citlivý port = WARN

### 1.5 Fail2ban status
```bash
ssh [TARGET] "fail2ban-client status 2>/dev/null && fail2ban-client status sshd 2>/dev/null"
```

Kontroluj:
- fail2ban běží = PASS
- fail2ban neběží = FAIL
- sshd jail aktivní = PASS
- sshd jail neexistuje = WARN
- > 0 currently banned = INFO (zaloguj počet)

### 1.6 Bind adresy (service exposure)
```bash
ssh [TARGET] "ss -tlnp 2>/dev/null | grep -v '127.0.0.1\|::1\|10.77.0'"
```

Jakákoli interní služba bindnutá na `0.0.0.0` místo `127.0.0.1` = FAIL.

Výjimky (smí být na 0.0.0.0):
- Port 22 (SSH)
- Port 80, 443 (web)
- Port 25 (SMTP - jen Alfa)
- Port 51820 (WireGuard)
- Port 2586 (ntfy - jen Alfa)
- Port 45876 (Beszel - jen Alfa)

### 1.7 File permissions — citlivé adresáře
```bash
ssh [TARGET] "
stat -c '%a %U %G %n' /root/.credentials/ /root/.credentials/* /root/.ssh/ /root/.ssh/id_* /root/.ssh/authorized_keys 2>/dev/null;
find /root/.credentials /root/.ssh -type f -perm /022 2>/dev/null | head -20
"
```

Požadované permissions:
| Cesta | Očekávaný chmod | Jiný = |
|---|---|---|
| `~/.credentials/` | 700 | FAIL |
| `~/.credentials/*` | 600 | FAIL |
| `~/.ssh/` | 700 | FAIL |
| `~/.ssh/id_*` (private) | 600 | FAIL |
| `~/.ssh/authorized_keys` | 600 | WARN |

### 1.8 SUID binary scan
```bash
ssh [TARGET] "find / -xdev -perm -4000 -type f 2>/dev/null | sort"
```

Porovnej výstup s baseline (pokud existuje z předchozího auditu). Jakýkoli NOVÝ SUID binary od posledního auditu = FAIL s důkladným popisem.

Běžné legitimní SUID binaries (whitelist):
```
/usr/bin/sudo, /usr/bin/su, /usr/bin/passwd, /usr/bin/newgrp, /usr/bin/gpasswd,
/usr/bin/chsh, /usr/bin/chfn, /usr/bin/mount, /usr/bin/umount, /bin/ping,
/usr/lib/openssh/ssh-keysign, /usr/lib/dbus-1.0/dbus-daemon-launch-helper,
/usr/sbin/pppd, /usr/bin/pkexec
```

Cokoli mimo whitelist = WARN, nové od minulého auditu = FAIL.

### 1.9 Listening services vs. expected
```bash
ssh [TARGET] "
ss -tlnp 2>/dev/null;
systemctl list-units --type=service --state=running --no-pager 2>/dev/null | grep -v '@'
"
```

Porovnej s `ecosystem-map.md`. Služby co běží ale nejsou v ecosystem-map = WARN.

### 1.10 Disk a zombie procesy
```bash
ssh [TARGET] "
df -h / /home 2>/dev/null;
ps aux 2>/dev/null | grep -E '^[^ ]+ +[0-9]+ +[0-9.]+ +[0-9.]+ .*Z ' | wc -l;
ps aux 2>/dev/null | awk '\$8~/^Z/ {print}' | head -10
"
```

Thresholds:
- Disk > 85% = WARN
- Disk > 95% = FAIL
- Zombie procesy > 5 = WARN
- Zombie procesy > 20 = FAIL

### 1.11 Hardcoded credentials check (bonus)
```bash
ssh [TARGET] "
grep -rn 'OPENAI_API_KEY\|sk-\|Bearer [A-Za-z0-9]\{20\}\|password.*=.*[A-Za-z0-9]\{8\}' \
  /home/claude/ /root/ --include='*.py' --include='*.js' --include='*.ts' --include='*.sh' \
  --exclude-dir='.git' --exclude-dir='node_modules' 2>/dev/null | head -20
"
```

Jakýkoli hardcoded credential = FAIL (okamžitá akce nutná).

### 1.12 Recent auth failures
```bash
ssh [TARGET] "
lastb 2>/dev/null | head -20;
journalctl -u sshd --since '24 hours ago' 2>/dev/null | grep -i 'failed\|invalid\|refused' | tail -20;
cat /var/log/auth.log 2>/dev/null | grep -i 'failed\|invalid' | tail -20
"
```

> 100 failed attempts za 24h = WARN, > 500 = FAIL.

---

## FÁZE 2: Analýza a scoring

### Scoring systém
Každý check dostane:
- **PASS** (zelená) — všechno OK
- **WARN** (žlutá) — suboptimální, ale ne kritické
- **FAIL** (červená) — kritický problém, nutná remediace

**Výsledné skóre:**
```
Security Score = (PASS × 3 + WARN × 1) / (total_checks × 3) × 100
```

Threshold:
- >= 90% = Secure
- 70-89% = Needs Attention
- < 70% = Critical

### Porovnání s předchozím auditem
Načti předchozí audit z `~/Documents/security-audits/`:
```bash
ls -la ~/Documents/security-audits/*.md 2>/dev/null | tail -5
```

Porovnej:
- Nové FAILy od posledního auditu = kritické (označ)
- Vyřešené FAILy od posledního auditu = poznamenej jako Fixed
- Nové neočekávané otevřené porty
- Nové SUID binaries

---

## FÁZE 3: Report

### Formát reportu

Generuj Markdown soubor na `~/Documents/security-audits/YYYY-MM-DD-[server]-audit.md`.
Pokud auditujeme oba, vytvoř dva soubory + jeden summary.

```markdown
# Security Audit — [SERVER] — YYYY-MM-DD HH:MM

**Score:** XX% (Secure / Needs Attention / Critical)
**Auditor:** Claude Code (security-self-audit v1.0.0)
**Duration:** Xs

---

## Executive Summary
[2-3 věty. Celkový stav. Kolik FAIL/WARN/PASS. Co je urgentní.]

## FAIL — Kritické problémy (okamžitá akce)

### FAIL-01: [Název problému]
- **Check:** [Co bylo testováno]
- **Nalezeno:** `[přesný výstup příkazu]`
- **Riziko:** [Co se může stát]
- **Remediace:**
  ```bash
  [přesné příkazy k opravě]
  ```
- **Deadline:** Okamžitě / 24h / 7 dní

[Opakuj pro každý FAIL]

---

## WARN — Doporučení ke zlepšení

### WARN-01: [Název]
- **Check:** [Co bylo testováno]
- **Nalezeno:** [výstup]
- **Remediace:** [příkazy nebo akce]

[Opakuj pro každý WARN]

---

## PASS — V pořádku

| Check | Status | Detail |
|---|---|---|
| Port scan | PASS | Pouze očekávané porty: 22, 80, 443 |
| SSH hardening | PASS | PasswordAuth=no, RootLogin=prohibit-password |
| ... | ... | ... |

---

## Diff od posledního auditu ([datum])

**Nové FAILy:** [seznam nebo "žádné"]
**Opravené FAILy:** [seznam nebo "žádné"]
**Nové porty:** [seznam nebo "žádné"]
**Nové SUID binaries:** [seznam nebo "žádné"]

---

## SUID Baseline (pro příští audit)
```
[kompletní výstup find / -xdev -perm -4000]
```

---

*Generováno: [timestamp] | Next audit: [datum +30 dní]*
```

### Konzolidovaný summary (pro oba servery)

Po dokončení obou auditů vytvoř:
`~/Documents/security-audits/YYYY-MM-DD-SUMMARY.md`

```markdown
# Security Summary — YYYY-MM-DD

| Server | Score | FAILs | WARNs | PASSes |
|---|---|---|---|---|
| Flash (10.77.0.1) | XX% | N | N | N |
| Alfa (89.221.212.203) | XX% | N | N | N |
| **CELKEM** | **XX%** | **N** | **N** | **N** |

## Top Priority Actions
1. [FAIL-01 Flash] Popis...
2. [FAIL-01 Alfa] Popis...
...
```

---

## FÁZE 4: Post-audit akce

### Automatické opravy (jen pokud BEZPEČNÉ a NEDESTRUKTIVNÍ)
Skill smí automaticky opravit:
```bash
# Permissions fix
ssh [TARGET] "chmod 700 /root/.credentials /root/.ssh && chmod 600 /root/.credentials/* /root/.ssh/id_* /root/.ssh/authorized_keys 2>/dev/null"

# fail2ban restart pokud neběží
ssh [TARGET] "systemctl start fail2ban && systemctl enable fail2ban"
```

### Vyžaduje Filipovo schválení (NEPTEJ SE — UPOZORNI a čekej na potvrzení):
- Změna UFW pravidel
- Změna SSH konfigurace
- Zabití procesů
- Jakékoli smazání souborů

### ntfy notifikace
Po dokončení auditu odešli push:
```bash
# Pokud jsou FAIL položky
curl -s \
  -H "Title: Security Audit: N FAILs nalezeno" \
  -H "Priority: high" \
  -H "Tags: warning,shield" \
  -d "Flash: XX% | Alfa: XX% | FAILs: N | Report: ~/Documents/security-audits/" \
  https://ntfy.sh/oneflow-security 2>/dev/null

# Pokud vše OK
curl -s \
  -H "Title: Security Audit: OK" \
  -H "Priority: default" \
  -H "Tags: white_check_mark,shield" \
  -d "Flash: XX% | Alfa: XX% | Vše v pořádku" \
  https://ntfy.sh/oneflow-security 2>/dev/null
```

### Aktualizace memory
Po auditu přidej do `~/.claude/projects/-Users-filipdopita/memory/security_hardening_2026_04_09.md`:
```
## Audit [YYYY-MM-DD]
Score: Flash XX%, Alfa XX%
FAILs: [seznam]
Opraveno: [seznam]
Next: [YYYY-MM-DD]
```

---

## Pravidla výkonu

- Veškerá SSH volání spouštěj **paralelně** (Bash tool × SSH sessions)
- Timeout na SSH command = 30s (přidej `ssh -o ConnectTimeout=10`)
- Pokud server nedostupný: označ jako SKIP a pokračuj s druhým
- NIKDY nespouštěj destruktivní příkazy (rm, dd, iptables -F, ufw disable)
- Credentials CHECK pouze přes grep patterns — NIKDY nevypisuj hodnoty klíčů

## Interní prioritizace checků

```
Pořadí závažnosti:
1. Hardcoded credentials      → KRITICKÉ, okamžitá akce
2. SSH PasswordAuth=yes       → KRITICKÉ, okamžitá akce
3. UFW neaktivní              → KRITICKÉ
4. Neočekávané otevřené porty → KRITICKÉ
5. Interní service na 0.0.0.0 → VYSOKÉ
6. Credentials permissions    → VYSOKÉ
7. Nové SUID binaries         → VYSOKÉ
8. SSL expiry < 7 dní         → VYSOKÉ
9. fail2ban neběží            → STŘEDNÍ
10. Disk > 95%                → STŘEDNÍ
11. SSH MaxAuthTries > 3      → NÍZKÉ
12. SSL expiry < 30 dní       → NÍZKÉ
13. Zombie procesy > 5        → INFORMAČNÍ
14. Disk > 85%                → INFORMAČNÍ
```

## Výstup do konzole (shrnutí po dokončení)

```
╔══════════════════════════════════════════════════════════╗
║              SECURITY AUDIT — YYYY-MM-DD                 ║
╠══════════════════════════════════════════════════════════╣
║ Flash  173.212.220.67 │ Score: XX%  │ FAIL:N WARN:N PASS:N ║
║ Alfa   89.221.212.203 │ Score: XX%  │ FAIL:N WARN:N PASS:N ║
╠══════════════════════════════════════════════════════════╣
║ URGENTNÍ: [pokud jsou FAILy — stručný seznam]           ║
╠══════════════════════════════════════════════════════════╣
║ Report: ~/Documents/security-audits/YYYY-MM-DD-SUMMARY  ║
╚══════════════════════════════════════════════════════════╝
```

## Error Handling

| Situace | Akce |
|---|---|
| SSH connection timeout | Ověř WireGuard: `wg show`, `ping 10.77.0.1`. Pokud WG down, restart: `wg-quick down wg0 && wg-quick up wg0` |
| nmap: permission denied | Spusť s `sudo`. Nmap SYN scan vyžaduje root |
| SSL check: connection refused | Služba neběží nebo Caddy/nginx down. Zkontroluj `systemctl status caddy` |
| UFW: command not found | UFW není nainstalovaný (nemělo by se stát). FAIL + okamžitá remediace |
| Disk >95% | Před auditem vyčisti: `journalctl --vacuum-size=100M`, smaž staré logy |
| Monit: not running | `systemctl start monit && systemctl enable monit`. FAIL v reportu |

## Common Mistakes

1. **Neskenuj z VPS sám sebe.** Port scan MUSÍ být z externího viewpointu (z Macu nebo druhého VPS).
2. **Neigonruj WARN.** WARN dnes = FAIL zítra. Každý WARN má remediation plan.
3. **Nepřepisuj UFW pravidla bez zálohy.** `ufw status numbered > /tmp/ufw_backup.txt` před změnou.
4. **Nekontroluj jen TCP.** UDP porty (WireGuard 51820, DNS) jsou stejně důležité.
5. **Neporovnávej jen s minulým auditem.** Porovnej s ecosystem-map.md (expected state).
