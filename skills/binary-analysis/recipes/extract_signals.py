# -*- coding: utf-8 -*-
# Ghidra headless post-script: extract security signals from imported binary
# Run via: ghidra-headless <project_dir> <project_name> -import <binary> -postScript extract_signals.py
# Output: <project_dir>/<binary_name>_signals.json
#
# Detects:
#   - All function names + entry points
#   - External imports (LIBC/Win32/Mach-O dyld bindings)
#   - Suspicious calls: system/exec/popen/eval/gets/strcpy/sprintf/scanf (cmd inject + buffer overflow markers)
#   - Network calls: socket/connect/recv/send/curl/CFNetwork (C2 / data exfil markers)
#   - Crypto calls: AES/RSA/MD5/SHA/openssl (ransomware / homebrew crypto markers)
#   - Strings >= 6 chars containing: http(s)/ftp/api keys hints/paths/email
#
# Output JSON consumed by audit-binary.sh which renders findings.md

#@category Audit
#@runtime Jython

import json
import os
import re
from ghidra.program.model.symbol import SymbolType
from ghidra.program.model.listing import CodeUnit

SUSPICIOUS_FN_PATTERNS = [
    "system", "exec", "execve", "execl", "execlp", "execv", "popen",
    "eval", "gets", "strcpy", "strcat", "sprintf", "scanf",
    "memcpy", "alloca", "atoi",
]

NETWORK_FN_PATTERNS = [
    "socket", "connect", "bind", "listen", "accept", "recv", "send",
    "recvfrom", "sendto", "gethostbyname", "getaddrinfo",
    "curl_easy", "CFNetwork", "NSURL", "WSAStartup", "InternetOpen",
    "HttpSend", "WinHttp",
]

CRYPTO_FN_PATTERNS = [
    "AES_", "EVP_", "RSA_", "MD5_", "SHA1_", "SHA256_", "SHA512_",
    "RAND_", "BN_", "EVP_Cipher", "CCCrypt", "CryptAcquire",
    "BCrypt", "CryptoAPI",
]

STRING_REGEXES = [
    (re.compile(r"^https?://"), "url"),
    (re.compile(r"^ftp://"), "url"),
    (re.compile(r"^/(usr|var|etc|tmp|root|home|opt)/"), "path"),
    (re.compile(r"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"), "email"),
    (re.compile(r"(?i)(api[_-]?key|secret|token|password|passwd|bearer)"), "secret_hint"),
    (re.compile(r"^-----BEGIN\s+"), "pem_block"),
    (re.compile(r"^[A-Z]:\\"), "windows_path"),
]

def matches_any(name, patterns):
    lname = name.lower()
    for p in patterns:
        if p.lower() in lname:
            return p
    return None

def collect_functions(program):
    funcs = []
    suspicious = []
    network = []
    crypto = []
    fm = program.getFunctionManager()
    for fn in fm.getFunctions(True):
        name = fn.getName()
        entry = "0x" + fn.getEntryPoint().toString().lstrip("0")
        external = fn.isExternal()
        funcs.append({"name": name, "entry": entry, "external": external})
        m = matches_any(name, SUSPICIOUS_FN_PATTERNS)
        if m:
            suspicious.append({"name": name, "entry": entry, "external": external, "matched": m})
        m = matches_any(name, NETWORK_FN_PATTERNS)
        if m:
            network.append({"name": name, "entry": entry, "external": external, "matched": m})
        m = matches_any(name, CRYPTO_FN_PATTERNS)
        if m:
            crypto.append({"name": name, "entry": entry, "external": external, "matched": m})
    return funcs, suspicious, network, crypto

def collect_imports(program):
    imports = []
    sym_table = program.getSymbolTable()
    for sym in sym_table.getExternalSymbols():
        if sym.getSymbolType() == SymbolType.FUNCTION or sym.getSymbolType() == SymbolType.LABEL:
            imports.append({
                "name": sym.getName(),
                "library": sym.getParentNamespace().getName() if sym.getParentNamespace() else None,
            })
    return imports

def collect_strings(program, min_len=6, max_count=200):
    interesting = []
    listing = program.getListing()
    count = 0
    data_iter = listing.getDefinedData(True)
    for data in data_iter:
        if count >= max_count:
            break
        try:
            if not data.hasStringValue():
                continue
            val = str(data.getValue())
        except:
            continue
        if not val or len(val) < min_len:
            continue
        for rgx, tag in STRING_REGEXES:
            if rgx.search(val):
                interesting.append({
                    "addr": "0x" + data.getAddress().toString().lstrip("0"),
                    "value": val[:200],
                    "tag": tag,
                })
                count += 1
                break
    return interesting

def main():
    program = currentProgram
    out = {
        "binary": program.getName(),
        "executable_path": program.getExecutablePath(),
        "language": str(program.getLanguage().getLanguageID()),
        "compiler_spec": str(program.getCompilerSpec().getCompilerSpecID()),
        "image_base": "0x" + program.getImageBase().toString().lstrip("0"),
        "memory_blocks": [],
    }

    # Memory layout
    for block in program.getMemory().getBlocks():
        out["memory_blocks"].append({
            "name": block.getName(),
            "start": "0x" + block.getStart().toString().lstrip("0"),
            "end": "0x" + block.getEnd().toString().lstrip("0"),
            "size": block.getSize(),
            "executable": block.isExecute(),
            "writable": block.isWrite(),
            "readable": block.isRead(),
            "initialized": block.isInitialized(),
        })

    funcs, suspicious, network, crypto = collect_functions(program)
    out["function_count"] = len(funcs)
    out["functions_sample"] = [f for f in funcs if not f["external"]][:30]
    out["external_function_count"] = len([f for f in funcs if f["external"]])
    out["suspicious_calls"] = suspicious
    out["network_calls"] = network
    out["crypto_calls"] = crypto
    out["imports"] = collect_imports(program)[:100]
    out["interesting_strings"] = collect_strings(program)

    # Compute project dir from program location
    proj_dir = os.environ.get("GHIDRA_OUT_DIR", "/tmp")
    out_path = os.path.join(proj_dir, "signals.json")
    with open(out_path, "w") as f:
        json.dump(out, f, indent=2, default=str)
    print("[extract_signals] wrote " + out_path)
    print("[extract_signals] functions=%d suspicious=%d network=%d crypto=%d strings=%d" % (
        out["function_count"], len(suspicious), len(network), len(crypto), len(out["interesting_strings"])
    ))

main()
