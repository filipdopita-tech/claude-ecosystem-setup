#!/usr/bin/env python3
"""
instagram-meta-api CLI wrapper — Meta Graph API v25.0 for OneFlow IG Business account.

Adapted from github.com/moboutrig/instagram-claude-skill (MIT).
Pattern from alex2learn.com/instagramguide (April 2026 first edition).

Usage:
    source ~/.credentials/instagram_meta.env
    python3 ig_api.py <command> [--args]

Commands:
    validate_token, get_profile, get_pages, publishing_limit
    create_container, check_status, publish_media
    publish_reel, publish_story, publish_carousel
    get_media, get_media_insights, get_account_insights
    get_conversations, get_messages, send_dm

Zero external dependencies (stdlib urllib + json only).
"""
import json
import os
import sys
import time
import urllib.parse
import urllib.request
import urllib.error
from typing import Any, Dict, Optional

API_VERSION = "v25.0"
# Page tokens (issued for FB Page that owns IG Business account) → Facebook Graph API.
# graph.instagram.com would be for IG Login direct tokens (different OAuth flow).
# OneFlow Publisher app issues PAGE tokens, so default GRAPH_BASE = graph.facebook.com.
GRAPH_BASE = f"https://graph.facebook.com/{API_VERSION}"
GRAPH_FB_BASE = f"https://graph.facebook.com/{API_VERSION}"
GRAPH_IG_BASE = f"https://graph.instagram.com/{API_VERSION}"  # for IG Login flow only


def env(name: str, required: bool = True) -> Optional[str]:
    val = os.environ.get(name)
    if required and not val:
        die(f"Missing env var {name}. Source ~/.credentials/instagram_meta.env first.")
    return val


def die(msg: str, code: int = 1) -> None:
    print(f"ERROR: {msg}", file=sys.stderr)
    sys.exit(code)


def http(
    method: str,
    url: str,
    params: Optional[Dict[str, Any]] = None,
    data: Optional[Dict[str, Any]] = None,
    timeout: int = 30,
) -> Dict[str, Any]:
    """Single HTTP call returning parsed JSON. Raises on non-2xx."""
    if params:
        url = f"{url}?{urllib.parse.urlencode(params)}"
    body = urllib.parse.urlencode(data).encode() if data else None
    req = urllib.request.Request(url, data=body, method=method)
    req.add_header("Accept", "application/json")
    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            return json.loads(resp.read().decode())
    except urllib.error.HTTPError as e:
        raw = e.read().decode(errors="replace")
        try:
            err = json.loads(raw).get("error", {})
            die(
                f"HTTP {e.code}: {err.get('message', raw)} "
                f"(type={err.get('type')}, code={err.get('code')}, subcode={err.get('error_subcode')})"
            )
        except json.JSONDecodeError:
            die(f"HTTP {e.code}: {raw[:500]}")
    except urllib.error.URLError as e:
        die(f"Network: {e.reason}")


def parse_args(argv: list) -> Dict[str, str]:
    """Simple --flag value parser. No argparse to keep zero deps."""
    out = {}
    i = 0
    while i < len(argv):
        a = argv[i]
        if a.startswith("--"):
            key = a[2:].replace("-", "_")
            val = argv[i + 1] if i + 1 < len(argv) and not argv[i + 1].startswith("--") else "true"
            out[key] = val
            i += 2 if val != "true" else 1
        else:
            i += 1
    return out


# ============================================================
# Account / token
# ============================================================

def cmd_validate_token() -> None:
    """Verify token works + show what it can access. Works for user + page tokens."""
    token = env("INSTAGRAM_ACCESS_TOKEN")
    # /me works on both user and page tokens; account_type is user-only — drop it.
    me = http("GET", f"{GRAPH_BASE}/me", params={"fields": "id,name", "access_token": token})
    # debug_token shows token type + app_id + scopes + expiry
    dbg = http("GET", f"{GRAPH_BASE}/debug_token",
               params={"input_token": token, "access_token": token})
    print(json.dumps({"me": me, "debug": dbg.get("data", {})}, indent=2))


