#!/usr/bin/env python3
"""
T+1 Postcard Queue Automation — Notion + ntfy integration.

Trigger flow:
  emise back-office signature event
    -> POST webhook -> notion_insert_postcard_row()
    -> daily 18:00 cron -> ntfy_daily_queue_summary()
    -> Filip writes -> manual status update v Notion
    -> T+3 cron check delivery -> ntfy_delivery_confirmation()

Setup:
  1. Notion API key v ~/.credentials/master.env (NOTION_API_KEY=secret_...)
  2. Database ID v env (NOTION_T1_POSTCARD_DB_ID=...)
  3. ntfy topic: https://ntfy.oneflow.cz/Filip
  4. Cron via launchd: ~/.claude/skills/unreasonable-hospitality/recipes/t1-postcard-launchd.plist

Notion DB schema (manual one-time setup):
  - Investor name (title)
  - Investor address (text — GDPR consented)
  - Emise amount (number, Kč)
  - Variant (select: A=Standard, B=Exit-bg, C=Repeat, D=Referral)
  - Personal note input (text — Filip's 1-factoid hook)
  - Status (select: Todo, Writing, Sent, Delivered, OptOut)
  - Sent date (date)
  - Tracking ID (text)
  - Delivered date (date)
  - GDPR consent (checkbox)
  - Opt-out (checkbox)

Cost: 0 Kč ongoing (Notion free tier + ntfy self-hosted).

Usage:
  # Insert a row from emise signature event
  python t1-postcard-automation.py insert --name "Jan Novák" --amount 250000 --address "..." --variant A

  # Send daily 18:00 queue summary
  python t1-postcard-automation.py daily-summary

  # Check T+3 delivery for sent postcards
  python t1-postcard-automation.py check-delivery
"""
from __future__ import annotations

import argparse
import json
import os
import sys
from datetime import datetime, timedelta
from pathlib import Path
from typing import Any
import urllib.request
import urllib.parse


CREDS_PATH = Path.home() / ".credentials" / "master.env"
NTFY_TOPIC = "https://ntfy.oneflow.cz/Filip"
NOTION_API = "https://api.notion.com/v1"
NOTION_VERSION = "2022-06-28"


def load_creds() -> dict[str, str]:
    """Read NOTION_API_KEY + NOTION_T1_POSTCARD_DB_ID from master.env."""
    creds = {}
    if not CREDS_PATH.exists():
        return creds
    for line in CREDS_PATH.read_text().splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        k, _, v = line.partition("=")
        creds[k.strip()] = v.strip().strip("'\"")
    return creds


def notion_request(path: str, method: str = "GET", body: dict | None = None) -> dict:
    creds = load_creds()
    key = creds.get("NOTION_API_KEY") or os.environ.get("NOTION_API_KEY")
    if not key:
        raise RuntimeError("NOTION_API_KEY missing — add to ~/.credentials/master.env")
    url = f"{NOTION_API}{path}"
    data = json.dumps(body).encode() if body else None
    req = urllib.request.Request(
        url,
        data=data,
        method=method,
        headers={
            "Authorization": f"Bearer {key}",
            "Notion-Version": NOTION_VERSION,
            "Content-Type": "application/json",
        },
    )
    with urllib.request.urlopen(req, timeout=15) as r:
        return json.loads(r.read().decode())


def notion_insert_postcard_row(
    investor_name: str,
    investor_address: str,
    emise_amount: int,
    variant: str,
    personal_note: str = "",
) -> str:
    """Insert new row do T+1 Postcard Queue. Returns Notion page ID."""
    creds = load_creds()
    db_id = creds.get("NOTION_T1_POSTCARD_DB_ID") or os.environ.get("NOTION_T1_POSTCARD_DB_ID")
    if not db_id:
        raise RuntimeError("NOTION_T1_POSTCARD_DB_ID missing")
    body = {
        "parent": {"database_id": db_id},
        "properties": {
            "Investor name": {"title": [{"text": {"content": investor_name}}]},
            "Investor address": {"rich_text": [{"text": {"content": investor_address}}]},
            "Emise amount": {"number": emise_amount},
            "Variant": {"select": {"name": variant}},
            "Personal note input": {"rich_text": [{"text": {"content": personal_note}}]},
            "Status": {"select": {"name": "Todo"}},
            "GDPR consent": {"checkbox": True},
        },
    }
    res = notion_request("/pages", method="POST", body=body)
    return res.get("id", "")


