#!/usr/bin/env python3
# === Adapted from TheAlgorithms/Python (MIT License) ===
# Building blocks: Python/graphs/{breadth_first_search, depth_first_search, check_cycle, connected_components}.py
# Use case: Link/network traversal pro scraping (competitor intel, lead-gen, content discovery).
#
# Usage:
#   python3 scraping-graph.py --bfs --start "https://example.com" --max-depth 3
#   python3 scraping-graph.py --dfs --start "https://example.com" --max-depth 5
#   python3 scraping-graph.py --components --edges-file links.json
#   python3 scraping-graph.py --cycle-detect --edges-file links.json
#
# IMPORTANT: This is a graph algorithm demo. For real scraping use playwright/requests
#            and respect robots.txt. Network IO here is OPTIONAL (--fetch flag).

import argparse
import json
import re
import sys
import urllib.request
import urllib.parse
from collections import defaultdict, deque


# === Graph algorithms (TheAlgorithms-derived) ===

def bfs(graph: dict[str, list[str]], start: str, max_depth: int = 10) -> dict:
    """BFS traversal — discover layers (great for 'find all pages within N hops')."""
    visited = {start}
    queue = deque([(start, 0)])
    layers = defaultdict(list)
    layers[0].append(start)
    order = [start]

    while queue:
        node, depth = queue.popleft()
        if depth >= max_depth:
            continue
        for neighbor in graph.get(node, []):
            if neighbor not in visited:
                visited.add(neighbor)
                queue.append((neighbor, depth + 1))
                layers[depth + 1].append(neighbor)
                order.append(neighbor)

    return {
        "algorithm": "bfs",
        "start": start,
        "max_depth": max_depth,
        "nodes_discovered": len(visited),
        "layers": dict(layers),
        "order": order,
    }


def dfs(graph: dict[str, list[str]], start: str, max_depth: int = 10) -> dict:
    """DFS traversal — go deep (great for 'crawl this branch fully before next')."""
    visited = set()
    order = []

    def _dfs(node, depth):
        if node in visited or depth > max_depth:
            return
        visited.add(node)
        order.append((node, depth))
        for neighbor in graph.get(node, []):
            _dfs(neighbor, depth + 1)

    _dfs(start, 0)
    return {
        "algorithm": "dfs",
        "start": start,
        "max_depth": max_depth,
        "nodes_discovered": len(visited),
        "order": order,
    }


def detect_cycles(graph: dict[str, list[str]]) -> dict:
    """Find cycles in directed graph (useful for: avoid infinite scraping loops)."""
    WHITE, GRAY, BLACK = 0, 1, 2
    color = defaultdict(int)
    cycles = []
    parent = {}

    def _dfs_cycle(node, path):
        color[node] = GRAY
        path.append(node)
        for neighbor in graph.get(node, []):
            if color[neighbor] == GRAY:
                cycle_start = path.index(neighbor)
                cycles.append(path[cycle_start:] + [neighbor])
            elif color[neighbor] == WHITE:
                parent[neighbor] = node
                _dfs_cycle(neighbor, path[:])
        color[node] = BLACK

    for node in list(graph.keys()):
        if color[node] == WHITE:
            _dfs_cycle(node, [])

    return {
        "has_cycles": len(cycles) > 0,
        "cycle_count": len(cycles),
        "cycles": cycles[:10] + (["..."] if len(cycles) > 10 else []),
    }


def connected_components(graph: dict[str, list[str]]) -> dict:
    """Find disconnected clusters (useful for: discover separate networks of related sites)."""
    # Treat as undirected for components
    undirected = defaultdict(set)
    for node, neighbors in graph.items():
        for n in neighbors:
            undirected[node].add(n)
            undirected[n].add(node)

    visited = set()
    components = []

    for start in list(undirected.keys()):
        if start in visited:
            continue
        # BFS this component
        comp = set()
        queue = deque([start])
        while queue:
            node = queue.popleft()
            if node in visited:
                continue
            visited.add(node)
            comp.add(node)
            for n in undirected[node]:
                if n not in visited:
                    queue.append(n)
        components.append(sorted(comp))

    return {
        "component_count": len(components),
        "largest_size": max((len(c) for c in components), default=0),
        "components": [{"size": len(c), "members": c[:20] + (["..."] if len(c) > 20 else [])}
                       for c in sorted(components, key=len, reverse=True)[:10]],
    }


