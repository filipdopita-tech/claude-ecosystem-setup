# Product / UX / CRO Megabase

Synthesized from:
- Filip's repo: `filipdopita-tech/claude-ecosystem-setup` (growth-hacker agent, gsd-ui-auditor, gsd-ui-researcher, gsd-roadmapper, content-creation expertise, design-visual expertise)
- Adam's repo: `adamkropacek/claude-ecosystem-adam` (content-creation, design-visual, frontend-ui expertise)

Domains excluded (covered in ads-sales-megabase.md): paid acquisition, ad creative, outbound sales, CRM.

---

## Product Strategy

### Jobs-to-be-Done / Positioning

**Both repos are sparse on explicit JTBD frameworks.** What exists is embedded in roadmapping and growth scaffolding:

- The GSD Roadmapper uses "goal-backward thinking": define what must be TRUE for users when each phase completes — not what features were shipped. This maps to JTBD outcome framing: the job is done when a user-observable state changes, not when code merges. (Filip)
- Phases should "feel inevitable, not arbitrary" — coherence test: each phase delivers one complete capability a user can exercise end-to-end.
- Observable success criteria are written from user perspective, not implementation task lists. Example anti-pattern: "implement auth" vs correct: "user can register, verify email, and log in without support contact."
- North star proxy in growth context: AARRR with explicit numeric targets per stage. Activation is defined as the user receiving first value within 24 hours of signup — the 24-hour window is a hard constraint, not a guideline. (Filip, Adam)
- Positioning for investment/financial products in Czech market: organic Instagram has lowest CAC; LinkedIn is B2B-only; referral programs work because trust networks in Czech market are personal and high-friction, making peer referral more effective than paid. (Filip)

### Roadmap / Prioritization

- PIE scoring: Potential × Importance × Ease. All experiment candidates require a measurable hypothesis + defined success metric before logging. Unlogged experiments are invisible and waste compounded iteration budget. (Filip)
- Roadmap phases: 2–5 phases maximum for v1. More than 5 phases signals scope that should be cut or deferred.
- Every v1 requirement maps to exactly one phase — orphaned requirements (unmapped to any phase) are a planning defect, not acceptable ambiguity.
- Solo developer constraint: avoid enterprise PM theater. No sprints, no velocity tracking, no ceremony that a one-person team cannot act on.

---

## UX Patterns

### UI Audit Framework (6 Pillars) — Filip

The GSD UI Auditor scores 1–4 on six pillars with grep-level evidence (no subjective impressions):

1. **Copywriting** — audit target: generic labels, missing empty-state copy, missing error-state copy. "Submit" and "Click here" fail. Empty states without explanation or next-step fail.
2. **Visuals** — focal point present per screen; icons always paired with labels (icon-only fails accessibility and comprehension); visual hierarchy must be detectable from 3m away.
3. **Color** — accent usage counted per file; hardcoded color hex values outside the design token system are flagged as violations; maximum accent usage is bounded (over-accenting kills hierarchy).
4. **Typography** — maximum 2 font weights per page; font size distribution must have detectable hierarchy (all-same-size fails); negative letter-spacing on large headings is correct.
5. **Spacing** — internal consistency within a declared scale (8px base or Tailwind spacing); mixing arbitrary pixel values and Tailwind scale classes is a defect.
6. **Experience Design** — loading state coverage, error state coverage, empty state coverage, disabled state coverage. All four must exist. Missing any one is a pillar deduction, not a minor note.

Top-3 priority fix format per audit: specific issue → user impact → concrete solution. No vague "improve the UX" recommendations.

### Microcopy Rules

- Every destructive action requires a confirmation with specific consequence phrasing ("This will permanently delete your account and all data — cannot be undone") not generic ("Are you sure?").
- Error messages must answer: what went wrong + what to do next. "Something went wrong" fails both.
- Empty states must contain: what this space is for + action to populate it. Blank canvas with no guidance is a dead end.
- Form field labels above the input, not inside (placeholder). Placeholder text disappears on focus and fails for users returning mid-form.
- CTA copy should state outcome, not action: "Start earning" > "Submit"; "See your results" > "Continue".

### Design System Constraints (Filip — OneFlow context, generalizable)

