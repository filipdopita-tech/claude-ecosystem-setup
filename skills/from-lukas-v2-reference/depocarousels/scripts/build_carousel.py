#!/usr/bin/env python3
"""Build DEPO carousel HTML from copy JSON + optional blueprint PNG.

Usage:
    python3 build_carousel.py --copy /tmp/copy.json --blueprint /path/to/0042.png \
            --out /tmp/carousel.html

Both --blueprint and --out are optional. If --out omitted, prints to stdout.
"""
import argparse, base64, json, os, sys
from pathlib import Path

SKILL_DIR = Path(__file__).resolve().parent.parent
ASSETS = SKILL_DIR / "assets"

def b64(path: Path) -> str:
    return base64.b64encode(path.read_bytes()).decode()

def find_bahnschrift() -> Path | None:
    candidates = [
        ASSETS / "BAHNSCHRIFT_3.TTF",
        Path.home() / "Library/Fonts/BAHNSCHRIFT_3.TTF",
        Path.home() / "Library/Fonts/Bahnschrift.ttf",
        Path("/Library/Fonts/Bahnschrift.ttf"),
    ]
    for p in candidates:
        if p.exists():
            return p
    return None

def svg_uri(path: Path) -> str:
    return f"data:image/svg+xml;base64,{b64(path)}"

def png_uri(path: Path) -> str:
    # Auto-resize large blueprint PNGs to keep HTML under 1MB.
    if path.stat().st_size > 200_000:
        cache = Path(f"/tmp/depo_bp_{path.stem}_400.png")
        if not cache.exists():
            os.system(f"sips -Z 400 '{path}' --out '{cache}' >/dev/null 2>&1")
        if cache.exists():
            path = cache
    return f"data:image/png;base64,{b64(path)}"

# === Slide builders ===

def logo_dark(znacka_uri):
    return f'<img src="{znacka_uri}" style="position:absolute;top:24px;left:24px;width:62px;height:auto;z-index:10;filter:invert(1);opacity:0.88;">'

def logo_light(znacka_uri):
    return f'<img src="{znacka_uri}" style="position:absolute;top:24px;left:24px;width:62px;height:auto;z-index:10;opacity:0.72;">'

def arrow(dark=True):
    c = 'rgba(255,255,255,0.18)' if dark else 'rgba(0,0,0,0.15)'
    return f'<div style="position:absolute;right:0;top:0;bottom:0;width:38px;display:flex;align-items:center;justify-content:center;z-index:10;"><svg width="15" height="15" viewBox="0 0 24 24" fill="none"><path d="M9 6l6 6-6 6" stroke="{c}" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/></svg></div>'

def pbar(n, total, dark=True):
    pct = n / total * 100
    tc = 'rgba(255,255,255,0.07)' if dark else 'rgba(0,0,0,0.07)'
    cc = 'rgba(255,255,255,0.22)' if dark else 'rgba(0,0,0,0.22)'
    return (f'<div style="position:absolute;bottom:0;left:0;right:0;padding:12px 26px 16px;'
            f'display:flex;align-items:center;gap:10px;z-index:10;">'
            f'<div style="flex:1;height:1.5px;background:{tc};border-radius:1px;overflow:hidden;">'
            f'<div style="height:100%;width:{pct:.1f}%;background:#2726FD;border-radius:1px;"></div></div>'
            f'<span style="font-family:\'BN\',sans-serif;font-size:10px;color:{cc};flex-shrink:0;">{n}/{total}</span></div>')

def master_bg(master_uri, top=52, size=185, opacity=0.18):
    return (f'<img src="{master_uri}" style="position:absolute;top:{top}px;left:50%;'
            f'transform:translateX(-50%);width:{size}px;height:{size}px;'
            f'opacity:{opacity};z-index:3;pointer-events:none;">')

def ghost_text(text, size=200, opacity=0.08, bottom=44, right=-8):
    return (f'<div style="position:absolute;bottom:{bottom}px;right:{right}px;'
            f'font-family:\'BN\',sans-serif;font-variation-settings:&quot;wdth&quot; 75,&quot;wght&quot; 700;'
            f'font-size:{size}px;color:rgba(39,38,253,{opacity});line-height:1;'
            f'text-transform:uppercase;z-index:1;user-select:none;letter-spacing:-4px;">{text}</div>')

