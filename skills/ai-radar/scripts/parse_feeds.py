#!/usr/bin/env python3
"""
ai-radar: parse RSS/XML/Markdown/HTML feed files, dedupe, emit health.json.
Volá se ze scan.sh po `jq -s 'add'` combine.

F-008: parse 4 zdrojů (Anthropic CHANGELOG MD, API HTML notes, OpenAI RSS, Google AI RSS).
F-009: dedupe na URL hash — stejný GitHub repo zmíněný na HN + Reddit = 1 entry.
F-013: per-source health.json status — skill pozná ghost failures.
F-019: parse Anthropic API HTML notes (2. ghost source eliminated).

Usage: python3 parse_feeds.py <run_id>
Output:
  - <run_id>-combined.json   (merged + deduped)
  - <run_id>-health.json     (per-source status report)
"""
import sys
import json
import re
import hashlib
import datetime
from html.parser import HTMLParser
from pathlib import Path
from xml.etree import ElementTree as ET

CACHE = Path.home() / ".claude/ai-radar/cache"


# ── parsers ──────────────────────────────────────────────────────────────

def parse_rss_xml(path: Path, source: str) -> list:
    """RSS 2.0 + Atom feed → list of item dicts."""
    if not path.exists() or path.stat().st_size == 0:
        return []
    items = []
    try:
        tree = ET.parse(str(path))
        root = tree.getroot()
        for node in root.iter():
            tag = node.tag.split('}')[-1]  # strip XML namespace
            if tag not in ('item', 'entry'):
                continue
            title, link, date = '', '', ''
            for child in node:
                ctag = child.tag.split('}')[-1]
                if ctag == 'title':
                    title = (child.text or '').strip()
                elif ctag == 'link':
                    link = (child.get('href') or child.text or '').strip()
                elif ctag in ('pubDate', 'published', 'updated'):
                    date = (child.text or '').strip()
            if title and link:
                items.append({
                    'title': title[:200],
                    'url': link,
                    'date': date,
                    'source': source,
                })
    except ET.ParseError as e:
        print(f"{source} XML parse error: {e}", file=sys.stderr)
    except Exception as e:
        print(f"{source} unexpected error: {e}", file=sys.stderr)
    return items


def parse_changelog_md(path: Path, source: str, max_sections: int = 15, max_bullets: int = 5) -> list:
    """Markdown CHANGELOG (## header + bullets) → list of items, newest first."""
    if not path.exists() or path.stat().st_size == 0:
        return []
    items = []
    try:
        content = path.read_text(errors='ignore')
        sections = re.split(r'^## ', content, flags=re.M)[1:]  # skip preamble
        base_url = 'https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md'
        for sec in sections[:max_sections]:
            lines = sec.strip().split('\n')
            if not lines:
                continue
            header = lines[0].strip()
            bullets = [ln.lstrip('- ').strip() for ln in lines if ln.startswith('-')]
            for bullet in bullets[:max_bullets]:
                if len(bullet) < 10:
                    continue
                items.append({
                    'title': f"Claude Code {header}: {bullet[:140]}",
                    'url': f"{base_url}#{header.lower().replace('.', '').replace(' ', '-')}",
                    'date': header if re.match(r'^\d{4}-\d{2}-\d{2}', header) else '',
                    'source': source,
                })
    except Exception as e:
        print(f"{source} MD parse error: {e}", file=sys.stderr)
    return items


class _AnthropicHTMLExtractor(HTMLParser):
    """F-019: extractor pro Anthropic API release-notes HTML.

    Strategy: headings (h2/h3) + bezprostředně následující paragraph/list = jeden release entry.
    Vystačí si s stdlib (žádný beautifulsoup requirement — kompliance cost-zero-tolerance).
    """
    def __init__(self):
        super().__init__()
        self.items = []
        self._depth = 0
        self._capturing_heading = False
        self._current_heading = []
        self._current_body = []
        self._body_capture_budget = 0

    def handle_starttag(self, tag, attrs):
        if tag in ('h1', 'h2', 'h3'):
            # flush previous entry
            self._flush_entry()
            self._capturing_heading = True
            self._current_heading = []
        elif tag in ('p', 'li'):
            self._body_capture_budget = 1  # capture next chunk of text

    def handle_endtag(self, tag):
        if tag in ('h1', 'h2', 'h3'):
            self._capturing_heading = False

    def handle_data(self, data):
        text = (data or '').strip()
        if not text:
            return
        if self._capturing_heading:
            self._current_heading.append(text)
        elif self._body_capture_budget > 0 and len(self._current_body) < 3:
            self._current_body.append(text[:200])
            self._body_capture_budget = 0

    def _flush_entry(self):
        heading = ' '.join(self._current_heading).strip()
        body = ' — '.join(self._current_body).strip()
        if heading and len(heading) > 4:
            self.items.append({
                'title': f"Anthropic API: {heading[:140]}{(' — ' + body[:100]) if body else ''}",
                'url': 'https://docs.anthropic.com/en/release-notes/api',
                'date': heading if re.match(r'^\d{4}-\d{2}-\d{2}', heading) else '',
                'source': 'anthropic-api-notes',
            })
        self._current_body = []