# === Optional: live link extraction (for actual scraping) ===
LINK_RE = re.compile(r'href=["\']([^"\']+)["\']', re.IGNORECASE)


def fetch_links(url: str, timeout: int = 10, max_links: int = 200) -> list[str]:
    """Fetch URL, extract <a href> links. Same-host only by default.
    For real scraping: use requests/playwright with proper headers."""
    try:
        req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0 OneFlow-AlgoRecall/1.0"})
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            html = resp.read(2_000_000).decode("utf-8", errors="ignore")  # 2MB cap
    except Exception as e:
        print(f"WARN: fetch {url} failed: {e}", file=sys.stderr)
        return []

    base = urllib.parse.urlparse(url)
    base_host = base.netloc

    links = []
    for match in LINK_RE.finditer(html):
        href = match.group(1).strip()
        if not href or href.startswith(("#", "javascript:", "mailto:", "tel:")):
            continue
        absolute = urllib.parse.urljoin(url, href)
        parsed = urllib.parse.urlparse(absolute)
        if parsed.netloc == base_host:  # same-host only
            clean = parsed._replace(fragment="").geturl()
            if clean not in links:
                links.append(clean)
        if len(links) >= max_links:
            break
    return links


def crawl(start: str, max_depth: int, max_pages: int = 100, polite_delay: float = 0.5) -> dict:
    """Polite crawler — discovers graph by fetching pages.
    Built on BFS. respects max_depth + max_pages."""
    import time
    graph = defaultdict(list)
    visited = {start}
    queue = deque([(start, 0)])
    pages = 0

    while queue and pages < max_pages:
        url, depth = queue.popleft()
        if depth >= max_depth:
            continue
        links = fetch_links(url)
        graph[url] = links
        pages += 1
        for link in links:
            if link not in visited:
                visited.add(link)
                queue.append((link, depth + 1))
        time.sleep(polite_delay)  # don't hammer the server

    return dict(graph)


def main():
    p = argparse.ArgumentParser(description="Scraping graph algorithms — BFS/DFS/cycles/components")
    p.add_argument("--bfs", action="store_true")
    p.add_argument("--dfs", action="store_true")
    p.add_argument("--cycle-detect", action="store_true")
    p.add_argument("--components", action="store_true")
    p.add_argument("--crawl", action="store_true", help="Live crawl + analyze (uses --start)")

    p.add_argument("--start", help="Start node (URL or ID)")
    p.add_argument("--max-depth", type=int, default=3)
    p.add_argument("--max-pages", type=int, default=100, help="Max pages for live crawl")
    p.add_argument("--polite-delay", type=float, default=0.5)
    p.add_argument("--edges-file", help="JSON file: {node: [neighbors], ...}")
    p.add_argument("--out", help="Write graph JSON to this path")

    args = p.parse_args()

    # Load or build graph
    if args.edges_file:
        with open(args.edges_file) as f:
            graph = json.load(f)
    elif args.crawl:
        if not args.start:
            print("ERROR: --crawl requires --start", file=sys.stderr)
            return
        graph = crawl(args.start, args.max_depth, args.max_pages, args.polite_delay)
        if args.out:
            with open(args.out, "w") as f:
                json.dump(graph, f, indent=2)
            print(f"Wrote graph ({len(graph)} nodes) to {args.out}", file=sys.stderr)
    else:
        # demo graph
        graph = {
            "A": ["B", "C"],
            "B": ["D", "E"],
            "C": ["F"],
            "D": [],
            "E": ["F", "B"],  # cycle B → E → B
            "F": ["A"],        # cycle A → C → F → A
        }
        print("# Using demo graph. Use --edges-file or --crawl for real data.", file=sys.stderr)

    if args.bfs:
        result = bfs(graph, args.start or list(graph.keys())[0], args.max_depth)
    elif args.dfs:
        result = dfs(graph, args.start or list(graph.keys())[0], args.max_depth)
    elif args.cycle_detect:
        result = detect_cycles(graph)
    elif args.components:
        result = connected_components(graph)
    else:
        # all-in-one summary
        first = list(graph.keys())[0]
        result = {
            "graph_size": {"nodes": len(graph), "edges": sum(len(v) for v in graph.values())},
            "bfs_summary": {"start": first, "discovered": bfs(graph, first, args.max_depth)["nodes_discovered"]},
            "cycles": detect_cycles(graph),
            "components": connected_components(graph),
        }

    print(json.dumps(result, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()