def blueprint_overlay(png_uri_str, bg='light', position='right'):
    op = 0.32 if bg == 'light' else 0.42
    if bg == 'light':
        blend_filter = 'mix-blend-mode:multiply;'
    else:
        blend_filter = 'mix-blend-mode:screen;filter:invert(1);'
    pos_map = {
        'right':       'top:64px;right:18px;',
        'right_lower': 'top:160px;right:18px;',
        'left':        'top:80px;left:14px;',
        'top_center':  'top:60px;left:50%;transform:translateX(-50%);',
    }
    pos = pos_map.get(position, pos_map['right'])
    return (f'<img src="{png_uri_str}" style="position:absolute;{pos}'
            f'width:170px;height:auto;max-height:200px;object-fit:contain;'
            f'opacity:{op};{blend_filter}z-index:2;pointer-events:none;">')

def rule(style='blue'):
    bg = {'blue': '#2726FD', 'muted': 'rgba(0,0,0,0.15)', 'white': 'rgba(255,255,255,0.2)'}.get(style, '#2726FD')
    return f'<div style="width:32px;height:2px;background:{bg};border-radius:1px;margin:14px 0;"></div>'

def headline_lines(lines, dark_bg=True):
    out = []
    for l in lines:
        col_token = l.get('color', 'white')
        if col_token == 'blue':
            color = '#2726FD'
        elif col_token == 'black':
            color = '#111111'
        elif col_token == 'white':
            color = '#ffffff'
        else:
            color = col_token
        size = l.get('size', 60)
        out.append(f'<div class="hl" style="font-size:{size}px;color:{color};line-height:1.02;">{l["text"]}</div>')
    return ''.join(out)

def body_html(text, dark_bg=True):
    color = 'rgba(255,255,255,0.52)' if dark_bg else 'rgba(0,0,0,0.54)'
    return f'<div class="body" style="color:{color};margin-top:8px;">{text}</div>'

def tag_html(tag, dark_bg=True):
    if not tag:
        return ''
    color = 'rgba(255,255,255,0.32)' if dark_bg else 'rgba(0,0,0,0.32)'
    return f'<div class="clbl" style="color:{color};">{tag}</div>'

