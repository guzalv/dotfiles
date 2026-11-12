#!/usr/bin/env -S uv run --quiet --script
# /// script
# requires-python = ">=3.10"
# dependencies = ["rapidfuzz"]
# ///
"""
Fuzzy search across AI library (helpers and docs).

Usage:
    query.py "search terms"
    query.py --helpers-only "search terms"
    query.py --docs-only "search terms"

Output: JSON with ranked results.
"""

import argparse
import json
import sys
from pathlib import Path

from rapidfuzz import fuzz

LIBRARY_DIR = Path(__file__).parent
HELPERS_INDEX = LIBRARY_DIR / "helpers-index.json"
DOCS_INDEX = LIBRARY_DIR / "docs-index.json"
SYNONYMS_FILE = LIBRARY_DIR / "synonyms.json"
# The indexes and synonyms hold personal content and are not tracked in version
# control. Generic templates ship alongside them; copy a template to its real
# name (drop ".example") and populate it. See ~/.agents/ai-library.md.
EXAMPLE_SUFFIX = ".example.json"


def load_json(path: Path) -> dict:
    """Load JSON file, return empty dict if not found."""
    if not path.exists():
        return {}
    with open(path) as f:
        return json.load(f)


def load_synonyms() -> dict[str, set[str]]:
    """Load synonyms and build bidirectional mapping."""
    raw = load_json(SYNONYMS_FILE)
    synonyms = {}

    for key, values in raw.items():
        # Add key -> values
        all_terms = {key.lower()} | {v.lower() for v in values}
        for term in all_terms:
            if term not in synonyms:
                synonyms[term] = set()
            synonyms[term].update(all_terms)

    return synonyms


def expand_query(query: str, synonyms: dict[str, set[str]]) -> set[str]:
    """Expand query terms using synonyms."""
    terms = set(query.lower().split())
    expanded = set(terms)

    for term in terms:
        if term in synonyms:
            expanded.update(synonyms[term])

    return expanded


def score_entry(entry: dict, query_terms: set[str]) -> float:
    """Score an entry against query terms using fuzzy matching."""
    summary = entry.get("summary", "").lower()
    tags = " ".join(entry.get("tags", [])).lower()
    searchable = f"{summary} {tags}"

    max_score = 0.0

    for term in query_terms:
        # Partial ratio handles substring matching well
        score = fuzz.partial_ratio(term, searchable) / 100.0
        max_score = max(max_score, score)

        # Bonus for exact tag match
        if term in entry.get("tags", []):
            max_score = max(max_score, 1.0)

    # Also score full query against summary
    full_query = " ".join(query_terms)
    full_score = fuzz.token_set_ratio(full_query, searchable) / 100.0

    return max(max_score, full_score)


def resolve_path(entry_id: str, source: str) -> str:
    """Resolve full path from entry id, finding the actual extension."""
    if source == "helpers":
        base_dir = LIBRARY_DIR / "helpers"
    else:
        base_dir = LIBRARY_DIR / "docs"

    base_path = base_dir / entry_id

    # Try common extensions
    for ext in [".sh", ".py", ".go", ".md", ".txt", ""]:
        candidate = base_path.parent / f"{base_path.name}{ext}"
        if candidate.exists():
            return str(candidate)

    # Return expected path even if file doesn't exist yet
    return str(base_path) + ".*"


def search(query: str, include_helpers: bool = True, include_docs: bool = True) -> list[dict]:
    """Search indexes and return ranked results."""
    synonyms = load_synonyms()
    query_terms = expand_query(query, synonyms)

    results = []

    if include_helpers:
        helpers_data = load_json(HELPERS_INDEX)
        for entry in helpers_data.get("helpers", []):
            score = score_entry(entry, query_terms)
            if score > 0.6:
                results.append({
                    "source": "helpers",
                    "id": entry["id"],
                    "summary": entry.get("summary", ""),
                    "tags": entry.get("tags", []),
                    "score": round(score, 3),
                    "path": resolve_path(entry["id"], "helpers")
                })

    if include_docs:
        docs_data = load_json(DOCS_INDEX)
        for entry in docs_data.get("docs", []):
            score = score_entry(entry, query_terms)
            if score > 0.6:
                results.append({
                    "source": "docs",
                    "id": entry["id"],
                    "summary": entry.get("summary", ""),
                    "tags": entry.get("tags", []),
                    "score": round(score, 3),
                    "path": resolve_path(entry["id"], "docs")
                })

    # Sort by score descending, return top 7
    results.sort(key=lambda x: x["score"], reverse=True)

    return results[:7]


def main():
    parser = argparse.ArgumentParser(description="Search AI library")
    parser.add_argument("query", help="Search terms")
    parser.add_argument("--helpers-only", action="store_true", help="Search only helpers")
    parser.add_argument("--docs-only", action="store_true", help="Search only docs")

    args = parser.parse_args()

    if not HELPERS_INDEX.exists() and not DOCS_INDEX.exists():
        print(
            f"note: no library indexes found in {LIBRARY_DIR}. Copy "
            f"helpers-index{EXAMPLE_SUFFIX} / docs-index{EXAMPLE_SUFFIX} to "
            "helpers-index.json / docs-index.json and populate them. "
            "See ~/.agents/ai-library.md.",
            file=sys.stderr,
        )

    include_helpers = not args.docs_only
    include_docs = not args.helpers_only

    results = search(args.query, include_helpers, include_docs)

    output = {"results": results}
    print(json.dumps(output, indent=2))


if __name__ == "__main__":
    main()
