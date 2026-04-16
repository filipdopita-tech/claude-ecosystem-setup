---
name: convert
description: "Use this skill for any document/image format conversion: HTML→PDF (pixel-perfect, preferred), HTML→PNG screenshot, SVG→PNG/PDF/WebP, Markdown→PDF, Markdown→DOCX, HTML→DOCX, any→any via Pandoc. Triggers: 'převeď', 'konvertuj', 'exportuj jako PDF', 'HTML do PDF', 'SVG na PNG', 'screenshot stránky', 'render HTML', 'export do PDF'."
---

# Konverzní pipeline — decision matrix

## KTERÁ METODA PRO CO

| Vstup → Výstup | Metoda | Proč |
|---|---|---|
| HTML → PDF | **Playwright Chromium** | Pixel-perfect, plný CSS3/JS, fonty, media queries |
| HTML → PNG/JPEG | **Playwright screenshot** | Přesný render jako v Chrome |
| SVG → PNG/PDF/WebP | **rsvg-convert** nebo **ImageMagick** | Vektorový render, správné fonty |
| Markdown → PDF | **Pandoc + WeasyPrint** nebo **Playwright** | Přes HTML intermediate |
| Markdown → DOCX | **Pandoc** | Nativní konverze |
| HTML → DOCX | **Pandoc** | Přes docx skill |
| PDF → PNG (render stran) | **pypdfium2** | Chromium PDF engine |
| PDF → Text | **pdfplumber** | Zachová layout |

**NIKDY nepoužívej WeasyPrint pro HTML→PDF** pokud HTML obsahuje: CSS Grid, Flexbox, custom fonts, JS, Bootstrap, Tailwind, shadcn, nebo jakékoli moderní CSS. WeasyPrint to zprasí.

---

## 1. HTML → PDF (Playwright — DEFAULT)

```python
from playwright.sync_api import sync_playwright
import os

def html_to_pdf(html_input: str, output_path: str, 
                format: str = "A4",
                margin_mm: int = 15,
                print_background: bool = True,
                landscape: bool = False):
    """
    html_input: cesta k .html souboru NEBO HTML string
    output_path: výstupní .pdf soubor
    """
    with sync_playwright() as p:
        browser = p.chromium.launch()
        page = browser.new_page()
        
        # Rozliš soubor vs HTML string
        if os.path.isfile(html_input):
            page.goto(f"file://{os.path.abspath(html_input)}")
        else:
            page.set_content(html_input, wait_until="networkidle")
        
        # Počkej na fonty a obrázky
        page.wait_for_load_state("networkidle")
        
        m = f"{margin_mm}mm"
        page.pdf(
            path=output_path,
            format=format,
            print_background=print_background,
            landscape=landscape,
            margin={"top": m, "bottom": m, "left": m, "right": m}
        )
        browser.close()

# Použití:
html_to_pdf("input.html", "output.pdf")
html_to_pdf("<h1>Ahoj</h1>", "output.pdf")
html_to_pdf("input.html", "output.pdf", format="A3", landscape=True)
```

### Vlastní page size (mm)
```python
page.pdf(
    path="output.pdf",
    width="210mm",   # A4 šířka
    height="297mm",  # A4 výška
    print_background=True,
    margin={"top": "20mm", "bottom": "20mm", "left": "15mm", "right": "15mm"}
)
```

### Headless Chrome s @media print CSS
```html
<!-- V HTML přidej print-specific styly -->
<style>
@media print {
    .no-print { display: none; }
    .page-break { page-break-before: always; }
    body { font-size: 12pt; }
}
</style>
```

### Lokální fonty a assety (DŮLEŽITÉ)
```python
# Pokud HTML odkazuje na lokální CSS/obrázky, musí být cesta k souboru absolutní
# NEBO použij base64 embedded resources

# Base64 embed CSS:
import base64, pathlib

css = pathlib.Path("styles.css").read_bytes()
css_b64 = base64.b64encode(css).decode()
html = f'<link rel="stylesheet" href="data:text/css;base64,{css_b64}">'

# Base64 embed obrázek:
img = pathlib.Path("logo.png").read_bytes()
img_b64 = base64.b64encode(img).decode()
html_img = f'<img src="data:image/png;base64,{img_b64}">'
```

---

## 2. HTML → PNG / JPEG (Playwright screenshot)

