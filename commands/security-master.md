---
name: security-master
description: Unified OneFlow security orchestrator — chainuje all security tools (Shannon AI pentest + /cso infra audit + security-redteam/blueteam/auditor + security-self-audit + ship-checker) do jednoho workflow. Use when "kompletní security audit", "security 100%", "before launch security check", "klientský security service", quarterly comprehensive review. Skip pro single-dimension audity (use specific tool directly).
---

# /security-master — Unified Security Orchestrator

## Cíl

Jeden command → kompletní security pohled napříč 4 vrstvami:

1. **App layer** — Shannon AI pentest (real exploits + PoC)
2. **Infra layer** — /cso (network, services, configs, VPS hardening)
3. **Code layer** — security-redteam → security-blueteam → security-auditor (3-agent peer review)
4. **Ship gate** — ship-checker (pre-publish leak scan, broken links, missing assets)

Output: aggregate security score (A-F) + per-layer findings + prioritized action plan.

## Kdy spustit

| Trigger | Mode |
|---|---|
| Před launchem nového produktu / klienta | `full` (all 4 layers) |
| Quarterly OneFlow self-audit | `full` (auto via cron 1.1, 1.4, 1.7, 1.10) |
| Klient jako paid service | `client-deliverable` (sanitized PDF output) |
| Po incidentu | `incident-response` (focused on relevant layer) |
| Single-dimension only | **NESPOUŠTĚJ** — use specific skill (Shannon nebo /cso nebo redteam) |

## Modes

### `full` (default — comprehensive 4-layer)

```
1. App layer → Shannon scan
   ~/scripts/automation/shannon-scan.sh <url> <repo> <workspace>
   → Findings: Injection/XSS/SSRF/Auth (validated PoC)

2. Infra layer → /cso skill
   → Findings: open ports, weak SSH, exposed services, secrets in env

3. Code layer → security-redteam → security-blueteam → security-auditor
   - redteam finds vulnerabilities (no exploitation)
   - blueteam proposes fixes
   - auditor grades A-F + validates fixes

4. Ship gate → ship-checker
   → Findings: secrets in commits, broken links, accessibility, SEO basics

5. Aggregate → ~/Documents/OneFlow-Vault/04-Security/audits/master-<date>.md
```

### `client-deliverable`

Same as `full` BUT:
- Each layer report sanitized via `~/scripts/automation/shannon-sanitize.sh`
- Final unified PDF output
- OneFlow brand header
- Disclaimer + methodology section
- Ready for klientský deliverable (potential 50-300k Kč revenue)

### `incident-response`

Reactive mode. Skip layers based on incident type:
- Data breach → Shannon + /cso (skip code review until containment)
- Service down → /cso + ship-checker
- Klient flagged vuln → Shannon + redteam
- Suspect package → security-blueteam (supply-chain auditor)

### `quarterly`

Recurring auto-mode (triggered by launchd):
- Full scan all 7 OneFlow domén
- Diff vs prior quarter (regression detection)
- Aggregate trend chart in dashboard
- Auto-archive findings >90 days resolved

## Workflow (full mode)

```
INPUT: target_name (default: oneflow-main), target_url, repo_path

1. PRE-FLIGHT (verify scope + auth)
   - Target je vlastní (allow-list) nebo má autorizaci?
   - Cost-guard check (max 5 scans/day, override available)
   - Token freshness check (refresh if >12h)

2. PARALLEL DISPATCH (4 layers concurrent kde možné)
   ┌─ Layer 1: Shannon scan (long-running, BG)
   ├─ Layer 2: /cso skill (interactive)
   ├─ Layer 3: security-redteam → blueteam → auditor (sequential agents)
   └─ Layer 4: ship-checker (fast)

3. WAIT for all layers complete

4. AGGREGATE
   - Total findings: C/H/M/L per layer
   - Cross-reference: same vuln found by multiple layers? = high confidence
   - Score: A (0 H+ findings), B (1-3 H), C (4-10 H), D (1+ C), F (3+ C)

5. OUTPUT
   - Master report: ~/Documents/OneFlow-Vault/04-Security/audits/master-<target>-<date>.md
   - Sanitized client report (if --client-deliverable)
   - ntfy notification (priority based on max severity)
   - Memory entry: project_security_audit_<target>_<date>.md

6. RECOMMEND CHAIN
   - Findings exist → security-blueteam orchestrated fixes → re-scan
   - No findings → schedule next audit (typically +90 days)
```

## Score rubric