- Monochrome-first systems: elegance through contrast and spacing, not accent color proliferation. Each accent use must justify itself.
- "Every element must either inform or guide" — decoration without function should be removed.
- Typography: body text 1.5–1.7 line-height, max 65ch width. Negative letter-spacing on headings (-1.2 to -2.5px at large sizes).
- No Playfair Display or equivalent decorative serifs in digital product contexts (2026 design pattern).
- Max 2 font weights per page — additional weights create visual noise without proportional hierarchy gain.
- Modern CSS (2026): scroll-driven animations via `animation-timeline: view()` eliminate JS overhead; container queries over media queries for component-level responsivity.

### UI Spec Contract Pattern (Filip)

Before any frontend implementation phase, produce a UI-SPEC.md as a prescriptive design contract. Prescriptive means specific values: "16px body at 1.5 line-height" not "consider 14–16px." Ambiguous specs produce inconsistent implementations.

Design contract covers: color tokens, type scale, spacing scale, component inventory, third-party registry safety check (each external component registry is vetted before inclusion — flags fetch/eval/env exfiltration patterns).

---

## CRO (Conversion Rate Optimization)

### Landing Page Patterns

- Above-fold CTA is mandatory. Scroll-to-CTA layouts convert worse on mobile.
- Social proof placement: below the hero headline, before the feature list. Social proof after features is too late — skeptical visitors exit before features.
- Form field count inversely correlates with conversion. Minimum viable form: email only for top-of-funnel. Add fields only when the data is used immediately (personalization, routing).
- Mobile-first and sub-3-second load are table stakes, not differentiators. Violating either is a conversion floor, not a ceiling concern. (Filip)
- Value proposition must be specific. "The best platform for X" fails. "X in 24 hours without Y" works because it answers the user's implicit question: "what changes for me and how fast?"

### Cognitive Load Reduction

- Single primary action per screen. Multiple equal-weight CTAs split attention and reduce total clicks on any one.
- Navigation hidden or minimal on landing/conversion pages. Navigation links are exits.
- Progress indicators on multi-step flows reduce abandonment — users who can see "step 2 of 4" complete at higher rates than users with no progress signal.
- Contrast between active and inactive states must be perceptible without color (color-blind safe): rely on border weight, opacity, or icon change, not color alone.

### Friction Audit Checklist

Audit entry points in order of friction cost:

1. Time-to-first-value (TTFV) — how long from landing to experiencing the product's core value. Target: under 5 minutes for SaaS, under 60 seconds for consumer.
2. Registration gate — is account creation required before value is shown? Deferring signup until after value delivery increases activation rate.
3. Form cognitive load — field count, required vs optional clarity, inline validation (on blur, not on submit).
4. Error recovery paths — after a user error, is recovery one click or three?
5. Mobile input friction — phone number fields, date pickers, and dropdowns all have mobile failure modes. Test each on iOS Safari.

### Experimentation

- PIE framework for prioritization (Filip): score each candidate on Potential (conversion uplift ceiling), Importance (traffic volume on that page/flow), Ease (implementation cost). Run highest PIE first.
- All experiments require: baseline metric, target metric, sample size estimate, and defined end condition. Experiments without end conditions run indefinitely and produce inconclusive data.
- A/B test one variable at a time on small-traffic sites. Multivariate testing requires orders of magnitude more traffic to reach significance.
- KPI targets (Filip/Adam): IG save rate 3–5%, engagement 6–10%; email open rate 30–40%, CTR 3–5%; web on-page time >2 minutes, scroll depth >60%.

---

## Retention

### Activation Moment

- Activation is defined as the user experiencing the product's core value within 24 hours of signup — this is the single most predictive event for long-term retention. Users who do not activate in 24 hours have dramatically lower 30-day retention. (Filip, Adam — consistent across both repos)
- Activation should be measurable as a single binary event: "user did X" not "user explored the product."
- Onboarding flow goal: get the user to the activation event by the shortest path. Every step that does not directly advance toward the activation event is friction.

### Habit Loops

