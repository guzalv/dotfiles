#!/usr/bin/env -S uv run --quiet --script
# /// script
# requires-python = ">=3.10"
# dependencies = ["rapidfuzz", "pyyaml"]
# ///
"""
Query the work-topic registry (current / future / previous work).

Given a distilled prompt, find the matching topic file so a session can resume
from where it left off. Modeled on ~/ai/library/query.py.

Metadata source of truth: YAML frontmatter in each topic .md file. If a file has
no frontmatter yet, fields are derived from its heading + Summary section + mtime
so the tool still works during migration.

Usage:
    work.py query "search terms"            # search current-work (default)
    work.py query "ROX-35712"               # ticket id -> exact top hit
    work.py query "terms" --all             # search all three dirs
    work.py query "terms" --include current,future
    work.py query "terms" --status all      # include done/blocked too
    work.py list                            # overview of active current-work
    work.py list --all                      # overview across all dirs

Output: JSON (query) or a compact table (list). Use --json with list for JSON.
"""

import argparse
import json
import math
import re
import sys
from datetime import date, datetime
from pathlib import Path

import yaml
from rapidfuzz import fuzz

AI_DIR = Path(__file__).parent
# Optional synonym expansion. Reuses the AI library synonyms if present. The file
# is personal/work-specific, so it is NOT tracked in version control. A generic
# template ships alongside it (synonyms.example.json); copy it to enable this.
SYNONYMS_FILE = AI_DIR / "library" / "synonyms.json"
SYNONYMS_EXAMPLE = AI_DIR / "library" / "synonyms.example.json"

DIRS = {
    "current": AI_DIR / "current-work",
    "future": AI_DIR / "future-work",
    "previous": AI_DIR / "previous-work",
}

TICKET_RE = re.compile(r"\b([A-Z]{2,}-\d+)\b")
PR_URL_RE = re.compile(r"https://github\.com/[\w.-]+/[\w.-]+/pull/\d+")
SCORE_THRESHOLD = 0.5
MISS_PENALTY = 0.5  # how much an unmatched query term lowers the score (0..1)


STOPWORDS = {
    "the", "a", "an", "and", "or", "of", "for", "to", "in", "on", "with", "is",
    "are", "be", "this", "that", "it", "as", "by", "from", "about", "into",
}


def load_synonyms() -> dict[str, set[str]]:
    """Load the AI library synonyms and build a bidirectional mapping."""
    if not SYNONYMS_FILE.exists():
        return {}
    with open(SYNONYMS_FILE) as f:
        raw = json.load(f)
    synonyms: dict[str, set[str]] = {}
    for key, values in raw.items():
        all_terms = {key.lower()} | {v.lower() for v in values}
        for term in all_terms:
            synonyms.setdefault(term, set()).update(all_terms)
    return synonyms


WORD_RE = re.compile(r"[a-z0-9]+")

# Field weights: a hit in the title/tags/tickets matters far more than in the
# long free-text summary, which otherwise matches almost any common word.
FIELD_WEIGHTS = {"title": 3.0, "tags": 3.0, "summary": 1.0}
MAX_WEIGHT = max(FIELD_WEIGHTS.values())


def tokenize(text: str) -> set[str]:
    return set(WORD_RE.findall(text.lower()))


def query_term_groups(query: str, synonyms: dict[str, set[str]]) -> list[set[str]]:
    """Split the query into terms. Each term becomes a synonym group.

    A document matching any member of a group satisfies that term, so synonyms
    widen recall without letting one concept inflate the score of another.
    Tokenization matches document tokenization (split on non-alphanumerics),
    so "rox-35712" becomes the terms "rox" and "35712".
    """
    groups = []
    seen = []
    for term in WORD_RE.findall(query.lower()):
        if term in STOPWORDS:
            continue
        group = {term}
        for syn in synonyms.get(term, set()):
            group.update(WORD_RE.findall(syn))
        if group not in seen:  # drop duplicate terms
            seen.append(group)
            groups.append(group)
    return groups


def entry_fields(entry: dict) -> dict[str, set[str]]:
    """Tokenized field sets for an entry, cached on the entry."""
    if "_fields" not in entry:
        entry["_fields"] = {
            "title": tokenize(entry["title"]),
            "tags": tokenize(" ".join(entry["tags"])),
            "summary": tokenize(entry["summary"]),
        }
    return entry["_fields"]


def term_hits_field(group: set[str], field_tokens: set[str]) -> float:
    """Match strength of a synonym group against a field's token set, in [0, 1]."""
    for term in group:
        if term in field_tokens:
            return 1.0
    best = 0.0
    for term in group:
        if len(term) < 4:  # short tokens (e.g. "rox", ids) must match exactly
            continue
        for tok in field_tokens:
            if len(tok) < 4:
                continue
            if term in tok or tok in term:
                best = max(best, 0.9)
            elif fuzz.ratio(term, tok) >= 90:
                best = max(best, 0.85)
    return best


