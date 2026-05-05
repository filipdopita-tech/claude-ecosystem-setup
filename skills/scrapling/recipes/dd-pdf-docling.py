#!/usr/bin/env python3
"""
DD prospekt PDF → strukturovaný markdown přes docling (IBM Document AI).

Pro use case OneFlow `dd-emitent` skill: prospekty 50-200 stran s tabulkami,
grafy, signaturovymi bloky. Docling poradí lépe než pdfplumber/pypdf protože:

- Detekuje tabulky a převádí na markdown table syntax
- Rozpozná hierarchii headingu (DD pravidla → markdown # ## ###)
- Vytáhne bibliografii / signatures / footnotes
- OCR fallback na obrazové stránky (RapidOCR built-in)

Use only docling venv (separate od scrapling kvůli ML deps):
    ~/.venvs/docling/bin/python dd-pdf-docling.py prospekt.pdf
    ~/.venvs/docling/bin/python dd-pdf-docling.py https://emitent.cz/prospekt.pdf

Output:
    ~/Desktop/Codex/scrapling-runs/dd-{stem}-YYYY-MM-DD/
    ├── source.md          (full structured markdown)
    ├── tables.json        (extracted tables as JSON arrays)
    ├── financial.txt      (auto-extracted DSCR/LTV/yield mentions)
    └── REPORT.md          (DD-friendly summary header)

Pair s `~/.claude/skills/scrapling/recipes/dd-emitent-html.py`:
- HTML landing → dd-emitent-html.py (rychlé, signal extract)
- PDF prospekt (50-200 stran) → THIS recipe (docling, struktura preserved)
- Combinable v dd-pipeline / dd-batch-sql workflows
"""

import sys
import os
import re
import json
import datetime
from pathlib import Path

# Docling venv specific path
sys.path.insert(0, '/Users/filipdopita/.venvs/docling/lib/python3.12/site-packages')

try:
    from docling.document_converter import DocumentConverter
except ImportError:
    print("ERROR: docling not in path. Run: ~/.venvs/docling/bin/python dd-pdf-docling.py", file=sys.stderr)
    sys.exit(1)

OUT_BASE = Path.home() / "Desktop/Codex/scrapling-runs"
TODAY = datetime.date.today().isoformat()

DSCR_RE = re.compile(r"DSCR[\s:]*\d+[.,]?\d*", re.IGNORECASE)
LTV_RE = re.compile(r"LTV[\s:]*\d+[.,]?\d*\s*%?", re.IGNORECASE)
YIELD_RE = re.compile(r"\d+[.,]?\d*\s*%\s*(p\.?a\.?|ročně|per annum)", re.IGNORECASE)
EBITDA_RE = re.compile(r"EBITDA[\s:]*[\d,. ]+", re.IGNORECASE)
EMISE_RE = re.compile(r"emise.{0,50}\d+[\s,. ]*(?:Kč|CZK|EUR|mil|miliard)", re.IGNORECASE)
SPLATNOST_RE = re.compile(r"splatnost.{0,80}\d{4}", re.IGNORECASE)


def extract_financial_signals(text: str) -> dict:
    """Auto-extract DD-relevant financial mentions."""
    return {
        "dscr": DSCR_RE.findall(text)[:10],
        "ltv": LTV_RE.findall(text)[:10],
        "yield": [m.group(0) if hasattr(m, 'group') else m for m in YIELD_RE.findall(text)][:10],
        "ebitda": EBITDA_RE.findall(text)[:10],
        "emise": EMISE_RE.findall(text)[:10],
        "splatnost": SPLATNOST_RE.findall(text)[:10],
    }


def main():
    if len(sys.argv) < 2:
        print("usage: dd-pdf-docling.py <pdf-url-or-path>", file=sys.stderr)
        sys.exit(1)

    src = sys.argv[1]
    stem = Path(src).stem if not src.startswith("http") else "remote"
    safe_stem = re.sub(r"[^a-zA-Z0-9._-]", "_", stem)[:60]
    out_dir = OUT_BASE / f"dd-{safe_stem}-{TODAY}"
    out_dir.mkdir(parents=True, exist_ok=True)

    print(f"[dd-docling] converting {src} -> {out_dir}", file=sys.stderr)

    converter = DocumentConverter()
    result = converter.convert(src)

    # Full markdown
    md = result.document.export_to_markdown()
    md_path = out_dir / "source.md"
    md_path.write_text(md)
    print(f"[dd-docling] markdown saved: {len(md)} chars -> {md_path}", file=sys.stderr)

    # Extract tables
    tables = []
    for table in result.document.tables:
        try:
            rows = []
            for row in table.data.table_cells:
                rows.append([cell.text if hasattr(cell, 'text') else str(cell) for cell in row])
            tables.append(rows)
        except Exception as e:
            tables.append({"_extract_error": str(e)})
    tables_path = out_dir / "tables.json"
    tables_path.write_text(json.dumps(tables, indent=2, ensure_ascii=False))
    print(f"[dd-docling] tables: {len(tables)} -> {tables_path}", file=sys.stderr)

    # Financial signals
    financial = extract_financial_signals(md)
    fin_path = out_dir / "financial.txt"
    with open(fin_path, "w") as f:
        for category, items in financial.items():
            if items:
                f.write(f"=== {category.upper()} ===\n")
                for item in items:
                    f.write(f"  {item}\n")
                f.write("\n")
    print(f"[dd-docling] financial signals: {sum(len(v) for v in financial.values())} mentions -> {fin_path}", file=sys.stderr)

    # DD-friendly REPORT
    report = [
        f"# DD Prospekt Quick Report",
        f"",
        f"- **Source:** {src}",
        f"- **Processed:** {datetime.datetime.now().isoformat()}",
        f"- **Pages converted:** {len(result.document.pages) if hasattr(result.document, 'pages') else 'N/A'}",
        f"- **Tables extracted:** {len(tables)}",
        f"- **Markdown size:** {len(md):,} chars (~{len(md)//5:,} tokens)",
        f"",
        f"## Financial signals (auto-extract)",
        f"",
    ]
    for category, items in financial.items():
        if items:
            report.append(f"### {category.upper()} ({len(items)} mentions)")
            for item in items:
                report.append(f"- `{item}`")
            report.append("")

    report.extend([
        f"## Files",
        f"- `source.md` — full markdown (DD analyst input)",
        f"- `tables.json` — structured tables for /algorithm-recall recipes",
        f"- `financial.txt` — DSCR/LTV/yield/EBITDA quick scan",
        f"",
        f"## Next steps (chain)",
        f"- `dd-emitent` skill — feed `source.md` as primary input",
        f"- `algorithm-recall recipes/dd-financial.py --screen` — DSCR/LTV combo screening",
        f"- `algorithm-recall recipes/dd-bayesian-risk.py` — A-F grading",
        f"",
        f"---",
        f"_Generated by `~/.claude/skills/scrapling/recipes/dd-pdf-docling.py` (docling 2.x, IBM)._",
    ])

    report_path = out_dir / "REPORT.md"
    report_path.write_text("\n".join(report))
    print(f"[dd-docling] DONE -> {report_path}", file=sys.stderr)
    print(report_path)  # stdout = path for chaining


if __name__ == "__main__":
    main()
