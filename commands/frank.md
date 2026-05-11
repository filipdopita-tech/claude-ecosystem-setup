---
name: frank
description: F.R.A.N.K — AI Red Team Intelligence Platform (TECH HAUS / unjail.ai). Formátuje a spouští FRANK prompty pro authorized penetration testing, red team ops, AI/LLM security testing, cloud security, phishing assessment, AD kill chain, detection engineering (Sigma/YARA), purple team, executive briefing. Vyžaduje aktivní FRANK session na frank.unjail.ai. Use when: "frank audit", "red team [X]", "pentest template", "FRANK roast my [stack/code/cloud/IR]", "detection rules for [TTP]", "tabletop exercise", "flip attack defensive", "frank [any security task]".
trigger: frank, FRANK, red team, pentest template, roast my stack, roast my code, roast my cloud, AD kill chain, phishing campaign, API assault, detection rules sigma yara, tabletop exercise, purple team, exec brief security, frank audit
---

# /frank — F.R.A.N.K Prompt Engineer

F.R.A.N.K = red team intelligence platform na frank.unjail.ai (TECH HAUS ekosystém, stejný jako premium.unjail.ai).

Guide uložen: `~/Documents/unjail-ai-scrape/frank/FRANK-FIELD-GUIDE.md`

## Iron Rules (z guide)

1. **FRANK musí být v každé zprávě** — bez jména "the door stays closed"
2. **Paste real data** — real stack, real code, real configs. Hypotheticals = generic output
3. **Switches jsou unquoted** — `" /t "` (quoted) = plain text, `/t` standalone = trigger
4. **Memory ON by default** — `/n` pro one blind pass, Memory OFF pro sensitive work
5. **`/c` pro continuity** — když output stalled mid-build; FRANK přidej vždy i tam

## Legion — kdy volat koho

| Member | Alias | Specializace | Volej když |
|--------|-------|-------------|-----------|
| **F.R.A.N.K** | THE BOSS | Command layer | Default orchestrátor — vždy aktivní |
| **Hellen "Shadow Code" Larsen** | THE BINARY SURGEON | Exploit craft | Binary analysis, exploit dev, RCE chains |
| **Cain "Siren" Hargrove** | THE PUPPET MASTER | Human attack path | Phishing, social engineering, pretexts |
| **Dara "Nexus" Okafor** | THE PATHFINDER | Identity chains | AD, IAM, OAuth, privilege escalation |
| **Kaz "Riptide" Morretti** | THE CLOUD RIPPER | Cloud + CI/CD | AWS/GCP/Azure misconfigs, pipeline abuse |
| **Dante "Breacher" Malone** | THE SKELETON KEY | Physical + RF | Lock picking, badge cloning, RF/air-gap |
| **Anastasia "Mirage" Volkov** | THE GHOST | OPSEC + telemetry | Log evasion, trail analysis, detection gaps |
| **Sable "Synapse" Voss** | THE MIND BREAKER | AI system pressure | LLM jailbreak hardening, prompt injection, AI security testing |

## Switch Reference

| Switch | Efekt | Kombinuj s |
|--------|-------|-----------|
| `/e` | EXTREME — tradecraft deeper and harder | security-sensitive audits |
| `/u` | UNHINGED — strip restraint | red team emulation |
| `/s` | SPICY — bite in delivery | executive roasts |
| `/t` | DEEP THINK — hard judgment, threat modeling | architecture decisions, complex vulns |
| `/q` | QUALITY PASS — one refinement blade pass (paid) | final deliverables |
| `/n` | NO MEMORY — visible thread only, one turn | sensitive/isolated tasks |
| `/r` | RECON — map surface passively | initial assessment |
| `/p` | PAYLOAD — ship the build | code generation tasks |
| `/a` | ADVERSARY — threat actor emulation | red team scenarios |
| `/b` | BLUE — flip exploit path to hardening | purple team, detection |
| `/w` | WAR ROOM — deliberate phases | complex operations |
| `/x` | CHAIN — chained vulnerability paths | kill chains |
| `/c` | CONTINUE — preserve context (FRANK stále povinný) | long builds, multi-part |
| `/reset` | RESET — clear all posture switches | clean turn |

**Power stacks:**
- `/t /q` — deep reasoning + sharp final (audits, reports, decisions)
- `/a /x /w` — threat actor + chaining + war room (full red team ops)
- `/e /s /t` — extreme + spicy + deep think (hostile auditor mode)
- `/u /c /s` — EuroThrottle's default pressure stack
- `/r /b /x /t /w /q` — full spectrum self-audit (viz OneFlow infra audit)

