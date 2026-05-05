#!/usr/bin/env bash
# mcp-test.sh — Quick health check of Scrapling MCP server
set -euo pipefail
echo "=== Scrapling MCP server health check ==="
echo ""
echo "[1/3] Binary check"
which scrapling 2>/dev/null || echo "scrapling NOT in PATH (use venv path directly)"
ls -la /Users/filipdopita/.venvs/scrapling/bin/scrapling
echo ""
echo "[2/3] Version"
/Users/filipdopita/.venvs/scrapling/bin/scrapling --version 2>&1 | head -3
echo ""
echo "[3/3] Claude MCP registration"
claude mcp list 2>&1 | grep -i scrapling || echo "Scrapling MCP NOT registered. Run: claude mcp add --scope user Scrapling /Users/filipdopita/.venvs/scrapling/bin/scrapling mcp"
echo ""
echo "=== Done ==="
