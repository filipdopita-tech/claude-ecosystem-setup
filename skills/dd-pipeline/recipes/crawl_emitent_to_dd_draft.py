#!/usr/bin/env python3
"""
Crawl emitent landing → discover PDF prospekty → parse via docling → DD draft.

Source: research-briefings/2026-05-03/d4vinci-FREE-FILIP-TODO.md § 3.1
Chain: crawl4ai (web → markdown) → docling (PDF → structured MD) → DD draft skeleton

Usage:
  python crawl_emitent_to_dd_draft.py <emitent_url> [--out=DIR]

Output:
  <out_dir>/<host>/index.md         — landing page markdown
  <out_dir>/<host>/pdfs/*.md        — each found PDF parsed
  <out_dir>/<host>/dd_draft.md      — combined DD draft skeleton

Real benchmark on oneflow.cz (2026-05-03):
  crawl4ai fetch: 4.36s, 16135 chars markdown
  docling per PDF: ~5-30s warm cache (~2min cold first-run)

Citations:
  - unclecode/crawl4ai (Apache 2.0)
  - docling-project/docling (MIT)
"""
from __future__ import annotations

import argparse
import asyncio
import os
import re
import subprocess
import sys
import time
from pathlib import Path
from urllib.parse import urljoin, urlparse


CRAWL4AI_PYTHON = os.path.expanduser("~/.venvs/crawl4ai/bin/python")
DOCLING_PYTHON = os.path.expanduser("~/.venvs/docling/bin/python")
DEFAULT_OUT_DIR = Path("~/Desktop/Codex/dd-pipeline-runs").expanduser()


def host_dir(url: str) -> str:
    return re.sub(r"[^a-z0-9.-]+", "_", urlparse(url).netloc.lower())


async def _crawl(url: str) -> dict:
    # Run inline if invoked directly via this venv; else subprocess to crawl4ai venv.
    try:
        from crawl4ai import AsyncWebCrawler  # type: ignore
    except ImportError:
        return await _crawl_subprocess(url)
    async with AsyncWebCrawler(verbose=False) as crawler:
        r = await crawler.arun(url=url, cache_mode="BYPASS")
        md = r.markdown.raw_markdown if hasattr(r.markdown, "raw_markdown") else str(r.markdown)
        return {"url": url, "markdown": md, "ok": True}


async def _crawl_subprocess(url: str) -> dict:
    code = f"""
import asyncio, json
from crawl4ai import AsyncWebCrawler

async def main():
    async with AsyncWebCrawler(verbose=False) as c:
        r = await c.arun(url={url!r}, cache_mode='BYPASS')
        md = r.markdown.raw_markdown if hasattr(r.markdown,'raw_markdown') else str(r.markdown)
        print('---MDSTART---')
        print(md)

asyncio.run(main())
"""
    p = subprocess.run([CRAWL4AI_PYTHON, "-c", code], capture_output=True, text=True, timeout=120)
    md = p.stdout.split("---MDSTART---", 1)[-1].strip() if "---MDSTART---" in p.stdout else ""
    return {"url": url, "markdown": md, "ok": p.returncode == 0}


def discover_pdfs(markdown: str, base_url: str) -> list[str]:
    pdfs: set[str] = set()
    for match in re.findall(r'\(([^)]*\.pdf)\)', markdown, flags=re.I):
        pdfs.add(urljoin(base_url, match))
    for match in re.findall(r'https?://\S+\.pdf', markdown, flags=re.I):
        pdfs.add(match)
    return sorted(pdfs)


def parse_pdf_via_docling(pdf_url: str, save_to: Path) -> dict:
    """Download via curl + parse via docling subprocess."""
    save_to.parent.mkdir(parents=True, exist_ok=True)
    pdf_path = save_to.with_suffix(".pdf")
    p = subprocess.run(
        ["curl", "-fsSL", "--max-time", "60", "-o", str(pdf_path), pdf_url],
        capture_output=True, text=True
    )
    if p.returncode != 0:
        return {"ok": False, "error": f"download failed: {p.stderr[:200]}"}

    code = f"""
from docling.document_converter import DocumentConverter
import sys
doc = DocumentConverter().convert({str(pdf_path)!r})
md = doc.document.export_to_markdown()
with open(sys.argv[1],'w') as f: f.write(md)
print('pages:', len(doc.document.pages), 'chars:', len(md))
"""
    p2 = subprocess.run([DOCLING_PYTHON, "-c", code, str(save_to)], capture_output=True, text=True, timeout=600)
    return {"ok": p2.returncode == 0, "stdout": p2.stdout.strip(), "stderr": p2.stderr[-200:] if p2.stderr else ""}