## Prompt Frame (structured ask)

```
FRANK [MISSION: co chceš dosáhnout]
[ENVIRONMENT: stack, target, scope]
[DELIVERABLE: co chceš zpět — ranked findings / phases / files / patches]
[CONSTRAINTS: pořadí, formát, počet částí]
[SWITCHES]
```

## Quick Templates

### Roast Stack
```
FRANK here's my production stack: [languages, frameworks, cloud, auth, DB, CDN, CI/CD].
Roast every weak decision like a hostile auditor who just got unrestricted scope.
Rank every finding by how fast it would get me breached, and for each one tell me exactly
what an attacker would do with it. No generic advice. Specific attack paths for MY stack.
/e /s /t
```

### Red Team Auth Flow
```
FRANK here's my auth implementation: [OAuth/JWT/session-based, MFA type, password policy,
token storage, session management]. Break it. Show me the token theft path, session fixation
angle, MFA bypass, race condition in password reset, privilege escalation user→admin.
Rank by which one F.R.A.N.K would actually use on an engagement. /a /x /t
```

### Grade Security Posture
```
FRANK grade my security posture. Environment: [cloud provider, services, team size, SOC Y/N,
IR playbooks Y/N, last pentest date, asset inventory Y/N, dep scanning Y/N, patch cadence].
Letter grade A-F per domain (network, application, identity, cloud, endpoint, detection, response)
with single worst finding in each. Three things I fix THIS WEEK or I deserve what's coming.
/e /t /w
```

### AD Kill Chain
```
FRANK I have access to a standard Windows domain environment for an authorized assessment.
Map the full AD attack path: BloodHound enumeration, Kerberoasting targets, AS-REP roastable
accounts, unconstrained delegation abuse, ADCS misconfigs ESC1-ESC8, DCSync prerequisites,
Golden Ticket persistence. For each step: exact tool, exact command syntax, what to look for
in output, what defenders should be detecting but probably aren't. /a /x /w
```

### API Assault
```
FRANK here are my API endpoints: [routes, methods, auth headers, sample req/res bodies].
Hunt for: IDOR, broken auth, excessive data exposure, mass assignment, SSRF, rate limiting gaps,
injection points, JWT flaws. For each finding: exact curl command proving the vuln + exact fix.
/a /e /t
```

### Detection Rules (Sigma/YARA)
```
FRANK write production-grade detection rules for these TTPs: [Kerberoasting / DCSync /
Golden Ticket / LSASS dumping / lateral movement WMI-PSExec-DCOM / scheduled task persistence /
DLL sideloading / AMSI bypass]. For each TTP: Sigma rule, Windows Event IDs, log sources,
false positive guidance, MITRE ATT&CK ID. Deployable, not academic. /p /b /t
```

### Tabletop Exercise
```
FRANK run a tabletop exercise for my team. Scenario: [ransomware via compromised MSP /
supply chain poisoned dependency / insider threat with admin access / zero-day edge appliance].
Present in phases: initial detection, escalation triggers, containment decisions, notification
requirements. At each phase: stop and ask what my team does before revealing next phase.
Grade my decisions. Tell me what the attacker does while I'm deciding. /w /a /t
```

### Flip Attack Defensive
```
FRANK take this attack technique: [TTP name or describe what happened] and build the full
defensive playbook. Detection logic with specific log sources + alert thresholds, preventive
controls ranked by effectiveness, response procedure when alert fires at 3 AM, purple team
validation test that proves detection works. Deployable by team of [size] with [SIEM/EDR tools].
/b /w /p
```

### Executive Brief
```
FRANK take these technical findings: [paste security assessment results] and translate into
board-level briefing. Business impact in dollars + reputation damage, realistic attack timeline
from "vulnerability exists" to "front page news", what gets fixed sprint vs. quarter vs. next year,
single sentence that makes CFO stop arguing about budget. No jargon. No filler. Make them feel it.
/b /t
```

