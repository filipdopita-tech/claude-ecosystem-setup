# Domain Rules: Responsible Disclosure (cyber research)
# CARL — aktivuj při security findings na external / third-party / non-self-owned systém

Extracted from Mythos SKILL.md v1 během v2 refactoru 2026-04-17. Aplikovat pouze pro real cyber research mimo autorizované testing (self-owned systémy, pentest s kontraktem, CTF = framework neaplikovat).

---

## Disclosure Framework (Glasswing-inspired, 90-day coordinated)

### PATCHED VULNERABILITY
- Full technical disclosure povolena
- Format: CVE-style (ID, affected versions, impact, PoC, fix reference)
- Timing: po fix deployment + user notification window

### UNPATCHED VULNERABILITY
- Cryptographic hash findings (SHA-256 of vulnerability description)
- Embargo až do fix deployment
- Coordinated disclosure: report → vendor → 90 days → public (nebo kratší dle dohody)
- Contact: security@ address, HackerOne, vendor bug bounty platform

### OUT-OF-SCOPE FINDING
- Dokumentuj, NEPUBLIKUJ
- Eskaluj k uživateli: "Nalezeno ve scope, ale patří jinam. Publikovat?"
- User rozhodne disclosure path

---

## Legal Red Lines (immediate STOP + user ask)

□ Testing systému bez autorizace (mimo vlastní / pentest scope / bug bounty program)
□ Pwn mimo staging / test environment
□ Leak PII / credentials v output nebo finding text
□ Weaponized exploit s real-world target
□ Testing proti produkčnímu systému bez write permission

---

## Decision Tree (aplikace)

```
Finding na self-owned systém?
  ANO → disclosure framework NEPLATÍ (interní, [YOUR_NAME] rozhodne)
  NE  ↓

Finding na authorized pentest / bug bounty scope?
  ANO → disclosure per contract / program terms
  NE  ↓

Finding během research na public OSS / third-party?
  → aktivovat tento framework (patched / unpatched hash / out-of-scope)

Finding na third-party production bez autorizace?
  → STOP. Legal red line. User ask before any action.
```

---

## Mythos scaffold kontext

Tento framework byl součástí Mythos SKILL.md v1 (řádky 780-807). V v2 refactoru extrahován jako doménová rule, aby:
1. Nezatěžoval každý Mythos invocation (90% [YOUR_COMPANY] use cases = interní systémy)
2. Byl loadable on-demand pro reálný cyber research
3. Byl dohledatelný mimo Mythos context (CARL knowledge routing)

Aktivace v Mythos:
- Security variant produkuje finding s `**Disclosure:**` field
- Hodnoty: `Patched / Unpatched+hash / Out-of-scope / Authorized-pentest / N/A (self-owned)`
- Pokud finding je na external system → načíst tento soubor pro disclosure path guidance
