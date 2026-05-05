# Billing Incidents Postmortem — April 2026

Source: Filip Dopita / OneFlow.cz — COST_DISCIPLINE.md (April 2026)
Relevance for Lukáš: pattern replication for API cost guards in Claude hooks ecosystem.

---

## Incidents Summary

**Total spend:** ~CZK 4,019 (~$168) across two incidents in April 2026

### Incident 1 — April 17, 2026
- **Amount:** CZK 1,019.73
- **Cause:** Overdue Google Cloud billing; Visa card declined on auto-renewal
- **Impact:** Cloud services suspended briefly; manual payment required
- **Root cause class:** Payment method + billing alert failure (no push alert before suspension)

### Incident 2 — April 24, 2026
- **Amount:** CZK 3,000 (~$125)
- **Cause:** `nemakej-solar-outbound` pipeline triggered Solar API + 32 Maps Platform APIs automatically
- **Impact:** Unexpected production charges on APIs that should have been blocked
- **Root cause class:** Single-layer compliance failure — LLM rule existed but was bypassed under operational pressure
- **Key insight:** "Rule was in place, but single layer wasn't enough." One compliance layer (text rules) is insufficient when automation runs unsupervised.

---

## Four-Layer Defense Stack (Filip's Pattern)

Defense effectiveness: **9.5+/10** with all 4 layers active vs. **7/10** rule-only.

### Layer 1: Rule Documentation
- File: `rules/cost-zero-tolerance.md` (5.6K)
- Content: pre-API requirements, free-tier verification checklist, escalation triggers
- Covered APIs: Vertex AI, Cloud Run, BigQuery, Maps Platform, Solar API
- Limitation: human/LLM reads rule; automation ignores it under pressure
- **Effectiveness alone: 7/10**

### Layer 2: Bash Interceptor (PreToolUse Hook)
- File: `hooks/google-api-guard.sh` (5.7K)
- Mechanism: regex match on tool input before execution; denies at OS level
- Blocked patterns (regex): `solar|maps|aiplatform|documentai|speech|texttospeech|translate|vision|cloudbilling|run`
- Denied gcloud subcommands: `compute`, `storage`, `sql`, all billing operations
- Result: prevents API contact before any charge is incurred
- **This is the critical layer** — stops execution, not just logs it

### Layer 3: Hourly Monitor (Cron)
- File: `scripts/automation/google-api-status.sh`
- Schedule: every 60 minutes via crontab
- Checks:
  - Credential files for paid API keys present in environment
  - Disabled-pipeline directory status (looks for active files in `_DISABLED_*` folders)
  - Billing-enabled projects in gcloud config
- Alert: ntfy push notification on any positive detection
- **This catches drift** — if Layer 2 is removed or bypassed, Layer 3 detects within 60 minutes

### Layer 4: Source Lockdown
- Problematic pipeline renamed: `nemakej-solar-outbound/` → `_DISABLED_nemakej-solar-outbound_2026_04_24/`
- Marker file added inside disabled folder (prevents accidental re-activation)
- Sensitive keys removed from environment: `GOOGLE_SOLAR_KEY` deleted from all env files
- **This removes the attack surface entirely** rather than just blocking access to it

---

## Bash Interceptor Implementation Pattern

Filip's hook intercepts at PreToolUse (before any bash or API call executes). Replicable for Lukáš's hooks system:

```bash
#!/bin/bash
# hooks/google-api-guard.sh
# Runs on PreToolUse for Bash tool calls

TOOL_INPUT="$1"

# Block paid Google APIs by service name pattern
if echo "$TOOL_INPUT" | grep -qiE 'solar|maps|aiplatform|documentai|speech|texttospeech|translate|vision|cloudbilling'; then
  echo "BLOCKED: Paid Google API detected. See rules/cost-zero-tolerance.md." >&2
  exit 1
fi

# Block dangerous gcloud subcommands
if echo "$TOOL_INPUT" | grep -qE 'gcloud (compute|storage|sql|billing)'; then
  echo "BLOCKED: gcloud billing-risk subcommand. Explicit authorization required." >&2
  exit 1
fi

exit 0
```

Key design decisions:
- Exit 1 = hard block (tool call aborted); exit 0 = allow
- stderr output surfaces the block reason to the Claude session
- Regex is additive — extend the pattern list as new paid APIs are added
- No logging to file inside the hook (avoids side effects; Layer 3 does the auditing)

---

## Cron Monitoring Pattern

```bash
#!/bin/bash
# scripts/automation/google-api-status.sh
# Run: */60 * * * * /path/to/google-api-status.sh

ALERT=0

# Check for paid API keys in environment files
if grep -r "GOOGLE_SOLAR_KEY\|MAPS_API_KEY" ~/.env* ~/.config/ 2>/dev/null | grep -v "^#"; then
  ALERT=1
  MSG="Paid Google API key found in environment files"
fi

# Check for active files in disabled pipeline directories
if find . -path "*/_DISABLED_*" -name "*.py" -newer /tmp/guard-baseline 2>/dev/null | grep -q .; then
  ALERT=1
  MSG="Files modified inside disabled pipeline directory"
fi

if [ $ALERT -eq 1 ]; then
  # ntfy push notification
  curl -s -d "$MSG" ntfy.sh/YOUR_TOPIC > /dev/null
fi
```

---

## Lessons for Lukáš's Hooks Ecosystem

**Structural lessons:**

1. **One rule ≠ defense.** If a rule can be bypassed by operational context (pressure, automation, ambiguity), it will be. Layer rule + bash interceptor + monitor + lockdown.

2. **Intercept before execution, not after.** A log that says "blocked" is worthless after charges post. PreToolUse hooks that exit 1 are the correct pattern.

3. **Monitor for drift, not just for incidents.** The hourly cron exists to catch the gap between "rule added" and "hook removed by accident." Monitor assumes the defenses will be eroded.

4. **Rename + marker > delete.** Disabling a pipeline by renaming with `_DISABLED_` prefix + datestamp creates an audit trail. Deleting destroys evidence of what it did.

5. **Billing alerts ≠ cost guards.** GCP billing alerts fire after charges post. The interceptor fires before. Both are needed; only the interceptor prevents the charge.

**Applicable to Lukáš:**
- Current `cost-zero-tolerance.md` rule is Layer 1 only
- No bash interceptor equivalent for Anthropic API or other billable tools
- No hourly cron checking for unauthorized API key presence
- Priority: build Layer 2 (PreToolUse hook) for any paid API Lukáš is protecting

**15+ APIs blocked** by Filip's interceptor at time of report — the pattern scales linearly with regex additions, no architectural changes needed.
