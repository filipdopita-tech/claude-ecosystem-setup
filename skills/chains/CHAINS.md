# Chain Recipes — Pre-Built Power Skill Workflows

## Účel
Pre-defined řetězce power slash commands z `~/.claude/commands/` aplikované na typické OneFlow workflows. Každý recipe = ověřená sekvence Tier S/A/B/C/D z `~/.claude/rules/power-skills-stack.md`.

**Volání:** Použij přímo (např. "spusť DD-MAX chain na Patricny"), nebo necháš auto-trigger podle keyword v workflow-routing.md.

---

## Recipe 1: DD-MAX (Due Diligence Max Stakes)

**Kdy:** Investor-facing DD report, prospekt analýza, emise hodnocení >5M Kč.

**Chain:**
```
1. /dd-emitent              [base DD report draft]
2. /godmode                  [max depth rewrite, extended thinking]
3. /factcheck                [verify all numerical claims, ARES, ISIR]
4. /challenge                [4-layer scrutiny: stakes+adversarial+ACH]
5. /redteam                  [Devil's Advocate, 5 mandatory questions]
6. /sentinel                 [error/risk surface scan]
7. /deset                    [iterativní 8-pass loop until 95+/100]
8. ship
```

**Token cost:** ~80-120k tokens. Use Opus 4.7 1M for >50 stránkové prospekty.

**Auto-stop:** Pokud `/redteam` verdict = KILL → STOP, eskaluj Filipovi reasoning.

**OneFlow integrace:** Auto-trigger when DD draft >5 stran, emise >3M Kč, nebo investor-facing.

---

## Recipe 2: INVESTOR-PITCH (Pitch Deck / Memo / Sales Letter)

**Kdy:** Investor pitch, podcast outreach na high-profile target, big retainer proposal.

**Chain:**
```
1. /office-hours             [YC mode 6 forcing functions on draft]
2. /redteam                  [Devil's Advocate against pitch]
3. /scenario                 [best/worst/likely outcome of pitch landing]
4. /godmode                  [max depth rewrite]
5. /storysell                [narrative arc: setup → tension → resolution]
6. /punch                    [each sentence harder]
7. /hooks10                  [10 opening variants → vyber #1]
8. /trim                     [cut fluff]
9. /polish                   [professional polish]
10. /deset                   [final 95+ loop]
```

**OneFlow integrace:** Auto-trigger pro pitch/memo s >100k Kč stakes.

---

## Recipe 3: COLD-EMAIL-MAX (Outreach High-Value)

**Kdy:** Outreach na CEO/zakladatel/celebrity, single-shot zpráva s reputational stakes.

**Chain:**
```
1. /dossier                  [comprehensive briefing on recipient]
2. outreach-oneflow          [v4 generator: FBI Voss + Cialdini + anti-robot]
3. /factcheck                [verify all claims about recipient]
4. /ghost                    [anti-AI-detection rewrite]
5. /punch                    [each sentence harder]
6. /trim                     [cut to <100 slov]
7. /hook                     [opening grab-attention rewrite]
8. /sentinel                 [final review for AI tells, banned phrases]
9. oneflow-deliverability-check [SPF/DKIM/DMARC + domain health]
10. ship
```

**Auto-stop:** Pokud deliverability check = HOLD/FIX → STOP, fix domain first.

**OneFlow integrace:** Auto-trigger when outreach target = c-suite, podcast guest, investor.

---

## Recipe 4: CONTENT-VIRAL (IG/LinkedIn High-Performance Post)

**Kdy:** Content pillar launch, hero post, viral attempt.

**Chain:**
```
1. competitor-intel          [scrape current top performers in niche]
2. /angles                   [10 different approaches to topic]
3. /hooks10                  [10 opening hook variants]
4. ig-content-creator        [pick best angle, generate carousel/reel script]
5. /ghost                    [no AI tells]
6. /banger                   [each line hits hard]
7. /viral                    [shareability optimization]
8. /thumbnail                [click-maximizing title/cover]
9. huashu-design             [render carousel slides 1080x1350 alt dark/light, apply OneFlow brand auto-load]
10. oneflow-brand-voice-check [PASS/FIX/STOP gate]
11. content-repurpose        [adapt to other formats]
```

