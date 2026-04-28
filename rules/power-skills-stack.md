# Power Skills Stack — 6-Tier Decision Matrix

## PRIORITA: Aktivuj na high-stakes výstupy (DD, investor materiál, ad copy, pivot, klientský deliverable)
Tento rule operuje SPOLU s existujícími rules — nepřepisuje voice, brand, cost-zero ani fb-safety. Volá power slash commands z `~/.claude/commands/` v řetězech podle situace.

---

## Tier System (40+ commands → 6 tier)

Každý tier má vlastní **trigger condition** a **typický chain partner**. Skills volej v pořadí tier S → A → B → C → D, ne náhodně.

### TIER S — Hardcore Quality Gates
Aplikuj jako **finální push** před shipnutím high-stakes výstupu.

| Command | Co dělá | Použij když |
|---|---|---|
| `/godmode` | Max effort, extended thinking, no shortcuts | Comprehensive answer, no detail can be skipped |
| `/beastmode` | Max output quality | Single-pass max effort (rychlejší než godmode) |
| `/l99` | Level 99 expertise cap (top expert framing) | Klientský deliverable kde expertní niveau = nutnost |
| `/deset` | Iterativní eval-loop, 8 iterací do 10/10 | Po draft, finální polish loop |

**Nikdy nedávej víc než 1 z těchto v sérii** (overlap >70%, jenom žereš tokeny). Vyber pattern:
- Speed: `/beastmode` (1 pass)
- Depth: `/godmode` (1 pass + extended thinking)
- Iteration: `/deset` (8 pass loop)
- Authority framing: `/l99` (rewrite jako world-class expert)

### TIER A — Critical Analysis (Adversarial Layer)
Aplikuj **před shipem** kdykoli stakes > 10k Kč nebo reputační dopad.

| Command | Co dělá | Použij když |
|---|---|---|
| `/challenge` | 4-layer scrutiny: stakes + adversarial + obviously-trap + ACH matrix | Před high-stakes rozhodnutím |
| `/redteam` | Devil's Advocate, 5 mandatory questions, evidence standard | Tear apart nápad před investicí času/peněz |
| `/mythos` | Bayesian falsification + ACH + calibrated confidence | Komplexní task, security-first, OneFlow stakes |
| `/sentinel` | Error/risk surface scan | Před deploy, code review, shipnutí |
| `/factcheck` | Verify all factual claims | Cokoli s čísly, citacemi, fakty |
| `/blindspots` | What I'm missing, hidden assumptions | Když cítím že odpověď je moc clean |

**Chain pattern:** `/challenge` jako primary, `/redteam` jako follow-up když verdict = RISKY. `/mythos` substitutes both pro maximum stakes.

### TIER B — Strategic Reasoning (Decision Frameworks)
Aplikuj **před rozhodnutím**, ne před výstupem.

| Command | Co dělá | Použij když |
|---|---|---|
| `/ooda` | Observe-Orient-Decide-Act loop | Tržní situace, konkurence move, rychlé rozhodnutí |
| `/scenario` | 3 futures: best/worst/likely | Plánování s nejistotou, big bet rozhodnutí |
| `/wargame` | Competitor/opponent simulation | Před launch, pricing change, positioning shift |
| `/premortem` | Imagine plan failed → why? | Před spuštěním nového projektu/služby |
| `/office-hours` | YC mode 6 forcing functions | Strategic clarity, kill weak ideas |
| `/flip` | Ban obvious default, force alternatives | Stuck, default by selhal, potřeba kreativity |
| `/chainlogic` | Explicit reasoning chain step-by-step | Komplexní logika kde každý krok záleží |
| `/ceomode` | CEO high-stakes business framing | Big budget, hiring, strategic call |
| `/founder` | Founder perspective advice | Pivot rozhodnutí, runway, prioritization |
| `/invert` | Think backward from goal | Goal-backward analysis, design thinking |

**Chain pattern:** Pick 1-2 primary, ne všechny. `/ooda` pro reactive, `/scenario` pro planning, `/wargame` pro competitive.

### TIER C — Output Polish (Copy/Content)
Aplikuj **na finální text** před shipnutím (post-eval, pre-publish).