def cmd_get_profile() -> None:
    """Profile info for the connected IG Business account."""
    token = env("INSTAGRAM_ACCESS_TOKEN")
    bid = env("INSTAGRAM_BUSINESS_ACCOUNT_ID")
    fields = "id,username,name,biography,followers_count,follows_count,media_count,profile_picture_url,website"
    out = http("GET", f"{GRAPH_BASE}/{bid}", params={"fields": fields, "access_token": token})
    print(json.dumps(out, indent=2))


def cmd_get_pages() -> None:
    """List FB Pages and their connected IG Business accounts."""
    token = env("INSTAGRAM_ACCESS_TOKEN")
    out = http("GET", f"{GRAPH_BASE}/me/accounts", params={"fields": "id,name,instagram_business_account", "access_token": token})
    print(json.dumps(out, indent=2))


def cmd_publishing_limit() -> None:
    """Check rate limit (100 posts/24h)."""
    token = env("INSTAGRAM_ACCESS_TOKEN")
    bid = env("INSTAGRAM_BUSINESS_ACCOUNT_ID")
    out = http("GET", f"{GRAPH_BASE}/{bid}/content_publishing_limit", params={"access_token": token})
    print(json.dumps(out, indent=2))


# ============================================================
# Publishing
# ============================================================

def cmd_create_container(args: Dict[str, str]) -> None:
    """Create a media container (step 1 of 2 for image/video publish)."""
    token = env("INSTAGRAM_ACCESS_TOKEN")
    bid = env("INSTAGRAM_BUSINESS_ACCOUNT_ID")
    data = {"access_token": token}
    if "image_url" in args:
        data["image_url"] = args["image_url"]
    elif "video_url" in args:
        data["video_url"] = args["video_url"]
        data["media_type"] = "VIDEO"
    else:
        die("Need --image-url or --video-url")
    if "caption" in args:
        data["caption"] = args["caption"]
    if "alt_text" in args:
        data["alt_text"] = args["alt_text"]
    out = http("POST", f"{GRAPH_BASE}/{bid}/media", data=data)
    print(json.dumps(out, indent=2))


def cmd_check_status(args: Dict[str, str]) -> None:
    """Check container status before publishing (especially for video)."""
    token = env("INSTAGRAM_ACCESS_TOKEN")
    cid = args.get("container_id") or die("Need --container-id")
    out = http("GET", f"{GRAPH_BASE}/{cid}", params={"fields": "status_code,status", "access_token": token})
    print(json.dumps(out, indent=2))


def cmd_publish_media(args: Dict[str, str]) -> None:
    """Publish a prepared container (step 2 of 2)."""
    token = env("INSTAGRAM_ACCESS_TOKEN")
    bid = env("INSTAGRAM_BUSINESS_ACCOUNT_ID")
    cid = args.get("container_id") or die("Need --container-id")
    data = {"creation_id": cid, "access_token": token}
    out = http("POST", f"{GRAPH_BASE}/{bid}/media_publish", data=data)
    print(json.dumps(out, indent=2))


def cmd_publish_reel(args: Dict[str, str]) -> None:
    """One-shot reel publish: create container + wait + publish."""
    token = env("INSTAGRAM_ACCESS_TOKEN")
    bid = env("INSTAGRAM_BUSINESS_ACCOUNT_ID")
    if "video_url" not in args:
        die("Need --video-url")
    data = {
        "media_type": "REELS",
        "video_url": args["video_url"],
        "caption": args.get("caption", ""),
        "access_token": token,
    }
    if "thumb_offset" in args:
        data["thumb_offset"] = args["thumb_offset"]
    if args.get("no_feed") == "true":
        data["share_to_feed"] = "false"
    if "trial" in args:
        data["is_trial"] = "true"
    cont = http("POST", f"{GRAPH_BASE}/{bid}/media", data=data)
    cid = cont["id"]
    print(f"Container created: {cid}. Waiting for upload...")
    for attempt in range(30):
        time.sleep(5)
        st = http("GET", f"{GRAPH_BASE}/{cid}", params={"fields": "status_code", "access_token": token})
        code = st.get("status_code")
        print(f"  attempt {attempt+1}: status_code={code}")
        if code == "FINISHED":
            break
        if code == "ERROR":
            die(f"Upload failed: {st}")
    pub = http("POST", f"{GRAPH_BASE}/{bid}/media_publish", data={"creation_id": cid, "access_token": token})
    print(json.dumps(pub, indent=2))


