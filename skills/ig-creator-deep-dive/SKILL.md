---
name: ig-creator-deep-dive
description: "Deep-dive analyzer pro IG kreátory ve free režimu. Trigger: 'analyzuj kreátora X', 'rozeber profil @user', URL instagram.com/USER + slovo 'rozeber/analyzuj/deep'. Stáhne posty (max 24 free), analyzuje captions přes Gemini Flash free, identifikuje top picks pro [YOUR_COMPANY] ekosystem, instaluje top 3 ADOPT, generuje CZ adaptaci formátu, vrací master report."
metadata:
  requires-env: GEMINI_API_KEY
  allowed-hosts:
    - instagram.com
    - REDACTED_VPN_IP
    - api.github.com
  version: "1.0"
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - WebFetch
---

# /ig-creator-deep-dive — Reusable IG Creator Analysis Pipeline

## Kdy použít
- "analyzuj kreátora @marc.kaz", "rozeber profil X", "deep-dive @creator"
- IG creator URL + signál pro hloubkovou analýzu
- Hledáš top tipy/skills/tools k implementaci do [YOUR_COMPANY]

## NEPOUŽÍVAT pro
- Single post/reel → použij `instagram-analyzer` skill
- [YOUR_COMPANY] vlastní profil → použij `instagram-analyzer` (B režim)
- Konkurence sleduj-jen → použij `competitor-intel` skill

## Architektura (free)
```
Mac (residential IP)              Flash (compute)
├── ig_analyzer.py             ──> Whisper medium (top 3 reels)
│   └── 24 posts max bez auth     └── transcripts.txt
├── Gemini 2.5 Flash free
│   └── analysis.json (24 entries)
├── WebFetch GitHub verify
└── brew/npx installs (top picks)
```

**Constraints**:
- 24 postů je hard cap bez auth (IG public mobile API limit)
- Apify scrape = paid → cost approval required (HARD STOP per cost-zero rule)
- Authenticated yt-dlp = HARD STOP per FB safety rule (precedent 2026-04-21)
- Whisper transcribce **POUZE na Flash** (Mac OOM 8GB RAM)
- yt-dlp **POUZE z Macu** (Flash IP = 429 ban)

## POSTUP

### Stage 1: Profile metadata fetch (Mac, ~2 min)
```bash
USER="${1:-marc.kaz}"  # default
WORK_DIR="$HOME/Desktop/${USER}-analysis"
mkdir -p "$WORK_DIR" && cd "$WORK_DIR"
python3 $HOME/scripts/social/ig_analyzer.py "$USER" \
  --metadata-only --max-posts 100 --output-dir . > fetch.log 2>&1
```

Output: `${USER}/profile.json`, `${USER}/posts.json`, `${USER}/stats.json`

Pokud `posts.json` má < 5 postů: profil je private/empty/banned → STOP.

### Stage 2: Captions extract (Mac, instant)
```bash
python3 << EOF
import json
with open('${USER}/posts.json') as f:
    posts = json.load(f)
out = [{'idx':i,'shortcode':p.get('shortcode'),
        'url':f"https://www.instagram.com/reel/{p.get('shortcode')}/",
        'caption':(p.get('caption') or '').strip()} for i,p in enumerate(posts,1)]
with open('captions_clean.json','w') as f:
    json.dump(out, f, indent=2, ensure_ascii=False)
print(f'Wrote {len(out)} entries')
EOF
```

### Stage 3: Gemini Flash analysis (Mac → Gemini API free, ~30s)

**Build prompt** s [YOUR_COMPANY] ekosystem fit rubrikou:
```bash
cat > /tmp/gemini_prompt.txt << 'PROMPT_EOF'
You are an AI tooling analyst. Below are ${N} Instagram reel captions from @${USER}, an AI/Claude Code creator. Each post promotes a specific tool, skill, or technique.

For [YOUR_NAME]'s "[YOUR_COMPANY]" ecosystem (Czech investment platform; tech stack: Claude Code on macOS + VPS Flash, Python/Node, lots of automation, MCP servers, GitHub-based skills, focus on cost-zero tools), produce a structured JSON analysis.

For EACH reel produce one object with EXACTLY these fields:
- idx: integer
- shortcode: string
- title: short tool/skill/technique name (≤60 chars)
- category: one of [claude-skill, claude-mcp, cli-tool, library, framework, sandbox, agent, technique, other]
- primary_use: 1 sentence
- github_url: extracted from caption or null
- install_hint: install command if visible, else null
- key_features: array of 2-5 strings
- cost: free / freemium / paid / unknown
- [your_company]_fit_score: integer 1-10 (relevance for [YOUR_COMPANY] ecosystem - investment tooling, automation, content, scraping, ops)
- adoption: ADOPT (install now) / EVAL (test first) / WATCH (monitor) / SKIP (not relevant)
- reasoning: 1-2 sentences explaining adoption verdict

Output ONLY valid JSON array, no prose. Start with [ end with ].

INPUT:
PROMPT_EOF
cat captions_clean.json >> /tmp/gemini_prompt.txt
```