def notion_query_status(status: str) -> list[dict]:
    """Query rows by Status."""
    creds = load_creds()
    db_id = creds.get("NOTION_T1_POSTCARD_DB_ID") or os.environ.get("NOTION_T1_POSTCARD_DB_ID")
    if not db_id:
        return []
    body = {
        "filter": {"property": "Status", "select": {"equals": status}},
        "page_size": 100,
    }
    res = notion_request(f"/databases/{db_id}/query", method="POST", body=body)
    return res.get("results", [])


def ntfy_push(message: str, title: str = "T+1 Postcard", priority: int = 3, tags: str = "envelope_with_arrow") -> None:
    """Push notification via ntfy.oneflow.cz."""
    req = urllib.request.Request(
        NTFY_TOPIC,
        data=message.encode(),
        method="POST",
        headers={
            "Title": title,
            "Priority": str(priority),
            "Tags": tags,
        },
    )
    try:
        urllib.request.urlopen(req, timeout=10)
    except Exception as exc:
        print(f"ntfy fail: {exc}", file=sys.stderr)


def daily_summary() -> None:
    """18:00 daily — count Todo rows + 3 oldest investor names."""
    todo_rows = notion_query_status("Todo")
    n = len(todo_rows)
    if n == 0:
        ntfy_push(
            "T+1 fronta: 0 postcards waiting. Žádný emise event v posledních 24h.",
            title="T+1 Daily 0",
            priority=2,
            tags="white_check_mark",
        )
        return
    names = []
    for row in todo_rows[:5]:
        title = row.get("properties", {}).get("Investor name", {}).get("title", [])
        if title:
            names.append(title[0].get("text", {}).get("content", "?"))
    msg_lines = [
        f"{n} postcards čeká k napsání.",
        "",
        "Top 5 oldest:",
        *[f"- {name}" for name in names],
        "",
        "Píšeš 30/45 min batch session. Cap 30/batch.",
        f"Notion: {os.environ.get('NOTION_T1_POSTCARD_DB_ID', '<db-id>')}",
    ]
    ntfy_push(
        "\n".join(msg_lines),
        title=f"T+1 Daily {n}",
        priority=4,
        tags="envelope,clock",
    )


def check_delivery() -> None:
    """Check rows Status=Sent older than 3 days, ping reminder for tracking."""
    sent_rows = notion_query_status("Sent")
    cutoff = datetime.utcnow() - timedelta(days=3)
    overdue = []
    for row in sent_rows:
        sent_date_prop = row.get("properties", {}).get("Sent date", {}).get("date") or {}
        sent_date_str = sent_date_prop.get("start", "")
        if not sent_date_str:
            continue
        try:
            sent_dt = datetime.fromisoformat(sent_date_str.replace("Z", "+00:00")).replace(tzinfo=None)
        except ValueError:
            continue
        if sent_dt < cutoff:
            title = row.get("properties", {}).get("Investor name", {}).get("title", [])
            name = title[0].get("text", {}).get("content", "?") if title else "?"
            overdue.append(name)
    if overdue:
        ntfy_push(
            f"{len(overdue)} postcards Sent T+3 ago, manually verify delivery: " + ", ".join(overdue[:5]),
            title="T+1 Delivery check",
            priority=3,
            tags="package,question",
        )


def main() -> int:
    p = argparse.ArgumentParser(description="T+1 Postcard Queue automation")
    sub = p.add_subparsers(dest="cmd", required=True)

    ins = sub.add_parser("insert", help="Insert new investor row from signature event")
    ins.add_argument("--name", required=True)
    ins.add_argument("--address", required=True)
    ins.add_argument("--amount", type=int, required=True)
    ins.add_argument("--variant", choices=["A", "B", "C", "D"], default="A")
    ins.add_argument("--note", default="")

    sub.add_parser("daily-summary", help="18:00 daily ntfy summary")
    sub.add_parser("check-delivery", help="T+3 delivery check")

    args = p.parse_args()
    if args.cmd == "insert":
        page_id = notion_insert_postcard_row(
            args.name,
            args.address,
            args.amount,
            args.variant,
            args.note,
        )
        print(f"Inserted Notion page: {page_id}")
        ntfy_push(
            f"Nový investor v T+1 fronta: {args.name} ({args.amount:,} Kč, variant {args.variant})",
            title="T+1 New",
            priority=3,
            tags="bell",
        )
    elif args.cmd == "daily-summary":
        daily_summary()
    elif args.cmd == "check-delivery":
        check_delivery()
    return 0


if __name__ == "__main__":
    sys.exit(main())