def cmd_publish_story(args: Dict[str, str]) -> None:
    """Publish a story (image or video)."""
    token = env("INSTAGRAM_ACCESS_TOKEN")
    bid = env("INSTAGRAM_BUSINESS_ACCOUNT_ID")
    data = {"media_type": "STORIES", "access_token": token}
    if "image_url" in args:
        data["image_url"] = args["image_url"]
    elif "video_url" in args:
        data["video_url"] = args["video_url"]
    else:
        die("Need --image-url or --video-url")
    cont = http("POST", f"{GRAPH_BASE}/{bid}/media", data=data)
    cid = cont["id"]
    pub = http("POST", f"{GRAPH_BASE}/{bid}/media_publish", data={"creation_id": cid, "access_token": token})
    print(json.dumps(pub, indent=2))


def cmd_publish_carousel(args: Dict[str, str]) -> None:
    """Publish a carousel (2-10 items, mixed media via 'video:' prefix)."""
    token = env("INSTAGRAM_ACCESS_TOKEN")
    bid = env("INSTAGRAM_BUSINESS_ACCOUNT_ID")
    urls = args.get("media_urls") or die("Need --media-urls (comma-separated, prefix videos with 'video:')")
    items = [u.strip() for u in urls.split(",")]
    if not 2 <= len(items) <= 10:
        die(f"Carousel needs 2-10 items, got {len(items)}")
    children = []
    for u in items:
        if u.startswith("video:"):
            data = {"video_url": u[6:], "media_type": "VIDEO", "is_carousel_item": "true", "access_token": token}
        else:
            data = {"image_url": u, "is_carousel_item": "true", "access_token": token}
        c = http("POST", f"{GRAPH_BASE}/{bid}/media", data=data)
        children.append(c["id"])
    parent = http("POST", f"{GRAPH_BASE}/{bid}/media", data={
        "media_type": "CAROUSEL",
        "children": ",".join(children),
        "caption": args.get("caption", ""),
        "access_token": token,
    })
    pub = http("POST", f"{GRAPH_BASE}/{bid}/media_publish", data={"creation_id": parent["id"], "access_token": token})
    print(json.dumps(pub, indent=2))


# ============================================================
# Media list + insights
# ============================================================

def cmd_get_media(args: Dict[str, str]) -> None:
    """List recent media (default 10)."""
    token = env("INSTAGRAM_ACCESS_TOKEN")
    bid = env("INSTAGRAM_BUSINESS_ACCOUNT_ID")
    fields = "id,caption,media_type,media_url,permalink,thumbnail_url,timestamp,username"
    out = http("GET", f"{GRAPH_BASE}/{bid}/media", params={"fields": fields, "limit": args.get("limit", "10"), "access_token": token})
    print(json.dumps(out, indent=2))


def cmd_get_media_insights(args: Dict[str, str]) -> None:
    """Get insights for a single post/reel/story."""
    token = env("INSTAGRAM_ACCESS_TOKEN")
    mid = args.get("media_id") or die("Need --media-id")
    metrics = args.get("metrics", "views,reach,saved,shares,likes,comments,total_interactions")
    out = http("GET", f"{GRAPH_BASE}/{mid}/insights", params={"metric": metrics, "access_token": token})
    print(json.dumps(out, indent=2))


