---
description: "Project pulse dashboard — kanban přehled všech projektů a jejich stavu"
---

# /pulse — Project Pulse Dashboard

Zobraz přehled všech aktivních projektů ve formátu CLI kanban boardu.

## Postup

1. Přečti všechny soubory `project_*.md` z `~/.claude/projects/<your-project-id>/memory/`
2. Z každého souboru extrahuj:
   - **Název** (z frontmatter `name:` nebo prvního nadpisu)
   - **Status** (hledej klíčová slova: ACTIVE, PENDING, PAUSED, COMPLETED, MONITORING, nebo odvoď z obsahu)
   - **Popis** (z frontmatter `description:` nebo první věta po nadpisu)
   - **Poslední aktivita** (datum z obsahu souboru, nebo modifikační čas)
3. Přečti také `session_handoff.md` pro kontext aktuální práce
4. Zobraz výsledky v tomto formátu:

```
═══════════════════════════════════════════════════
  PROJECT PULSE                    [datum] [čas]
═══════════════════════════════════════════════════

📊 Celkem: X projektů | ● Active: Y | ◐ Pending: Z | ○ Paused: W

─── ● ACTIVE ──────────────────────────────────────
  ▸ Dashboard v4          dash.oneflow.cz, Vercel deploy
  ▸ AI Intel Digest       Daily news, cron 5:00 UTC
  ▸ Scraping systémy      ARES, Dluhopisy, LinkedIn SN

─── ◐ PENDING ─────────────────────────────────────
  ▸ Dashboard Redesign    Brand redesign + ecosystem mapa

─── ◉ MONITORING ──────────────────────────────────
  ▸ Crucix Watchlist      OSINT, sledovat do ~června 2026

─── ○ PAUSED ──────────────────────────────────────
  (žádné)

─── ✓ COMPLETED ───────────────────────────────────
  (žádné)

═══════════════════════════════════════════════════
```

5. Pod dashboard přidej sekci "Aktuální focus" z session_handoff.md (pokud existuje)
6. Na konci nabídni: "Chceš detail konkrétního projektu? Řekni název."

## Pravidla
- ŽÁDNÝ sub-agent — čti soubory přímo
- Výstup čistě česky
- Max 1-2 emoji na řádek (jen indikátory statusu)
- Pokud soubor nemá explicitní status, odvoď z kontextu (např. "PENDING" pokud obsahuje "čeká na", "TODO")
- Seřaď projekty v každé kategorii abecedně
