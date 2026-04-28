---
name: site-builder
description: "Rychlý generátor production-grade landing pages z business name. Použij pro: emitent landing pages, klient nabídky, programmatic SEO. Pipeline: ARES enrichment → OneFlow brand template → Next.js/Tailwind/shadcn → Vercel deploy. Trigger: /site-builder <ico_or_name>, 'vygeneruj web pro X', 'landing pro emitenta Y', 'klient nabídka stránka'."
argument-hint: "<IČO|business_name> [--type=emitent|client|seo] [--brand=oneflow|custom]"
user-invocable: true
allowed-tools:
  - Bash
  - Task
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - WebFetch
metadata:
  source: "skool-intel cherry-pick 2026-04-28: claude-code-architects 'SITE BUILDER: Paste a Business Name, Get a $500 Website in 60 Seconds'"
  filip-adaptace: "Místo Google Maps (banned cost-zero) → ARES + emitent web scrape. Místo náhodných AI obrázků → OneFlow brand monochrome. Deploy Vercel (ne Cloudflare)."
---

# Site Builder — Paste IČO/Name → Production Landing Page

Generuje **production-grade landing page** z minimálního inputu (IČO nebo business name) za <5 min lokálně, deploy na Vercel.

**Argument:** `$ARGUMENTS` — IČO (8 cifer) NEBO business name + optional flags.

## Use Cases

| Type | Trigger | Output |
|---|---|---|
| `emitent` | DD result hotov, potřebuju investor-facing one-pager | `/sites/emitent-{slug}/` Next.js project |
| `client` | Nová OneFlow klient nabídka, vlastní landing | `/sites/client-{slug}/` Next.js project |
| `seo` | Programmatic SEO page (1 z N batchů) | append do existujícího `oneflow-seo-pages` repo |

## Pipeline (5 kroků)

### Step 1 — Enrichment (zero cost, zero halucinace)
```bash
ICO="${1:-}"
NAME="${2:-}"

# ARES lookup pokud IČO
if [[ "$ICO" =~ ^[0-9]{8}$ ]]; then
  curl -s "https://ares.gov.cz/ekonomicke-subjekty-v-be/rest/ekonomicke-subjekty/$ICO" > /tmp/ares.json
  NAME=$(jq -r '.obchodniJmeno' /tmp/ares.json)
  ADDR=$(jq -r '.sidlo.textovaAdresa' /tmp/ares.json)
  ACTIVITY=$(jq -r '.czNace[0].textCz // "—"' /tmp/ares.json)
fi

# OpenSpace skill chain
# `oneflow-ares-enrichment` — viz ~/.claude/skills nebo OpenSpace MCP
# `oneflow-emitent-risk-score` — A-F grade pokud type=emitent
```

**Memory check:** Pokud emitent JE v `~/.claude/projects/<your-project-id>/memory/dd-*.md` → reuse exiting DD data. Nepřepiš.

### Step 2 — Web scrape primary source (pokud existuje)
```bash
# Najdi web firmy přes ARES → website pole NEBO Google search "{NAME} site:.cz" (DuckDuckGo, ne Google)
# Pokud najdeš: scrape přes /defuddle skill nebo Playwright (extract logo, primary color, key copy)
# Pokud ne: použij OneFlow brand template
```

### Step 3 — Generate copy (OpenSpace brand-voice-check enforced)
Volej `oneflow-brand-voice-check` na každý copy block. Banned words detection.

Sekce landing page:
1. **Hero** — H1 + subhead + primary CTA
2. **Trust signals** — DSCR / LTV / vintage / track record (pokud emitent)
3. **What we offer** — bullet list services / dluhopisy parametrů
4. **Social proof** — recenze, výsledky, čísla (jen ověřené, žádné halucinace!)
5. **CTA section** — calibrated question (Voss), ne ano-ne
6. **Footer** — legal disclaimer (CNB/ECSP per type)

