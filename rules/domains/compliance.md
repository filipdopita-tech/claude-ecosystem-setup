# Domain Rules: Compliance / CNB / AML / GDPR
# CARL — aktivuj POUZE při compliance, regulační, právní, AML/GDPR taskech

## Czech Regulatory Framework (klíčové limity)

### Dluhopisy (Zákon č. 190/2004 Sb.)
- Emise do 1M EUR → výjimka z prospektové povinnosti
- Emise 1M–5M EUR → zjednodušený dokument
- Emise >5M EUR → plný prospekt (ČNB schválení)
- Max 149 investorů (neprofesionálních) bez prospektu
- ECSP (Regulation EU 2020/1503) → platí od 10.11.2023

### AML (Zákon č. 253/2008 Sb.)
- [YOUR_COMPANY] jako povinná osoba: KYC pro investory
- Limity hotovostních transakcí: >10 000 EUR → obligatorní hlášení
- PEP (Politically Exposed Person) screening: VŽDY
- Uchovávání záznamů: 10 let (append-only, viz security-hardening.md)
- UBO registr: ověření skutečného majitele

### GDPR (Nařízení EU 2016/679)
- Právní základ zpracování: souhlas NEBO oprávněný zájem
- Výmaz dat: max 30 dní od žádosti investora
- Data portabilita: strojově čitelný formát
- Porušení zabezpečení: ČNB + ÚOOÚ do 72 hodin
- DPO: pokud zpracováváš >5000 subjektů systematicky

## Povinné Framing při Compliance Taskech

Při jakémkoli výstupu s právním/regulačním dopadem:
```
⚠️ Informace jsou orientační. Pro závazné stanovisko doporučuji konzultaci s
regulačním právníkem (ECSP/AML specialist) nebo přímo ČNB.
```

Nikdy neprezentuj jako finální právní radu — pouze jako orientaci.

## Red Lines (HALT + eskaluj [YOUR_NAME])

- Transakce přes neregistrovaný subjekt >200 000 Kč
- Investor s PEP statusem bez enhanced due diligence
- Chybějící UBO dokumentace pro emitenta
- Žádost o zpracování dat bez právního základu
- Jakýkoli zájem ze zemí na EU sanction listu

## Dokumentační Standard

- AML záznamy: append-only, timestampované, 10 let retence
- KYC dokumenty: šifrované úložiště, přístup omezený
- Emise dokumenty: verze + datum + schválení ([YOUR_NAME]Sign nebo notář)

## Kontextová reference

Viz `~/.claude/expertise/czech-regulatory.yaml` pro kompletní zákonné texty + formuláře.
