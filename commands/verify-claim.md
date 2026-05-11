---
name: verify-claim
description: "Ověří faktuální claims před shippingem. Kombinuje Step-Back (abstract principle → concrete answer) a Chain-of-Verification (CoVe). Aktivuj když: finanční/právní rozhodnutí, DD výstup, tvrzení o infrastruktuře, emitent/investor data, citace zákonů/regulací, nebo kdykoli je cena chyby vysoká. Výstup: REVISED answer + confidence + identified errors."
allowed-tools:
  - Read
  - Grep
  - Glob
  - WebFetch
  - WebSearch
---

# /verify-claim

Pro momenty kdy první odpověď vypadá dobře, ale cena chyby je vysoká. Step-Back + CoVe = -20-30% halucinace.

## Kdy použít

- DD report (čísla, CNB status, ISIR, UBO)
- Claim o zákoně/regulaci (CNB, AML, GDPR, ECSP limity)
- Infrastructure claim ("služba X běží na Y", "port Z je otevřený")
- Cold email claim (deliverability status, blocklist, doménové zdraví)
- Emitent/investor fakta před komunikací
- Kdykoli řekneš "myslím že" místo "vím že"

## NEPOUŽÍVAT pro

- Triviální ops (grep, read, ls)
- Subjektivní volby (tone, styl, preference)
- Rychlé brainstormy kde je explorace hodnota

## POSTUP

### KROK 1: Step-Back — najdi obecný princip

Místo odpovědi rovnou na konkrétní otázku, zeptej se:

> "Jaký je obecný princip, zákon, nebo koncept za touto otázkou?"

Příklad:
- Otázka: "Musí emitent XYZ mít prospekt schválený ČNB?"
- Step-back: "Jaké jsou prahy pro prospektovou povinnost v zákoně 190/2004?"
- Abstraktní princip: "Do 1M EUR výjimka, 1-5M zjednodušený doc, >5M plný prospekt (+ max 149 neprofesionálních investorů bez prospektu)"
- Teprve pak aplikuj na XYZ: "XYZ emituje 3M EUR → zjednodušený dokument nutný"

**Proč:** Bez kroku back dělá model pattern matching na povrchu otázky. Se step-back nejdřív ukotvil obecný rámec, pak aplikuje.

### KROK 2: CoVe — Chain-of-Verification

Po vygenerování odpovědi (nebo draftu DD, emailu, tvrzení):

**2a. Extract claims:** Vypiš 3-7 konkrétních faktuálních tvrzení z odpovědi.

```
Claim 1: "ČNB registrace emitenta je platná"
Claim 2: "DSCR 1.45 vypočteno z Q4 2025 CF"
Claim 3: "LTV 62% dle znaleckého posudku ze 2025-09"
```

**2b. Generate verification questions:** Pro každý claim vytvoř 1-2 otázky co by claim vyvrátily:

```
Claim 1 → Q: Je v ISIR insolvenční řízení proti tomuto IČO?
Claim 1 → Q: Je v CNB seznamu sankcionovaných subjektů?
Claim 2 → Q: Je CF z auditovaných výkazů nebo z plánů?
Claim 2 → Q: Je splátkový kalendář v DSCR zohledněn?
Claim 3 → Q: Je znalecký posudek starší 12 měsíců?
```

**2c. Answer each question independently:** Nečti původní odpověď. Odpovídej čerstvě, jen z dat.

```
Q: Je v ISIR insolvence? → isir.justice.cz check → negativní
Q: Je CF auditovaný? → dokument "ucetni_zaverka_2025_audit.pdf" → ANO
Q: Posudek starší 12 měsíců? → datum 2025-09 → ne, 7 měsíců
```

**2d. Find inconsistencies:** Porovnej odpovědi s původními claims.

Pokud mismatch → původní claim byl špatně.

**2e. Revised output:** Vygeneruj opravenou verzi s explicitní confidence na každý claim.

### KROK 3: Output formát

```markdown
## ORIGINAL OUTPUT
[původní odpověď]

## EXTRACTED CLAIMS
- C1: [claim] — confidence pre-verification: [High/Med/Low]
- C2: ...

## VERIFICATION QUESTIONS + ANSWERS
- C1 Q1: [otázka] → [nezávislá odpověď z dat]
- C1 Q2: ...

## INCONSISTENCIES
- [claim X] byl špatně → správně: [Y]
- NEBO: "Žádné inconsistencies, všechny claims ověřeny"

## REVISED OUTPUT
[opravená verze s inline confidence markers]

## CONFIDENCE SUMMARY
- High (ověřeno z primárního zdroje): [claims]
- Medium (odvozeno, pravděpodobné): [claims]
- Low (nejisté, flaguj uživateli): [claims]
```

## Příklady

### Příklad 1: DD claim
```
Původní: "Emitent Patricny má DSCR 1.8, silný."

Step-back: Co je benchmark pro DSCR? → <1.2 riziko, 1.2-1.5 OK, >1.5 silný.

CoVe:
- C1: DSCR 1.8 → Q: z jakých CF? z auditovaného výkazu nebo plánů?
  A: z plánů 2026 → NE auditovaných.
- C1 revised: "DSCR 1.8 (z plánů, nikoli auditovaných výkazů) → Medium confidence. Skutečný DSCR může být nižší."
```

### Příklad 2: Infra claim
```
Původní: "Port 2586 ntfy běží na Flash."

Step-back: Ntfy default port? 80/443 public, 2586 custom → platná konfig.

CoVe:
- C1: "Port 2586 ntfy běží" → Q: `ss -tlnp | grep 2586` na Flash?
  A: SSH check → LISTEN na 2586 yes.
- C1 confirmed: High confidence.
```

## Integrace s ostatními skills

- **/deset:** po /verify-claim spusť /deset pro quality gap check
- **/mythos:** CoVe je interní při Bayesian update, /verify-claim je levnější alternativa
- **/redteam:** /verify-claim najde faktické chyby, /redteam najde strategické slabiny
- **dd-emitent:** spusť /verify-claim před finální prezentací DD

## Reference

- Step-Back Prompting: arxiv.org/abs/2310.06117 (Google DeepMind 2023)
- Chain-of-Verification: arxiv.org/abs/2309.11495 (Meta 2023)
- Kombinace: -20-30% hallucination reduction na factual tasks
