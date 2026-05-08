---
name: shannon
description: Shannon AI pentester wrapper. Spouští autonomní white-box web app + API penetration testing přes Claude. Use when user wants security audit of own web app, klientský pentest (s autorizací), pre-deploy security gate, OWASP vulnerability scan with proof-of-concept exploits. Trigger: "pentest X", "security audit X", "shannon scan X", "najdi zranitelnosti v X", "pre-deploy security check", "ověř bezpečnost web aplikace".
---

# Shannon AI Pentester

## Co dělá

Shannon Lite (KeygraphHQ, AGPL-3.0, 40k+ stars) — autonomní AI pentester:
1. **Recon**: Nmap, Subfinder, WhatWeb, Schemathesis, source code analysis
2. **Vulnerability identification**: OWASP Top 10 (Injection, XSS, SSRF, Broken Auth/Authz)
3. **Exploitation**: real exploits přes browser automation + CLI tools
4. **Reporting**: pouze proven findings s working PoC

Rozdíl proti `/cso` nebo `security-redteam` agent: **Shannon spouští real exploits** proti běžící aplikaci. Není to passive scanner. Validates vulnerabilities přes actual proof-of-concept.

Powered by Claude (Opus 4.7 / Sonnet 4.6 / Haiku 4.5 tier system, automatic).

## Installation

**Status**: ✅ INSTALLED na Flash VPS (10.77.0.1) v `/home/claude/shannon-pentest/`
- Auth: Claude Code OAuth token (Filipova Max sub)
- User: `claude` (docker group, non-root per Shannon requirement)
- Docker: 28.2.2, worker image building on first run (~1GB)
- Temporal: localhost:8233 (monitoring UI)

## Jak spustit

### Quick scan (Filip's own systems)

```bash
ssh claude@10.77.0.1 "cd ~/shannon-pentest && ./shannon start \
  -u https://oneflow.cz \
  -r /home/claude/shannon-pentest/sample-repos/oneflow-website \
  -w oneflow-2026-04-30"
```

**Required arguments:**
- `-u <url>` — target URL (musí být accessible)
- `-r <path>` — local path to source code repository (white-box requirement, **MUSÍ být git repo** — preflight validation `runPreflightValidation` requires `.git` directory; pokud chybí: `cd repo && git init && git add . && git commit -m "init"`)
- `-w <name>` — workspace name (auto-resumes if exists)

**Optional:**
- `-c <yaml>` — custom config
- `-o <dir>` — output directory pro deliverables
- `--pipeline-testing` — fast mode (minimal prompts)
- `--debug` — preserve container after exit

### Monitoring

```bash
# List workspaces
ssh claude@10.77.0.1 "cd ~/shannon-pentest && ./shannon workspaces"

# Tail logs
ssh claude@10.77.0.1 "cd ~/shannon-pentest && ./shannon logs <workspace>"

# Status (running workers)
ssh claude@10.77.0.1 "cd ~/shannon-pentest && ./shannon status"

# Temporal UI (port forward přes WG)
ssh -L 8233:localhost:8233 claude@10.77.0.1
# Then open: http://localhost:8233
```

### Stop / cleanup

```bash
ssh claude@10.77.0.1 "cd ~/shannon-pentest && ./shannon stop"          # stop containers
ssh claude@10.77.0.1 "cd ~/shannon-pentest && ./shannon stop --clean"  # + remove volumes
```

## Use Cases (Filip's ekosystém)

### 1. OneFlow vlastní weby (LEGAL — vlastní)
- `oneflow.cz` (main marketing site)
- `terminal.oneflow.cz` (Social Publisher dashboard)
- `<klient>.oneflow.cz` (<klient> landing)
- `partners.oneflow.cz` (klient downloads)
- `legal.oneflow.cz` (Privacy/Data Deletion)
- `<klient>.oneflow.cz` (<klient>)
- `ciad.cz` (institucionální brand)

Source code obvykle na Mac (`~/Documents/oneflow-*/`). Sync přes /mac SSHFS:
```bash
# Repo na Mac, scan z Flash
ssh claude@10.77.0.1 "cd ~/shannon-pentest && ./shannon start \
  -u https://terminal.oneflow.cz \
  -r /mac/Documents/social-publisher \
  -w social-publisher-2026-04-30"
```

### 2. Klientské weby (LEGAL pouze s autorizací)
**MANDATORY**: před spuštěním scan na klientský web musí existovat:
- ✅ Written authorization (smlouva nebo email s explicit "souhlas s pentestem")
- ✅ Scope definition (které URL, kdy, intenzita)
- ✅ Out-of-hours timing dohodnut

Bez autorizace = **legal red line**, žádný scan.

### 3. Pre-deploy security gate
Před launchem nového projektu (ASR, klient deliverable) → Shannon scan → fix findings → ship.

