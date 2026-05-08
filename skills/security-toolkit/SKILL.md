---
name: security-toolkit
description: Defensive 100% security ekosystém pro OneFlow. 7 vrstev — perimeter (UFW+fail2ban+CrowdSec) → NIDS (Suricata+ET-Open) → HIDS (auditd+AIDE+AppArmor) → endpoint (ClamAV+rkhunter+chkrootkit) → vuln mgmt (nuclei+osv-scanner+trivy+lynis) → secret mgmt (gitleaks+trufflehog) → observability (ntfy+daily threat digest+SSL expiry+compliance reports). ČNB ECSP + AML + GDPR Art. 32 ready. Vše na Flash VPS, 0 Kč.
trigger: security audit, recon vlastní domény, scan oneflow.cz, hardening Lynis, find secrets, vuln scan, threat intel, compliance audit, ČNB ECSP, AML security, GDPR Art 32, NIDS, HIDS, file integrity, intrusion detection, defensive security
---

# /security-toolkit

Defensive security toolkit pro OneFlow infrastrukturu. Vše běží na Flash VPS (`/root/security-toolkit/`).

## 7 vrstev defensivní posture

| Vrstva | Tooly | Účel |
|---|---|---|
| **L1 Perimeter** | UFW + fail2ban (sshd/caddy/postfix/dovecot/recidive) + CrowdSec | Default-deny + brute-force ban + collaborative threat intel feed |
| **L2 Network IDS** | Suricata + ET-Open ruleset | Real-time network attack detection, alerts → eve.json |
| **L3 Host IDS** | auditd + AIDE + AppArmor | Kernel audit (passwd/sudo/ssh/cred), file integrity, MAC |
| **L4 Endpoint** | ClamAV daily def + rkhunter weekly + chkrootkit weekly | Malware/rootkit detection on filesystem |
| **L5 Vuln mgmt** | nuclei + osv-scanner + trivy + lynis | Web/IaC/package CVE + system hardening score |
| **L6 Secret mgmt** | gitleaks + trufflehog | Leaked credential detection, verified live secrets flag |
| **L7 Observability** | ntfy + daily threat digest + SSL expiry + weekly self-audit | Alerting, compliance report, certificate lifecycle |

## Recon & forensics tooly (ad-hoc)
| Vrstva | Tooly | Use case |
|---|---|---|
| **Recon** | subfinder, ProjectDiscovery httpx 1.9.0, amass, masscan, nmap | Subdomain enum + live filter + port scan vlastních domén |
| **Web sec** | testssl.sh, nuclei, nikto | SSL/TLS + web vuln + legacy webserver scan |
| **Forensics** | tshark, binwalk, tcpdump | Ad-hoc network/file analysis při incidentu |

## Wrapper commands (na Flash)

| Command | Popis |
|---|---|
| `/root/security-toolkit/bin/recon.sh <domain>` | Full recon: subdomény → live → high+critical vulns |
| `/root/security-toolkit/bin/hardening.sh [--quick]` | Lynis + rkhunter + chkrootkit + osv. `--quick` = jen lynis+osv |
| `/root/security-toolkit/bin/web-scan.sh <url>` | testssl + nuclei + nikto + headers |
| `/root/security-toolkit/bin/secret-scan.sh <path>` | gitleaks + trufflehog (verified live secrets) |
| `/root/security-toolkit/bin/weekly-self-audit.sh` | Orchestrator: vše + ntfy report |

## Reports

Všechny reporty: `/root/security-toolkit/reports/`
Format: `<scan-type>-<target>-<YYYYMMDD-HHMMSS>/SUMMARY.md`

## Weekly cron

Spouští se Sun 04:00 UTC na Flash:
```cron
0 4 * * 0 /root/security-toolkit/bin/weekly-self-audit.sh > /var/log/security-weekly.log 2>&1
```

ntfy report jde na `https://ntfy.oneflow.cz/Filip` s priority:
- `urgent` — high+critical vulns nebo verified live secrets
- `high` — gitleaks findings
- `default` — clean

## Skenované domény (default v weekly cronu)

- oneflow.cz
- partners.oneflow.cz
- terminal.oneflow.cz
- <klient>.oneflow.cz
- legal.oneflow.cz
- asr.oneflow.cz

Edituj v `weekly-self-audit.sh` array `DOMAINS` pro přidání/odebrání.

## Quick usage examples

```bash
# Sken konkrétní domény
ssh root@10.77.0.1 '/root/security-toolkit/bin/recon.sh terminal.oneflow.cz'

# Hardening audit Flash
ssh root@10.77.0.1 '/root/security-toolkit/bin/hardening.sh'

# SSL/TLS audit
ssh root@10.77.0.1 '/root/security-toolkit/bin/web-scan.sh https://oneflow.cz'

# Secret leak check v scriptech
ssh root@10.77.0.1 '/root/security-toolkit/bin/secret-scan.sh /root/scripts'

# Manuální weekly run
ssh root@10.77.0.1 '/root/security-toolkit/bin/weekly-self-audit.sh'
```

## Manual install/update

Source: `~/scripts/security-toolkit/install.sh` (Mac) → deploys to `/root/security-toolkit-install.sh` (Flash).

```bash
ssh root@10.77.0.1 '/root/security-toolkit-install.sh'  # idempotent
```

## Související skills

- `/cso` — strategic security audit (gstack plugin, čte výsledky tohoto toolkitu)
- `security-self-audit` — defensive audit own VPS infra (high-level, doplňuje tento toolkit)
- `/postmortem` — po incidentu

## Co tento toolkit NEDĚLÁ

Defensive only. Nikdy nepoužívej proti cizí infrastruktuře bez authorized engagement (CZ TZ § 230). Konkrétně **NEINSTALOVÁNO** ze Z4nzu/hackingtool:
- DDoS tools (SlowLoris, UFOnet, GoldenEye, Asyncrone)
- Phishing kits (Setoolkit, Evilginx3, BlackEye, ShellPhish, BlackPhish + 12 dalších)
- Payload/RAT/C2 (TheFatRat, Stitch, Sliver, Havoc, Mythic, Pyshell + 13 dalších)
- Wireless attack (Wifite, Fluxion, EvilTwin, Wifiphisher, Bettercap + 8 dalších)
- Exploit frameworks (RouterSploit, WebSploit, Commix)
- Social media bruteforce (Facebook/Instagram attack)
- IDN homograph (EvilURL)
- Payload injectors (Debinject, Pixload)

Tyhle nástroje jsou v Z4nzu repo, ale jejich použití bez authorized pentest engagement je trestný čin (TZ § 230 — neoprávněný přístup, § 231 — opatření přístupového zařízení).