- Retention cadence (Filip/Adam): 2x weekly touchpoints via email/newsletter is the documented retention mechanism in both repos. Less frequent loses mind share; more frequent increases unsubscribe rate.
- Referral mechanism: for trust-based products (financial, professional), referral works when the incentive is bilateral (both referrer and referee get value) and when the referral action is low-friction (share a link, not fill a form).
- Trigger → Action → Variable Reward → Investment model: products that encode user data over time (investment history, preferences, created content) create switching costs that function as retention. Build for data accumulation from day one.

### Reactivation

**Both repos are sparse on explicit reactivation campaign patterns.** What exists is structural:
- Email is the primary reactivation channel (both repos treat it as the owned retention channel).
- Reactivation emails should reference specific user activity or inactivity ("You haven't checked your portfolio in 14 days") — behavior-triggered emails outperform broadcast.
- AARRR funnel structure implies reactivation sits between Retention and Referral: a lapsed user who reactivates can become a referrer if the reactivation experience is strong.

### Churn Signals

**Sparse in both repos.** No explicit churn signal taxonomy documented. Inferred from funnel structure:
- Non-activation within 24 hours is the primary leading indicator.
- Drop in weekly engagement cadence (email open rate declining) is the lagging indicator.
- No documented behavioral churn model (session frequency thresholds, feature abandonment patterns) in either repo.

---

## Pricing Strategy

**Both repos are sparse on pricing strategy.** Neither contains a dedicated pricing framework, tier design, anchoring patterns, or free trial vs freemium analysis. The only documented pricing signal:**

- Unit economics constraint (Filip — growth-hacker agent): maintain LTV:CAC ratio above 3:1 with payback period under 6 months. This constrains pricing floor: price must be high enough that LTV/3 covers acquisition cost within 6 months.
- Revenue model in documented context: placement fees + advisory services (professional financial services context). Not a SaaS subscription model.
- No documented value-based pricing methodology, tier anchoring, or free trial conversion data in either repo.

**Gap recommendation:** If pricing strategy knowledge is needed, mine dedicated product/pricing sources (Reforge, Price Intelligently / ProfitWell corpus, or Stripe Atlas pricing guides) — neither Filip's nor Adam's repo contains this domain.

---

## Cross-Cutting Patterns

### AARRR Funnel — Documented Numbers (Filip + Adam, consistent)

| Stage | Mechanism | Target KPI |
|---|---|---|
| Acquisition | Organic Instagram, email, SEO, LinkedIn (B2B) | Instagram: 6–10% engagement, 3–5% saves |
| Activation | First value within 24 hours; 5-email welcome series | Email: 30–40% open rate |
| Retention | 2x weekly newsletter | Email: 3–5% CTR |
| Referral | Bilateral incentive, friend invite = free consultation | Not quantified |
| Revenue | Placement fees, advisory | LTV:CAC > 3:1, payback < 6 months |

### Channel Priority by CAC (Filip — Czech market context)

1. Organic Instagram (lowest CAC)
2. Email/newsletter (owned, no ongoing CAC)
3. SEO/blog (slow build, near-zero marginal CAC at scale)
4. LinkedIn (B2B segments only)
5. Referral programs (high trust, low reach)
6. PR placements (medium CAC, credibility multiplier)
7. Events (high CAC, high close rate for high-ACV deals)

### Content Hook Formulas (Filip + Adam — identical across both repos)

For content-driven CRO and top-of-funnel:
- **Curiosity gap**: unknown information angle ("What 80% of investors don't know about X")
- **Relatable pain**: first-person cost experience
- **Pattern interrupt**: contradiction to conventional wisdom
- **Stat bomb**: surprising data point as opening line
- **Urgent command**: warning against common mistake
- **Contrarian**: unpopular truth stated directly

Carousel structure for conversion content (7 slides max): Hook → Problem → Solution → Proof → Steps → Example → CTA. This is the same in both repos — indicates tested, not speculative.

### Posting Cadence (Czech market, Filip + Adam)

- Instagram: Tue–Thu, 12:00–13:00 or 19:00–21:00
- Newsletter: Tue–Wed, 07:00–09:00
- LinkedIn: Tue–Thu, 08:00–10:00 or 17:00–18:00

Reel formula: 0–3s hook, 3–8s setup, 8–22s value, 22–30s CTA. No introductions — state the hook immediately.