def _split_frontmatter(text: str) -> tuple[dict, str]:
    """Return (frontmatter_dict, body). Empty dict if no valid frontmatter."""
    if not text.startswith("---"):
        return {}, text
    parts = text.split("\n---", 1)
    if len(parts) < 2:
        return {}, text
    fm_block = parts[0][3:]  # drop leading ---
    body = parts[1].lstrip("\n")
    try:
        data = yaml.safe_load(fm_block) or {}
        if not isinstance(data, dict):
            return {}, text
        return data, body
    except yaml.YAMLError:
        return {}, text


def _derive_title(body: str, fallback: str) -> str:
    for line in body.splitlines():
        if line.startswith("# "):
            return line[2:].strip()
    return fallback


def _derive_summary(body: str) -> str:
    """Grab text under a '## Summary' heading until the next heading."""
    lines = body.splitlines()
    out: list[str] = []
    capturing = False
    for line in lines:
        if line.strip().lower() == "## summary":
            capturing = True
            continue
        if capturing:
            if line.startswith("## "):
                break
            out.append(line)
    return " ".join(w for w in " ".join(out).split())


def _derive_updated(body: str, path: Path, dirkey: str) -> str:
    """Date the topic was last touched.

    Order: explicit date under the '## Last updated' / '## Created' heading,
    then the latest date mentioned anywhere in the body (these notes keep dated
    log entries), then file mtime as a last resort.
    """
    heading = "## Created" if dirkey == "future" else "## Last updated"
    lines = body.splitlines()
    for i, line in enumerate(lines):
        if line.strip() == heading:
            for follow in lines[i + 1 :]:
                m = re.search(r"\d{4}-\d{2}-\d{2}", follow)
                if m:
                    return m.group(0)
    today = date.today().isoformat()
    body_dates = [d for d in re.findall(r"\d{4}-\d{2}-\d{2}", body) if d <= today]
    if body_dates:
        return max(body_dates)
    return date.fromtimestamp(path.stat().st_mtime).isoformat()


def _default_status(dirkey: str) -> str:
    return {"current": "active", "future": "future", "previous": "done"}[dirkey]


def _as_date(value: str) -> str:
    """Normalize a frontmatter date (may be a datetime.date) to ISO string."""
    if isinstance(value, (date, datetime)):
        return value.isoformat()[:10]
    return str(value)


def load_entry(path: Path, dirkey: str) -> dict:
    """Build a registry entry from a topic file, using frontmatter when present."""
    text = path.read_text(encoding="utf-8", errors="replace")
    fm, body = _split_frontmatter(text)

    entry_id = fm.get("id") or path.stem
    title = fm.get("title") or _derive_title(body, path.stem)
    summary = fm.get("summary") or _derive_summary(body)

    tickets = fm.get("tickets")
    if not tickets:
        # Derive from the title only (original case). Avoid the uppercased
        # filename, where date fragments like "09-26" become fake tickets.
        tickets = sorted(set(TICKET_RE.findall(title)))
    tickets = [str(t).upper() for t in tickets]

    tags = fm.get("tags") or []
    tags = [str(t) for t in tags]

    status = fm.get("status") or _default_status(dirkey)
    updated = _as_date(fm["updated"]) if fm.get("updated") else _derive_updated(body, path, dirkey)
    prs = fm.get("prs")
    if not prs:
        prs = sorted(set(PR_URL_RE.findall(body)))

    return {
        "id": entry_id,
        "title": title,
        "summary": summary,
        "tags": tags,
        "tickets": tickets,
        "status": str(status),
        "dir": dirkey,
        "updated": updated,
        "prs": [str(p) for p in prs],
        "path": str(path),
        "has_frontmatter": bool(fm),
    }


def load_entries(dirkeys: list[str]) -> list[dict]:
    """Load all top-level topic .md files from the given dirs."""
    entries = []
    for dirkey in dirkeys:
        base = DIRS[dirkey]
        if not base.exists():
            continue
        for path in sorted(base.glob("*.md")):
            if path.name.startswith("."):
                continue
            entries.append(load_entry(path, dirkey))
    return entries


def compute_idf(entries: list[dict], term_groups: list[set[str]]) -> list[float]:
    """IDF per query term over the candidate corpus. Rare terms weigh more."""
    n = len(entries)
    idf = []
    for group in term_groups:
        df = 0
        for entry in entries:
            fields = entry_fields(entry)
            all_tokens = fields["title"] | fields["tags"] | fields["summary"]
            if term_hits_field(group, all_tokens) > 0:
                df += 1
        idf.append(math.log((n + 1) / (df + 1)) + 1.0)
    return idf


