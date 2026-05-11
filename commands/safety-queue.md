---
name: safety-queue
description: Persistent permission queue + decision history pro hard-stop akce (ze 5 zón hard-stop-zone.md). Cherry-picked z jcode SAFETY_SYSTEM.md. Použij když chceš (a) zafronotvat permission request s rationale + urgency místo synchronní AskUserQuestion, (b) auditovat past Filip-decisions, (c) navrhnout promotion akce do auto-allow (po N approvals). NOT pro real-time blocking otázky — to dělá autonomy-guard hook. NOT pro instant ntfy alerty — ty pošli rovnou.
---

# Safety Queue — Persistent Permission Queue & Decision Learning

Cherry-picked z [1jehuang/jcode](https://github.com/1jehuang/jcode) `docs/SAFETY_SYSTEM.md`. Tento skill **doplňuje** existující `~/.claude/rules/hard-stop-zone.md` (5 zón) a `~/.claude/hooks/autonomy-guard.sh` (real-time block), netvoří paralelní systém.

**Rozdíl proti hard-stop-zone:**
- `hard-stop-zone.md` = pravidla CO vyžaduje povolení
- `autonomy-guard.sh` = real-time blocking JEDEN konkrétní request
- `safety-queue` = perzistentní log + decision history + učení patternů (long-running queue, batch review)

## Use Cases

### 1. Async permission request

Filip není u terminálu. Claude chce udělat akci v hard-stop zóně, ale:
- Akce není časově urgentní (nemusí být do 5 minut)
- Filip ji možná schválí později
- Mezitím Claude pokračuje s jinou prací

**Tehdy:** zapiš request do `~/.claude/safety/queue.json` s `wait: false`, pošli ntfy notification, pokračuj jinou prací. Filip rozhodne kdykoli později.

### 2. Decision history audit

Filip se ptá: *"Kolikrát jsi se mě letos ptal na cost approval?"*
*"Schválil jsem někdy něco co jsem teď zpětně zalitoval?"*

**Tehdy:** read `~/.claude/safety/history.json`, agreguj per-action-type, ukázat top patterns.

### 3. Auto-allow promotion suggestion

Pokud Filip 5x po sobě schválil stejný typ akce ("install npm package", "create branch", "git push to feature branch"), navrhni promotion do auto-allow.

**Tehdy:** analyzuj history, najdi action types s ≥5 approvals + 0 denials, navrhni Filipovi update `hard-stop-zone.md` exception list.

---

## Architecture

```
~/.claude/safety/
├── queue.json          # Pending permission requests (max 50, FIFO)
├── history.json        # Past decisions (append-only, 1000 entry rolling cap)
├── patterns.json       # Auto-detected patterns (refreshed weekly)
└── README.md           # This skill's documentation
```

### queue.json format

```json
{
  "version": 1,
  "updated_at": "2026-04-29T15:30:00Z",
  "pending": [
    {
      "id": "req_abc123",
      "ts": "2026-04-29T15:25:00Z",
      "session_id": "session-uuid",
      "action": "git_push_to_main",
      "category": "destructive",
      "urgency": "low",
      "description": "Push 3 commits to oneflow-dashboard:main",
      "rationale": "Tested locally, all CI green",
      "wait": false,
      "context": { "repo": "oneflow-dashboard", "commits": 3 }
    }
  ]
}
```

### history.json format

```json
{
  "version": 1,
  "entries": [
    {
      "id": "req_abc123",
      "ts_requested": "2026-04-29T15:25:00Z",
      "ts_decided": "2026-04-29T17:42:00Z",
      "decided_via": "ntfy_reply" | "tui" | "explicit_message" | "timeout",
      "decision": "approved" | "denied" | "timeout",
      "filip_message": "yes go for it",
      "action": "git_push_to_main",
      "category": "destructive",
      "response_time_seconds": 8220,
      "outcome_followup": null
    }
  ]
}
```

---

## Integration s existujícími systémy

### Real-time blocking (NEZASAHUJ)

Pokud akce **musí být teď** (Filip je u terminálu):
- `autonomy-guard.sh` exit 2 = block
- `AskUserQuestion` (s ToolSearch loaded) = synchronous prompt
- Žádný safety-queue overhead

### Async queueing (TENTO skill)

Pokud akce **může počkat**:
1. `request_permission(...)` → append do queue.json
2. Send ntfy: `https://ntfy.oneflow.cz/Filip` + URL k review
3. Pokračuj jinou prací (není blocked)
4. Filip odpoví kdykoli (přes ntfy reply, /safety:approve, edit JSON)
5. Po decision: append do history.json + retry akci

### Klasifikace akcí (delegate na hard-stop-zone.md)

Akce patří do queue jen když **prošla** `autonomy-guard.sh` jako hard-stop:
- platby/payment/billing
- odeslání zpráv (email/WA/SMS/Slack/Telegram/LinkedIn)
- nevratná destrukce (DROP/rm -rf prod/force push main)
- FB/Meta login automatizace
- strategická volba >100k Kč

Vše ostatní = ROZHODNI SÁM (per `feedback_full_autonomy.md`).

---

## CLI / Claude commands

### Append do queue (Claude akce)

```python
import json, uuid, time
from datetime import datetime, timezone
from pathlib import Path

queue_file = Path.home() / ".claude" / "safety" / "queue.json"
queue_file.parent.mkdir(exist_ok=True, parents=True)

def request_permission(action, category, description, rationale, urgency="low", wait=False, context=None):
    queue = json.loads(queue_file.read_text()) if queue_file.exists() else {"version": 1, "pending": []}
    req = {
        "id": f"req_{uuid.uuid4().hex[:8]}",
        "ts": datetime.now(timezone.utc).isoformat(),
        "action": action,
        "category": category,  # "destructive"|"financial"|"comm"|"fb_login"|"strategic"
        "urgency": urgency,    # "low"|"normal"|"high"
        "description": description,
        "rationale": rationale,
        "wait": wait,
        "context": context or {},
    }
    queue["pending"].append(req)
    queue["pending"] = queue["pending"][-50:]  # Keep last 50
    queue["updated_at"] = datetime.now(timezone.utc).isoformat()
    queue_file.write_text(json.dumps(queue, indent=2))
    # Send ntfy
    import subprocess
    subprocess.run(["curl", "-s", "-d", f"{action}: {description}", "https://ntfy.oneflow.cz/Filip"], check=False)
    return req["id"]
```

### Filip rychlá review

```bash
# List pending
jq -r '.pending[] | "\(.id) [\(.urgency)] \(.action): \(.description)"' ~/.claude/safety/queue.json

# Approve (move to history)
~/.claude/scripts/safety-decide.sh req_abc123 approved "looks good"

# Deny
~/.claude/scripts/safety-decide.sh req_abc123 denied "wait for friday"

# Stats
~/.claude/scripts/safety-stats.sh           # totals per category
~/.claude/scripts/safety-stats.sh --patterns  # auto-detected patterns
```

### Pattern detection (weekly cron candidate)

```python
# Find action types s ≥5 approvals + 0 denials → suggest promotion
def find_promotion_candidates(history, min_approvals=5):
    counts = {}  # action_type → {"approved": n, "denied": n}
    for entry in history["entries"]:
        a = entry["action"]
        c = counts.setdefault(a, {"approved": 0, "denied": 0})
        c[entry["decision"]] = c.get(entry["decision"], 0) + 1
    return [
        a for a, c in counts.items()
        if c.get("approved", 0) >= min_approvals and c.get("denied", 0) == 0
    ]
```

---

## Workflow (typický)

```
1. Claude chce udělat akci → autonomy-guard.sh check
2. Pokud HARD-STOP zone:
   a. Synchronní variant (Filip u terminálu): AskUserQuestion → real-time decision
   b. Async variant (Filip mimo): safety-queue request_permission(wait=False)
                                  + ntfy notification
                                  + pokračuj jinou prací
3. Filip rozhodne (kdykoli):
   - Reply na ntfy
   - /safety-decide CLI
   - Edit ~/.claude/safety/queue.json přímo
4. Decision → append history.json + retry původní akci
5. (Weekly) pattern analysis → promotion suggestions
```

---

## Edge cases

- **Stale request** (>72h pending): auto-mark `timeout`, log do history.
- **Duplicate request** (same action + category v posledních 10 min): merge do existing.
- **Conflicting decisions** (Filip approve + later say "ne"): timestamp poslední wins, both logged.
- **Queue overflow** (>50): drop oldest pending, log warning.
- **Disk full** (queue.json corrupt): fallback na in-memory + log error.

---

## NEPOUŽÍVAT pro

- Real-time block (use `autonomy-guard.sh` exit 2)
- Synchronous user input (use `AskUserQuestion` tool)
- Operativa mimo hard-stop zone (rozhodni sám per autonomy)
- Triviální informational notifications (use `ntfy` direct)

---

## Filozofie (z jcode)

> *"There is no 'always denied' tier — if the user explicitly approves something, the agent can do it."*

Tato systém **neblokuje** akce, jen dělá Filipovo rozhodování:
- **Persistent** (nezmizí s session)
- **Audit-able** (history)
- **Pattern-aware** (učí se Filipovy preference)

Hard-stop zone = WHAT requires permission.
Safety-queue = HOW to ask asynchronously + LEARN from history.

---

## Reference

- Source: [1jehuang/jcode](https://github.com/1jehuang/jcode) `docs/SAFETY_SYSTEM.md` (MIT license, cherry-picked 2026-04-29)
- Komplementární: `~/.claude/rules/hard-stop-zone.md` (5 zón definice)
- Komplementární: `~/.claude/rules/completion-mandate.md` (autonomy default)
- Komplementární: `~/.claude/hooks/autonomy-guard.sh` (real-time block)
- Memory: `feedback_no_send_without_approval.md`, `feedback_full_autonomy.md`