### Step 4 — Build Next.js project
Stack (per existing OneFlow defaults):
- Next.js 14 App Router
- Tailwind CSS
- shadcn/ui (button, card, dialog)
- Inter Tight font (per oneflow-brand-manual-2026.md)
- Monochrome palette (#0A0A0C dark / #F2F0ED light, žádné barvy)

```bash
SLUG=$(echo "$NAME" | tr 'A-Z' 'a-z' | tr -cd 'a-z0-9-' | tr ' ' '-')
TYPE="${3:-emitent}"
TARGET="$HOME/sites/${TYPE}-${SLUG}"

# Use existing copyweb skill jako template starter
~/.claude/skills/copyweb/scaffold.sh "$TARGET" --template=oneflow-landing
# (Pokud copyweb scaffold neexistuje → create-next-app + manual setup, viz fallback níže)
```

**Fallback bez copyweb scaffoldu:**
```bash
mkdir -p "$TARGET" && cd "$TARGET"
npx create-next-app@latest . --typescript --tailwind --app --no-src-dir --import-alias "@/*" --use-npm
npx shadcn-ui@latest init -d
npx shadcn-ui@latest add button card dialog
```

### Step 5 — Deploy Vercel
```bash
cd "$TARGET"
vercel --prod --yes  # Filip má Vercel access (per memory/vercel_access.md)

# Output: production URL → memory log + ntfy notification
URL=$(vercel inspect "${TYPE}-${SLUG}" --token=$VERCEL_TOKEN 2>&1 | grep -oP 'https://[a-z0-9-]+\.vercel\.app' | head -1)
echo "✅ Deployed: $URL"
ntfy send "Filip" "Site Builder: $TYPE/$SLUG hotov → $URL"
```

## Anti-Patterns (NIKDY)

- **Google Maps API enrichment** — banned cost-zero. Použij ARES + emitent web scrape.
- **Generické AI obrázky bez brand check** — OneFlow palette only. Stock fotky OK pokud monochrome filtered.
- **Vykřičníky v B2B copy** — banned per oneflow-brand-manual.
- **"Inovativní řešení" / "synergie"** — banned words per oneflow-all.md.
- **Halucinované DSCR / LTV / vintage** — vždy z DD dokumentu, NIKDY z paměti. Flag `[VERIFIED]` nebo skip sekci.
- **Cloudflare Pages deploy** — Filip preferuje Vercel (existing setup, OAuth ready).

## Integrace s ostatními skills/agents

- **DD result jako input** → `/dd-emitent` output → site-builder spotřebuje
- **Brand voice check** → OpenSpace `oneflow-brand-voice-check` skill
- **Programmatic SEO** → existující `/programmatic-seo` skill pro batch pages
- **Image gen** → `/of-design` skill (mono palette enforcement)
- **Post-deploy QA** → `/qa` nebo `/browse` skill pro live audit

## Cost = 0 Kč
- ARES API: free
- Vercel deployment: included (Filip plan)
- Next.js + Tailwind + shadcn: open source
- Žádné Google APIs (cost-zero compliance)

## Verification Checklist

Před `vercel --prod`:
```
□ Brand voice check PASS (žádné banned words)
□ Žádné halucinované finanční metriky
□ Disclaimer per type (emitent = ECSP/CNB risk warning, client = OneFlow s.r.o. footer)
□ Mobile responsive (test v Playwright nebo /browse)
□ Lighthouse > 90 (perf + a11y)
□ Žádné inline styles, žádné !important hacks
```

## Output Format (JSON pro chain)

```json
{
  "type": "emitent|client|seo",
  "slug": "<kebab-case>",
  "ico": "<8-cifer | null>",
  "name": "<full business name>",
  "local_path": "$HOME/sites/{type}-{slug}",
  "deployed_url": "https://...vercel.app",
  "build_log": "/tmp/site-builder-{slug}.log",
  "verification": {
    "brand_check": "PASS|FAIL",
    "lighthouse": 92,
    "bundle_size_kb": 145
  },
  "next_actions": [
    "Add custom domain via Vercel CLI",
    "Configure analytics (GA4 / Plausible)",
    "Add Schema.org markup (Organization / LocalBusiness)"
  ]
}
```

## Scaling (programmatic-seo mode)

Pro batch generaci 10+ stránek:
```bash
# Read CSV s seznamem (IČO, type, custom_field)
while IFS=, read -r ico type field; do
  /site-builder "$ico" "--type=$type"
  sleep 30  # rate limit ARES
done < emitenti-batch.csv
```

Output: 1 PR per page do `oneflow-seo-pages` repo, single Vercel deploy.

## Reference

- Source insight: skool-intel claude-code-architects (2026-04-26 scrape)
- Stack rules: `~/.claude/expertise/frontend-ui.yaml`
- Brand: `~/docs/oneflow-brand-manual-2026.md`, `~/.claude/expertise/oneflow-brand.yaml`
- Memory pattern: `feedback_design_workflow.md` (Stitch → Claude pipeline pro UI exploration first)