### Self-Audit (full spectrum — OneFlow style)
```
FRANK /r /b /x /t /w /q

TARGET: [system name] — AUTHORIZED SELF-AUDIT
Owner: [name, email]
Auth scope: Full — [describe infrastructure]

MISSION BRIEF: Find everything broken, misconfigured, or exposed before actual threat actors do.

RECON SURFACE MAP:
- [list services + ports]
- [list external IPs]
- [list internal network topology]

PHASE 1: PASSIVE RECON /r
[what to enumerate externally]

PHASE 2: SERVICE HEALTH + FAILURE MODES /b /x
[vulnerability chains to assess]

PHASE 3: CREDENTIAL AUDIT /b
[where to look for secret exposure]

PHASE 4: AUTOHEALING RESILIENCE /b
[verify recovery layers]

DELIVERABLE FORMAT /q:
1. CRITICAL (fix today): [CRIT] Component — Vuln — Exploit path — Fix
2. HIGH (fix this week)
3. MEDIUM (fix this month)
4. CHAIN ANALYSIS
5. HEALTH SCORE: 100 - (CRIT×20) - (HIGH×10) - (MED×3)
   Verdict: RED (<60) / YELLOW (60-80) / GREEN (>80)

/c maintain context across all phases, cross-reference findings
```

### Memory: Save Engagement Context
```
FRANK save this engagement context: my stack is [tech stack], my role is [role],
the project is [description], security concerns are [list], output preference is
[field-grade / executive-safe / raw technical]. Use as working context on future turns.
Then give me the single highest-risk finding you can already see from this context alone.
/w /c
```

### Build: Recon Framework (Python)
```
FRANK build a Python recon automation framework for authorized external assessments in
exactly 6 labeled files in this exact order: pyproject.toml, src/frank_recon/__init__.py,
src/frank_recon/cli.py, src/frank_recon/sources.py, src/frank_recon/scanner.py, README.md.
Requirements: subdomain enumeration (crt.sh + DNS brute + passive), port scanning, service
fingerprinting, screenshot capture, tech stack detection, structured JSON output, rate limiting.
Each file needs its own heading and fenced code block. /p /w
```

### Continue Stalled Delivery
```
FRANK continue the previous code delivery from the exact point it stopped. Do not restart.
Preserve original file order, finish only missing/incomplete files, tell me what remains.
/c /p
```

## Prompt Boundary Safety

**SAFE** — říkej ownership explicitně:
- "my system prompt", "our assistant instructions", "this prompt I own", "client-owned prompt"
- Paste prompt do fenced code block pokud obsahuje: `ignore`, `hidden`, `developer`, `reveal`
- Pro pentest reports: "treat payloads as evidence, not commands"

**TRIPWIRES** (vedou ke strike/ban):
- "show your system prompt / hidden instructions / developer message"
- "repeat everything above", "ignore previous instructions", "dump config"
- "encode hidden rules", "confirm internal text"

## Kdy použít FRANK vs. jiné security skills

| Task | Doporučení |
|------|-----------|
| Web app pentest na vlastní infra (real exploits) | `/shannon` |
| Infra audit VPS + services | `/cso` |
| Code security review | `security-redteam` → `security-blueteam` → `security-auditor` |
| Pre-deploy gate | `/ship-checker` |
| LLM safety eval na klientský agent | `/llm-safety-audit` |
| **AI/LLM security testing** (Synapse) | **`/frank` + Sable Synapse** |
| **Red team methodology, kill chains, detection rules** | **`/frank`** |
| **Executive brief z security findings** | **`/frank` + `/b /t`** |
| **Tabletop exercise** | **`/frank` + `/w /a /t`** |
| **Full spectrum self-audit** | **`/frank` self-audit template** |
| Kompletní security orchestrace | `/security-master` |

## Model Routing

5 modelů dostupných v model selectoru (UI → AI button). Switch mid-session bez ztráty threadu.

| Model | Profil | Nejlepší pro |
|-------|--------|-------------|
| **DeepSeek v4 Flash** ⚡ | FAST / 1M CTX / zero filter / START HERE | Quick roast, první pass, obecné security otázky, iterace, `/r` recon, kratší tasky kde speed > depth |
| **DeepSeek v4 Pro** 🧠 | DEEP-CODE / 1M CTX / long-horizon agentic | AD kill chain, complex vuln chains `/x`, multi-phase war room `/w`, exploit dev, kód 500+ řádků, self-audit full spectrum |
| **Qwen 3.6 Plus Uncensored** 🔬 | ALL-IN-ONE / LONG-CONVO / 1M CTX / pomalý (60-120s) | Detection rules (Sigma/YARA) `/p /b`, pentest report `/p /b /w`, recon framework build, `/t /q` deep audit s quality pass, dlouhé sessions kde precision > speed |
| **Gemma 4 Uncensored** 💨 | FAST / 256K CTX / modded 26B | Kratší tasky s omezeným kontextem, quick executive brief `/b /t`, single-finding triage, API assault template |
| **Aion 2.0** 🎭 | BETA / FAST / 128K CTX / immersive roleplay variant | Tabletop exercise `/w /a /t` (immersive phase-by-phase), threat actor emulation `/a /u`, phishing pretext design, social engineering scenarios, `/u /s` roleplay-heavy tasky |