```python
from playwright.sync_api import sync_playwright
import os

def html_to_image(html_input: str, output_path: str,
                  width: int = 1200,
                  full_page: bool = True,
                  device_scale_factor: float = 2.0):  # 2x = retina quality
    """
    device_scale_factor=2.0 = 2x ostrost (retina). Pro IG kariery použij 2-3x.
    """
    with sync_playwright() as p:
        browser = p.chromium.launch()
        page = browser.new_page(
            viewport={"width": width, "height": 800},
            device_scale_factor=device_scale_factor
        )
        
        if os.path.isfile(html_input):
            page.goto(f"file://{os.path.abspath(html_input)}")
        else:
            page.set_content(html_input, wait_until="networkidle")
        
        page.wait_for_load_state("networkidle")
        
        # Určí formát z extension
        fmt = "jpeg" if output_path.endswith((".jpg", ".jpeg")) else "png"
        page.screenshot(
            path=output_path,
            full_page=full_page,
            type=fmt
        )
        browser.close()

# IG carousel slide (1080x1350):
def html_to_instagram(html_input: str, output_path: str):
    with sync_playwright() as p:
        browser = p.chromium.launch()
        page = browser.new_page(
            viewport={"width": 1080, "height": 1350},
            device_scale_factor=2.0
        )
        if os.path.isfile(html_input):
            page.goto(f"file://{os.path.abspath(html_input)}")
        else:
            page.set_content(html_input, wait_until="networkidle")
        page.wait_for_load_state("networkidle")
        page.screenshot(path=output_path, clip={"x":0,"y":0,"width":1080,"height":1350})
        browser.close()
```

---

## 3. SVG → PNG / PDF / WebP

```bash
# rsvg-convert (doporučeno — vektorový render, správné fonty)
rsvg-convert input.svg -o output.png                    # PNG (výchozí)
rsvg-convert input.svg -f pdf -o output.pdf             # PDF
rsvg-convert input.svg -f svg -o output_clean.svg       # Clean SVG
rsvg-convert -w 1200 input.svg -o output_1200.png       # Šířka 1200px
rsvg-convert -w 2160 -h 2160 input.svg -o icon_2x.png  # Fixed dimensions

# ImageMagick (pro batch nebo WebP)
magick input.svg -density 300 output.png                # High-DPI PNG
magick input.svg -density 300 output.webp               # WebP
magick input.svg -density 300 -resize 1080x1080 output.png

# Python via subprocess
import subprocess

def svg_to_png(svg_path: str, output_path: str, width: int = None):
    cmd = ["rsvg-convert"]
    if width:
        cmd += ["-w", str(width)]
    cmd += [svg_path, "-o", output_path]
    subprocess.run(cmd, check=True)

def svg_to_pdf(svg_path: str, output_path: str):
    subprocess.run(["rsvg-convert", "-f", "pdf", svg_path, "-o", output_path], check=True)
```

---

## 4. Markdown → PDF

```bash
# Metoda A: pandoc → HTML → Playwright PDF (nejlepší vizuál)
pandoc input.md -o /tmp/intermediate.html --standalone --embed-resources
# pak spusť html_to_pdf("/tmp/intermediate.html", "output.pdf")

# Metoda B: pandoc přímo do PDF přes weasyprint
pandoc input.md -o output.pdf --pdf-engine=weasyprint

# Metoda C: pandoc s LaTeX (pro vědecké dokumenty)
pandoc input.md -o output.pdf --pdf-engine=xelatex
```

---

## 5. Markdown → DOCX

```bash
pandoc input.md -o output.docx
pandoc input.md -o output.docx --reference-doc=template.docx  # s template
```

---

## 6. PDF stránky → PNG (pro náhled/edit)

```python
import pypdfium2 as pdfium
from pathlib import Path

def pdf_to_images(pdf_path: str, output_dir: str, scale: float = 2.0):
    """scale=2.0 = 144 DPI (retina). scale=3.0 = 216 DPI."""
    Path(output_dir).mkdir(exist_ok=True)
    doc = pdfium.PdfDocument(pdf_path)
    for i, page in enumerate(doc):
        bitmap = page.render(scale=scale)
        pil_image = bitmap.to_pil()
        pil_image.save(f"{output_dir}/page_{i+1:03d}.png")

pdf_to_images("document.pdf", "/tmp/pages/")
```

---

## 7. Batch konverze

```python
from pathlib import Path
from playwright.sync_api import sync_playwright

def batch_html_to_pdf(html_dir: str, output_dir: str):
    Path(output_dir).mkdir(exist_ok=True)
    html_files = list(Path(html_dir).glob("*.html"))
    
    with sync_playwright() as p:
        browser = p.chromium.launch()
        
        for html_file in html_files:
            page = browser.new_page()
            page.goto(f"file://{html_file.absolute()}")
            page.wait_for_load_state("networkidle")
            output = Path(output_dir) / html_file.with_suffix(".pdf").name
            page.pdf(path=str(output), format="A4", print_background=True,
                     margin={"top":"15mm","bottom":"15mm","left":"15mm","right":"15mm"})
            page.close()
            print(f"✓ {html_file.name} → {output.name}")
        
        browser.close()
```