| Command | Co dělá | Použij když |
|---|---|---|
| `/ghost` | Anti-AI-detection rewrite | Klientský ghostwriting, SEO obsah |
| `/punch` | Každá věta hard | Copywriting, ad copy, landing page |
| `/banger` | Viral-grade line | Hook, opening, subject line |
| `/storysell` | Story narrative struktura | Pitch, sales letter, case study |
| `/trim` | Cut fluff, redundancy | Jakýkoli text >100 slov |
| `/polish` | Professional polish | Investor email, klientský dokument |
| `/raw` | Strip formatting (no bold/headers) | Plain text výstup, conversation feel |
| `/viral` | Shareability optimization | Social posts, blog headlines |
| `/hook` | Rewrite opening to grab attention | First sentence email/post/article |
| `/hooks10` | 10 hook variants | Před publikací — vybrat nejlepší |
| `/rephrase` | Same content, different words | Repurpose, A/B test variants |
| `/cliffhanger` | Curiosity-driven ending | Newsletter, post, story ending |
| `/thumbnail` | Click-maximizing title/headline | YT video, blog post, IG carousel |
| `/captionme` | Engagement-driving social caption | IG, FB, LinkedIn caption |

**Chain pattern:** `/punch → /trim → /polish` pro klientské. `/hooks10 → vyber → /banger → /viral` pro social.

### TIER D — Discovery / Brainstorm
Aplikuj **na začátku** (explore phase), ne před shipem.

| Command | Co dělá | Použij když |
|---|---|---|
| `/angles` | 10 different approaches | Stuck, prvotní explorace tématu |
| `/remix` | Combine 2 unrelated ideas | Cross-pollination, creative breakthrough |
| `/xray` | See through surface answer | Co je za prvním layerem? |
| `/unpack` | Break complex idea to components | Přehledný breakdown |
| `/pareto` | 20/80 leverage points | Prioritizace, time/effort allocation |
| `/bottleneck` | Single biggest constraint | Optimalizace systému |
| `/leverage` | Single highest-impact move | Strategic prioritization |
| `/gapfinder` | What I don't know | Knowledge gap audit |
| `/timeline` | Chronological history of topic | Background research |
| `/dossier` | Comprehensive briefing on topic/person | Pre-meeting prep |
| `/persona` | Respond as specific expert | Sektorový pohled |
| `/mirror` | Match writing sample tone | Style replication |

### TIER E — Reasoning Depth Modulation
Volej když **default thinking není dost**.

| Command | Co dělá | Použij když |
|---|---|---|
| `/deepthink` | Extended thinking, every layer | Komplexní problém |
| `/overthink` | Deliberately over-analyze | Detail catch, edge cases |
| `/investigate` | Investigative journalist mode | Hluboký research with skepticism |
| `/mentor` | Personal mentor framing | Career/strategy advice |
| `/megaprompt` | Generate detailed comprehensive prompt | Když mám rough idea → potřebuju spec |
| `/promptfix` | Fix vague/bad prompt | Po prvním fail — refine input |
| `/autoprompt` | Build perfect prompt from rough idea | Recursive self-improvement |
| `/teachme` | Structured lesson, not just answer | Want to learn, not just solve |
| `/masterclass` | World-class expert teaching | Deep skill acquisition |

### TIER F — Format Modifiers (no logic change, just shape)

| Command | Co dělá |
|---|---|
| `/eli5` | Five-year-old explanation |
| `/digest` | Read all → essence only |
| `/layered` | 3 levels of explanation |
| `/flow` | Smoother reading |
| `/voice` | Lock tone for rest of conversation |
| `/rolelock` | Lock specific role |
| `/unlocked` | Remove caution, hedging |
| `/nofilter` | Direct unfiltered honest assessment |
| `/sources` | Back up every claim with sources |

---

## Decision Matrix — Kdy volat co