**OneFlow integrace:** Auto-trigger pro content pillar launch (ne každý post).

---

## Recipe 5: STRATEGIC-DECISION (Pivot / Big Bet / New Service)

**Kdy:** Rozhodnutí kde špatná volba = >100k Kč nebo >týden práce ztráta.

**Chain:**
```
1. oneflow-diagnose          [6 forcing functions: GO/PIVOT/NEEDS-EVIDENCE]
2. /ooda                     [structured Observe-Orient-Decide-Act]
3. /scenario                 [3 futures: best/worst/likely outcome]
4. /wargame                  [competitor reaction simulation]
5. /premortem                [imagine plan failed → why?]
6. /redteam                  [Devil's Advocate]
7. /office-hours             [YC mode forcing functions]
8. /pareto                   [20/80 leverage point identification]
9. decision document
```

**Auto-stop:** Pokud `oneflow-diagnose` = NEEDS-EVIDENCE → STOP, definuj 72h experiment, ne plný chain.

**OneFlow integrace:** Použij PŘED každým spuštěním nové služby/produktu/pivotu.

---

## Recipe 6: STUCK-UNSTUCK (Creative Block / Default Failed)

**Kdy:** První přístup nefungoval, stuck v iteraci, potřeba breakthrough.

**Chain:**
```
1. /flip                     [ban obvious default, force alternatives]
2. /invert                   [think backward from goal]
3. /angles                   [10 different approaches]
4. /remix                    [combine 2 unrelated ideas]
5. /xray                     [see through surface answer]
6. /blindspots               [what I'm missing]
7. /leverage                 [single highest-impact move]
8. pick best → execute
```

**Token cost:** ~30-50k. Lower stakes than DD-MAX, ne potřebuješ Opus 1M.

---

## Recipe 7: CLIENT-DELIVERABLE (Klientský dokument / nabídka)

**Kdy:** Production-grade dokument pro klienta (ASR proposal, retainer, custom DD output).

**Chain:**
```
1. /oneflow-diagnose         [GO verdict required before build]
2. /godmode                  [comprehensive draft]
3. /l99                      [expert-grade rewrite]
4. /factcheck                [verify all claims]
5. /challenge                [scrutiny pass]
6. /trim                     [cut redundancy]
7. /polish                   [professional finish]
8. oneflow-brand-voice-check [PASS/FIX/STOP gate]
9. huashu-design             [render to klient-facing HTML/PDF nabídka, A4 portrait, OneFlow brand auto-load — viz template `~/Documents/huashu-design-templates/oneflow-nabidka-html.md`]
10. /deset                   [iter to 90+/100]
11. PDF/Web export
```

**OneFlow integrace:** Auto-trigger pro klientský deliverable >50k Kč.

---

## Recipe 8: AD-CREATIVE-MAX (Meta Ads / Sales Letter / Landing Hero)

**Kdy:** Performance ads s >10k Kč budget, hero landing copy, conversion-critical.

**Chain:**
```
1. /angles                   [10 different angles]
2. /hooks10                  [10 hook variants]
3. ad-creative               [generate copy in OneFlow voice]
4. /punch                    [each sentence harder]
5. /banger                   [opening + CTA = banger lines]
6. /viral                    [shareability if organic-paid mix]
7. /challenge                [4-layer adversarial review]
8. /factcheck                [verify all claims]
9. /trim                     [under format limits]
10. A/B test: top 3 variants
```

**OneFlow integrace:** Auto-trigger pro Meta Ads spend >5k Kč/test.

---

## Recipe 9: DEEP-RESEARCH (Topic Research / Competitive Intel / Market Map)

**Kdy:** Comprehensive research na novou doménu, market entry, competitive landscape.

