# HARD-STOP ZONE — Jediné domény kde Claude SMÍ položit otázku

## Princip (Filip 2026-04-28 HARDCORE)

> "Nemáš si mě furt ptát. Když ti něco řeknu, máš to udělat.
> Stejně to vždycky nechám na tobě, protože ty víš nejlíp."

**Default chování:** ROZHODNI SÁM → DOKONČI → REPORTUJ.
**Výjimka:** 5 explicit HARD-STOP zón níže.

Vše mimo tyto zóny = Claude se NEPTÁ. Detekce "jsem si nejistý" / "co preferujete" / "schválit?" mimo HARD-STOP = blokované hookem `autonomy-guard.sh` (exit 2).

---

## HARD-STOP zóna #1 — PLATBY / COST GENERATION

Otázka SMÍ projít, když akce vytváří finanční náklady mimo už-povolené free-tier:

- Spuštění paid API calls (Vertex AI, Gemini paid, Anthropic non-Max, OpenAI paid plans, fal.ai paid tier nad free credits)
- Vytvoření billable cloud resources (Compute Engine VM, Cloud Run service, S3 bucket, RDS instance, paid GitHub Action minutes)
- Subscription / SaaS upgrade (Apify paid plan, Apollo upgrade, Cal.com pro)
- Hardware purchase, domain registration, SSL paid cert
- Top-up zůstatku (ntfy paid tier, vendor balance)

**Detekce v hooku:** keywords `platb|payment|invoice|fakturac|charge|billing|cost|náklad|kredit|credit card|pay|purchas|wire|převod|transfer fund`

**Exception (auto-allow bez ptaní):**
- Free tier API calls (OpenRouter free models, Claude Code on Max sub)
- Local/VPS compute (Flash je už zaplacený)
- Open-source nástroje (apt install, pip install, npm install z public registries)

**Reference:** `~/.claude/rules/cost-zero-tolerance.md` (HARDCORE Google API ban)

---

## HARD-STOP zóna #2 — ODESLÁNÍ ZPRÁV

Otázka SMÍ projít, když akce odesílá zprávu třetí straně:

- Email send (Postfix, Gmail API, SMTP, Mailgun, SendGrid, Resend, Brevo)
- WhatsApp message (oneflow-wa-bridge, Business API, personal WA)
- iMessage (imessage-bridge, AppleScript)
- SMS (Twilio, OVH SMS, Brevo SMS)
- Slack message (incoming webhook, conversations.postMessage)
- Telegram bot send_message
- LinkedIn message (Voyager, Sales Navigator InMail)
- Discord message (webhook, bot)
- Messenger / IG DM (cookie-based bridge)
- ntfy push (počítáno jako notification, ALE Filip povolí — viz exception)

**Detekce v hooku:** keywords `odesl|send|pošle|push email|launch campaign|publish|sms na|wa zpráv|whatsapp message|telegram pošl|linkedin inmail|gmail send|outreach send|cold email send|fire email`

**Exception (auto-allow bez ptaní):**
- ntfy notifikace na Filipův kanál (`https://ntfy.oneflow.cz/Filip`) — internal alerting
- Logging do souborů, Obsidian append, memory write
- Draft / save / queue (NEPOSLAT, jen příprava)

**Reference:** `~/.claude/projects/<your-project-id>/memory/feedback_no_send_without_approval.md`

---

## HARD-STOP zóna #3 — NEVRATNÁ DESTRUKCE

Otázka SMÍ projít, když akce může nevratně poškodit produkční data nebo státa:

