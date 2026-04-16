---
name: instagram-analyzer
description: "Analyzuj Instagram profil, post/reel, nebo bulk kreátory. Stáhne metadata, videa, transkribuje audio, extrahuje frames a poskytne obsahovou analýzu. Trigger: 'analyzuj IG', 'rozeber mi ig post', 'instagram analýza', 'bulk IG', URL s instagram.com."
compatibility: Requires yt-dlp on Mac (residential IP), Whisper on Flash VPS, Google Sheets service account for bulk mode.
metadata:
  requires-env: GOOGLE_SHEETS_SERVICE_ACCOUNT
  allowed-hosts:
    - instagram.com
    - YOUR_VPS_IP
  version: "1.0"
---

# /instagram-analyzer — Instagram Content Analyzer

## Kdy použít
- Uživatel napíše `/instagram-analyzer`
- Uživatel sdílí Instagram URL (reel/post)
- Uživatel řekne "analyzuj IG profil X", "rozeber mi ig post", apod.
- Uživatel chce inspiraci z cizího IG obsahu
- Uživatel chce analyzovat kreátory z Google Sheets ("analyzuj kreátory", "bulk IG")

## Tři režimy

### A) Single Post/Reel (URL)
Uživatel dá konkrétní URL. Rychlá analýza jednoho postu.

### B) Profile Analysis (username)
Analýza celého profilu — metadata, engagement stats, top posty.

### C) Bulk Creator Analysis (Google Sheets)
Analyzuj všechny kreátory z Google Sheets tab "IG Creators".

## POSTUP

### Krok 1: Detekce režimu
- Pokud vstup obsahuje `instagram.com/reel/` nebo `instagram.com/p/` → režim A (single post)
- Pokud vstup obsahuje username (bez URL) → režim B (profile)
- Pokud není jasné, zeptej se

### Krok 2A: Single Post Analysis

**POZOR: Transkripce (Whisper) běží na VPS Flash, ne na Macu.** Mac má 8 GB RAM a OOMuje při paralelním Whisperu. Flash má 12 GB + semafor max 2 paralelních whisper instancí. Viz memory `project_ig_analyzer_flash_migration.md`.

Použij orchestrator wrapper (yt-dlp na Macu → scp mp4 → Flash worker → rsync výsledky):

```bash
$HOME/scripts/social/ig_transcribe_remote.sh "URL"
```

Podporuje multiple URLs:
```bash
$HOME/scripts/social/ig_transcribe_remote.sh "URL1" "URL2" "URL3"
```

Výstup: `~/Desktop/ig_analysis/<shortcode>/{video.mp4, audio.mp3, transcript.txt, frames/}`

Pipeline krokuje:
1. Mac: yt-dlp stáhne mp4 (residential IP obchází IG rate-limit)
2. scp mp4 → Flash `/home/claude/ig_transcribe/input/<shortcode>.mp4`
3. ssh Flash `systemctl start ig-transcribe-worker.service` (oneshot, blokující)
4. Flash: ffmpeg audio+frames, openai-whisper medium (thread-local, max 2 parallel)
5. rsync `/home/claude/ig_transcribe/output/` → `~/Desktop/ig_analysis/`

Pak **Přečti transkript** a **prohlédni frames** (Read tool na `.txt` a `.jpg` v `~/Desktop/ig_analysis/<shortcode>/`)

6. **Analyzuj a prezentuj**:

#### Výstupní formát (single post):
```
## IG Analýza: [shortcode]

### Obsah
- **Téma:** [hlavní téma videa]
- **Formát:** [talking head / screen recording / B-roll / carousel / mix]
- **Délka:** [odhadni z frame count * 3s]

### Transkript (klíčové body)
1. [bod 1]
2. [bod 2]
3. [bod 3]

### Hook analýza
- **Otevírací hook:** "[první věta]"
- **Síla hooku:** [1-10] — [proč]

### Engagement vzorce
- **CTA:** [jaké CTA používá]
- **Retention prvky:** [co drží pozornost]

### Aplikovatelnost pro OneFlow
- **Použitelné prvky:** [co by šlo adaptovat]
- **Adaptace pro CZ:** [jak by to vypadalo v češtině]
- **Doporučení:** [konkrétní akční kroky]
```

### Krok 2B: Profile Analysis

1. **Spusť ig_analyzer.py z Macu** (VPS dostává 429):
```bash
ssh mac "python3 $HOME/scripts/social/ig_analyzer.py USERNAME --metadata-only --output-dir /tmp/ig_analysis"
```

2. **Přečti výstupy**:
```bash
cat /mac/tmp/ig_analysis/USERNAME/profile.json
cat /mac/tmp/ig_analysis/USERNAME/posts.json
cat /mac/tmp/ig_analysis/USERNAME/stats.json
```

3. **Analyzuj a prezentuj**:

