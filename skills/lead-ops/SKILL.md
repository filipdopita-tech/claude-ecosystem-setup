# Skill: lead-ops
# Trigger: /lead-ops

Spustí OneFlow Lead-Ops pipeline z ~/Documents/lead-ops/.

## Co dělá

Načte kontext projektu a přepne Claude do správného módu podle vstupu.

## Postup při invokaci

1. Nastavit working context: `~/Documents/lead-ops/`
2. Načíst `CLAUDE.md` pro routing table
3. Načíst `modes/_shared.md` pro scoring framework
4. Pokud existuje `modes/_profile.md`: načíst. Jinak zkopírovat z `modes/_profile.template.md`.
5. Načíst `config/profile.yml` pro OneFlow ICP a proof points

Pak reagovat na uživatelův vstup dle routing table v CLAUDE.md:

| Vstup | Akce |
|---|---|
| Jméno / URL / popis | `evaluate` mode — vyhodnoť, ulož report + TSV |
| `batch` | `batch` mode — zpracuj frontu z data/inbox.md |
| `tracker` / `pipeline` / `stav` | `tracker` mode — zobraz funnel |
| `followup` / `follow-up` | `followup` mode — kdo potřebuje kontakt |
| `outreach` + jméno | `outreach` mode — generuj draft zprávy |
| `deep` + jméno | `deep` mode — hluboký research |
| `patterns` / `vzory` | `patterns` mode — analýza dat |

## Relevantní soubory

```
~/Documents/lead-ops/
├── CLAUDE.md                 ← routing + pravidla
├── modes/
│   ├── _shared.md            ← scoring framework (systém)
│   ├── _profile.md           ← user customizace (nikdy nepřepisuj)
│   ├── _profile.template.md  ← template pro nové uživatele
│   ├── evaluate.md
│   ├── batch.md
│   ├── outreach.md
│   ├── followup.md
│   ├── tracker.md
│   ├── deep.md
│   └── patterns.md
├── config/profile.yml        ← OneFlow ICP + proof points
├── data/
│   ├── pipeline.md           ← hlavní tracker
│   └── inbox.md              ← fronta ke zpracování
├── reports/                  ← evaluační reporty
├── batch/
│   ├── batch-runner.sh       ← parallel orchestrator
│   ├── batch-prompt.md       ← self-contained worker prompt
│   └── tracker-additions/    ← TSV výstupy z workerů
├── merge.mjs
├── dedup.mjs
├── normalize.mjs
└── verify.mjs
```

## Klíčová pravidla

- NIKDY neposílej zprávy/e-maily automaticky
- SKIP pod 3.0/5 bez Filipova overridu
- Data zůstávají lokálně (data/, reports/ v .gitignore)
- Odpovídej česky