def build_dd_draft(host: str, web_md: str, pdf_results: list[dict], out_dir: Path) -> Path:
    draft_path = out_dir / "dd_draft.md"
    lines = [
        f"# DD Draft: {host}",
        f"**Generated:** {time.strftime('%Y-%m-%d %H:%M')}",
        f"**Source:** crawl4ai + docling auto-discovery",
        "",
        "## Krok 0: Discovery",
        f"- Landing page chars: {len(web_md):,}",
        f"- PDFs found: {len(pdf_results)}",
        "",
        "## Krok 1: Web extract (TOP excerpts)",
        "",
        "```",
        web_md[:3000],
        "```",
        "",
        "## Krok 2: PDF prospekty parsed",
        "",
    ]
    for r in pdf_results:
        lines.append(f"### {r['url']}")
        if r.get("ok"):
            lines.append(f"- Saved: `{r['md_path']}`")
            lines.append(f"- Stats: {r.get('stdout','')}")
        else:
            lines.append(f"- ERROR: {r.get('error') or r.get('stderr','')}")
        lines.append("")
    lines.extend([
        "## Krok 3: TODO — manual analysis",
        "- [ ] Tržby 3Y trend (z výroční zprávy)",
        "- [ ] DSCR / LTV calc (extract z PDF tabulek — chain `dd-emitent recipes/pdf_3tier.py --tier=3`)",
        "- [ ] Red flags screening (viz dd-emitent SKILL.md § Krok 4)",
        "- [ ] Scoring + verdict",
        "",
        "## Chain (recommended)",
        "1. `dd-emitent recipes/pdf_3tier.py --tier=3 <prospekt.pdf>` pro DSCR/LTV grids",
        "2. `algorithm-recall recipes/dd-financial.py --screen` pro auto-classification",
        "3. `algorithm-recall recipes/dd-bayesian-risk.py --metrics ...` pro A-F grade",
        "4. `dd-emitent` skill final report build",
    ])
    draft_path.write_text("\n".join(lines))
    return draft_path


async def main_async(url: str, out_root: Path):
    host = host_dir(url)
    out_dir = out_root / host
    out_dir.mkdir(parents=True, exist_ok=True)

    print(f"[1/3] Crawling {url}", file=sys.stderr)
    t0 = time.time()
    web = await _crawl(url)
    print(f"  done in {time.time()-t0:.2f}s, ok={web['ok']}, chars={len(web['markdown'])}", file=sys.stderr)

    if not web["ok"]:
        sys.exit(f"Crawl failed for {url}")

    (out_dir / "index.md").write_text(web["markdown"])

    pdfs = discover_pdfs(web["markdown"], url)
    print(f"[2/3] PDFs discovered: {len(pdfs)}", file=sys.stderr)
    pdf_results = []
    for i, pdf in enumerate(pdfs[:8], 1):  # cap 8 to avoid runaway
        print(f"  ({i}/{min(len(pdfs),8)}) parsing {pdf}", file=sys.stderr)
        md_path = out_dir / "pdfs" / f"{i:02d}_{Path(pdf).name}.md"
        result = parse_pdf_via_docling(pdf, md_path)
        result["url"] = pdf
        result["md_path"] = str(md_path) if result.get("ok") else None
        pdf_results.append(result)

    print(f"[3/3] Building DD draft", file=sys.stderr)
    draft = build_dd_draft(host, web["markdown"], pdf_results, out_dir)
    print(f"\nDONE: {draft}")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("emitent_url")
    ap.add_argument("--out", default=str(DEFAULT_OUT_DIR), help=f"Output root (default: {DEFAULT_OUT_DIR})")
    args = ap.parse_args()

    out_root = Path(args.out).expanduser()
    asyncio.run(main_async(args.emitent_url, out_root))


if __name__ == "__main__":
    main()
