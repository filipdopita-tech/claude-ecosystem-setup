---
description: E2E verification subagent — run after completing a feature/fix
argument-hint: [service name or URL to test]
---

Spusť jako subagent (Agent tool) s modelem sonnet:

Verify that the recently changed code works end-to-end:

1. **Identify changed files** (git diff HEAD~1 --name-only)
2. **Determine service type** (Python FastAPI / Node / shell script / systemd service)
3. **Run appropriate checks:**
   - Python service: `python3 -m py_compile <files>` + import check
   - Node service: `node --check <files>` + `npm test --if-present`
   - Shell script: `bash -n <file>` + test run with safe args
   - Systemd: `systemctl is-active <service>` + health endpoint check
4. **Check logs** for errors (last 20 lines)
5. **Report:** PASS / FAIL + konkrétní řádek kde selhalo

Argument: $ARGUMENTS (service name, URL, nebo "auto" pro autodetekci)
