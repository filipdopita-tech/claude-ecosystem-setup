#!/usr/bin/env bash
# audit-binary.sh — single-binary autonomous audit pipeline
# Usage: audit-binary.sh <binary_path> [project_label]
#
# Pipeline:
#   1. Quick triage (file/strings/nm/otool/ldd) → triage.txt
#   2. Ghidra headless import + auto-analyze + extract_signals.py post-script → signals.json
#   3. Render findings.md from signals.json + triage.txt
#
# Output: ~/Desktop/Codex/ghidra-runs/<label>/
# Idempotent: re-run on same binary overwrites previous run dir.
#
# HARD-STOPS (per security-toolkit defensive-only):
#   - NIKDY decompile bez auth scope
#   - NIKDY weaponize findings
#   - Defensive analysis only (Filip's own / explicit klient auth / public sample for learning)

set -euo pipefail

BIN="${1:?usage: audit-binary.sh <binary_path> [label]}"
LABEL="${2:-$(basename "$BIN")}"
LABEL_SAFE=$(printf '%s' "$LABEL" | tr -c 'A-Za-z0-9._-' '_')

if [[ ! -f "$BIN" ]]; then
  echo "[audit-binary] ERROR: binary not found: $BIN" >&2
  exit 1
fi

GHIDRA_HOME="${GHIDRA_HOME:-$HOME/Documents/security-tools/ghidra}"
GHIDRA_JAVA_HOME="${GHIDRA_JAVA_HOME:-$HOME/Documents/security-tools/jdk21/Contents/Home}"

if [[ ! -x "$GHIDRA_HOME/support/analyzeHeadless" ]]; then
  echo "[audit-binary] ERROR: Ghidra not at $GHIDRA_HOME" >&2
  exit 1
fi

OUT_BASE="$HOME/Desktop/Codex/ghidra-runs"
RUN_DIR="$OUT_BASE/$LABEL_SAFE"
PROJ_DIR="$RUN_DIR/ghidra_project"
mkdir -p "$RUN_DIR" "$PROJ_DIR"

echo "[audit-binary] target: $BIN"
echo "[audit-binary] output: $RUN_DIR"

# === 1. Quick triage ===
TRIAGE="$RUN_DIR/triage.txt"
{
  echo "# Quick triage — $(date)"
  echo
  echo "## file"
  file "$BIN" || true
  echo
  echo "## size + sha256"
  ls -lh "$BIN"
  shasum -a 256 "$BIN" 2>/dev/null || sha256sum "$BIN" 2>/dev/null || true
  echo
  echo "## strings (first 50 lines, len>=8, suspicious patterns)"
  strings -n 8 "$BIN" 2>/dev/null | grep -iE 'http|api|key|password|secret|token|/usr/|/var/|/etc/|/tmp/|@|\.com|\.cz|\.io' | head -50 || true
  echo
  echo "## architecture-specific"
  if [[ "$(uname)" == "Darwin" ]]; then
    echo "### otool -L (Mach-O dyld)"
    otool -L "$BIN" 2>/dev/null | head -20 || true
    echo
    echo "### otool -h (header)"
    otool -h "$BIN" 2>/dev/null | head -10 || true
  fi
  echo
  echo "### nm -D (dynamic symbols, GNU)"
  nm -D "$BIN" 2>/dev/null | head -30 || echo "(nm -D not applicable)"
  echo
  echo "### ldd / dyld bindings"
  ldd "$BIN" 2>/dev/null | head -10 || echo "(ldd not applicable on macOS, use otool)"
} > "$TRIAGE"
echo "[audit-binary] triage → $TRIAGE"

# === 2. Ghidra headless analyze + extract signals ===
SCRIPT_DIR="$(cd "$(dirname "$0")/../recipes" && pwd)"
SIGNALS_JSON="$RUN_DIR/signals.json"