def score_entry(entry: dict, term_groups: list[set[str]], idf: list[float], raw_query: str) -> float:
    """IDF-weighted, field-weighted term-overlap score in [0, 1].

    An exact ticket-id match forces the result to the top (1.0).
    """
    query_tickets = {t.upper() for t in TICKET_RE.findall(raw_query.upper())}
    if query_tickets & set(entry["tickets"]):
        return 1.0

    if not term_groups:
        return 0.0

    fields = entry_fields(entry)
    matched = 0.0  # IDF-weighted strength of terms this doc matches
    shortfall = 0.0  # IDF-weighted strength of terms it misses
    for group, term_idf in zip(term_groups, idf):
        best = 0.0
        for field, weight in FIELD_WEIGHTS.items():
            best = max(best, (weight / MAX_WEIGHT) * term_hits_field(group, fields[field]))
        matched += term_idf * best
        shortfall += term_idf * (1.0 - best)

    # Softened recall: a strong match on a rare, distinctive term survives extra
    # unmatched query words, instead of being averaged away. Matching only common
    # (low-IDF) terms still scores low.
    denom = matched + MISS_PENALTY * shortfall
    return matched / denom if denom else 0.0


def resolve_scope(args) -> list[str]:
    if getattr(args, "all", False):
        return ["current", "future", "previous"]
    if getattr(args, "include", None):
        keys = [k.strip() for k in args.include.split(",") if k.strip()]
        bad = [k for k in keys if k not in DIRS]
        if bad:
            sys.exit(f"Unknown scope(s): {', '.join(bad)}. Valid: {', '.join(DIRS)}")
        return keys
    return ["current"]


def cmd_query(args):
    if not SYNONYMS_FILE.exists():
        hint = f"note: no synonyms file at {SYNONYMS_FILE}; synonym expansion is off."
        if SYNONYMS_EXAMPLE.exists():
            hint += f" Copy {SYNONYMS_EXAMPLE.name} to {SYNONYMS_FILE.name} (same dir) to enable it."
        print(hint, file=sys.stderr)
    synonyms = load_synonyms()
    term_groups = query_term_groups(args.query, synonyms)
    entries = load_entries(resolve_scope(args))

    # Apply the status filter before scoring so IDF reflects the candidate set.
    status_filter = args.status
    candidates = [
        e
        for e in entries
        if status_filter == "all" or e["dir"] != "current" or e["status"] == status_filter
    ]

    idf = compute_idf(candidates, term_groups)
    results = []
    for entry in candidates:
        score = score_entry(entry, term_groups, idf, args.query)
        if score >= SCORE_THRESHOLD:
            out = {k: entry[k] for k in ("id", "title", "summary", "status", "tickets", "dir", "updated", "path")}
            out["score"] = round(score, 3)
            results.append(out)

    results.sort(key=lambda x: x["score"], reverse=True)
    print(json.dumps({"results": results[: args.limit]}, indent=2))


def cmd_list(args):
    entries = load_entries(resolve_scope(args))
    status_filter = args.status
    rows = []
    for entry in entries:
        if status_filter != "all" and entry["dir"] == "current" and entry["status"] != status_filter:
            continue
        rows.append(entry)
    rows.sort(key=lambda e: e["updated"], reverse=True)

    if args.json:
        slim = [{k: e[k] for k in ("id", "title", "status", "tickets", "dir", "updated", "path")} for e in rows]
        print(json.dumps({"topics": slim}, indent=2))
        return

    if not rows:
        print("(no matching topics)")
        return
    for e in rows:
        tickets = ",".join(e["tickets"]) if e["tickets"] else "-"
        print(f"{e['updated']}  [{e['dir']:<8}] {e['status']:<7} {tickets:<20} {e['title']}")


def main():
    parser = argparse.ArgumentParser(description="Query the work-topic registry")
    sub = parser.add_subparsers(dest="command", required=True)

    def add_scope(p):
        p.add_argument("--all", action="store_true", help="Search current, future and previous")
        p.add_argument("--include", help="Comma list of scopes: current,future,previous")
        p.add_argument(
            "--status",
            default="active",
            choices=["active", "blocked", "done", "all"],
            help="Status filter for current-work (default: active). 'all' disables it.",
        )

    q = sub.add_parser("query", help="Search for a matching topic")
    q.add_argument("query", help="Distilled search terms")
    q.add_argument("--limit", type=int, default=7, help="Max results (default 7)")
    add_scope(q)
    q.set_defaults(func=cmd_query)

    l = sub.add_parser("list", help="List topics (overview)")
    l.add_argument("--json", action="store_true", help="JSON output")
    add_scope(l)
    l.set_defaults(func=cmd_list)

    args = parser.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