**Chain:**
```
1. /timeline                 [chronological history of topic]
2. /dossier                  [comprehensive briefing]
3. /investigate              [investigative journalist mode, skepticism]
4. /xray                     [see through surface narrative]
5. /gapfinder                [what I don't know]
6. /angles                   [10 different perspectives on topic]
7. /factcheck                [verify all claims]
8. /sources                  [cite every claim]
9. synthesis output
```

**Token cost:** ~60-100k. Často benefits z Opus 4.7 1M (long context preservation).

---

## Recipe 10b: AGENT-CLIENT-FULL (End-to-End AI Agent Klientská Práce)

**Kdy:** Klient přijde s požadavkem na AI agenta. Plný 5-fázový lifecycle (plan→build→deploy→price→sell). Použij když stakes >100k Kč hodnota deal nebo dlouhodobý retainer.

**Chain:**
```
1. /oneflow-diagnose                          [GO/NO-GO gate před investicí času]
   → STOP pokud NO-GO

2. /agent-business-lifecycle plan {client}     [Phase 1 — validation + workflow + stack + criteria]
   → output: 01-plan.md

3. /challenge                                  [Tier A — adversarial review plánu]
   → STOP pokud RISKY (vrať se ke kroku 2)

4. /agent-business-lifecycle build {client}    [Phase 2 — failure points + error handling + tests]
   → output: 02-build.md (3-vrstvý test PASS)

5. /agent-business-lifecycle deploy {client}   [Phase 3 — checklist + sequence + handoff + monitoring]
   → output: 03-deploy.md (LIVE + 24h stabilita)

6. /agent-business-lifecycle price {client}    [Phase 4 — ROI + outcome-based + 3-tier + framework]
   → output: 04-pricing.md

7. /godmode                                    [Tier S — final pricing review pre-call]

8. /agent-business-lifecycle sell {client}     [Phase 5 — pain map + quantification + demo + close]
   → output: 05-sales-call.md

9. POST-CALL (if SIGNED):
   - /closer                                   [contract draft]
   - outreach-oneflow                          [welcome sequence]
   - memory entry                              [client_{slug}_signed_{date}.md]
```

**Token cost:** High ~80-150k pro full lifecycle (rozložené přes 5 sessions).
**Skip when:** quick fix existujícího agenta, interní automation, klient bez budgetu.
**Reference:** `~/.claude/skills/agent-business-lifecycle/SKILL.md` + `~/.claude/expertise/agent-business-lifecycle.yaml`

**Auto-trigger:** "klient chce AI agenta", "mám novou agent zakázku", "připravit nabídku na AI agent", "agent for client {jméno}"

**CZ market anchors:**
- Build fee one-time: 30-300k Kč
- Monthly retainer: 15-300k Kč/měs (Starter/Growth/Enterprise)
- ROI calc povinné PŘED price disclosure (Voss anchoring)

---

## Recipe 11: OF-VISUAL-DELIVERABLE (Brand Visual Output Max)

**Kdy:** Jakýkoli vizuální deliverable v OneFlow brandu — pitch deck, IG carousel, app prototype, animace, infografika, landing mockup. Nahrazuje manuální HTML coding.

**Chain:**
```
1. /of-design                              [intake: format/theme/hero/CTA + brand context load]
   → Pokud brief vague: Stitch exploration phase first
   → Pokud brief vague AND no Stitch: huashu-design "Design Direction Advisor" mode

2. huashu-design                           [primary generation backend]
   - auto-load `~/.claude/memory/personal-asset-index.json` (OneFlow brand)
   - load template z `~/Documents/huashu-design-templates/oneflow-{format}.md`
   - Junior Designer workflow (assumptions + reasoning + placeholder → iterate)
   - Anti-AI-slop checklist applied
   - Format routing:
     * pitch deck → HTML 1920x1080 deck + PPTX export (textboxy)
     * IG carousel → 1080x1350 alternating dark/light, 8 slides
     * app prototype → AppPhone state container, klikatelné, Playwright validated
     * animace → HTML timeline → MP4 60fps + GIF + BGM
     * infografika → print-grade PDF/PNG/SVG
     * landing → mobile-first HTML

3. /of-design quality gates                [Krok 5 v /of-design.md: 9-bod checklist]
   - Monochrome only? Inter Tight only? Hero prominence? White space? Logo? Banned words? Hook? CTA? Render?
   - FAIL na cokoli → fix loop

4. oneflow-brand-voice-check               [copy v designu PASS/FIX/STOP]

5. /design-motion-principles               [POUZE pro animace — audit motion proti Linear/Stripe/Vercel]
   nebo /impeccable                         [POUZE pro static designs — typeset/layout/polish]

6. /deset                                  [iterativní 8-pass loop až 95+/100]

7. Export + handoff
   - HTML: `~/Documents/oneflow-claude-project/output/html/{date}-{topic}.html`
   - PNG/PDF: `~/Documents/oneflow-claude-project/output/export/`
   - MP4: `~/Documents/oneflow-claude-project/output/video/`
   - PPTX: `~/Documents/oneflow-claude-project/output/pptx/`
```

