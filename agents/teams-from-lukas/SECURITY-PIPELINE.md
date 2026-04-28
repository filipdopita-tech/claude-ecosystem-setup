# Security Pipeline Architecture

Three-agent adversarial security pipeline for Claude Code ecosystems. Designed for depth over breadth — this is not a linter or a regex scanner. It runs adversarial reasoning against real code.

---

## Architecture

```
/security-scan [path]
        |
        v
  +-----------+     spawned in parallel (single Agent message)
  |           |--------------------------------------------+
  |           |                                            |
  |  Step 1   v                                            v
  |     +------------+                          +------------------+
  |     | red-team   |  (Sonnet)                | blue-team        |
  |     | attacker   |  adversarial scan        | familiarize      |
  |     +------------+  finds vulns             +------------------+
  |           |
  |     REDTEAM_REPORT
  |           |
  |  Step 2   v
  |     +------------+
  |     | blue-team  |  (Sonnet)
  |     | defender   |  reads files, proposes fixes
  |     +------------+
  |           |
  |     BLUETEAM_REPORT
  |           |
  |  Step 3   v
  |     +------------+
  |     | auditor    |  (Haiku)
  |     | judge      |  grades A-F, exec summary
  |     +------------+
  |           |
  |     AUDITOR_REPORT
  |           |
  |  Step 4   v
  |     write security-reports/scan-<ISO>.md
  |     print TL;DR + grade + must-do to console
  +---------------------------------------------+
```

---

## Agent roles

| Agent               | Model  | Perspective        | Input                      | Output                            |
|---------------------|--------|--------------------|----------------------------|------------------------------------|
| security-redteam    | Sonnet | Offensive attacker | Target path                | Vulnerability table + detail blocks |
| security-blueteam   | Sonnet | Defensive engineer | Red-team report + codebase | Per-finding remediation with code   |
| security-auditor    | Haiku  | Independent judge  | Both reports               | Grade A-F + exec summary            |

---

## Grading scale

| Grade | Meaning                                         | Ship decision              |
|-------|-------------------------------------------------|----------------------------|
| A     | Zero HIGH; all MED addressed                    | Clear to ship              |
| B     | Zero HIGH; MED fixes incomplete but present     | Ship with sprint follow-up |
| C     | HIGH present, each has remediation proposed     | Hold — re-scan after fixes |
| D     | HIGH present, at least one has no remediation   | Blocked                    |
| F     | CRITICAL present with no remediation            | Escalate, no deploy        |

---

## Cost estimate per scan

Estimates assume a medium-complexity Claude Code ecosystem (~30-80 files, ~5,000-20,000 tokens of source).

| Scenario               | Approx. cost |
|------------------------|--------------|
| Small target (<20 files) | $0.10-$0.30 |
| Medium target (20-80 files) | $0.30-$0.80 |
| Large target (80+ files, deep hooks) | $0.80-$1.50 |

Cost drivers: red-team and blue-team are both Sonnet (expensive per token); auditor is Haiku (cheap). The parallel spawn in Step 1 does not reduce cost — it reduces wall-clock time.

To reduce cost: scope the scan to a subdirectory rather than the full ecosystem.

---

## Parallel orchestration

Step 1 spawns two Agent tool calls in the same Claude message. This is intentional:

- Wall-clock time drops by ~40-50% on medium scans compared to sequential.
- The blue-team agent uses the parallel slot to read the codebase, so when it receives the red-team report it can respond faster.
- Both agents operate independently — no shared state, no race conditions.

The orchestrating command (`/security-scan`) waits for both Step 1 agents before proceeding to Step 2.

---

## False positive handling

The blue-team agent is instructed to dispute findings with evidence. If it identifies a false positive, it must cite file:line evidence and explain why the finding does not represent a real vulnerability. The auditor validates the dispute.

A disputed finding that the auditor accepts does not count against the grade. A disputed finding that the auditor rejects retains its original severity.

---

## Integration with pre-write-secrets-scan.sh

This pipeline and the existing `pre-write-secrets-scan.sh` hook serve different layers:

| Layer                   | Mechanism                        | Scope                         | Depth  |
|-------------------------|----------------------------------|-------------------------------|--------|
| pre-write-secrets-scan.sh | PreToolUse on Write, regex match | Sensitive filenames only      | Surface |
| security-redteam agent  | Full file read + reasoning       | All files, all vuln categories | Deep   |

The regex hook catches accidental writes to `.env`, `credentials.json`, SSH key files. It fires in real time during editing. It is fast and cheap.

The red-team agent catches hardcoded secrets inside non-sensitive-named files, injection flaws, supply chain risks, insecure configuration, and everything else that a regex on filenames cannot see. It runs on demand or before push.

Both layers are complementary. Running this pipeline does not replace the write-time hook.

---

## cost-aware-security-gate.sh hook

The `cost-aware-security-gate.sh` hook fires as PreToolUse on Bash when it detects `git push`, `git commit -m`, or `gh pr create`. It checks whether `security-reports/` contains a scan file less than 7 days old with grade A or B.

If not: advisory printed to stderr and logged to `~/.claude/logs/security-gate.log`.
It always exits 0 (advisory, never blocking).

This hook does not replace the pipeline — it reminds the user to run it.

---

## Adding to settings.json

To wire the gate hook into your Claude Code settings, add to `hooks`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "/Users/lukasdlouhy/Desktop/lukasdlouhy-claude-ecosystem/hooks/cost-aware-security-gate.sh"
          }
        ]
      }
    ]
  }
}
```