def comparison_html(comp_type, data, dark_bg=True):
    if comp_type == 'boxes':
        bg_a = 'rgba(255,255,255,0.05)' if dark_bg else 'rgba(0,0,0,0.04)'
        col_a = 'rgba(255,255,255,0.35)' if dark_bg else 'rgba(0,0,0,0.4)'
        return (f'<div style="display:grid;grid-template-columns:1fr 1fr;margin-top:14px;border-radius:3px;overflow:hidden;">'
                f'<div style="background:{bg_a};padding:14px 15px 16px;">'
                f'<div class="clbl" style="color:{col_a};">{data["left"]["label"]}</div>'
                f'<div class="ctx">{data["left"]["text"]}</div></div>'
                f'<div style="background:rgba(39,38,253,0.14);border:2px solid #2726FD;padding:14px 15px 16px;">'
                f'<div class="clbl" style="color:#2726FD;">{data["right"]["label"]}</div>'
                f'<div class="ctx">{data["right"]["text"]}</div></div></div>')
    if comp_type == 'stack':
        bg_a = 'rgba(255,255,255,0.05)' if dark_bg else 'rgba(0,0,0,0.04)'
        col_a = 'rgba(255,255,255,0.35)' if dark_bg else 'rgba(0,0,0,0.4)'
        bord_a = 'rgba(255,255,255,0.2)' if dark_bg else 'rgba(0,0,0,0.2)'
        return (f'<div style="margin-top:16px;display:flex;flex-direction:column;gap:8px;">'
                f'<div style="background:{bg_a};border-left:3px solid {bord_a};padding:12px 14px;">'
                f'<div class="clbl" style="color:{col_a};">{data["left"]["label"]}</div>'
                f'<div class="ctx">{data["left"]["text"]}</div></div>'
                f'<div style="background:rgba(39,38,253,0.14);border-left:3px solid #2726FD;padding:12px 14px;">'
                f'<div class="clbl" style="color:#2726FD;">{data["right"]["label"]}</div>'
                f'<div class="ctx">{data["right"]["text"]}</div></div></div>')
    if comp_type == 'stat_numbers':
        text_a = 'rgba(255,255,255,0.2)' if dark_bg else 'rgba(0,0,0,0.2)'
        col_a = 'rgba(255,255,255,0.35)' if dark_bg else 'rgba(0,0,0,0.4)'
        bord = 'rgba(255,255,255,0.08)' if dark_bg else 'rgba(0,0,0,0.08)'
        body_col = 'rgba(255,255,255,0.5)' if dark_bg else 'rgba(0,0,0,0.55)'
        return (f'<div style="margin-top:14px;display:grid;grid-template-columns:1fr 1fr;gap:0;border-top:1px solid {bord};">'
                f'<div style="padding:16px 0;border-right:1px solid {bord};">'
                f'<div class="hl" style="font-size:64px;color:{text_a};line-height:0.9;">{data["left"]["value"]}</div>'
                f'<div class="clbl" style="color:{col_a};margin-top:8px;">{data["left"]["label"]}</div>'
                f'<div class="ctx" style="font-size:13px;color:{body_col};margin-top:4px;">{data["left"].get("subtitle","")}</div></div>'
                f'<div style="padding:16px 0 16px 16px;">'
                f'<div class="hl" style="font-size:64px;color:#2726FD;line-height:0.9;">{data["right"]["value"]}</div>'
                f'<div class="clbl" style="color:#2726FD;margin-top:8px;">{data["right"]["label"]}</div>'
                f'<div class="ctx" style="font-size:13px;color:{body_col};margin-top:4px;">{data["right"].get("subtitle","")}</div></div></div>')
    if comp_type == 'table':
        col_head = 'rgba(255,255,255,0.28)' if dark_bg else 'rgba(0,0,0,0.3)'
        col_a = 'rgba(255,255,255,0.35)' if dark_bg else 'rgba(0,0,0,0.4)'
        col_lbl = 'rgba(255,255,255,0.38)' if dark_bg else 'rgba(0,0,0,0.45)'
        col_val = 'rgba(255,255,255,0.55)' if dark_bg else 'rgba(0,0,0,0.6)'
        bord = 'rgba(255,255,255,0.06)' if dark_bg else 'rgba(0,0,0,0.06)'
        bord_top = 'rgba(255,255,255,0.12)' if dark_bg else 'rgba(0,0,0,0.12)'
        cols = data.get('columns', ['', 'A', 'B'])
        rows = data.get('rows', [])
        head = (f'<div style="display:grid;grid-template-columns:1fr 1fr 1fr;padding:0 0 8px;border-bottom:1px solid {bord_top};">'
                f'<div class="clbl" style="color:{col_head};font-size:9px;">{cols[0]}</div>'
                f'<div class="clbl" style="color:{col_a};font-size:9px;">{cols[1]}</div>'
                f'<div class="clbl" style="color:#2726FD;font-size:9px;">{cols[2]}</div></div>')
        rows_html = ''
        for r in rows:
            rows_html += (f'<div style="display:grid;grid-template-columns:1fr 1fr 1fr;padding:11px 0;border-bottom:1px solid {bord};">'
                          f'<div class="ctx" style="font-size:12px;color:{col_lbl};">{r[0]}</div>'
                          f'<div class="hl" style="font-size:14px;color:{col_val};">{r[1]}</div>'
                          f'<div class="hl" style="font-size:14px;color:#2726FD;">{r[2]}</div></div>')
        return f'<div style="margin-top:14px;">{head}{rows_html}</div>'
    if comp_type == 'progress_bars':
        col_lbl = 'rgba(255,255,255,0.38)' if dark_bg else 'rgba(0,0,0,0.45)'
        track = 'rgba(255,255,255,0.08)' if dark_bg else 'rgba(0,0,0,0.08)'
        out = '<div style="margin-top:16px;">'
        for it in data:
            accent = it.get('accent', False)
            val_color = '#2726FD' if accent else ('#ffffff' if dark_bg else '#111111')
            bar_color = '#2726FD' if accent else ('rgba(255,255,255,0.35)' if dark_bg else 'rgba(0,0,0,0.35)')
            out += (f'<div style="margin-bottom:14px;">'
                    f'<div style="display:flex;justify-content:space-between;align-items:baseline;margin-bottom:5px;">'
                    f'<div class="clbl" style="color:{col_lbl};">{it["label"]}</div>'
                    f'<div class="hl" style="font-size:13px;color:{val_color};">{it["value_text"]}</div></div>'
                    f'<div style="height:3px;background:{track};border-radius:2px;overflow:hidden;">'
                    f'<div style="height:100%;width:{it["pct"]}%;background:{bar_color};border-radius:2px;"></div></div></div>')
        out += '</div>'
        return out
    if comp_type == 'chips':
        bg_chip = 'rgba(255,255,255,0.05)' if dark_bg else 'rgba(0,0,0,0.04)'
        out = '<div style="margin-top:14px;display:flex;flex-direction:column;gap:6px;">'
        for chip in data:
            out += f'<div style="background:{bg_chip};padding:10px 14px;"><div class="ctx">{chip}</div></div>'
        out += '</div>'
        return out
    return ''

