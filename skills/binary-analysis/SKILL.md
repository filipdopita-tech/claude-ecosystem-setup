---
name: binary-analysis
description: Use when reverse engineering binary file (ELF/PE/Mach-O), klient pentest deliverable má binární komponentu (C/C++/Go/Rust app), forensic analysis suspicious sample (ransomware/dropper/keylogger), CVE PoC analýza, decompilation legacy software bez source. Ghidra (NSA, free Apache-2.0) jako primary toolchain + radare2/binwalk fallback. Triggers — "reverse engineer binary", "decompile X", "analyzuj binárku", "Ghidra setup", "binary forensics", "co dělá tahle .exe/.so/.dylib", "ransomware sample analysis", "klient má C++ službu, audit".
license: Apache-2.0 (Ghidra upstream)
---

# Binary Analysis

Reverse engineering toolkit pro Filipův pentest/forensic scope. **Default = Ghidra** (NSA Apache-2.0, mature, multi-arch). Radare2/binwalk pro quick triage.

## When NOT to use

- Source code je dostupný → use `code-reviewer` agent místo binary analysis
- JS/Python/Ruby app → not compiled, source je read-only translation
- Klient nemá explicit auth scope (per security-toolkit defensive-only stance)
- HARD-STOP: malware authoring, unauthorized exploit dev (legal red zone)

## Filip use cases