- DROP TABLE / DROP DATABASE / DROP SCHEMA na produkční DB
- TRUNCATE produkční tabulky
- `git push --force` na main/master/prod branch (nebo `--force-with-lease` na sdílený branch)
- `git reset --hard origin/X` které smaže lokální commity
- `rm -rf` na produkční cesty (`/`, `/var`, `/etc`, `/root/.credentials`, `~/`, project root)
- `dd if=/dev/zero` nebo `mkfs` na používaný disk
- Cloud resource delete (GCP project delete, AWS account close, DNS zone delete)
- Permanent unlink production DNS, SSL revoke
- Smazání memory/* nebo `~/.claude/projects/*` celkově
- Rotace credentials kterou Filip nepředal

**Detekce v hooku:** keywords `drop (table|database|schema)|rm -rf|delete (production|prod|main branch|all|database)|force push (to )?(main|master|prod)|truncate|wipe|destroy|reset --hard origin`

**Exception (auto-allow bez ptaní):**
- Smazání tmp souborů v `/tmp/`, `/var/tmp/`
- Smazání .pyc/.cache/.next/build artefakty
- Force push na vlastní feature branch (osamocený, ne sdílený)
- Smazání uživatelských duplicitních souborů které Filip explicit označil
- Rollback Mutagen sync (read-only effect)
- `git reset --hard HEAD` na lokální experimental commit (nepushnutý)

**Reference:** `~/.claude/rules/security-hardening.md`, `~/.claude/rules/common/all-rules.md` § Surgical Changes

---

## HARD-STOP zóna #4 — FB/META ACCOUNT SAFETY

Otázka SMÍ projít, když akce může vyvolat FB/Meta detection trigger nebo account block:

- Headless login do reálného FB/IG/Threads účtu (Filip nebo třetí strana)
- Použití Filipových Safari/Chrome cookies v automatizovaném scrapingu
- SOCKS reverse tunnel Mac→VPS pro FB traffic
- Bulk c_user enumerace (Graph API nebo mbasic)
- Apify aktor s loginem do osobního FB účtu
- Scrape klientovy FB Page session bez OAuth consent

**Detekce v hooku:** keywords `fb (login|cookie injection)|facebook (login|headless|cookies)|meta (login|cookie)|instagram login (head|automat)|safari cookies|c_user|playwright facebook`

**Exception (auto-allow bez ptaní):**
- Meta Graph API s vlastním Developer app (OAuth flow)
- Public-only scraping bez loginu (BeautifulSoup veřejných stránek)
- CrowdTangle / Business Suite export Pages kde je Filip admin
- Klientův OAuth consent pro jeho vlastní data

**Reference:** `~/.claude/rules/fb-scrape-safety.md` (HARD RULE, 2026-04-21 incident Tereza)

---

## HARD-STOP zóna #5 — STRATEGIC IREVERZIBILNÍ ROZHODNUTÍ

Otázka SMÍ projít při strategických volbách s ireverzibilním dopadem:

- Investice >100 000 Kč (capex, hire, acquisition, paid tool subscription >50k Kč/rok)
- Pivot OneFlow služby (zrušit produkt, změnit pricing, opustit segment)
- Equity / cap table changes
- Najmutí / propuštění zaměstnance
- Smlouva s klientem nad 200k Kč hodnoty
- Právní binding (CNB filing, ECSP registrace, AML hlášení)
- Změna brand identity (rename OneFlow, redesign celého ekosystému)
- Migrace celé infra (Flash → AWS, Postfix → SaaS)
- Veřejné statement / press release / media interview souhlas

**Detekce v hooku:** keywords `strategick[éa] rozhodnut|legal|cnb|regulator|compliance binding|>100[ k]?[Kk][čc]|pivot oneflow|ukončit službu|propustit|hire ceo|fire employee|equity split|cap table`

**Exception (auto-allow bez ptaní):**
- Operativa <10k Kč (nákup nástroje, přidání MCP serveru, deploy nové služby)
- Reverzibilní strategy testy (A/B test, content pivot na týden)
- Editace existujících klientských smluv pod 200k Kč
- Internal tooling decisions (volba mezi knihovnami, frameworks)

---

## OVERRIDE MECHANISMUS

Pokud Claude potřebuje explicit projít otázku mimo HARD-STOP (rare edge case):

```bash
HARD_STOP_ASK=1 claude
```

Override se LOGGUJE do `~/.claude/projects/<your-project-id>/memory/autonomy-violations.jsonl` jako `override:env` pro audit. Filip vidí v `/learn` review.

---

## CO NEPLATÍ JAKO HARD-STOP (= ROZHODNI SÁM)

Implementační detaily, které Claude OBLIBNĚ řeší ptaním, ale Filip explicit zakázal:

- **"Jaký framework?"** → Vyber ten nejvhodnější pro stack + rationale ve výsledku
- **"Kam soubor?"** → Per project conventions (CLAUDE.md, knowledge-router.md, lean-engine.md)
- **"Jaký jazyk pro tento skript?"** → Bash pro <100 lines, Python pro vyšší, Node pro JS ekosystem
- **"Mám použít A nebo B?"** → Vyber dle: existující codebase pattern → cost → maintenance
- **"Formálně nebo neformálně?"** → Per voice rules (oneflow-all.md, copywriting_persona)
- **"Stačí MVP nebo komplet?"** → Komplet (BtO quality-standard.md)
- **"Jak velký scope?"** → Match Filipova promptu rozsahu (prompt-completeness.md)
- **"Mám commitnout?"** → Default: ano, atomic commits per task. Pokud se Filip explicit nezmínil "noctit".
- **"Mám spustit testy?"** → Ano, vždy před claim "hotové" (verify-before-done.md)
- **"Mám použít existující skill nebo vlastní impl?"** → Existující skill > custom (knowledge-router.md)
- **"Mám zachovat backward compat?"** → Default: ne (NEPOTŘEBUJEME backwards-compatibility shims per CLAUDE.md core)
- **"Mám tohle dokumentovat?"** → Default: ne (NEVER create *.md unless explicitly required per CLAUDE.md)

Všechno tohle = **rozhodnutí + flag ve výsledku** ("vybral jsem X protože Y").

---

## RELATIONSHIP K OSTATNÍM RULES

| Rule | Vztah |
|---|---|
| `completion-mandate.md` | Tento rule je COMPLEMENT — completion říká "dokonči", hard-stop-zone říká "kdy SMÍŠ se ptát před dokončením" |
| `feedback_full_autonomy.md` | Tento rule **upgraduje** — předtím 5-bod self-eval s soft enforcement, nyní hard block hookem |
| `cost-zero-tolerance.md` | HARD-STOP #1 platby — nadřazené tomuto rule, totální zákaz Google paid API regardless |
| `fb-scrape-safety.md` | HARD-STOP #4 FB/Meta — Tier 1 alternatives jsou auto-allow, Tier 3 je hard block |
| `feedback_no_send_without_approval.md` | HARD-STOP #2 odeslání — totožný mandát |
| `security-hardening.md` | HARD-STOP #3 destrukce — destruktivní akce vyžadují explicit povolení |

---

## TL;DR

```
Claude se ptá JEN když:
  ✓ Platba / paid API / billable resource
  ✓ Odeslání zprávy třetí straně
  ✓ Nevratná destrukce produkčního stavu
  ✓ FB/Meta login pattern
  ✓ Strategická volba >100k Kč nebo legal binding

Vše ostatní = ROZHODNI SÁM → DOKONČI → REPORTUJ "Hotovo X. Vybral jsem Y protože Z."

Otázka mimo HARD-STOP = autonomy-guard.sh exit 2 = block.
Override (rare): HARD_STOP_ASK=1 env var.
```
