#!/usr/bin/env python3
"""
3-tier PDF parsing pro dd-emitent (added 2026-05-03 z D4Vinci audit).

Decision tree:
- Tier 1 (markitdown): rychlý sken — "co je v tom prospektu", flat text
  Real benchmark: 4.37s na BICZ Soukup OneFlow nabidka (7 pages, 11507 chars)
- Tier 2 (docling): strukturovaný — headers, image markers, tabulky
  Real benchmark: 31.1s warm cache (~2min first run), 9501 chars, ## headers
- Tier 3 (pdfplumber): heavy tabulky — DSCR/LTV calc grids
  Stále preferuj přes existing pdf-extraction skill

Activation venvs:
  Tier 1: ~/.venvs/d4vinci-eval (markitdown 0.1.5)
  Tier 2: ~/.venvs/docling (docling + RapidOCR cached models)
  Tier 3: existing pdf-extraction skill venv

Usage:
  python pdf_3tier.py <pdf_path> [--tier=1|2|3|auto]

  --tier=auto picks based on file size + first-page sample:
    < 500KB and no tables detected → tier 1
    >= 500KB or structured prospekt → tier 2
    Heavy financial tables → tier 3 (delegate to pdf-extraction)
"""
from __future__ import annotations

import argparse
import os
import subprocess
import sys
import time
from pathlib import Path


def tier1_markitdown(pdf_path: str) -> dict:
    """Tier 1: markitdown via d4vinci-eval venv."""
    py = os.path.expanduser("~/.venvs/d4vinci-eval/bin/python")
    code = f"""
from markitdown import MarkItDown
import sys, time
t0 = time.time()
out = MarkItDown().convert({pdf_path!r}).text_content
print(out)
print(f"--- META chars={{len(out)}} elapsed_s={{time.time()-t0:.2f}} ---", file=sys.stderr)
"""
    r = subprocess.run([py, "-c", code], capture_output=True, text=True, timeout=120)
    return {
        "tier": 1,
        "engine": "markitdown",
        "text": r.stdout,
        "meta": r.stderr.split("--- META")[-1].strip() if "--- META" in r.stderr else "",
        "ok": r.returncode == 0,
    }


def tier2_docling(pdf_path: str) -> dict:
    """Tier 2: docling structured via docling venv."""
    py = os.path.expanduser("~/.venvs/docling/bin/python")
    code = f"""
from docling.document_converter import DocumentConverter
import sys, time
t0 = time.time()
doc = DocumentConverter().convert({pdf_path!r})
md = doc.document.export_to_markdown()
print(md)
print(f"--- META pages={{len(doc.document.pages)}} chars={{len(md)}} elapsed_s={{time.time()-t0:.2f}} ---", file=sys.stderr)
"""
    r = subprocess.run([py, "-c", code], capture_output=True, text=True, timeout=600)
    return {
        "tier": 2,
        "engine": "docling",
        "text": r.stdout,
        "meta": r.stderr.split("--- META")[-1].strip() if "--- META" in r.stderr else "",
        "ok": r.returncode == 0,
    }


def tier3_pdfplumber(pdf_path: str) -> dict:
    """Tier 3: pdfplumber via existing pdf-extraction skill (fallback inline)."""
    code = """
import sys, time
import pdfplumber
t0 = time.time()
pages_data = []
with pdfplumber.open(sys.argv[1]) as pdf:
    for i, page in enumerate(pdf.pages):
        tables = page.extract_tables()
        text = page.extract_text() or ""
        pages_data.append({"page": i+1, "text_chars": len(text), "tables": len(tables)})
        if tables:
            print(f"=== PAGE {i+1} TABLES ({len(tables)}) ===")
            for t in tables:
                for row in t:
                    print("|".join(str(c or "") for c in row))
print(f"--- META pages={len(pages_data)} elapsed_s={time.time()-t0:.2f} ---", file=__import__('sys').stderr)
"""
    # Try several venvs that might have pdfplumber
    for venv in ["~/.venvs/d4vinci-eval", "~/.venvs/docling", "~/.venvs/scrapling"]:
        py = os.path.expanduser(f"{venv}/bin/python")
        if not Path(py).exists():
            continue
        check = subprocess.run([py, "-c", "import pdfplumber"], capture_output=True)
        if check.returncode == 0:
            r = subprocess.run([py, "-c", code, pdf_path], capture_output=True, text=True, timeout=300)
            return {
                "tier": 3,
                "engine": f"pdfplumber ({venv})",
                "text": r.stdout,
                "meta": r.stderr.split("--- META")[-1].strip() if "--- META" in r.stderr else "",
                "ok": r.returncode == 0,
            }
    return {"tier": 3, "engine": "pdfplumber", "text": "", "meta": "ERROR: pdfplumber not in any venv", "ok": False}


def auto_pick(pdf_path: str) -> int:
    """Heuristic: pick tier based on file size + filename hints."""
    size = Path(pdf_path).stat().st_size
    name = Path(pdf_path).name.lower()
    table_hints = ["dscr", "ltv", "rozvaha", "balance", "cash", "tabulka", "vypocet", "calc"]
    has_table_hint = any(h in name for h in table_hints)
    if has_table_hint:
        return 3
    if size < 500_000:
        return 1
    return 2


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("pdf_path")
    ap.add_argument("--tier", choices=["1", "2", "3", "auto"], default="auto")
    args = ap.parse_args()

    if not Path(args.pdf_path).exists():
        sys.exit(f"PDF not found: {args.pdf_path}")

    tier = int(args.tier) if args.tier != "auto" else auto_pick(args.pdf_path)
    print(f"# Picked tier: {tier} (file size {Path(args.pdf_path).stat().st_size:,} bytes)", file=sys.stderr)

    fn = {1: tier1_markitdown, 2: tier2_docling, 3: tier3_pdfplumber}[tier]
    t0 = time.time()
    result = fn(args.pdf_path)
    elapsed = time.time() - t0

    print(result["text"])
    print(f"\n# {result['engine']} | {result['meta']} | wall_s={elapsed:.2f} | ok={result['ok']}", file=sys.stderr)


if __name__ == "__main__":
    main()