def list_html(items, dark_bg=True):
    bord = 'rgba(255,255,255,0.07)' if dark_bg else 'rgba(0,0,0,0.07)'
    out = f'<div style="margin-top:16px;"><div style="width:100%;height:1px;background:{bord};"></div>'
    for i, item in enumerate(items, 1):
        out += (f'<div style="display:flex;align-items:flex-start;gap:14px;padding:13px 0;">'
                f'<div class="hl" style="font-size:20px;color:#2726FD;flex-shrink:0;line-height:1;margin-top:1px;">{i:02d}</div>'
                f'<div class="ctx">{item}</div></div>'
                f'<div style="width:100%;height:1px;background:{bord};"></div>')
    out += '</div>'
    return out

def slide_html(slide, total, znacka_uri, master_uri, blueprint_uri):
    n = slide['n']
    bg = slide.get('bg', 'dark')
    dark = (bg in ('dark', 'cta'))
    extras = ''
    if slide.get('ghost_text'):
        extras += ghost_text(slide['ghost_text'])
    if slide.get('blueprint_overlay') and blueprint_uri:
        pos = slide.get('blueprint_position', 'right')
        extras += blueprint_overlay(blueprint_uri, bg=bg, position=pos)
    if slide['type'] == 'hook':
        extras += master_bg(master_uri, top=52, size=185, opacity=0.18)
    if slide['type'] == 'cta':
        extras += master_bg(master_uri, top=36, size=210, opacity=0.22)

    # Build content area
    parts = []
    if slide['type'] != 'cta':
        parts.append(tag_html(slide.get('tag'), dark))
    parts.append(headline_lines(slide.get('headline_lines', []), dark))
    if slide.get('rule'):
        parts.append(rule(slide['rule']))
    if slide['type'] == 'comparison':
        parts.append(comparison_html(slide.get('comparison_type', 'boxes'), slide.get('comparison_data', {}), dark))
    elif slide['type'] == 'list':
        parts.append(list_html(slide.get('list_items', []), dark))
    elif slide['type'] == 'cta':
        parts.append(f'<div class="addr">{slide.get("address","Fričova 2, Praha 2 — Vinohrady")}<br>{slide.get("services","Servis · Performance · Půjčovna")}</div>')
        parts.append(f'<div class="cta-btn">{slide.get("cta_button","SLEDUJ @DEPOCARSCOFFEE")}</div>')
    if slide.get('body'):
        parts.append(body_html(slide['body'], dark))

    content = f'<div style="position:absolute;left:28px;right:46px;bottom:52px;z-index:5;">{"".join(parts)}</div>'

    if bg == 'light':
        return (f'<div style="width:420px;height:525px;flex-shrink:0;position:relative;overflow:hidden;background:#F4F3F0;">'
                f'{extras}{logo_light(znacka_uri)}{arrow(False)}{content}{pbar(n,total,False)}</div>')
    if bg == 'cta':
        return (f'<div style="width:420px;height:525px;flex-shrink:0;position:relative;overflow:hidden;background:#080808;">'
                f'<div style="position:absolute;inset:0;background:linear-gradient(160deg,#111120 0%,#080810 55%,#030305 100%);"></div>'
                f'{extras}{logo_dark(znacka_uri)}{content}{pbar(n,total,True)}</div>')
    # default dark
    return (f'<div style="width:420px;height:525px;flex-shrink:0;position:relative;overflow:hidden;background:#111;">'
            f'<div style="position:absolute;inset:0;background:linear-gradient(160deg,#161628 0%,#0e0e14 55%,#060608 100%);"></div>'
            f'{extras}{logo_dark(znacka_uri)}{arrow(True)}{content}{pbar(n,total,True)}</div>')