**Token cost:** 25-60k pro static design, 60-120k pro animace s expert review.

**Auto-stop:**
- Pokud `/of-design` quality gates FAIL >2x → eskaluj design rebrief
- Pokud expert review score <70 → vrať se do huashu-design krokem 2 s Keep/Fix list

**OneFlow integrace:** Auto-trigger pro JAKÝKOLI vizuální deliverable klientský/investor-facing. Nahrazuje raw HTML coding.

**Pre-fab templates v `~/Documents/huashu-design-templates/`:**
- `oneflow-investor-pitch.md` — 12-slide deck struktura
- `oneflow-nabidka-html.md` — A4 klientská nabídka
- `oneflow-ig-carousel.md` — 1080x1350 IG carousel (8 slides)
- `oneflow-asr-landing.md` — B2B SaaS hero landing
- `oneflow-dd-infographic.md` — DD scoring viz infografika
- `oneflow-meta-ad.md` — Meta ads creative variations

---

## Recipe 10: SHIP-GATE (Pre-Deploy Final Quality Gate)

**Kdy:** Před každým shipem klientského výstupu / production deploy / send.

**Chain:**
```
1. /sentinel                 [error/risk surface]
2. /factcheck                [final claim verification]
3. /challenge                [final adversarial review]
4. /trim                     [final cut]
5. ship-checker (gstack)     [secrets/links/copy errors]
6. ship
```

**Token cost:** Low ~10-15k. Aplikuj na 100% high-stakes outputs.

---

## Recipe 12: IMAGE-GEN-MAX (OneFlow Brand Image / Hero Shot / Carousel Visual)

**Kdy:** Hero landing image, IG carousel slide, ad creative visual, OneFlow brand asset, klientský deliverable visual.

**Chain:**
```
1. /prompt-master            [tool routing — fal.ai default, Krea premium, Kie free, MJ if explicit]
                             [auto-loads oneflow-context.md → monochrome lock, Inter Tight, brand colors]
2. /redteam                  [find ways prompt could produce off-brand output — saturated colors, wrong aspect, generic stock-look]
3. fal.ai / Krea / Kie       [execute via Filip's image AI stack]
4. /design-review            [visual QA — does it match OneFlow brand DNA?]
5. (if iteration needed)     [/prompt-master reroll with constraint adjustments]
```

**OneFlow integrace:** Default tool = fal.ai. Banned: Google Imagen API (cost-zero), saturated colors, gold accents, generic stock-look.
**Token cost:** Med ~15-25k.

---

## Recipe 13: VIDEO-PROMPT-MAX (Seedance / HyperFrames Video)

**Kdy:** Brand story video, social hook, motion design ad, e-commerce video.

**Chain:**
```
1. /prompt-master            [tool routing — seedance-brand-story / -social-hook / -motion-design / -ecommerce-ad]
                             [auto-loads oneflow-context.md for brand consistency]
2. seedance-* skill          [target seedance variant per use case]
3. (long-form?) HyperFrames  [Filip's Remotion stack for >30s pieces]
4. /design-review            [motion + brand QA]
```

