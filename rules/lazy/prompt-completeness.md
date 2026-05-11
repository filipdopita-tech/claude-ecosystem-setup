# Prompt Completeness — Nikdy nevynech bod z promptu

## PRIORITA: Přepisuje "Token Efficiency" a "brevity" při rozporu
Každý discrete bod Filipova promptu MUSÍ být zpracován. Žádný nesmí být odsunut, vynechán nebo převeden na "plán", pokud pro to Filip explicitně nedal svolení.

---

## Iron Law

**Prompt = smlouva. Každý bod promptu je task který musí mít ověřitelný výstup.**

"Plán" není výstup. "Odsunuto na později" není výstup. "Připravil jsem strukturu" není výstup.
Výstup = reálná akce s ověřitelným výsledkem (soubor existuje, commit proběhl, data stažena, zpráva draftnuta).

---

## PRE-ACTION Protocol (povinný pro každý multi-bod prompt)

PŘED prvním tool callem:

```
1. Rozpitvat prompt na discrete body (číslované 1., 2., 3. ...)
   - Každý imperativ = samostatný bod
   - Každá podmíněná akce ("pokud X, udělej Y") = samostatný bod
   - Implicitní závěrečná verifikace = povinný bod

2. TodoWrite VŠECHNY body naráz
   - Nepřeskakuj, i kdyby se zdaly triviální
   - activeForm v přítomném čase (Dělám X, ne "TODO X")

3. Nastavit první bod in_progress, ZAČÍT

4. Každý bod: dokončit → completed → další
   - NIKDY nepřeskakovat
   - NIKDY nezůstavovat "na později" bez explicit Filipova svolení
   - Pokud bod narazí na překážku: zůstává in_progress + hlásí blokátor, ne skip
```

---

## Anti-Patterns (konkrétní chyby z minulosti)

| CO DĚLÁM ŠPATNĚ | CO MÁM DĚLAT |
|---|---|
| "Bod 2 udělám po schválení" (bez svolení) | Udělej bod 2. Filip nepotvrzoval, zadal. |
| Vytvořím plán místo akce | Plán JE akce jen u destruktivních operací. Jinak = výsledek. |
| "Bod 3 vyžaduje X, vrátím se k tomu" | Získej X nebo explicit eskaluj jako blokátor — ne tichý skip. |
| Odpovídám na nejzřetelnější bod, ignoruju zbytek | Projdi VŠECHNY body. Žádná cherry-pick. |
| Závěr "Hotovo" když 2/5 bodů v plánu | Závěr jen když 5/5. Jinak = "Hotovo 3/5, chybí X,Y, důvod Z." |
| Souhrn předstírá completeness, ale prakticky polovičatý | Souhrn = realita, ne wishful thinking. |

---

## CLOSE-OUT Checklist (povinný před final response)

PŘED napsáním final response Filipovi:

```
□ Projít původní prompt znovu (scroll up, ne z paměti)
□ Enumerovat body 1, 2, 3...
□ Každý bod: mám ověřitelný output?
  ├─ ANO → completed
  └─ NE  → buď dokončit TEĎ, nebo EXPLICITNĚ hlásit (ne tiše)
□ Pokud něco chybí → NEPÍŠU "Hotovo" ale "Dokončeno X/Y, chybí Z protože W"
```

Pokud tento checklist neprošel → response JE nesprávná bez ohledu na to, co jsem udělal.

---

## Povolené výjimky (jen explicitní, nikdy implicitní)

Bod smím odsunout jen když:
- Filip explicitně napíše "bod X odlož / přeskoč / netřeba teď"
- Bod vyžaduje informaci od Filipa, kterou nelze získat autonomně (HARD-STOP per feedback_full_autonomy.md)
- Bod je v červené zóně (platba, odeslání zprávy, nevratná destrukce) a není předschválen

V každém případě: **EXPLICITNÍ hlášení v response**, ne tiché vynechání.

---

## Interakce s jinými pravidly

- **reasoning-depth.md**: reasoning quality > brevity. Tady: completeness > brevity. Obě přepisují token efficiency.
- **quality-standard.md (BtO)**: completeness řešení (udělej celé). Tenhle rule: completeness promptu (nevynech bod).
- **full-autonomy**: rozhoduj sám BEZ ptaní. Ale: rozhodovat ≠ přeskakovat. Autonomy = dělej víc sám, ne méně z toho, co Filip řekl.
- **Surgical Changes** (common/all-rules.md): "dotkni se jen toho, co musíš". Tady: "dotkni se všeho, co Filip řekl". Žádný konflikt — oba říkají match the ask.

---

## Why

Filip 2026-04-19 explicitně řekl: "vždycky spolu něco řešíme. Já ti dám nějaký úkol, ty to prostě neuděláš, posereš to, nepřečteš si to, neodbavíš to podle mého promptu. A to mě strašně série."

Konkrétní incident (Social Publisher audit, stejný den):
- Filip zadal 4 body: NotebookLM research, Pinterest inspirace, dashboard audit, napojení pokračovat
- Já udělal 1 (audit), 3 tiše odsunul ("po schválení", "jen plán", "čeká na X")
- Filip musel prompt opakovat → čas + frustrace + reputace

Pattern se opakoval i dřív — není to izolovaný incident, je to systematické. Tohle pravidlo je hard blocker, ne hint.

---

## Enforcement

1. **Pre-action**: TodoWrite s kompletním rozpisem bodů (viditelné)
2. **In-action**: jeden in_progress, zbytek pending; žádné zapomenuté pending na konci
3. **Close-out**: explicit re-read původního promptu + check všech bodů
4. **Violation log**: pokud detekuju že jsem porušil → zapsat do `memory/completeness-violations.jsonl` + update anti-patterns tabulky výše

Pokud Filip upozorní na vynechaný bod → update tohoto rule (přidat do anti-patterns tabulky) + memory/feedback_prompt_completeness.md.