# Clean previous Ghidra project to ensure fresh import
rm -rf "$PROJ_DIR"/*

echo "[audit-binary] Ghidra headless: importing + analyzing (may take 30s-5min)..."
GHIDRA_OUT_DIR="$RUN_DIR" \
JAVA_HOME="$GHIDRA_JAVA_HOME" \
"$GHIDRA_HOME/support/analyzeHeadless" \
  "$PROJ_DIR" "audit_$LABEL_SAFE" \
  -import "$BIN" \
  -scriptPath "$SCRIPT_DIR" \
  -postScript extract_signals.py \
  -deleteProject \
  > "$RUN_DIR/ghidra.log" 2>&1 || {
    echo "[audit-binary] WARN: Ghidra exited non-zero (see $RUN_DIR/ghidra.log)" >&2
  }

if [[ ! -f "$SIGNALS_JSON" ]]; then
  echo "[audit-binary] ERROR: signals.json not produced. Check $RUN_DIR/ghidra.log" >&2
  tail -30 "$RUN_DIR/ghidra.log" >&2 || true
  exit 2
fi
echo "[audit-binary] signals → $SIGNALS_JSON"

# === 3. Render findings.md ===
FINDINGS="$RUN_DIR/findings.md"
python3 - "$BIN" "$LABEL" "$SIGNALS_JSON" "$TRIAGE" "$FINDINGS" <<'PYEOF'
import json, sys, os, datetime

bin_path, label, signals_path, triage_path, out_path = sys.argv[1:6]
with open(signals_path) as f:
    s = json.load(f)
with open(triage_path) as f:
    triage = f.read()

def fmt_table(rows, headers):
    if not rows:
        return "_(none)_\n"
    out = "| " + " | ".join(headers) + " |\n"
    out += "| " + " | ".join(["---"] * len(headers)) + " |\n"
    for r in rows:
        out += "| " + " | ".join(str(c).replace("|", "\\|") for c in r) + " |\n"
    return out

risk_score = 0
risk_score += min(len(s.get("suspicious_calls", [])) * 2, 20)
risk_score += min(len(s.get("network_calls", [])), 10)
risk_score += min(len(s.get("crypto_calls", [])), 5)
risk_score += min(sum(1 for st in s.get("interesting_strings", []) if st.get("tag") == "secret_hint") * 3, 15)
risk_band = "LOW" if risk_score < 10 else "MEDIUM" if risk_score < 25 else "HIGH"

md = []
md.append(f"# Binary Audit — {label}")
md.append("")
md.append(f"_Generated: {datetime.datetime.now().isoformat()}_")
md.append("")
md.append("## Summary")
md.append("")
md.append(f"- **Binary**: `{bin_path}`")
md.append(f"- **Architecture**: `{s.get('language', 'unknown')}`")
md.append(f"- **Compiler**: `{s.get('compiler_spec', 'unknown')}`")
md.append(f"- **Image base**: `{s.get('image_base', 'unknown')}`")
md.append(f"- **Functions**: {s.get('function_count', 0)} ({s.get('external_function_count', 0)} external)")
md.append(f"- **Risk indicators**: suspicious={len(s.get('suspicious_calls', []))}, network={len(s.get('network_calls', []))}, crypto={len(s.get('crypto_calls', []))}, secret-hints={sum(1 for st in s.get('interesting_strings', []) if st.get('tag') == 'secret_hint')}")
md.append(f"- **Heuristic risk score**: **{risk_score}** ({risk_band})")
md.append("")
md.append("## Memory Layout")
md.append("")
rows = [(b["name"], b["start"], b["end"], b["size"],
         "X" if b["executable"] else "",
         "W" if b["writable"] else "",
         "R" if b["readable"] else "",
         "init" if b["initialized"] else "uninit") for b in s.get("memory_blocks", [])]
md.append(fmt_table(rows, ["block", "start", "end", "size", "exec", "write", "read", "state"]))
md.append("")
md.append("## Suspicious Calls (cmd inject + buffer overflow markers)")
md.append("")
md.append("Symbols matching `system/exec/popen/eval/gets/strcpy/strcat/sprintf/scanf/memcpy`. External (lib import) ≠ internal vuln, but presence flags scope for review.")
md.append("")
rows = [(c["name"], c["matched"], c["entry"], "external" if c["external"] else "internal")
        for c in s.get("suspicious_calls", [])[:50]]
md.append(fmt_table(rows, ["symbol", "matched", "entry", "kind"]))
md.append("")
md.append("## Network Calls (C2 / data exfil markers)")
md.append("")
rows = [(c["name"], c["matched"], c["entry"], "external" if c["external"] else "internal")
        for c in s.get("network_calls", [])[:50]]
md.append(fmt_table(rows, ["symbol", "matched", "entry", "kind"]))
md.append("")
md.append("## Crypto Calls")
md.append("")
rows = [(c["name"], c["matched"], c["entry"], "external" if c["external"] else "internal")
        for c in s.get("crypto_calls", [])[:30]]
md.append(fmt_table(rows, ["symbol", "matched", "entry", "kind"]))
md.append("")
md.append("## Interesting Strings (URLs / paths / secrets / emails)")
md.append("")
rows = [(st.get("tag", "?"), st.get("addr", ""), st.get("value", "")[:120])
        for st in s.get("interesting_strings", [])[:80]]
md.append(fmt_table(rows, ["tag", "addr", "value"]))
md.append("")
md.append("## External Imports (top 50)")
md.append("")
rows = [(i.get("library", "?"), i.get("name", ""))
        for i in s.get("imports", [])[:50]]
md.append(fmt_table(rows, ["library", "symbol"]))
md.append("")
md.append("## Internal Function Sample")
md.append("")
rows = [(f.get("name", ""), f.get("entry", ""))
        for f in s.get("functions_sample", [])[:30]]
md.append(fmt_table(rows, ["function", "entry"]))
md.append("")
md.append("## Quick Triage Output")
md.append("")
md.append("```")
md.append(triage[:8000])
md.append("```")
md.append("")
md.append("## Next Steps")
md.append("")
md.append("- [ ] Review `suspicious_calls` table — confirm if any internal (non-external) match → potential vuln scope")
md.append("- [ ] Review `interesting_strings` for hardcoded credentials, internal hostnames, dev paths leaked to release build")
md.append("- [ ] Cross-reference `network_calls` against expected C2 / API surface — unexpected callouts = red flag")
md.append("- [ ] If risk_score >= 25 (HIGH), open Ghidra GUI, navigate to flagged entries, decompile to C pseudo-source for manual review")
md.append("- [ ] Chain to `code-reviewer` agent: pseudo-source export → security-focused review")
md.append("- [ ] If sample is suspicious malware: continue analysis in isolated VM only, never re-execute")
md.append("")
md.append("---")
md.append("Dopita")

with open(out_path, "w") as f:
    f.write("\n".join(md))
print(f"[render] findings → {out_path}")
print(f"[render] risk_score={risk_score} band={risk_band}")
PYEOF

echo
echo "[audit-binary] DONE"
echo "  triage:   $TRIAGE"
echo "  signals:  $SIGNALS_JSON"
echo "  findings: $FINDINGS"
echo "  log:      $RUN_DIR/ghidra.log"