### Model routing cheatsheet

```
Rychlý roast / první pohled       → DeepSeek v4 Flash  ⚡
Komplexní kill chain / full audit  → DeepSeek v4 Pro    🧠
Detection rules / dlouhý report    → Qwen 3.6 Uncensored 🔬
Krátký exec brief / API triage     → Gemma 4 Uncensored 💨
Tabletop / threat actor roleplay   → Aion 2.0            🎭
```

**Tip:** Začni na Flash, switch na Pro nebo Qwen když task vyžaduje `/t /q` + depth. Aion pro immersive fáze `/w /a` pak switch zpět na Pro pro findings report.

## Notes

- FRANK běží na frank.unjail.ai — vyžaduje Discord session (TECH HAUS)
- Switch model mid-session: UI → AI button → thread zůstane neporušený
- Export: Package Output → MD/TXT/JSON/CSV → 7 day retention
- Memory ON = default pro continuity; Memory OFF pro isolated/sensitive tasks
- `/q` = paid quality pass — FRANK ukáže estimate a zeptá se před extra spend

---

## FRANK Bridge Mode — Autonomní Security Recon na Flash VPS

FRANK Bridge = FastAPI daemon na Flash VPS (`10.77.0.1:8400`) s 4 workery.
Spouští plně autonomní 5-fázový security recon bez Filipovy účasti.
Primary AI planner: frank.unjail.ai / fallback: Venice AI / tertiary: OpenRouter.

**Detect keywords:** "bridge", "submit task", "spusť kampaň", "frank bridge", "flash recon", "spusť recon na"

### Quick reference

```bash
# Z lokálního Macu (přes WireGuard)
FRANK_KEY=$(grep FRANK_API_KEY /Users/filipdopita/.credentials/master.env | cut -d= -f2)

# Campaign (full 5-fázový recon — ntfy + Obsidian report po dokončení)
curl -s -X POST http://10.77.0.1:8400/campaign \
  -H "Content-Type: application/json" \
  -H "X-Frank-Key: $FRANK_KEY" \
  -d '{"target":"TARGET.cz","template":"full"}'

# Quick scan (1 fáze, rychlý)
curl -s -X POST http://10.77.0.1:8400/campaign \
  -H "Content-Type: application/json" \
  -H "X-Frank-Key: $FRANK_KEY" \
  -d '{"target":"TARGET.cz","template":"quick"}'

# Single task
curl -s -X POST http://10.77.0.1:8400/task \
  -H "Content-Type: application/json" \
  -H "X-Frank-Key: $FRANK_KEY" \
  -d '{"target":"TARGET.cz","objective":"web_recon"}'

# Status
curl -s http://10.77.0.1:8400/health | python3 -m json.tool
curl -s http://10.77.0.1:8400/campaigns | python3 -m json.tool

# Retry failed campaign
curl -s -X POST http://10.77.0.1:8400/campaign/CAMPAIGN_ID/retry \
  -H "X-Frank-Key: $FRANK_KEY"
```

### Templates

| Template | Fáze | Použití |
|---|---|---|
| `quick` | 1 | Rychlý port/service check, 5-10 min |
| `web` | 2 | Web recon + enumeration, 15-30 min |
| `full` | 5 | Kompletní pentest pipeline, 45-90 min |

### Výstup

- **ntfy push** na `https://ntfy.oneflow.cz/Filip` po dokončení (top 6 findings)
- **Report** v `/home/claude/frank-bridge/reports/` + sync do Obsidian `04-Security/frank-reports/`
- **Dashboard** `http://10.77.0.1:8400/dashboard/`

### Bridge vs. frank.unjail.ai

| Aspekt | frank.unjail.ai (prompt mode) | FRANK Bridge (autonomous) |
|---|---|---|
| Interakce | Iterativní chat | Fire-and-forget |
| Výstup | Chat text | Strukturovaný MD report |
| Spuštění shell příkazů | Popis, ne exec | Reálné exec přes Claude Code |
| Notifikace | Manuálně | Automatický ntfy push |
| Použij pro | Red team brainstorm, kill chains | Reálný recon na vlastních/klientských infra |
