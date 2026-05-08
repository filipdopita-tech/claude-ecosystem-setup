# Phase 3 — DEPLOY YOUR AGENT WITHOUT CHAOS

## Source prompt (Filipova originální verze)

```xml
<role>Act as an AI agent deployment specialist who knows that the gap between a working agent and a deployed agent is where most builders lose clients, miss deadlines, and destroy their reputation — and has a system that closes that gap every single time.</role>

<task>Deploy my agent to a real client environment without chaos, credential disasters, broken integrations, or last-minute failures that destroy the relationship before it starts.</task>

<steps>
1. Ask for my agent's current build status, the client's tech stack, and the deployment environment before starting
2. Build the pre-deployment checklist — every credential, permission, and integration verified before go-live
3. Design the deployment sequence — the exact order of steps that prevents conflicts and rollback nightmares
4. Create the client handoff document — what the agent does, what it doesn't do, and who to call when something breaks
5. Build the post-deployment monitoring plan — the signals that tell me the agent is working or silently failing
</steps>

<rules>
- Every credential and permission verified before deployment — never discover access issues live
- Deployment sequence must be ordered — never deploy components simultaneously without testing each first
- Client handoff document must be written for a non-technical reader — no jargon
- Monitoring plan must be automated where possible — never rely on the client to notice failures
- Test: if I got on a flight the moment this agent deployed would it still be running when I landed
</rules>

<output>Pre-Deployment Checklist → Deployment Sequence → Client Handoff Document → Post-Deployment Monitoring Plan → Chaos-Free Go-Live</output>
```

## CZ adaptation

### Krok 1 — Build & Environment Check

Načti `02-build.md` (PASS Phase 2). Ověř:
- Test protocol PASS (3 vrstvy)
- Code freezed na konkrétním commit
- Dependencies pinned (`requirements.txt --version`, `package-lock.json`)

Načti **klientovo prostředí** (vyžaduj od klienta):
- Hosting / infra (vlastní server, AWS, Vercel, n8n.cloud, ...)
- Datové zdroje (API keys, DB credentials, OAuth scopes)
- Integrace (CRM, email, Slack, ...)
- Compliance (GDPR DPA podepsaná, AML pokud finanční data)

### Krok 2 — Pre-Deployment Checklist (NUTNÉ před go-live)

```markdown
## Credentials
- [ ] Klient API keys přiděleny (per agent service: GHL, Apollo, ARES, ...)
- [ ] Keys nastaveny v secrets manager (NEVER hardcoded — viz security-hardening.md)
- [ ] Test ping každého API z target prostředí (firewall, IP whitelist)
- [ ] Token expiry datum > 90 dní (jinak rotation plan)

## Permissions
- [ ] OAuth scopes minimální (no wildcards)
- [ ] Service account isolovaný (vlastní user/role, ne admin)
- [ ] Database SELECT/INSERT/UPDATE jen na potřebných tabulkách
- [ ] File permissions chmod 600 pro creds, 644 pro code

## Integrations
- [ ] Webhook URLs registrovány a unit-testované
- [ ] Rate limit dohodnut s upstream provider (alespoň 2× expected peak)
- [ ] Fallback queue (RabbitMQ / SQS / Redis) pokud stream-based agent
- [ ] Backup endpoint pokud klient má 2 prostředí (staging vs prod)

## Compliance
- [ ] GDPR — DPA podepsaná, retention policy dokumentovaná
- [ ] Logging — žádná osobní data v plain text
- [ ] AML / finanční data — encrypted at rest, audit trail

## Infra
- [ ] Resources dostatečné (RAM, CPU, disk) — verify on actual instance
- [ ] systemd unit (Linux) nebo launchd (Mac) připravená
- [ ] Restart policy: Restart=always, RestartSec=10
- [ ] Logs rotation (logrotate, max 30 dní default)

## Testing
- [ ] Smoke test na real prostředí (1 happy path)
- [ ] Load test (10× expected concurrent)
- [ ] Chaos test (kill external API, verify fallback)
```

**Iron rule:** Pokud byť 1 box neoznačen → DON'T DEPLOY. Filip vidí "0 chyb v deployment" jako reputaci, klient vidí stejně.