| Scenario | Action |
|---|---|
| Klient má C++/Go/Rust službu, audit pre-deploy | Ghidra decompile → `shannon-pentester` chain |
| Suspicious binary v incident response (Filip's own infra) | Ghidra static analysis + sandbox dynamic |
| CVE PoC understanding (defensive purpose) | Ghidra + Context7 docs lookup |
| Legacy software bez source (klient migrace) | Ghidra decompile + `code-reviewer` agent na pseudo-source |
| ELF/PE supply-chain dependency check | binwalk extraction → Ghidra decompile suspicious sections |

## Install (zero-cost local)

```bash
# Prerequisite: JDK 21
brew install --cask temurin@21
java -version  # must show 21.x

# Download Ghidra release
mkdir -p ~/Documents/security-tools
cd ~/Documents/security-tools
LATEST=$(curl -s https://api.github.com/repos/NationalSecurityAgency/ghidra/releases/latest | grep -oE '"tag_name": "[^"]+"' | cut -d'"' -f4)
curl -L -o ghidra.zip "https://github.com/NationalSecurityAgency/ghidra/releases/download/${LATEST}/ghidra_${LATEST#Ghidra_}_PUBLIC.zip"
unzip ghidra.zip
mv ghidra_*_PUBLIC ghidra
cd ghidra
./ghidraRun  # GUI launch

# Headless mode (CLI batch analysis)
./support/analyzeHeadless ~/projects MyProject -import /path/to/binary -postScript MyScript.java
```

Per `cost-zero-tolerance.md`: Ghidra je free (Apache-2.0), 0 Kč.

## Quick triage cascade

Před plným Ghidra session vždy run quick triage:

```bash
# 1. File type identification
file /path/to/binary
# ELF 64-bit LSB shared object, x86-64 ...

# 2. Strings extraction (kandidáti pro IOCs, paths, URLs)
strings -n 8 /path/to/binary | grep -iE 'http|api|key|password|/usr/|/var/' | head -50

# 3. Import table (Linux: nm/ldd, macOS: otool, Windows PE: pefile)
nm -D /path/to/binary 2>/dev/null | head -30
ldd /path/to/binary

# 4. Embedded files / firmware
binwalk /path/to/binary
binwalk -e /path/to/binary  # extract všechno

# 5. radare2 quick analysis (fast, CLI)
r2 -A /path/to/binary  # auto-analyze
# uvnitř: aaa, afl (list functions), pdf @main (decompile main)
```

## Ghidra workflow (klient pentest scope)

1. **New Project** → `Non-Shared Project` → `<klient_name>_audit`
2. **File → Import File** → vyber binárku, accept defaults
3. **Auto-analyze** ✓ (zaškrtni vše kromě `Decompiler Parameter ID` na první pass)
4. **Symbol Tree** → najít `entry`, `main`, exported functions
5. **Decompile** (F5 v code listing) → C-like pseudo-source
6. **Export pseudo-source** → File → Export → `C/C++` → použij jako input pro `code-reviewer` agent

## Headless batch (CI/CD integration)

```bash
# Analyze 50 binárek jedním shotem
for bin in /path/to/binaries/*.so; do
    ./support/analyzeHeadless ~/projects BatchProject \
        -import "$bin" \
        -postScript ExtractFunctions.java \
        -overwrite
done
# Output → ~/projects/BatchProject/<bin_name>.txt s function list
```

Chain: každá binárka → headless extract → `algorithm-recall recipes/contact-dedup.py` (deduplicate signatures across batch) → `dd-batch-sql` (DuckDB query suspicious patterns napříč 50+ samples).

## PyGhidra (Python scripting)

Ghidra 11+ má native Python via `pyghidra`:

```bash
./support/pyghidraRun  # Python REPL s Ghidra API
```

```python
# Inside PyGhidra
from ghidra.app.script import GhidraScript

# List všechny strings v binary
strings = currentProgram.getListing().getDefinedData(True)
for s in strings:
    if s.getDataType().getName() == "string":
        print(f"{s.getAddress()}: {s.getValue()}")

# Najít všechny funkce co volají `system()` (potential cmd injection)
sys_func = getFunction("system")
if sys_func:
    refs = getReferencesTo(sys_func.getEntryPoint())
    for ref in refs:
        print(f"system() called from: {ref.getFromAddress()}")
```

## Autonomous pipeline (recipes + scripts, built 2026-05-08)

Reusable batch infrastructure místo ad-hoc Ghidra GUI runs.

### Single binary
```bash
~/.claude/skills/binary-analysis/scripts/audit-binary.sh <binary_path> [label]
```
3-stage pipeline: (1) quick triage (file/strings/otool/nm/ldd/sha256), (2) Ghidra headless import + auto-analyze + `extract_signals.py` post-script, (3) render `findings.md` s heuristic risk score (suspicious×2 + network×1 + crypto×1 + secret-hints×3, capped). Output v `~/Desktop/Codex/ghidra-runs/<label>/` — `triage.txt`, `signals.json`, `findings.md`, `ghidra.log`.

### Batch
```bash
~/.claude/skills/binary-analysis/scripts/audit-batch.sh <dir> [pattern]
~/.claude/skills/binary-analysis/scripts/audit-batch.sh --list <file_with_paths>
```
Loops single-binary auditor across všech executable/shared object/Mach-O/ELF v adresáři. Generuje `INDEX.md` s risk-ranked tabulkou pro per-binary `findings.md` deep dive.

### What `extract_signals.py` extracts
- Function inventory + entry points (internal vs external)
- **Suspicious calls**: `system/exec/popen/eval/gets/strcpy/strcat/sprintf/scanf/memcpy` — cmd inject + buffer overflow markers
- **Network calls**: `socket/connect/recv/send/curl_easy/CFNetwork/WinHttp` — C2 / data exfil markers
- **Crypto calls**: `AES/RSA/MD5/SHA/EVP/CCCrypt/BCrypt` — ransomware / homebrew crypto markers
- **Interesting strings** (top 200): URLs, paths, secret hints (api_key/token/password), PEM blocks, emails, Windows paths
- Memory layout (sections, X/W/R perms, init state)
- External imports (top 100, with library)

### Demo run (verified 2026-05-08)
- `/bin/ls` (151K Mach-O) → 136 functions, risk_score=4 (LOW), 2 suspicious (memcpy, sscanf), 0 network, 0 secret-hints. ~3s analyze.
- `/usr/bin/curl` (540K Mach-O) → 313 functions, risk_score=35 (HIGH), 5 suspicious, 10 network (curl_easy_*), 27 secret-hints (URLs/API references — expected pro HTTP klienta, ne anomálie). ~15s analyze.

### Tuning
- Add custom signal patterns: edit `*_FN_PATTERNS` arrays v `extract_signals.py`
- Add custom string regexes: append `(re.compile(r"..."), "tag")` to `STRING_REGEXES`
- Adjust risk score: edit Python heredoc v `audit-binary.sh`
- Persistent Ghidra project (pro GUI follow-up): odstraň `-deleteProject` flag z `audit-binary.sh`

## Remote pipeline on Flash VPS (built 2026-05-08)

Compute + storage offloaded na Flash (10.77.0.1) — Mac filesystem zůstává čistý, batch audity běží na 12GB RAM Linux box. Mac má thin wrapper.

### Flash side (`vmi3170453`, x86_64, 11Gi RAM)
- Ghidra 12.0.4 + JDK 21 Temurin: `/opt/binary-analysis/{ghidra,jdk21}` (847M + 346M)
- Recipes/scripts: `/opt/binary-analysis/{recipes,scripts}/`
- Output base: `/opt/binary-analysis/runs/<label>/` (na Flash disk, 40G free)

### Mac wrapper
```bash
~/.claude/skills/binary-analysis/scripts/audit-remote.sh <binary> [label]
~/.claude/skills/binary-analysis/scripts/audit-remote.sh --batch <flash_dir> [pattern]
~/.claude/skills/binary-analysis/scripts/audit-remote.sh --pull <label>      # rsync findings → Mac
~/.claude/skills/binary-analysis/scripts/audit-remote.sh --ls                # list Flash runs
~/.claude/skills/binary-analysis/scripts/audit-remote.sh --tail <label>      # tail Flash ghidra.log
```

### Source binary resolution (4 modes, auto-detected)
1. `/mac/...` path (Flash SSHFS view) → no upload
2. Mac path under `/Users/...` → translated to `/mac/Users/...` (Flash SSHFS)
3. Mac path under `$HOME/...` → translated to `/mac/<user>/...`
4. Other Mac path (`/bin/ls`, `/opt/...`) → `scp` upload to Flash `/tmp/audit-uploads/<sha>/`

### Demo run (verified 2026-05-08, Flash `vmi3170453`)
- `/usr/bin/ls` (Flash native ELF) → 136 funcs, risk_score=20 (MEDIUM), ~4s
- Mac `/bin/ls` → scp-upload mode → Flash audit → 136 funcs, risk_score=4 (LOW), ~4s. Cross-host parity.
- Pull: `audit-remote.sh --pull <label>` rsyncne findings.md/signals.json/triage.txt/ghidra.log na Mac (~/Desktop/Codex/ghidra-runs/), Ghidra projekt zůstává na Flash.

### When to use Mac vs Flash pipeline
| Situace | Pipeline |
|---|---|
| Ad-hoc 1-2 binárky, GUI follow-up možný | Mac (`audit-binary.sh`) |
| Batch >5 binárek | Flash (`audit-remote.sh --batch`) — využij 12GB RAM |
| Klient sample (auth scope), nechci na Macu | Flash (scp-upload mode, isolated) |
| OneFlow vlastní C++ utility v `~/Documents/` | Mac (rychlejší, žádný hop) NEBO Flash (přes /mac SSHFS) |
| Long-running 30+ min analýza | Flash (Mac neřvi ventilátorem, sleep nezablokuje) |
| Storage discipline (Mac disk pln) | Flash (40G free na /opt) |

## Chain s existing skills/agents

- **Klient pentest** — `shannon-pentester` agent web app scan → pokud najde binární komponentu → `binary-analysis` deep dive → findings zpět do `shannon` report
- **Forensic incident** — `agency-incident-commander` agent triage → suspicious binary → Ghidra → IOCs → `agency-evidence-collector` (screenshots/diffs) → `agency-reality-checker` (verify pre-report)
- **Pseudo-source review** — Ghidra export C → `code-reviewer` agent → bug findings
- **Supply-chain audit** — `supply-chain-risk-auditor` agent flags suspicious dep → binary-analysis decompile → confirm/deny
- **CVE PoC understanding** — `mcp__context7__query-docs` CVE database → Ghidra decompile patched binary → diff vs unpatched

## HARD-STOPS (per security-toolkit defensive-only stance)

- **NIKDY** decompile/RE software bez auth scope (klient explicit OK / OneFlow vlastní binárka / authorized bug bounty)
- **NIKDY** distribute decompiled commercial software (DMCA / EULA violations)
- **NIKDY** weaponize findings (PoC pro defensive understanding OK, exploit kit dev NEPOVOLENO)
- **NIKDY** Ghidra Server (multi-user collaborative) bez network isolation (CVE-2024-21424 ekvivalenty občas)

## Alternativy (situační)

| Tool | When |
|---|---|
| **Ghidra** (default) | Multi-arch, decompile, scripting, batch — Filipovo go-to |
| **radare2** | Quick CLI, scripting Python via r2pipe, lighter than Ghidra |
| **binwalk** | Firmware/IoT extraction, embedded file carving |
| **objdump/nm/strings** | One-liner triage, ne plný RE |
| **IDA Pro** | NIKDY (paid $1k+/year, hard-stop cost-zero-tolerance) |
| **Hopper** | macOS native, paid ($129) — skip |

## References

- Repo: https://github.com/NationalSecurityAgency/ghidra (Apache-2.0)
- Releases: https://github.com/NationalSecurityAgency/ghidra/releases
- DevGuide: `<install>/DevGuide.md`
- Security advisories: https://github.com/NationalSecurityAgency/ghidra/security/advisories
- PyGhidra docs: `<install>/Ghidra/Features/PyGhidra/README.md`
- Filip's security toolchain: `~/.claude/skills/security-toolkit/`, `~/.claude/skills/shannon/`

## Verification post-install

```bash
~/Documents/security-tools/ghidra/ghidraRun --version
# Should output Ghidra version, e.g. 11.2

# Headless test on /bin/ls (system binary, safe target)
~/Documents/security-tools/ghidra/support/analyzeHeadless /tmp test_proj \
    -import /bin/ls -overwrite -scriptPath /tmp -postScript Hello.java 2>&1 | tail -20
```