---

## 8. Utility script (uložit jako ~/scripts/convert.py)

```python
#!/usr/bin/env python3
"""
Universal converter. Použití:
  python3 ~/scripts/convert.py input.html output.pdf
  python3 ~/scripts/convert.py input.html output.png
  python3 ~/scripts/convert.py input.svg output.png
  python3 ~/scripts/convert.py input.md output.pdf
  python3 ~/scripts/convert.py input.md output.docx
"""
import sys, os, subprocess
from pathlib import Path

def main():
    if len(sys.argv) < 3:
        print(__doc__)
        sys.exit(1)
    
    src = Path(sys.argv[1])
    dst = Path(sys.argv[2])
    src_ext = src.suffix.lower()
    dst_ext = dst.suffix.lower()
    
    if not src.exists():
        print(f"Error: {src} neexistuje"); sys.exit(1)
    
    dst.parent.mkdir(parents=True, exist_ok=True)
    
    # HTML → PDF
    if src_ext in (".html", ".htm") and dst_ext == ".pdf":
        from playwright.sync_api import sync_playwright
        with sync_playwright() as p:
            b = p.chromium.launch()
            pg = b.new_page()
            pg.goto(f"file://{src.absolute()}")
            pg.wait_for_load_state("networkidle")
            pg.pdf(path=str(dst), format="A4", print_background=True,
                   margin={"top":"15mm","bottom":"15mm","left":"15mm","right":"15mm"})
            b.close()
        print(f"✓ {src} → {dst}")
    
    # HTML → PNG/JPEG
    elif src_ext in (".html", ".htm") and dst_ext in (".png", ".jpg", ".jpeg"):
        from playwright.sync_api import sync_playwright
        with sync_playwright() as p:
            b = p.chromium.launch()
            pg = b.new_page(viewport={"width":1200,"height":800}, device_scale_factor=2.0)
            pg.goto(f"file://{src.absolute()}")
            pg.wait_for_load_state("networkidle")
            fmt = "jpeg" if dst_ext in (".jpg",".jpeg") else "png"
            pg.screenshot(path=str(dst), full_page=True, type=fmt)
            b.close()
        print(f"✓ {src} → {dst}")
    
    # SVG → PNG/PDF/WebP
    elif src_ext == ".svg":
        if dst_ext == ".pdf":
            subprocess.run(["rsvg-convert", "-f", "pdf", str(src), "-o", str(dst)], check=True)
        elif dst_ext in (".webp",):
            subprocess.run(["magick", str(src), "-density", "300", str(dst)], check=True)
        else:  # png, jpg
            subprocess.run(["rsvg-convert", str(src), "-o", str(dst)], check=True)
        print(f"✓ {src} → {dst}")
    
    # Markdown → PDF
    elif src_ext == ".md" and dst_ext == ".pdf":
        import tempfile
        with tempfile.NamedTemporaryFile(suffix=".html", delete=False) as tmp:
            subprocess.run(["pandoc", str(src), "-o", tmp.name,
                           "--standalone", "--embed-resources"], check=True)
            from playwright.sync_api import sync_playwright
            with sync_playwright() as p:
                b = p.chromium.launch()
                pg = b.new_page()
                pg.goto(f"file://{tmp.name}")
                pg.wait_for_load_state("networkidle")
                pg.pdf(path=str(dst), format="A4", print_background=True,
                       margin={"top":"20mm","bottom":"20mm","left":"20mm","right":"20mm"})
                b.close()
        print(f"✓ {src} → {dst}")
    
    # Markdown → DOCX
    elif src_ext == ".md" and dst_ext == ".docx":
        subprocess.run(["pandoc", str(src), "-o", str(dst)], check=True)
        print(f"✓ {src} → {dst}")
    
    else:
        print(f"Nepodporovaná kombinace: {src_ext} → {dst_ext}")
        sys.exit(1)

if __name__ == "__main__":
    main()
```

---

## Časté problémy

| Problém | Příčina | Fix |
|---|---|---|
| Bílé boxy místo textu | Chybí lokální font | Embed font jako base64 nebo `@font-face` s absolutní cestou |
| Oříznutý obsah | Špatný viewport/margin | Přidej `wait_for_load_state("networkidle")` + zkontroluj margin |
| SVG pixelated | Malý rozlišení | `-w 2160` u rsvg-convert nebo `device_scale_factor=3` |
| Obrázky chybí | Relativní cesty | Použij absolutní cesty nebo base64 |
| WeasyPrint fallout | CSS Grid/Flex | Přejdi na Playwright |
| JS-rendered content | WeasyPrint bez JS | Playwright povinně |
