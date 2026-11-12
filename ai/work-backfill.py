#!/usr/bin/env -S uv run --quiet --script
# /// script
# requires-python = ">=3.10"
# dependencies = ["pyyaml"]
# ///
"""
One-time (and repeatable) backfill of frontmatter into work-topic files.

Frontmatter is intentionally minimal: only the non-derivable curation fields
`status` and `tags`. Title, summary, tickets, PRs and dates stay derived from
the body by work.py, so there is nothing to keep in sync.

Subcommands:
    extract            Print JSON {id, path, dir, title, summary} for every
                       top-level topic .md that still lacks frontmatter.
                       Feed this to a tagging pass.
    apply TAGS.json    Prepend frontmatter to each file. TAGS.json maps
                       id -> {"tags": [...], "status": "active|blocked|done"}.
                       status is optional (defaults by dir). Files that already
                       have frontmatter are skipped. The body is never changed.

Safe by design: apply only prepends a frontmatter block; remove the block to
revert.
"""

import json
import re
import sys
from datetime import date
from pathlib import Path

import yaml

AI_DIR = Path(__file__).parent
DIRS = {
    "current": AI_DIR / "current-work",
    "future": AI_DIR / "future-work",
    "previous": AI_DIR / "previous-work",
}
DEFAULT_STATUS = {"current": "active", "future": "future", "previous": "done"}


def iter_topic_files():
    for dirkey, base in DIRS.items():
        if not base.exists():
            continue
        for path in sorted(base.glob("*.md")):
            if path.name.startswith("."):
                continue
            yield dirkey, path


def has_frontmatter(text: str) -> bool:
    return text.startswith("---")


def derive_title(body: str, fallback: str) -> str:
    for line in body.splitlines():
        if line.startswith("# "):
            return line[2:].strip()
    return fallback


def derive_summary(body: str) -> str:
    lines = body.splitlines()
    out, capturing = [], False
    for line in lines:
        if line.strip().lower() == "## summary":
            capturing = True
            continue
        if capturing:
            if line.startswith("## "):
                break
            out.append(line)
    text = " ".join(w for w in " ".join(out).split())
    return text[:400]


def cmd_extract(_args):
    items = []
    for dirkey, path in iter_topic_files():
        text = path.read_text(encoding="utf-8", errors="replace")
        if has_frontmatter(text):
            continue
        items.append(
            {
                "id": path.stem,
                "path": str(path),
                "dir": dirkey,
                "title": derive_title(text, path.stem),
                "summary": derive_summary(text),
            }
        )
    print(json.dumps(items, indent=2))
    print(f"\n{len(items)} file(s) without frontmatter.", file=sys.stderr)


def cmd_apply(args):
    tags_map = json.loads(Path(args.tags_file).read_text())
    by_id = {dirkey_path.stem: dirkey_path for _, dirkey_path in iter_topic_files()}

    applied, skipped, missing = 0, 0, []
    for entry_id, meta in tags_map.items():
        path = by_id.get(entry_id)
        if not path:
            missing.append(entry_id)
            continue
        text = path.read_text(encoding="utf-8", errors="replace")
        if has_frontmatter(text):
            skipped += 1
            continue
        dirkey = next(k for k, b in DIRS.items() if b == path.parent)
        fm = {
            "status": meta.get("status") or DEFAULT_STATUS[dirkey],
            "tags": meta.get("tags") or [],
        }
        block = "---\n" + yaml.safe_dump(fm, sort_keys=False, allow_unicode=True) + "---\n\n"
        path.write_text(block + text, encoding="utf-8")
        applied += 1

    print(f"applied={applied} skipped(existing)={skipped}")
    if missing:
        print(f"WARNING: {len(missing)} id(s) not found: {', '.join(missing)}")


def main():
    import argparse

    parser = argparse.ArgumentParser(description="Backfill work-topic frontmatter")
    sub = parser.add_subparsers(dest="command", required=True)
    sub.add_parser("extract").set_defaults(func=cmd_extract)
    ap = sub.add_parser("apply")
    ap.add_argument("tags_file", help="JSON map: id -> {tags, status?}")
    ap.set_defaults(func=cmd_apply)
    args = parser.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
