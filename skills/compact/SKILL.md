---
name: compact
description: "Kondenzuj aktuální konverzaci do 5-7 bullet pointů pro copy-paste do nové Claude session. Mid-session snapshot, NE end-of-session handoff. Trigger: /compact nebo uživatel napíše COMPACT."
---

# /compact — Mid-Session Context Snapshot

## Rozdíl oproti session-handoff
- **session-handoff** = konec session, dlouhý formát, ukládá do `memory/session_handoff.md`
- **compact** = kdykoliv uprostřed session, krátký formát, output rovnou do chatu pro copy-paste

## Kdy použít
- [YOUR_NAME] řekne `/compact` nebo "COMPACT"
- Před přechodem na nový chat (když session běží dlouho ale není na konci)
- Když [YOUR_NAME] pracuje na něčem co chce paralelně otevřít v novém chatu
- Po velkém taskem kde je potřeba předat state do další konverzace

## Output formát

Vypiš PŘESNĚ tohle, nic víc, nic míň:

```
## 📦 Session Compact — {YYYY-MM-DD HH:MM}

**Cíl:** {jednovětí co se dělalo}

**Stav:**
• [STATUS] {fakt/rozhodnutí/milestone}
• [STATUS] {další}
• [STATUS] {další}
• [STATUS] {další}
• [STATUS] {další}

**Kritický kontext:**
- Klíčové file paths: {seznam}
- Aktivní rozhodnutí: {co se odhodlalo a proč}
- Blockery: {co čeká nebo co selhalo}

**Pro nový chat:**
{jedna věta co zadat v novém chatu aby Claude okamžitě navázal}
```

## Pravidla

1. **Max 5-7 bullet pointů v sekci Stav.** Víc = přetížení, méně = málo info.
2. **STATUS tag** = jeden z: `DONE`, `WIP`, `TODO`, `BLOCKED`, `DECIDED`
3. **Zachovej konkrétní data:** čísla, file paths, příkazy, URL. NE vague statements.
4. **Žádné meta komentáře** jako "Podívejme se na..." nebo "Zde je shrnutí...". Jen raw obsah.
5. **Poslední věta "Pro nový chat"** musí být self-contained — Claude v novém chatu má dostat vše co potřebuje k okamžitému pokračování.
6. **Neukládej nikam** — compact je disposable snapshot, NE persistent state. [YOUR_NAME] si ho sám zkopíruje kam potřebuje.
7. **Rychlost > elegance.** Vypiš compact okamžitě, bez přípravných frází.

## Příklad dobrého compactu

```
## 📦 Session Compact — 2026-04-09 15:42

**Cíl:** Implementace IG bulk analyzer + strategická analýza 10 postů o Claude Code optimalizaci

**Stav:**
• [DONE] Stáhl 10 postů (8 reelů + 2 posty), transkribovány přes Whisper
• [DONE] Report uložen: $HOME/Documents/research/claude-code-ig-analysis-2026-04-09.md
• [DECIDED] COMPACT skill implementovat (missing piece mezi inline a session-handoff)
• [DECIDED] CLAUDE.md rules diet = real win (1403 řádků loaded vždy)
• [WIP] Caveman skill in progress
• [TODO] Audit tokenů rules/ tree

**Kritický kontext:**
- Klíčové file paths: ~/.claude/skills/compact/SKILL.md, ~/.claude/rules/*.md
- Aktivní rozhodnutí: Skip peak hours warning, Antigravity proxy, PDF preprocessing (redundantní)
- Blockery: Žádné

**Pro nový chat:**
Pokračuj v implementaci z reportu $HOME/Documents/research/claude-code-ig-analysis-2026-04-09.md — zbývá caveman skill + rules tree audit.
```

## Anti-patterns (NEDĚLEJ)

- ❌ Dlouhé odstavce místo bullet pointů
- ❌ Opakování obecných info z CLAUDE.md
- ❌ Ukládání do souboru (to dělá session-handoff)
- ❌ Vágní statements jako "probírali jsme X"
- ❌ Chybějící file paths pro rozpracované věci
- ❌ Emoji spam (max 📦 v headline)
