---
description: Run the 3-agent security red-team pipeline (attacker → defender → auditor) against a target path and write a graded report.
allowed-tools: Agent, Read, Bash, Grep
---

# /security-scan [path]

Orchestrate a 3-agent adversarial security pipeline against the target directory or file list.

**You MUST complete all four steps in order. You MUST NOT skip any step. You MUST NOT soften the final grade.**

---

## Step 0 — Resolve target

If `$ARGUMENTS` is provided, use it as the target path. Otherwise use the current working directory.

```
TARGET="${ARGUMENTS:-$(pwd)}"
```

Verify the target exists before proceeding. If it does not exist, abort with an error message.

---

## Step 1 — Spawn red-team and blue-team agents IN PARALLEL

Spawn both agents in the same message (two Agent tool calls in one turn). Do NOT wait for one to finish before spawning the other.

**Agent 1 — Red team attacker:**
- Agent file: `agents/security-redteam.md`
- Model: sonnet
- Prompt: `Perform a full adversarial security scan of the following target. Examine every file. Follow the full checklist in your system prompt. Target: $TARGET`
- Capture output as `REDTEAM_REPORT`

**Agent 2 — Blue team defender:**
- Agent file: `agents/security-blueteam.md`
- Model: sonnet
- Prompt: `You will receive the red-team report once it is ready. For now, read the target directory and familiarize yourself with the codebase so you can respond quickly. Target: $TARGET`
- This agent will be re-invoked in Step 2 with the actual red-team report.

Wait for both agents to complete before proceeding to Step 2.

---

## Step 2 — Pass red-team report to blue-team for remediation

Invoke the blue-team agent with the full red-team report:

- Agent file: `agents/security-blueteam.md`
- Model: sonnet
- Prompt: `Here is the red-team report. Produce concrete remediations for every finding. Read the referenced files yourself to verify current state before proposing fixes.\n\n$REDTEAM_REPORT`
- Capture output as `BLUETEAM_REPORT`

---

## Step 3 — Pass both reports to auditor for grading

Invoke the auditor agent:

- Agent file: `agents/security-auditor.md`
- Model: haiku
- Prompt: `Grade the following security engagement. Apply your rubric strictly. Produce the final report.\n\nRED-TEAM REPORT:\n$REDTEAM_REPORT\n\nBLUE-TEAM REMEDIATIONS:\n$BLUETEAM_REPORT`
- Capture output as `AUDITOR_REPORT`

---

## Step 4 — Write report and print TL;DR

**Write the combined report to disk:**

```
REPORT_DIR="security-reports"
ISO_DATE=$(date -u +"%Y-%m-%dT%H-%M-%SZ")
REPORT_FILE="$REPORT_DIR/scan-$ISO_DATE.md"
mkdir -p "$REPORT_DIR"
```

Report file structure:
```markdown
# Security Scan Report
**Target:** $TARGET
**Date:** $ISO_DATE
**Pipeline:** security-redteam + security-blueteam + security-auditor

---

## Red Team Findings
$REDTEAM_REPORT

---

## Blue Team Remediations
$BLUETEAM_REPORT

---

## Auditor Grade and Executive Summary
$AUDITOR_REPORT
```

**Print TL;DR to console** (extract from auditor report):
```
=== SECURITY SCAN COMPLETE ===
Target:  $TARGET
Report:  $REPORT_FILE
Grade:   [extracted from AUDITOR_REPORT]

MUST-DO-BEFORE-SHIP:
[extracted must-do list from AUDITOR_REPORT]

Full report written to: $REPORT_FILE
```

---

## Guardrails

- You MUST NOT summarize or paraphrase findings in a way that reduces apparent severity.
- You MUST NOT omit the must-do list from the console output.
- You MUST NOT skip Step 1 parallelism — both agents must be spawned in the same message.
- If the auditor returns grade D or F, append this warning to the console output:
  ```
  WARNING: Grade $GRADE — system is NOT cleared for ship. See must-do list above.
  ```
- The report file is the authoritative record. Do not modify it after writing.
