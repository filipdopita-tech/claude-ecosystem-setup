# OneFlow Context Layer for prompt-master

Filip-specific defaults to inject into generated prompts when task touches OneFlow brand, content, ads, or copy.

**When to load:** if user's prompt task involves carousel, reel, post, IG/FB/LinkedIn, landing, email, ad, hero shot, brand asset, OneFlow voice, klientský deliverable.

**When to skip:** generic technical/coding prompts, third-party brands, Filip's personal use unrelated to OneFlow.

---

## Brand Voice Constraints (embed in copy/content prompts)

- Language: **česky** (ne slovensky), output language matches user's input language unless explicit otherwise
- Tone: přímý, sebevědomý, bez omluv, bez vykřičníků v B2B
- Sentence length: max 25 slov pro marketing, max 40 slov pro DD/compliance
- Vykání novým kontaktům, tykání jen pokud explicit existující vazba
- Podpis: "Dopita" (DM/short), "Filip Dopita | OneFlow" (email)
- Max 1-2 emoji per output, 0 emoji v investor/legal výstupu

## Banned Words (CZ — never output these)

inovativní, revoluční, komplexní řešení, win-win, synergie, paradigma, disruptivní, "v dnešní době", "závěrem lze konstatovat", "S pozdravem", "Dovoluji si", "Dovolte mi", "Rád bych Vám", "Obracím se na Vás"

## AI Patterns to Strip

- Seznamy s přesně 5/10 položkami (uniform = AI signal)
- "Furthermore" / "Moreover" transitions
- Em dashes (—) — Filip rule
- Uniform sentence length (mix krátké a dlouhé)

## Visual Lock (image-gen prompts)

**Color palette (monochrome only):**
- Dark surface: `#0A0A0C` (background), `#1A1A1A` (fills), `#555555` (gray accent), `#000000` (black)
- Light surface: `#F2F0ED` (background), `#E5E3E0` (borders), `#C8C4BF` (warm accent)
- **NEVER:** saturated colors, gold, oranžová, zlato

**Font:** Inter Tight only (when text in image). Generally avoid text in AI-gen images (Filip dělá overlay separately).

**Format presets:**
- Carousel slide: `1080x1350` (4:5)
- Reel / IG Story: `1080x1920` (9:16)
- Landing hero: `1920x1080` (16:9)
- Profile / square: `1080x1080` (1:1)
- LinkedIn banner: `1584x396` (4:1)

**Style references (pin if relevant):**
- Brand manuál: `~/docs/oneflow-brand-manual-2026.md`
- Pinterest Style Bible: memory `pinterest_style_bible.md`
- Reference: severe minimalism, editorial photography, depth, no clutter

## Image AI Tool Routing

| Use case | Tool | Why |
|---|---|---|
| Default exploration | **fal.ai** (FLUX.1, Krea via fal) | Filip primary, fastest, cheapest |
| Premium hero shot | **Krea** direct API | Highest quality |
| Bulk / free credits | **Kie.ai** | Free tier available |
| Editorial photography style | **fal.ai/krea-image** | Best for OneFlow aesthetic |
| Logo / vector | **Recraft v3** (via fal.ai) | SVG output |
| **NEVER** | Google Imagen direct | 🛑 Cost-zero rule |

API keys: `~/.claude/mcp-keys.env` or `~/.credentials/master.env`

## Video AI Tool Routing

| Use case | Tool |
|---|---|
| Short brand story (15-30s) | **seedance-brand-story** skill |
| Social hook (3-7s) | **seedance-social-hook** skill |
| Motion design ad | **seedance-motion-design** skill |
| Long-form rendered | **HyperFrames** (Filip's Remotion stack) |

## Cold Email / Outreach Prompt Defaults

When user asks for cold email / DM / outreach prompt:
- **MUST embed:** v4 pre-send checklist (10 bod) — see `~/.claude/rules/domains/cold-email.md`
- **MUST use:** calibrated questions per Voss (no yes/no CTA)
- **MUST include:** banned openers list (no "Dovoluji si...", "Rád bych...")
- **DO NOT use:** /ghost-style rewrites for investor/legal (precision wins)

## Filip's Anti-Patterns (avoid generating prompts that produce these)

- "Sure", "Skvělá otázka", "Absolutely" openers
- Trailing summaries ("Doufám že tohle pomohlo...")
- Em dash (—) — replace with comma or period
- Excessive bullets where prose works better
- Generic CTAs ("Rád si o tom popovídám")
- Vykřičníky v B2B textu

## Reasoning-Native Models (Filip's stack)

When prompt targets these, **NEVER** add CoT/think-step-by-step:
- Claude Opus 4.7 / 4.7 1M (default Filip workhorse for stakes)
- Claude Sonnet 4.6 (default for general)
- OpenAI o3 / o3-mini / o4-mini
- DeepSeek-R1, Qwen3 thinking mode

To control depth: use "think carefully" (more) or "respond quickly" (less). Adaptive thinking handles the rest.

## Default Tool Choice When User Doesn't Specify

| Task | Default tool |
|---|---|
| Image gen | fal.ai (Filip primary) |
| Video gen | seedance skill matching scenario |
| Code generation | Claude (Opus for architecture, Sonnet for impl) |
| Long context (>200k) | Opus 4.7 1M |
| Free fallback (cost-sensitive) | OpenRouter free models |
| Coding agent | Cursor with Composer-mode prompt |
| Quick draft | Sonnet 4.6 direct |

🛑 **NEVER recommend:** Google Gemini API, Vertex AI, Google paid services (cost-zero rule, see `~/.claude/rules/cost-zero-tolerance.md`).

## Filip Decision Rule

When in doubt: pick monochrome, pick CZ, pick fal.ai, pick Claude direct, pick honest direct phrasing, pick calibrated CTA, pick Inter Tight, pick `1080x1350` aspect.