**Run Gemini**:
```bash
export GEMINI_API_KEY=$(grep '^GEMINI_API_KEY=' ~/.claude/mcp-keys.env | head -1 | cut -d= -f2- | tr -d '"')
gemini --model gemini-2.5-flash --prompt "$(cat /tmp/gemini_prompt.txt)" > gemini_raw.txt 2>&1
sed -n '/^\[/,/^\]/p' gemini_raw.txt > analysis.json
```

**Verify**: `analysis.json` musí být validní JSON array, length > 0.

### Stage 4: Top picks identification (Mac, instant)
```bash
python3 << EOF
import json
from collections import Counter
with open('analysis.json') as f:
    data = json.load(f)
sorted_d = sorted(data, key=lambda x: x.get('[your_company]_fit_score',0), reverse=True)
print('=== TOP 10 BY USER_COMPANY FIT ===')
for i, item in enumerate(sorted_d[:10], 1):
    print(f"{i}. [{item['[your_company]_fit_score']}/10] {item['title']}")
    print(f"   {item['category']} | {item['adoption']} | {item.get('github_url','N/A')}")
print()
print('Adoption:', Counter(x['adoption'] for x in data))
EOF
```

### Stage 5: GitHub verify (WebFetch, top 4-6 picks)
Pro každý top pick (ADOPT + high-score EVAL):
- Verify stars, last commit, license
- Check install instructions in README
- Flag risks (low star count, abandoned project, security caveats)

### Stage 6: Selective transcribe (Flash, top 3 reels, ~10 min)
Captions zachycují 95% signálu. Transcribce je pojistka pro top 3:
```bash
TOP3_URLS=$(python3 -c "
import json
with open('analysis.json') as f:
    d = sorted(json.load(f), key=lambda x: x.get('[your_company]_fit_score',0), reverse=True)
print(' '.join(f'\"https://www.instagram.com/reel/{e[\"shortcode\"]}/\"' for e in d[:3]))
")
nohup $HOME/scripts/social/ig_transcribe_remote.sh $TOP3_URLS > transcribe.log 2>&1 & disown
```

### Stage 7: Implement top picks (varies)
Pro každý ADOPT verdikt:
- **claude-skill**: `npx --package=skills@latest -- skills add <handle> -g -y -a claude-code`
- **cli-tool (brew available)**: `brew install <tool>` (Mac) + check Linux install pro Flash
- **MCP server (Docker)**: clone na Flash → `docker compose up --build -d`
- **library**: `pip install` v relevant venv

**Vždy verify**: nainstalovaný? Funguje? Reálný test příkaz?

### Stage 8: CZ content adaptace (volitelně)
Pokud je creator content-strong (>5k followers, structured posts), generuj 5 [YOUR_COMPANY] IG postů ve formátu:
```
🚨 [ALL CAPS CLAIM]
Někdo postavil X.
Ships with: 3-5 features
👉 GitHub URL
[CTA otázka]? Drop 🔥
```
Aplikuj [YOUR_COMPANY] brand (monochrome, Inter Tight, alternující dark/light), check banned words.

### Stage 9: Master report
Generuj `REPORT.md` v `${WORK_DIR}/`:
- TL;DR + adoption breakdown
- Per pick: install verify + GitHub data + [YOUR_COMPANY] use case
- Skipped + důvody
- Pattern analysis (replikovatelný format)
- Pipeline cost & metrics
- Next steps offer

### Stage 10: Memory update
Vytvoř `~/.claude/projects/-Users-YOUR_USERNAME/memory/project_${USER}_ig_analysis_${DATE}.md`:
- Implemented this session
- Skipped + důvody
- Klíčový insight z transcribce
- Reference (REPORT.md path)

Update `MEMORY.md` index s novou položkou.

## Cost guard

| Akce | Náklad | Constraint |
|---|---|---|
| ig_analyzer.py 24 posts | 0 Kč | Mac residential IP only |
| Gemini Flash analyze | 0 Kč | free tier 1500/den |
| Whisper top 3 | 0 Kč | Flash CPU |
| GitHub verify (4-6) | 0 Kč | WebFetch free |
| Brew/npx installs | 0 Kč | Open source |
| **Apify deeper scrape** | **paid** | **HARD STOP — cost approval** |
| **Authenticated IG scrape** | n/a | **HARD STOP — FB safety rule** |

## Limitace
- 24 postů max free (IG public mobile API limit). Po prvním fetchu Mac IP rate-limited (~30 min cooldown).
- Whisper top 3 (ne všech 24) — captions = 95% signal, 5% nuance neworth 2h compute.
- CubeSandbox-style tools vyžadující KVM bare-metal = SKIP (Flash je Contabo containerized).

## Auto-trigger pravidla pro tento skill
- IG URL kreátora + slovo "deep" / "rozeber" / "analyzuj kompletně" → tento skill
- "Analyzuj profil X a vyber co se hodí pro [YOUR_COMPANY]" → tento skill
- Single post URL → `instagram-analyzer` (rychlejší)
- Konkurence pravidelně → `competitor-intel`

## Poslední run
- 2026-04-25: @marc.kaz, 24/24 reels, 3 ADOPT (RTK upgrade, paper2code, auto-browser deployed na Flash), 5 CZ postů. 0 Kč. Memory: `project_marc_kaz_ig_analysis_2026_04_25.md`.