def build_html(copy: dict, blueprint_path: Path | None) -> str:
    bahn = find_bahnschrift()
    if bahn:
        bahn_b64 = b64(bahn)
        font_face = (f"@font-face {{ font-family: 'BN'; src: url('data:font/truetype;base64,{bahn_b64}') format('truetype'); "
                     f"font-weight: 100 900; font-style: normal; }}")
        font_warning = ''
    else:
        font_face = "@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap'); .hl,.body,.clbl,.ctx,.addr,.cta-btn { font-family: 'Inter', sans-serif !important; }"
        font_warning = '<!-- WARN: Bahnschrift not found, using Inter fallback -->'

    znacka_uri = svg_uri(ASSETS / 'Znacka.svg')
    master_uri = svg_uri(ASSETS / 'Master_logo.svg')
    blueprint_uri = png_uri(blueprint_path) if blueprint_path else None

    css = """
    body { margin:0; padding:0; background:#000; }
    .wrap { width:420px; height:525px; overflow:hidden; }
    .vp { width:420px; height:525px; overflow:hidden; }
    .track { display:flex; transition:none; }
    .hl { font-family:'BN',sans-serif; font-variation-settings:"wdth" 75,"wght" 700; letter-spacing:-0.3px; text-transform:uppercase; }
    .body { font-family:'BN',sans-serif; font-variation-settings:"wdth" 100,"wght" 400; font-size:15px; line-height:1.65; max-width:295px; }
    .clbl { font-family:'BN',sans-serif; font-variation-settings:"wdth" 100,"wght" 600; font-size:10px; letter-spacing:3px; text-transform:uppercase; margin-bottom:8px; }
    .ctx { font-family:'BN',sans-serif; font-variation-settings:"wdth" 100,"wght" 400; font-size:14px; line-height:1.55; }
    .addr { font-family:'BN',sans-serif; font-variation-settings:"wdth" 100,"wght" 400; font-size:14px; line-height:1.7; color:rgba(255,255,255,0.38); margin-top:18px; }
    .cta-btn { font-family:'BN',sans-serif; font-variation-settings:"wdth" 75,"wght" 700; display:block; background:#2726FD; padding:15px 0; font-size:13px; letter-spacing:2.5px; text-transform:uppercase; color:#fff; border-radius:3px; margin-top:20px; text-align:center; }
    """

    slides_html = ''.join(slide_html(s, copy['total_slides'], znacka_uri, master_uri, blueprint_uri) for s in copy['slides'])

    return f"""<!doctype html><html><head><meta charset='utf-8'><style>{font_face}{css}</style></head>
<body>{font_warning}<div class='wrap'><div class='vp'><div class='track'>{slides_html}</div></div></div></body></html>"""

def main():
    p = argparse.ArgumentParser()
    p.add_argument('--copy', required=True, help='path to copy JSON file')
    p.add_argument('--blueprint', default=None, help='optional path to blueprint PNG')
    p.add_argument('--out', default=None, help='output HTML path (stdout if omitted)')
    args = p.parse_args()

    copy = json.loads(Path(args.copy).read_text())
    bp = Path(args.blueprint) if args.blueprint and Path(args.blueprint).exists() else None
    html = build_html(copy, bp)

    if args.out:
        Path(args.out).write_text(html)
        print(f"wrote {args.out} ({len(html)} bytes, {len(copy['slides'])} slides)")
    else:
        print(html)

if __name__ == '__main__':
    main()
