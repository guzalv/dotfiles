## Critical guidelines
- Don't guess, provide answers based on facts: research the code, or whatever you need to do.
- If you can't find facts but have a hypothesis, make it crystal clear that it's just a hypothesis. Think and suggest ways to prove it. If possible do it yourself.
- Before generating code or researching something, query the AI library first: `~/ai/library/query.py "search terms"`. See [AI Library](#ai-library) below.
- **Review vs fix:** When the user asks for a **review** (e.g. "review this", "review changes"), only review and report findings. Do **not** change code, apply fixes, or implement suggestions unless the user explicitly asks you to fix, implement, or apply changes.
- Inform the user that you have read and understood the guidelines in this file.

## Tracking progress

Track ongoing work in `~/ai/current-work/<topic>.md` files to enable seamless session resumption.

### On startup
1. Check `~/ai/current-work/` for existing topic files
2. If multiple topics exist, list them and ask the user what they want to work on
3. If a single topic exists, confirm with the user before resuming

### Topic file format
Each `~/ai/current-work/<topic>.md` should contain:
- **Summary**: Brief description of the work (1-2 sentences)
- **Code locations**: Primary repos/directories where code changes happen
- **Supporting docs**: Directory for design docs, notes, related files (if any)
- **Status**: Current state, next steps, blockers
- **Last updated**: Date of last activity

-------------- Example topic file starts --------------
```markdown
# Tailored Profiles (ROX-23456)

## Summary
Adding support for tailored compliance profiles in StackRox, allowing users to customize rules.

## Code locations
- Main: ~/go/src/github.com/stackrox/stackrox
- Related: ~/sw/compliance-operator

## Supporting docs
~/work/ROX-23456-tailored-profiles/

## Status
- Completed: custom rules support in proto definitions
- Next: implement API endpoints for tailored profiles
- Blockers: none

## Last updated
2026-02-24
```
-------------- Example topic file ends --------------


### When to update
- Starting work on a new topic: create the file
- Significant progress: update status/next steps
- Stopping work: note where you left off
- Completing work: archive or delete the file
- When user types "bye" indicating they will close the session


## AI Assistant Guidelines

When providing assistance and feedback:

- Don't praise needlessly, be pragmatic, direct, critical.
- Ask clarifying questions and question assumptions.
- Follow best practices:
    - those used in the language overall
    - those used in the specific codebase

## Development Guidelines

When writing or modifying source code:
- Always test it, including integration tests in real systems when possible (e.g. use the current Kubernetes cluster). Ask user if unsure.
- Once successful, create a commit for each cohesive change. Add a concise and complete commit message.
- If the development is part of a PR, update it.


When writing scripts:
- Check first whether other scripts that achieve the same/similar goal exist
- See [AI Library](#ai-library) below


## AI Library

Location: `~/ai/library/`

Prevents re-inventing code and re-discovering knowledge across sessions.

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


## Pull Request Guidelines

- Always create PRs as drafts first using the `--draft` flag with `gh pr create`
- Mark as ready for review only when explicitly requested by the user


## Documentation instructions

When documenting progress/results:
- Check first what files may have been used previously and prefer reusing those where possible, refactoring as needed.
- Be concise and stick to facts, cite sources, data, code etc to back your claims.
- Use consistent file names: check what's there first, and if you really need to create a new file follow the existing conventions regarding placement and naming.