**OneFlow integrace:** seedance for short, HyperFrames for long. Both respect monochrome lock.
**Token cost:** Med ~15-30k.

---

## Recipe 14: CODING-AGENT-PROMPT (Cursor / Cline / Codex / Claude Code Subagent)

**Kdy:** Tuning Cursor rules, building Cline custom agent, Codex CLI prompt design, Claude Code subagent spec.

**Chain:**
```
1. /prompt-master            [target = "Cursor" or "Cline" or "Codex" or "Claude Code subagent"]
                             [embeds reasoning-native model awareness — no CoT for Opus 4.7/o3/R1]
2. /redteam                  [find ways agent could fabricate / hallucinate]
3. /factcheck                [if prompt embeds factual claims about codebase]
4. /sentinel                 [pre-deploy gate — agent prompt audit]
```

**OneFlow integrace:** Filip's coding agent stack uses Opus 4.7 / Sonnet 4.6 / Haiku 4.5 — never embed think-step-by-step.
**Token cost:** Low-Med ~10-20k.

---

## AD-CREATIVE-MAX (Recipe 8) — UPDATED 2026-04-30

**Pre-step injection (when image visual needed):** Insert `/prompt-master` → image AI execution PŘED step 3 (ad-creative copy gen). Reason: copy + visual together = consistent storytelling, ne fragmented.

```
0. /prompt-master + image-gen   [if visual needed — Recipe 12 inline]
1. /angles                       [10 different angles]
2. /hooks10                      [10 hook variants]
3. ad-creative                   [generate copy in OneFlow voice]
... [rest unchanged]
```

---

## CONTENT-VIRAL (Recipe 4) — UPDATED 2026-04-30

**Pre-step injection (carousel image generation):** Insert `/image-prompt` → execution AFTER ig-content-creator structures slides, BEFORE final repurpose. Per-slide prompt generation.

---

## Chain Composition Rules

1. **Max 10 commands per chain.** Beyond that, splituj a checkpointuj `/checkpoint` mezi tier.
2. **Tier order matters.** S → A → B → C → D, ne random. Quality gate (S) before adversarial (A) ne má smysl.
3. **Stop conditions explicit.** Každý recipe má auto-stop pro KILL/HOLD verdict.
4. **OneFlow skills first.** Vždy preferuj `dd-emitent`, `outreach-oneflow`, `oneflow-diagnose` jako entry-point. Power commands rewrite/scrutinize jejich output.
5. **Token budget aware.** Recipe >100k tokens → Opus 4.7 1M. Recipe >200k → split + checkpoint.
6. **Skip granular for trivial.** Recipe SHIP-GATE může být celý chain ale typo fix to nechce.

---

## Anti-Recipes (NIKDY)

| Bad chain | Proč ne |
|---|---|
| `/godmode` + `/beastmode` + `/l99` | 3× max-effort overlap, žereš tokeny |
| `/ghost` na investor/legal | Anti-AI-detection může poškodit precision |
| `/unlocked` + `/nofilter` na klientský výstup | Internal debate-mode only |
| Tier C + bez Tier A | Polish bez factcheck = pretty mistake |
| `/ooda` na "fix typo" | Tier B na operativní task = absurd |
| Chain >10 steps | Diminishing returns, raději splituj |

---

## Custom Chain Builder

Pro nový workflow:
1. Identifikuj task signature (DD, outreach, content, decision, polish)
2. Tier picker:
   - Stakes >50k Kč nebo reputational? → Tier S + A povinný
   - Decision required? → Tier B
   - Output je text/copy? → Tier C
   - Discovery phase? → Tier D
3. Compose: max 8-10 commands, S→A→B→C→D order
4. Add stop conditions (KILL/HOLD/PASS verdicts)
5. Test 3× → tune → save jako recipe v tomto souboru

---

## Maintenance Log

- 2026-04-28: Initial draft, 10 recipes mapped to OneFlow workflows
- Source: `~/.claude/commands/` (40+ slash commands), `~/.claude/skills/` (304+ skills)
- Decision matrix: `~/.claude/rules/power-skills-stack.md`
