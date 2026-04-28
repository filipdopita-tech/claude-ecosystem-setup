# Research Workflow: NotebookLM First

> Trvalé pravidlo. Aktivní vždy, když Claude Code potřebuje provést research.

## Proč
NotebookLM je zdarma (Google). Claude Code tokeny stojí peníze. Každý research, který může udělat NotebookLM, MUSÍ jít přes NotebookLM.

## Kdy použít NotebookLM
- Rešerše tématu (trh, konkurence, technologie, trendy)
- Analýza více zdrojů najednou (články, videa, dokumenty)
- Sumarizace a syntéza informací z webu/YouTube
- Příprava podkladů pro content (IG, LinkedIn, newsletter)
- Competitive intelligence a market research
- Due diligence research na firmy/produkty

## Kdy NEPOUŽÍVAT NotebookLM
- Čtení lokálních souborů (git, kód, config) - to dělá Claude přímo
- Jednoduchý grep/lookup v paměti nebo na VPS
- Práce s API/databází
- Real-time data (kurzy, ceny) - tam web search
- Kódování a debugging

## Research Workflow (5 kroků)

### 1. Příprava zdrojů (KRITICKÉ pro kvalitu)
NotebookLM je tak dobrý, jak dobré jsou jeho zdroje. Špatné zdroje = špatný research.

**Zdroje hledej přes:**
- `/yt-research [téma]` pro YouTube videa (yt-dlp search)
- Web search pro články a studie (najdi URL)
- Známé autoritativní zdroje pro dané téma

**Pravidla výběru zdrojů:**
- Min 5, ideálně 8-15 zdrojů na research task
- Mix typů: YouTube + články + studie/reporty
- Preferuj zdroje < 12 měsíců staré (pokud není historický kontext)
- Anglické i české zdroje (NotebookLM zvládá obojí)
- VYŘAĎ: clickbait, affiliate-heavy, outdated, low-authority
- Pro CZ specifika: hledej i .cz zdroje (cnb.cz, czso.cz, e15.cz, forbes.cz)

### 2. Vytvoření notebooku
```bash
python3 ~/Documents/Claude_NotebookLM/notebooklm_skill.py pipeline \
  --name "[Téma] Research [YYYY-MM]" \
  --urls URL1 URL2 URL3 ... \
  --type report \
  --instructions "Comprehensive analysis in Czech. Focus on: [specifické otázky]. Include data points, statistics, and actionable insights." \
  --language cs
```

### 3. Strukturované dotazování
Po nahrání zdrojů polož 3-7 cílených otázek přes `ask`:

**Šablona otázek pro quality research:**
1. "Jaké jsou hlavní trendy v [téma] v posledním roce? Uveď konkrétní čísla a zdroje."
2. "Jaké jsou největší rizika a příležitosti v [téma]? Seřaď podle dopadu."
3. "Jak se [téma] liší v CZ kontextu oproti globálnímu trhu?"
4. "Jaká data nebo statistiky jsou k dispozici? Cituj přesné hodnoty."
5. "Jaké jsou protichůdné názory nebo kontroverze v [téma]?"
6. "Co je actionable - co by měl investor/founder udělat na základě těchto informací?"
7. "[Specifická otázka relevantní pro OneFlow/Filipa]"

**Anti-patterns (špatné dotazy):**
- "Řekni mi vše o X" - příliš široké, slabé odpovědi
- Ano/ne otázky - nízká informační hodnota
- Dotazy mimo scope nahraných zdrojů - halucinace

### 4. Export a syntéza
- Stáhni report/mindmap/data_table přes `download`
- Přečti výstup do Claude Code kontextu
- Claude Code DOPLNÍ vlastní kontext (memory, rules, OneFlow specifika)
- Claude Code NEKOPÍRUJE NotebookLM output, ale SYNTETIZUJE s vlastním kontextem

### 5. Kvalitní kontrola
- Ověř klíčová čísla/tvrzení z NotebookLM výstupu (cross-check)
- Pokud NotebookLM tvrdí něco překvapivého, ověř web searchem
- Označ co je z NotebookLM a co je Claudeův vlastní kontext

## Naming Convention
Notebooky pojmenovat: `[Kategorie] [Téma] [YYYY-MM]`
Příklady:
- "Market CZ Dluhopisy 2026-04"
- "Competitor Portu Analysis 2026-04"
- "Tech AI Safety Trends 2026-04"
- "Content Ideas Investing 2026-04"

## Artifact Type Selection
| Potřeba | Typ | Kdy |
|---------|-----|-----|
| Hloubková analýza | `report` | Default pro research |
| Vizuální přehled | `mindmap` | Mapování tématu |
| Strukturovaná data | `data_table` | Srovnání, metriky |
| Quick summary | `ask` (otázky) | Rychlý research |
| Prezentace | `slides` | Pro sdílení s týmem |
| IG/content | `infographic` | Vizuální content |

## Integrace s dalšími skills
- `/yt-research` → najde YouTube URL → NotebookLM je zpracuje
- `/last30days` → pokud NotebookLM nestačí na real-time data, fallback na last30days
- Web search → jen jako doplněk nebo cross-check, ne primární research tool
