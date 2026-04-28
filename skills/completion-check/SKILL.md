---
name: completion-check
description: Audit completion-mandate violations from current session + last 7/30 days. Reads violations.jsonl + hook logs, summarizes blocking-phrase patterns, fires improvement suggestions. Use ad-hoc to verify enforcement is working ("/completion-check") or after a frustrating session ("show me where I gave up").
allowed-tools: Read, Bash, Grep, Glob
---

# Completion Check

Lokální audit completion-mandate enforcement. Ukáže Filipovi:
1. Kolik violations bylo detekováno (period: session / 7d / 30d)
2. Které fráze nejčastěji
3. Které soubory / nástroje nejvíc problematic
4. Trend — fungs systém line-up nebo decline

## Použití

```
/completion-check          # default: 7 dní
/completion-check session  # jen current session
/completion-check 30       # last 30 days
/completion-check trend    # weekly trend
```

## Implementace (krok po kroku)

### 1. Determinujte time window

```bash
ARG="${1:-7}"
case "$ARG" in
  session) WINDOW="session" ;;
  trend)   WINDOW="trend" ;;
  *)       WINDOW="${ARG}d" ;;  # 7d / 30d / 1d
esac
```

### 2. Source data

- Violations log: `~/.claude/projects/<your-project-id>/memory/completion-mandate-violations.jsonl`
- Hook logs:
  - `~/.claude/logs/completion-mandate-hook.log` (UserPromptSubmit injects)
  - `~/.claude/logs/completion-blocking-hook.log` (Write/Edit warnings + blocks)
  - `~/.claude/logs/completion-stop-hook.log` (Stop hook detections)

### 3. Parse + aggregate (Bash + jq)

```bash
VIOLATIONS=~/.claude/projects/<your-project-id>/memory/completion-mandate-violations.jsonl

# Default 7d filter
SINCE=$(date -u -v-7d +%Y-%m-%d)

# Total count
TOTAL=$(jq -s "[.[] | select(.ts >= \"$SINCE\")] | length" "$VIOLATIONS")

# Top phrases
jq -s "[.[] | select(.ts >= \"$SINCE\") | .phrases | split(\"|\") | .[]] | group_by(.) | map({phrase:.[0], count:length}) | sort_by(.count) | reverse | .[0:10]" "$VIOLATIONS"

# Top files
jq -s "[.[] | select(.ts >= \"$SINCE\") | .file] | group_by(.) | map({file:.[0], count:length}) | sort_by(.count) | reverse | .[0:10]" "$VIOLATIONS"

# Tool breakdown
jq -s "[.[] | select(.ts >= \"$SINCE\") | .tool] | group_by(.) | map({tool:.[0], count:length})" "$VIOLATIONS"

# Sessions affected
jq -s "[.[] | select(.ts >= \"$SINCE\") | .session] | unique | length" "$VIOLATIONS"

# Block events (exit 2 fired)
grep "BLOCK" ~/.claude/logs/completion-blocking-hook.log | tail -20

# Override events
jq -s "[.[] | select(.ts >= \"$SINCE\" and .override == true)] | length" "$VIOLATIONS"
```

### 4. Trend (weekly)

```bash
# Last 4 weeks, count violations per week
for W in 0 1 2 3; do
  START=$(date -u -v-$((W*7+7))d +%Y-%m-%d)
  END=$(date -u -v-$((W*7))d +%Y-%m-%d)
  COUNT=$(jq -s "[.[] | select(.ts >= \"$START\" and .ts < \"$END\")] | length" "$VIOLATIONS")
  echo "Week -$W: $COUNT violations ($START → $END)"
done
```

### 5. Output formát

```markdown
## Completion-Mandate Audit — last 7 days

**Total violations:** 23
**Sessions affected:** 4 / 12 (33%)
**Blocks fired (exit 2):** 2
**Overrides used:** 1
**Trend (4 weeks):** 31 → 23 → 18 → 12 (↓ improvement)

### Top blocking phrases
1. potřebuji-vaše-cz: 8x
2. doporučuji-bez-akce-cz: 6x
3. není-možné-cz: 4x
4. po-schválení-cz: 3x
5. omluva-blokátor-cz: 2x

### Top problematic files
1. ~/Documents/oneflow-nabidky/draft-12.html (5x)
2. ~/Desktop/dd-emitent-X.md (3x)

### Tools breakdown
Write: 12 | Edit: 8 | Stop: 3

### Recent block events
2026-04-26T15:23 Write /Users/.../offer.html (3 hits, 612 chars)
2026-04-25T11:08 Edit /Users/.../report.md (4 hits, 845 chars)

### Recommendations
- "potřebuji vaše" je top phrase → chytíš se na decision-deflect, dotahuj rozhodnutí
- 2 blocks v 7d = healthy enforcement (ne moc, ne málo)
- Trend ↓ = rule funguje, edge cases klesají
```

### 6. Bonus: Filip-friendly prompts

Pokud TOTAL == 0 v 7d → "Hotovo. Žádné violations. Systém je tichý nebo session-light."
Pokud TOTAL > 50 v 7d → "POZOR: vysoký count. Zvaž rule revize nebo deeper investigation."
Pokud trend roste 3 weeks v řadě → "REGRESSION: violations rostou. Podívej se na rule drift."

### 7. Status line integration (optional)

Generovat malé `~/.claude/state/completion-violations-24h.txt`:

```bash
COUNT_24H=$(jq -s "[.[] | select(.ts >= \"$(date -u -v-1d +%Y-%m-%dT%H:%M:%SZ)\")] | length" "$VIOLATIONS" 2>/dev/null || echo 0)
echo "$COUNT_24H" > ~/.claude/state/completion-violations-24h.txt
```

Statusline script pak může přidat indikátor: `🔇` 0 violations, `⚠` 1-5, `🚨` 6+.

## Skip
- Nespouštět automaticky každou session (overhead). Spouští se manuálně přes `/completion-check`.
- Pokud violations.jsonl neexistuje → "Hotovo. Systém běží, ale neměl ještě žádný hit."