def cmd_get_account_insights(args: Dict[str, str]) -> None:
    """Get account-level insights.

    Meta API v22+ requires metric_type=total_value for views/profile_views/reach.
    """
    token = env("INSTAGRAM_ACCESS_TOKEN")
    bid = env("INSTAGRAM_BUSINESS_ACCOUNT_ID")
    metrics = args.get("metrics", "views,reach,profile_views")
    period = args.get("period", "day")
    params = {
        "metric": metrics,
        "period": period,
        "metric_type": args.get("metric_type", "total_value"),
        "access_token": token,
    }
    if "since" in args:
        params["since"] = args["since"]
    if "until" in args:
        params["until"] = args["until"]
    out = http("GET", f"{GRAPH_BASE}/{bid}/insights", params=params)
    print(json.dumps(out, indent=2))


# ============================================================
# DMs (require Advanced Access)
# ============================================================

def cmd_get_conversations(args: Dict[str, str]) -> None:
    """List DM conversations."""
    token = env("INSTAGRAM_ACCESS_TOKEN")
    bid = env("INSTAGRAM_BUSINESS_ACCOUNT_ID")
    out = http("GET", f"{GRAPH_BASE}/{bid}/conversations", params={"platform": "instagram", "limit": args.get("limit", "10"), "access_token": token})
    print(json.dumps(out, indent=2))


def cmd_get_messages(args: Dict[str, str]) -> None:
    """List messages in a conversation."""
    token = env("INSTAGRAM_ACCESS_TOKEN")
    cid = args.get("conversation_id") or die("Need --conversation-id")
    out = http("GET", f"{GRAPH_BASE}/{cid}", params={"fields": "messages{id,from,to,message,created_time}", "access_token": token})
    print(json.dumps(out, indent=2))


def cmd_send_dm(args: Dict[str, str]) -> None:
    """Send a DM (24h reply window, 1000 char max, requires Advanced Access)."""
    token = env("INSTAGRAM_ACCESS_TOKEN")
    bid = env("INSTAGRAM_BUSINESS_ACCOUNT_ID")
    rid = args.get("recipient_id") or die("Need --recipient-id")
    msg = args.get("message") or die("Need --message")
    if len(msg) > 1000:
        die(f"Message too long ({len(msg)}/1000 chars)")
    payload = {
        "recipient": json.dumps({"id": rid}),
        "message": json.dumps({"text": msg}),
        "access_token": token,
    }
    out = http("POST", f"{GRAPH_BASE}/{bid}/messages", data=payload)
    print(json.dumps(out, indent=2))


# ============================================================
# Dispatch
# ============================================================

COMMANDS = {
    "validate_token": cmd_validate_token,
    "get_profile": cmd_get_profile,
    "get_pages": cmd_get_pages,
    "publishing_limit": cmd_publishing_limit,
    "create_container": cmd_create_container,
    "check_status": cmd_check_status,
    "publish_media": cmd_publish_media,
    "publish_reel": cmd_publish_reel,
    "publish_story": cmd_publish_story,
    "publish_carousel": cmd_publish_carousel,
    "get_media": cmd_get_media,
    "get_media_insights": cmd_get_media_insights,
    "get_account_insights": cmd_get_account_insights,
    "get_conversations": cmd_get_conversations,
    "get_messages": cmd_get_messages,
    "send_dm": cmd_send_dm,
}


def main() -> None:
    if len(sys.argv) < 2 or sys.argv[1] in ("-h", "--help"):
        print(__doc__)
        print("\nAvailable commands:")
        for c in COMMANDS:
            print(f"  {c}")
        sys.exit(0)
    cmd = sys.argv[1]
    if cmd not in COMMANDS:
        die(f"Unknown command: {cmd}. Run with --help for list.")
    fn = COMMANDS[cmd]
    args = parse_args(sys.argv[2:])
    if fn.__code__.co_argcount == 0:
        fn()
    else:
        fn(args)


if __name__ == "__main__":
    main()
