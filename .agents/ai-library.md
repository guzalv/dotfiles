## AI Library

Location: `~/ai/library/`

Prevents re-inventing code and re-discovering knowledge across sessions.

Do this only when it makes sense. If the prompt is a question that you know the answer to, skip this.

### Structure

```
~/ai/library/
├── helpers/           # Executable code (scripts)
├── docs/              # Knowledge documentation
├── helpers-index.json
├── docs-index.json
├── query.py           # Fuzzy search tool
└── synonyms.json      # Search synonyms
```

### Querying the library

**Before generating code or researching something:**

```bash
~/ai/library/query.py "search terms"
```

Options:
- `--helpers-only` - search only executable code
- `--docs-only` - search only documentation

Output is JSON with ranked results:
```json
{
  "results": [
    {"source": "helpers", "id": "git/parse-jira", "summary": "...", "tags": [...], "score": 0.92, "path": "..."},
    {"source": "docs", "id": "stackrox/sensor-comm", "summary": "...", "tags": [...], "score": 0.85, "path": "..."}
  ]
}
```

- If a result matches: read the file at `path`, use it
- If no match: proceed, then document your work (see below)

### When to add to the library

**Add a helper** when you write reusable code (not project-specific business logic).

**Add a doc** when you:
- Research architecture or component relationships
- Figure out non-obvious workflows or config locations
- Discover integration patterns between systems
- Discover a non-obvious operational procedure incidentally during a task (e.g. how to connect to a service, where credentials live, what a resource is actually named vs. what you'd expect) — save it as soon as it's confirmed working, don't wait to be asked

**Heuristic**: if you had to try more than one thing to get something working, it's worth documenting.

**Don't add**: current work progress (use `~/ai/current-work/`), tiny/obvious details, transient info.

### Creating a helper

1. Write file in `~/ai/library/helpers/<category>/<name>.<ext>`
2. Add to `helpers-index.json`:
   ```json
   {"id": "category/name", "summary": "One sentence: what + when.", "tags": ["keywords"]}
   ```

**Helper format:**
```bash
#!/usr/bin/env bash
# @language: bash
# @created: YYYY-MM-DD
#
# Short description.
#
# USAGE: script-name.sh <required> [optional]
# OUTPUT: What it prints/returns
#
# EXAMPLES:
#   $ script-name.sh foo
#   output

set -euo pipefail
# implementation
```

### Creating a doc

1. Write file in `~/ai/library/docs/<category>/<name>.md`
2. Add to `docs-index.json`:
   ```json
   {"id": "category/name", "summary": "One sentence: what this explains.", "tags": ["keywords"]}
   ```

**Doc format:**
```markdown
---
created: YYYY-MM-DD
sources:
  - path/to/code
  - or URLs
---
# Title

## Overview
Brief explanation.

## Details
...
```

### Categories

Use existing or create new: `git/`, `k8s/`, `auth/`, `stackrox/`, `general/`, etc.

### Maintenance

- Update files directly; indexes only have id/summary/tags
- Remove obsolete entries from both index and filesystem
- Add new synonyms to `synonyms.json` when you notice missing mappings
- When user types "bye" indicating they'll close the session, check if any content needs updating and do it