def parse_anthropic_api_html(path: Path, max_items: int = 30) -> list:
    """F-019: Anthropic API HTML release-notes (`docs.anthropic.com/en/release-notes/api`)."""
    if not path.exists() or path.stat().st_size == 0:
        return []
    try:
        content = path.read_text(errors='ignore')
        extractor = _AnthropicHTMLExtractor()
        extractor.feed(content)
        extractor._flush_entry()  # final entry
        return extractor.items[:max_items]
    except Exception as e:
        print(f"anthropic-api-notes HTML parse error: {e}", file=sys.stderr)
        return []


# ── dedupe ───────────────────────────────────────────────────────────────

def dedupe_by_url(items: list) -> tuple[list, int]:
    """Dedupe by URL hash. First occurrence wins. Returns (deduped, removed_count)."""
    seen = set()
    out = []
    for item in items:
        url = (item.get('url') or '').strip()
        if not url:
            continue
        key = hashlib.md5(url.encode('utf-8', errors='ignore')).hexdigest()
        if key in seen:
            continue
        seen.add(key)
        out.append(item)
    return out, len(items) - len(out)


# ── health.json ──────────────────────────────────────────────────────────

def build_health(run_id: str, existing_count: int, parsed_sources: dict, deduped: int, removed: int) -> dict:
    """F-013: per-source status report. Skill přečte a report [YOUR_NAME] ghost failures."""
    sources = {}
    # jq-combined sources (inferred z combined items)
    jq_sources = ['claude-code-releases', 'github-trending-llm', 'github-trending-agents',
                  'hn', 'reddit', 'mcp-new']
    for src in jq_sources:
        # check if source files exist + non-empty
        # (heuristic: existing_count > 0 means at least some jq worked;
        # per-source nelze bez re-count, nechme status "unknown" pokud chybí evidence)
        sources[src] = {'status': 'unknown', 'items': 0, 'via': 'jq-combine'}

    # parsed sources (explicit per-file)
    for src, meta in parsed_sources.items():
        sources[src] = meta

    return {
        'run_id': run_id,
        'timestamp': datetime.datetime.now().isoformat(timespec='seconds'),
        'total_items_pre_dedupe': existing_count + sum(s.get('items', 0) for s in parsed_sources.values()),
        'total_items_post_dedupe': deduped,
        'duplicates_removed': removed,
        'sources': sources,
        'jq_combined_count': existing_count,
        'parsed_count': sum(s.get('items', 0) for s in parsed_sources.values()),
    }


# ── main ─────────────────────────────────────────────────────────────────

def main():
    if len(sys.argv) < 2:
        print("usage: parse_feeds.py <run_id>", file=sys.stderr)
        sys.exit(1)

    run_id = sys.argv[1]
    combined_path = CACHE / f"{run_id}-combined.json"
    health_path = CACHE / f"{run_id}-health.json"

    if not combined_path.exists():
        print(f"combined.json missing: {combined_path}", file=sys.stderr)
        sys.exit(1)

    try:
        existing = json.loads(combined_path.read_text() or '[]')
    except json.JSONDecodeError:
        existing = []

    # F-008 + F-019: parse 4 zdrojů které jq -s 'add' ignoruje
    parsed_sources = {}

    cc = parse_changelog_md(CACHE / f"{run_id}-01-cc-changelog.md", 'anthropic-cc-changelog')
    parsed_sources['anthropic-cc-changelog'] = {
        'status': 'ok' if cc else 'empty',
        'items': len(cc),
        'via': 'parse_changelog_md',
    }

    api = parse_anthropic_api_html(CACHE / f"{run_id}-01-api-notes.html")
    parsed_sources['anthropic-api-notes'] = {
        'status': 'ok' if api else 'empty',
        'items': len(api),
        'via': 'parse_anthropic_api_html',
    }

    oai = parse_rss_xml(CACHE / f"{run_id}-03-openai.xml", 'openai-blog')
    parsed_sources['openai-blog'] = {
        'status': 'ok' if oai else 'empty',
        'items': len(oai),
        'via': 'parse_rss_xml',
    }

    goog = parse_rss_xml(CACHE / f"{run_id}-04-google-ai.xml", 'google-ai-blog')
    parsed_sources['google-ai-blog'] = {
        'status': 'ok' if goog else 'empty',
        'items': len(goog),
        'via': 'parse_rss_xml',
    }

    parsed = cc + api + oai + goog

    # F-009: dedupe merged set
    merged = existing + parsed
    deduped, removed = dedupe_by_url(merged)

    combined_path.write_text(json.dumps(deduped, indent=2, ensure_ascii=False))

    # F-013: emit health.json
    health = build_health(run_id, len(existing), parsed_sources, len(deduped), removed)
    health_path.write_text(json.dumps(health, indent=2, ensure_ascii=False))

    # F-023: single-prefix output (no double [parse_feeds][parse_feeds])
    print(
        f"+{len(parsed)} items (cc:{len(cc)} api:{len(api)} oai:{len(oai)} goog:{len(goog)}) | "
        f"dedupe: {len(merged)}→{len(deduped)} (-{removed}) | "
        f"health: {health_path.name}",
        file=sys.stderr
    )


if __name__ == '__main__':
    main()