Auto-chain: oneflow-diagnose GO verdict → Shannon scan staging → only ship if PASS.

### 4. DD pro emitenty (tech-heavy pitch)
Pokud emitent prezentuje "secure platform / proprietary tech" jako selling point:
- Filip's `/dd-emitent` skill DOES NOT scan jejich aktualní web (ne vlastní, ne authorized)
- ALE: Shannon scan se může VYŽÁDAT v rámci DD jako podmínka investice

### 5. Periodic OneFlow self-audit
Pre-build hook pro CI/CD: každý quarter spustit Shannon na main OneFlow systems.

## Output struktura

Po dokončení scanu:
```
/home/claude/shannon-pentest/workspaces/<workspace-name>/
├── deliverables/
│   ├── shannon-report.md       # main report (markdown)
│   ├── findings/               # individual vulnerabilities
│   │   ├── INJ-001-sqli.md     # PoC + exploitation steps
│   │   ├── XSS-002-stored.md
│   │   └── ...
│   ├── logs/                   # raw scanner output
│   └── attachments/            # screenshots, requests, responses
└── temporal-state/             # workflow state (resume)
```

## Integration s OneFlow ekosystémem

### Auto-sync findings → Obsidian
```bash
# Po scanu: copy report do Obsidian vault
ssh claude@10.77.0.1 "cp /home/claude/shannon-pentest/workspaces/<name>/deliverables/shannon-report.md \
  /mac/Documents/OneFlow-Vault/04-Security/shannon-<target>-$(date +%Y-%m-%d).md"
```

### Auto-trigger /cso po Shannon findings
Pokud Shannon najde HIGH/CRITICAL → auto-spawn `/cso` skill pro infrastructure-level audit (Shannon = app layer, /cso = infra layer).

### Memory entry per scan
Po každém scanu: append do `~/.claude/projects/-Users-filipdopita/memory/shannon_scan_<target>_<date>.md`.

## Cost & Performance

- **Compute**: Flash VPS (12GB RAM, 6vCPU). Scan = 1× docker container ~1-3GB RAM peak.
- **AI cost**: Claude Code OAuth token = Filipova Max kvóta. Scan = ~50k-500k tokens (multi-agent), záleží na scope.
- **Disk**: Worker image ~1GB, workspaces ~50-200MB per scan.
- **Time**: simple landing page ~5-15 min, complex SaaS ~30-60 min, mega scope ~hours.

## Safety boundaries

- ✅ Vlastní systémy (OneFlow domains, vlastní VPS subdomains)
- ✅ Autorizované klienty (s written consent)
- ✅ CTF / staging environments
- ❌ Bez autorizace na cizí systém — illegal (computer fraud)
- ❌ Production payment systémy bez explicit Filipova povolení (možné disruption)

## Troubleshooting

**"Shannon must not be run as root"** → use `claude` user via `ssh claude@10.77.0.1`

**"Docker permission denied"** → claude user musí být v `docker` group: `usermod -aG docker claude`

**OAuth token expired** → re-extract z Mac keychain:
```bash
security find-generic-password -s "Claude Code-credentials" -w | python3 -c "
import json,sys
d=json.load(sys.stdin)
print(d['claudeAiOauth']['accessToken'])"
```
→ update `/home/claude/shannon-pentest/.env` `CLAUDE_CODE_OAUTH_TOKEN=...`

**Worker build fails** → `./shannon build --no-cache` z claude shell.

**Temporal UI nedostupná** → port forward `ssh -L 8233:localhost:8233 claude@10.77.0.1`

## Related skills / agents

- `security-redteam` agent — adversarial code review (no exploitation, source-only)
- `security-blueteam` agent — defensive fixes for findings
- `security-auditor` agent — final A-F grading
- `/cso` skill — infrastructure-first security audit (network, services, configs)
- `/security-self-audit` — Filipova VPS self-audit
- `from-lukas:security-scan` — 3-agent red-team pipeline
- `gsd-secure-phase` — retroactive threat mitigation verification
- `oneflow-diagnose` — pre-build product diagnostic (gate before scan)

**Workflow chains:**
- `oneflow-diagnose GO` → Shannon scan staging → fix → ship
- Shannon HIGH finding → `security-blueteam` → fix → re-scan
- Pre-quarterly self-audit: Shannon (apps) + `/cso` (infra) → unified report

## Reference

- Repo: https://github.com/KeygraphHQ/shannon
- Sample report: `~/shannon-pentest/sample-reports/shannon-report-juice-shop.md`
- Architecture: SHANNON-PRO.md (full Pro version is paid; Lite covers Filip use cases 100%)
- Coverage: COVERAGE.md (current OWASP categories)
- License: AGPL-3.0 (OK pro internal use, není redistribuce)