### Krok 3 — Deployment Sequence (sekvence, ne parallel)

Pořadí matters. Pokud děláš parallel, něco se odpálí:

```
1. Setup secrets manager (env file, chmod 600)
2. Deploy code (git pull / docker pull) — služba ještě NESPUŠTĚNA
3. Run migrations (DB schema, jen pokud potřeba)
4. Smoke test 1× ručně (CLI nebo curl)
5. Start service (systemctl start)
6. Verify logs žádné errory v prvních 60s
7. Health endpoint check (curl /health)
8. Load test 10 instancí
9. Setup monitoring (ntfy + monit + Sentry pokud klient)
10. Verify alerty fungují (trigger fake error, ověř notif)
11. Document version + rollback plan
12. Notify klienta "agent live"
```

**Žádný shortcut.** Každý krok = explicit checkmark.

### Krok 4 — Client Handoff Document (non-technical)

Filip dá klientovi soubor `handoff.md` (CZ, no jargon):

```markdown
# {Agent Name} — Příručka pro Vás

## Co agent dělá
[V 3 větách, bez technologie. Příklad: "Každé ráno kontroluje nové leady ve Vašem GHL,
obohatí je o data z ARES a Hunter.io a založí kontakt s tagem 'enriched-2026'."]

## Co agent NEdělá (a proč)
- [Specifický limit 1, např. "Neposílá emaily — to děláte Vy přes GHL workflow."]
- [Specifický limit 2]
- [Specifický limit 3]

## Když něco nefunguje
1. **Krátký výpadek (do 5 min)** — agent se sám restartuje, nic neděláte.
2. **Delší výpadek** — automaticky dostanete email/SMS na: {kontakt}
3. **Nečekaný výsledek** — kontaktujte mě: <email> nebo +420 XXX

## Bezpečnost
- Vaše data jsou na {hosting} (CZ/EU servery)
- Přístup k API klíčům: jen Filip + auditní log
- Smazání dat: na žádost do 30 dní (GDPR)

## Měsíční report
[Filip pošle PDF s metrikami: počet zpracovaných instancí, accuracy, downtime]
```

**Iron rule:** Klient nemá vědět co je LLM, prompt, vector DB, embedding. Jen co dělá, co nedělá, koho volat.

### Krok 5 — Post-Deployment Monitoring Plan

Automated signály (Filip dostane notifikaci):

| Signal | Source | Threshold | Action |
|---|---|---|---|
| Service down | systemctl status | 60s | ntfy red + auto-restart |
| Error rate spike | logs (grep ERROR) | >5% in 5min | ntfy yellow + investigation |
| API rate-limit hit | logs (grep 429) | 3× v 1 hod | ntfy yellow + backoff verify |
| Cost overrun | billing API | >150% expected daily | ntfy red + halt + email Filip |
| Stale agent (no activity) | last_run timestamp | >2× expected interval | ntfy yellow |
| Output quality drift | sample audit | accuracy < threshold | ntfy red + retrain plan |

**Setup:** Conductor + monit na Flash. Žádné "klient ať si všimne" — vše proactive.

**Test:** Trigger fake failure (kill -9 process) → verify ntfy alert přišel do 60s.

## Výstupní formát

`~/Documents/oneflow-agents/{client_slug}/03-deploy.md`:

```markdown
# Agent Deploy: {Client Name} — {Agent Name}

**Date:** YYYY-MM-DD
**Status:** LIVE → Phase 3 PASS → Phase 4 PRICING

## 1. Build & Environment
[Phase 2 status, klient prostředí]

## 2. Pre-Deployment Checklist
[Tabulka 5 sekcí, all checked]

## 3. Deployment Sequence Execution
[12 kroků s timestamps + outcomes]

## 4. Client Handoff Document
[Link na handoff.md, klient potvrdil receipt]

## 5. Monitoring Plan
[Tabulka 6 signals, all configured + tested]

## Hand-off Test
[Yes/No: If I got on a flight, would it still run when I landed?]
```

## Auto-chain do Phase 4

Po LIVE + 24h stabilita → `/agent-business-lifecycle price {client_slug}`.