| Task signature | Tier sequence |
|---|---|
| DD report, investor memo, prospekt | S(godmode) → A(challenge+redteam+factcheck) → S(deset) |
| Cold email, outreach DM | outreach-oneflow → C(ghost+punch+trim) → A(factcheck) |
| IG carousel, reel script, post | D(angles+hooks10) → ig-content-creator → C(ghost+banger+viral) |
| Strategic decision (pivot, hiring, big bet) | B(ooda+scenario+wargame+premortem) → A(redteam) → A(office-hours) |
| Stuck/creative block | D(flip+angles+remix+blindspots) → pick best |
| Klientský deliverable (nabídka, návrh) | oneflow-diagnose → S(godmode+l99) → C(polish+trim) → A(challenge) |
| Landing page copy, ad creative | D(angles) → C(punch+banger+hook+viral) → A(challenge) → S(deset) |
| Code/architecture decision | B(scenario+premortem) → A(challenge+redteam) → ship |
| Quick fact-check, verify claim | A(factcheck+sources) only |
| Brainstorm, explore | D(angles+remix+blindspots+xray) only |
| Polish existing draft | C(trim+polish) → S(deset) only |

---

## Anti-Patterns (NIKDY)

1. **Tier stacking >3 v jednom chain** — overhead > benefit. Max 3 commands za sebou.
2. **/godmode + /beastmode + /l99** — všechny tři dělají totéž. Pick one.
3. **Tier C bez Tier A** na high-stakes výstup — polish bez factcheck = pretty mistake.
4. **Tier D na finální text** — discovery commands jsou pre-draft, ne post-draft.
5. **/ghost na investor/legal/compliance dokumenty** — anti-AI-detection může poškodit precision.
6. **`/unlocked` + `/nofilter` na klientský výstup** — interní debate-mode only.
7. **Tier B na operativní task** — `/ooda` na "fix typo" = absurd.

---

## Auto-Trigger Mapping (pro hooks/routing)

Tyto patterns aktivují power chain bez explicit /command:

| Filip phrase | Auto-chain |
|---|---|
| "fakt důležité", "kritické", "stakes vysoké" | Tier S(godmode) + Tier A(challenge) |
| "rozcupuj to", "najdi díry", "co může selhat" | `/redteam` + `/sentinel` |
| "vymysli alternativy", "stuck", "default selhal" | `/flip` + `/angles` + `/remix` |
| "rozhodni mezi", "jaká strategie", "kam jít" | `/ooda` + `/scenario` |
| "co kdyby spadlo", "premortem", "co když selže" | `/premortem` + `/redteam` |
| "udělej to viral", "punch hardr", "banger" | `/banger` + `/punch` + `/viral` |
| "neznělo to AI", "ghostwrite", "lidsky" | `/ghost` + `/trim` + `/polish` |
| "deep dive", "max detail", "comprehensive" | `/godmode` (or `/beastmode` for speed) |
| "10 nápadů", "10 angles", "víc verzí" | `/angles` (or `/hooks10` for hooks) |
| "co mi uniká", "blind spots", "co nevidím" | `/blindspots` + `/xray` |

---

## Vztah k existujícím rules

- **`workflow-routing.md`**: koexistuje, power-skills-stack přidává Tier dimension. Workflow-routing řeší WHEN (which skill), tento rule řeší DEPTH (how hard).
- **`reasoning-depth.md`**: tier S aktivuje full-depth mode automaticky.
- **`completion-mandate.md`**: Tier S se aktivuje když Filip explicit "kompletně dokonči", Tier A před každým ship.
- **`oneflow-all.md`**: voice/banned words wins při konfliktu s `/ghost`. Pro OneFlow brand content NIKDY nepouštěj `/ghost` na finální text.
- **`writing-sentence-craft.md`**: Tier C operuje POD těmito sentence-level rules.

---

## Skip when (NEAKTIVUJ)

- Triviální ops: grep, ls, mv, status check, single read
- Conversation/info-only odpovědi (Filip se ptá "co to je")
- Refactoring/bugfix kde není creative dimension
- Explicit override: "rovnou", "rychlý draft", "bez loopů", "skip skill"

---

## Maintenance

Když přibude nový power command v `~/.claude/commands/`:
1. Zařadit do tier (S/A/B/C/D/E/F) podle funkce
2. Přidat řádek do tier table
3. Zvážit auto-trigger pattern v workflow-routing.md
4. Test: `/skill-health` ukazuje aktuální usage

Soubor maintainovaný 2026-04-28+, source audit `~/.claude/commands/` (40+ slash commands).