#### Výstupní formát (profile):
```
## IG Profil: @username

### Přehled
| Metrika | Hodnota |
|---------|---------|
| Followers | X |
| Posts | X |
| Avg Likes | X |
| Avg Comments | X |
| Engagement Rate | X% |

### Top 5 postů (by likes)
[tabulka s shortcode, likes, date, caption preview]

### Content strategie
- **Posting frekvence:** [kolik za týden]
- **Content mix:** [% video vs image vs carousel]
- **Hlavní témata:** [analýza captionů]
- **Tone of voice:** [popis stylu]
- **CTA vzorce:** [jaké CTA používají]

### Co se dá použít pro OneFlow
- [konkrétní doporučení 1]
- [konkrétní doporučení 2]
- [konkrétní doporučení 3]
```

### Krok 2C: Bulk Creator Analysis

1. **Spusť bulk analyzer z Macu** (VPS nemá přístup ke Google API ani k IG):
```bash
ssh mac "python3 $HOME/scripts/social/ig_bulk_analyzer.py --max 10 --delay 5"
```

Pro všechny PENDING kreátory (bez limitu):
```bash
ssh mac "python3 $HOME/scripts/social/ig_bulk_analyzer.py"
```

Pro re-analýzu všech:
```bash
ssh mac "python3 $HOME/scripts/social/ig_bulk_analyzer.py --force"
```

2. **Přečti výsledky**:
```bash
ssh mac "cat /tmp/ig_analysis/bulk_report.json"
```

A pro detaily jednotlivých kreátorů:
```bash
ssh mac "cat /tmp/ig_analysis/USERNAME/profile.json"
ssh mac "cat /tmp/ig_analysis/USERNAME/posts.json"
ssh mac "cat /tmp/ig_analysis/USERNAME/stats.json"
```

3. **Prezentuj souhrnný report**:

#### Výstupní formát (bulk):
```
## Bulk IG Creator Analysis

### Přehled
| Creator | Followers | Avg Likes | Avg Comments | Avg Views | ER% |
|---------|-----------|-----------|--------------|-----------|-----|
| @x      | X         | X         | X            | X         | X%  |

### Ranking (relevance pro OneFlow)
1. @creator1 (score 9/10) — [proč]
2. @creator2 (score 7/10) — [proč]

### Doporučení k implementaci
1. [konkrétní akce z top kreátora]
2. [konkrétní akce z druhého kreátora]

### Content vzorce k replikaci
- Hook pattern: [společný vzorec v top postech]
- CTA pattern: [co funguje]
- Visual style: [co mají společného]
```

4. **Google Sheets** — výsledky se automaticky zapisují zpět do tab "IG Creators"
   - Sheet ID: `12LBNKEFQfOwdE2FAo4aAp-QCP6QZImARGjKgS5sBGjE`
   - Tab: `IG Creators`
   - Service account: `/tmp/sa.json` (Mac) nebo `~/.credentials/oneflow-scraper-service-account.json`

### Krok 3: Nabídni follow-up
- "Chceš stáhnout a transkribovat top videa?"
- "Mám vytvořit CZ adaptaci nejlepšího postu?"
- "Chceš to uložit do content plánu?"
- "Chceš přidat další kreátory do sheetu?"

## Důležité poznámky
- Instagram mobile API funguje JEN z Macu (residential IP). VPS dostává 429.
- yt-dlp pro Instagram reely MUSÍ běžet z Macu (residential IP), Flash dostává rate-limit.
- Pro profile scraping VŽDY spouštěj přes `ssh mac` (nebo přímo na Macu).
- **Whisper transkripce běží VÝHRADNĚ na Flash** přes `ig_transcribe_remote.sh`. Medium model, thread-local per task, semafor max 2 parallel. Mac NIKDY nespouští Whisper (OOM riziko, 8 GB RAM).
- Single post output: `~/Desktop/ig_analysis/<shortcode>/` (rsynced z Flash).
- Při analýze pro OneFlow vždy zohledni brand voice z ~/Documents/oneflow-claude-project/

## Error Handling

| Situace | Akce |
|---|---|
| yt-dlp 429 (rate limit) | STOP. Instagram blokuje IP. Čekej 30 min, nebo zkus jinou session cookie |
| yt-dlp login required | Obnov cookies: `yt-dlp --cookies-from-browser chrome` na Macu |
| Whisper OOM na Flash | Zkontroluj `free -h`, sniž model na `small`, ověř semafor (max 2 parallel) |
| scp/rsync timeout | Ověř WireGuard: `wg show`, ping YOUR_VPS_IP |
| Empty transcript | Zkontroluj audio: `ffprobe audio.mp3`. Pokud tiché/hudba, přeskoč transkripci |
| Google Sheets 403 | Service account nemá přístup ke sheetu. Sdílej sheet s SA emailem |

## Common Mistakes

1. **Nespouštěj yt-dlp z VPS.** Datacenter IP = instant ban. VŽDY z Macu (residential IP).
2. **Nespouštěj Whisper na Macu.** 8 GB RAM = OOM. VŽDY na Flash přes ig_transcribe_remote.sh.
3. **Nekombinuj bulk + single.** Bulk jde přes Sheets pipeline, single přes přímou URL.
4. **Neparsuj IG HTML.** Používej yt-dlp pro metadata, ne scraping HTML stránky.
5. **Neukládej cookies do memory.** Session cookies patří do `~/.credentials/`, ne do SKILL.md.