| Grade | Criteria | Action |
|---|---|---|
| A | 0 CRITICAL, 0 HIGH across all layers | Ship + monitor (re-scan +90d) |
| B | 1-3 HIGH, 0 CRITICAL | Ship + fix HIGH next sprint |
| C | 4-10 HIGH OR 1 CRITICAL | Block ship, fix this sprint |
| D | 1+ CRITICAL | Hotfix immediately, ship blocked |
| F | 3+ CRITICAL OR layer failure | Stop everything, full incident response |

## Per-layer responsibilities

### Layer 1: Shannon (App)

- **Tool**: Shannon AI pentester (`~/scripts/automation/shannon-scan.sh`)
- **Coverage**: OWASP Top 10 (Injection, XSS, SSRF, Broken Auth/Authz)
- **Validation**: Real PoC exploits — only validated findings reported
- **Time**: 5-60 min per target
- **Output**: `~/Documents/OneFlow-Vault/04-Security/shannon-scans/<workspace>.md`

### Layer 2: /cso (Infra)

- **Tool**: `/cso` skill (Chief Security Officer mode)
- **Coverage**: VPS hardening, SSH, firewall, services exposure, secrets in env, SSL/TLS, DNS
- **Output**: Live console output + memory entry
- **Time**: 5-15 min interactive

### Layer 3: Code Review (Static)

- **Tools**: `security-redteam` agent → `security-blueteam` agent → `security-auditor` agent
- **Coverage**: SAST (no exploits), secret scanning, dependency vulns, insecure defaults
- **Output**: 3 markdown reports (red, blue, audit verdict A-F)
- **Time**: 15-45 min per layer

### Layer 4: Ship Gate

- **Tool**: `ship-checker` skill
- **Coverage**: secrets in git, broken links, missing OG/favicon, a11y blockers, basic SEO
- **Output**: Pass/fail console output
- **Time**: 1-5 min

## Auto-chains

Filip's existing wiring respects existing tool boundaries. /security-master orchestrates ABOVE existing tools — doesn't replace.

| Trigger phrase | Auto-action |
|---|---|
| "kompletní security audit X" | `/security-master full --target X` |
| "security 100%" | `/security-master full` |
| "klientský security audit" | `/security-master client-deliverable --client X` |
| "po incidentu" | `/security-master incident-response` |
| "quarterly review" | `/security-master quarterly` (also auto via cron) |

## Anti-patterns (NEVER)

- Spustit /security-master pro single-dimension task (use specific skill)
- Spustit /security-master bez authorization na klientský target
- Aggregate report bez sanitizace pro klient deliverable
- Skip Layer 4 (ship gate) — vždy levný + catches edge cases

## Output format (master report)

```markdown
# Security Master Audit — <target> — <date>

## Verdict: <A-F>

## Layers

### App layer (Shannon) — <verdict>
- <C> CRITICAL, <H> HIGH, <M> MEDIUM, <L> LOW
- Top 3 findings (with PoC links)
- Full report: <path>

### Infra layer (/cso) — <verdict>
- Findings (services exposed, weak configs, etc.)
- Recommendations

### Code layer (red→blue→audit) — <verdict>
- redteam findings: <count>
- blueteam fixes: <count proposed>
- auditor grade: <A-F>

### Ship gate — <PASS|FAIL>
- Issues caught at gate

## Cross-reference

Findings co confirmed víc layers (high confidence):
- <finding>: Shannon + redteam confirmed (highest priority)

## Action plan (prioritized)

1. <CRITICAL item> — owner, deadline
2. ...

## Re-audit schedule

Next: <date> (90 days)
```

## Resources

- Shannon: `~/.claude/skills/shannon/SKILL.md`
- Shannon agent: `~/.claude/agents/shannon-pentester.md`
- /cso skill: `~/.claude/skills/cso/`
- security-* agents: `~/.claude/agents/security-{redteam,blueteam,auditor}.md`
- ship-checker: `~/.claude/agents/ship-checker.md`
- Sanitizer: `~/scripts/automation/shannon-sanitize.sh`
- Quarterly cron: `~/scripts/automation/shannon-quarterly-audit.sh`
- Dashboard: `~/Documents/OneFlow-Vault/04-Security/shannon-scans/_DASHBOARD.md`

## Related skills

- `/cso` — infra-only deep dive
- `/shannon` — app-only deep dive
- `/security-self-audit` — Filipova VPS-specific defensive audit
- `from-lukas:security-scan` — 3-agent red-team pipeline (subset of Layer 3)
- `gsd-secure-phase` — retroactive threat mitigation verify (per-phase)
- `oneflow-diagnose` — pre-build product diagnostic (gate before /security-master)
