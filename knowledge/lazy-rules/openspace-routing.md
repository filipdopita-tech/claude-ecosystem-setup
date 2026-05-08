# OpenSpace Routing (load on-demand)

Local + cloud registry = 10+ OneFlow-related skills. Triggers kdy volat `execute_task` nebo `search_skills`:

**Auto-search KDYŽ:** před implementací nové logiky, Filip zmíní workflow co už může být skill, task má deterministic strukturu (ARES lookup, DSCR calc, deliverability probe)
```
mcp__openspace__search_skills(query="<task description>", source="all")
→ hit >= 80% confidence = použij skill, ne reimplement
```

**OneFlow private skills v cloudu (Agent: OneFlow, 6 skills):**
| Task trigger | Skill | Use |
|---|---|---|
| DSCR, EBITDA / debt service, emitent scoring | `oneflow-dscr-screener` | first-layer DD, GO/REVIEW/RED |
| LTV, kolaterál, loan-to-value, zástava | `oneflow-ltv-screener` | haircut-aware, 50/70/75% thresholds |
| ARES, IČO lookup, CZ firma enrichment | `oneflow-ares-enrichment` | status, legal form, risk flag |
| A-F grade, composite risk, DD verdict | `oneflow-emitent-risk-score` | 6-dim weighted scoring |
| SPF, DKIM, DMARC, blacklist, pre-send | `oneflow-deliverability-check` | SEND/HOLD/FIX verdict |
| brand voice, banned words, copy check, AI patterns | `oneflow-brand-voice-check` | PASS/FIX/STOP |

**Community skills staženo (7+ in `/community/`):**
- `long-form-writer`: 2000+ slov articles, multi-layer expansion (DD memos)
- `cron-doctor`, `cron-log-analysis`: cron job failure triage
- `nano-pdf`: PDF editing via natural language (prospekty)
- `council`: multi-perspective feedback (strategická rozhodnutí)
- `arxiv`: akademické papery (OSINT research)
- `daily-news-push-system`, `open-sea-automation`: auto-sync from weekly cron

**NE-používat OpenSpace pro:**
- Triviální ops (grep, read, ls) — overhead 30+ s
- Nedeterministické kreativní úkoly (brainstorm, strategie) — Opus 4.7 direct
- Finanční rozhodnutí s nuancí — skills jsou screening, ne verdikt
