---
name: research-paper
description: Fetch and manage scholarly papers via legal-first cascade (OpenAlex/Unpaywall/Semantic Scholar/arXiv) with Sci-Hub fallback. Caches PDFs, generates Obsidian notes with YAML frontmatter, supports topic-level research with citation-sorted multi-paper fetch. Use for DD prep, podcast guest research, market intel backed by academic sources, content fact-checking, sector trend analysis. Invoke with DOI, publisher URL, or paper title. Personal scholarly use only (CZ § 30).
---

# /research-paper

Stáhni vědecký paper, vytvoř Obsidian poznámku, propoj s OneFlow projekty.

## Triggers

| Filip phrase | Action |
|---|---|
| "stáhni paper [DOI/URL/title]" | `paper <q> --obsidian` |
| "co píšou o [topic]" | `paper-search "topic"` |
| "research [topic], top 10" | `paper-deep "topic" -n 10` |
| "stažený paper k DD/podcastu" | propoj `related_projects:` v note |
| "ověř claim [X] vědeckým zdrojem" | `paper-search "X" --year-from 2020` |

## Workflow

### 1. Fetch single paper
```bash
paper "<DOI | publisher URL | paper title>" --obsidian --open
```
Output:
- PDF v `~/Documents/research-cache/papers/<sha1>.pdf`
- Note v `~/Documents/OneFlow-Vault/06-Knowledge/Research-Papers/<year>-<slug>.md`
- Metadata v `metadata.jsonl`

### 2. Topic research
```bash
paper-deep "<topic>" -n 10 --year-from 2020
```
- Top 10 most-cited z OpenAlex
- Auto-fetch + auto-note
- MOC v `06-Knowledge/Research-Papers/MOC-<topic>.md`

### 3. Health check
```bash
paper --probe
```
Ukáže: IP, mirror status, API status, počet cached papers.

### 4. Browse cache
```bash
paper --list
```

## Cascade pořadí (legal-first)

1. **OpenAlex** OA URL (free, 0 přístup, gold/green/hybrid OA)
2. **Unpaywall** (specialised OA finder)
3. **Semantic Scholar** (`openAccessPdf` field)
4. **arXiv** (title match, preprint)
5. **Sci-Hub** (5 mirrors: ru, st, red, box, su) — fallback only

V praxi 60-70 % paperů legal-first hit, 30-40 % Sci-Hub.

## Obsidian note schema

```yaml
---
doi: "10.xxxx/yyyy"
title: "..."
authors: [...]
year: 2024
journal: "..."
cited_by: 123
concepts: [...]      # OpenAlex concepts (auto)
source: "openalex_oa | unpaywall | sci-hub:sci-hub.ru"
fetched: "2026-04-30T10:00:00Z"
local_pdf: "/Users/.../research-cache/papers/<sha1>.pdf"
sectors: []          # Filip: real-estate, energy, esg, ai, fintech, ...
related_projects: [] # Filip: [[project-name]] — DD, podcast, content
status: unread       # unread | reading | read | cited
type: research-paper
---
```

## Cross-linking do projektů

Po fetchnutí paperů relevantních pro projekt:

1. Otevři note: `~/Documents/OneFlow-Vault/06-Knowledge/Research-Papers/<year>-<slug>.md`
2. Doplň `sectors: [esg, real-estate]`
3. Doplň `related_projects: ["[[project_emitent_xyz_dd_2026_04_30]]"]`
4. V projektovém memory entry přidej zpětný link: `[[Research-Papers/<year>-<slug>]]`

## OneFlow use cases

| Kontext | Workflow |
|---|---|
| **DD emitenta** | `paper-deep "<sektor> bond default rates" -n 5` → cituj v memo (ne attachni PDF) |
| **OneFlow Cast guest prep** | `paper-search "<guest expertise>"` → top 5 paperů → highlights v note |
| **Content fact-check** | `paper-search "<claim>"` → ověř recent meta-analyses |
| **Trend tracker rozšíření** | weekly `paper-deep "<sector trend>" -n 5 --year-from 2025` → MOC update |
| **Investiční memo backing** | `paper "<DOI>" --obsidian` → cite by DOI v memu (kredibilita > blog) |

## Bezpečnost

- VPN doporučeno před `paper-deep` (multi-fetch). `paper --probe` ukáže aktuální IP.
- Cache jen Mac, ne Flash (žádný VPS trail pro Elsevier blocklisting).
- Personal use only — nesdílej PDFs s klienty / podcast guesty (cituj DOI).
- Rate limit 3s default mezi batch items.

## Souvisí

- Skill `/dd-emitent` — papers cite v DD reportu
- Skill `/notebooklm-research` — downstream deep analysis (uploadni PDFs jako `source_add` typ `file`)
- Skill `/paper2code` — arxiv papery: chain ARXIV_ID z metadata.jsonl → minimal Python implementace
- Skill `/trend-tracker` — daily/weekly auto-research
- Skill `/qmd` — query Obsidian vault včetně Research-Papers/
- Skill `/defuddle` — pre-fetch fallback: clean web text z paper landing page když cascade selže
- Memory `project_research_pipeline_2026_04_30.md` — full setup history

## Pipeline chain (Research Paper Pipeline)

Default downstream auto-suggest po úspěšném fetch:
1. `/research-paper "<DOI|arxiv ID|title>"` — fetch + Obsidian note (THIS skill)
2. (arxiv-only) `/paper2code <arxiv_id>` — minimal citation-anchored implementace
3. `/notebooklm-research "<topic>" --type=market` — citation-rich synthesis se zdroji
4. `/qmd` query → cross-link s OneFlow projects (DD memos, podcast prep, content)

Cache lookup pro chain: `~/Documents/research-cache/metadata.jsonl` (jsonl s `source`, `doi`, `arxiv_id`, `local_pdf`).

## Limity

- Sci-Hub uploads frozen since Dec 2020 → very recent papers (2024+) often miss in Sci-Hub. Use Unpaywall/arXiv first.
- Some publishers (Elsevier) ban known mirror IPs → if all mirrors fail, manually try Tor.
- Sci-Net (2025 P2P) zatím nemá public API — manual workflow.
