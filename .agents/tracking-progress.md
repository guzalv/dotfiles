## Tracking progress

Track ongoing work in `~/ai/current-work/<topic>.md` files to enable seamless session resumption. Archived work moves to `~/ai/previous-work/`, deferred follow-ups live in `~/ai/future-work/`.

Do this only when it makes sense. If the prompt is a question that you know the answer to, skip this.

### The registry and query tool

The three work dirs form a registry queried with `~/ai/work.py` (modeled on `~/ai/library/query.py`, and reusing its `synonyms.json`). Do not read every topic file — query the registry.

Each topic file starts with YAML frontmatter holding only the non-derivable fields:
```yaml
---
status: active        # active | blocked | done  (future-work: future; previous-work: done)
tags:                 # lowercase search keywords; include concepts NOT in the title
  - compliance-operator
  - stale-data
  - sweeper
---
```
Everything else (title, summary, tickets, PR URLs, last-updated date) is derived from the body at query time, so there is nothing to keep in sync. `tags` drive search recall — add terms a future search would use that the title does not already contain.

Commands:
- `~/ai/work.py query "<terms>"` — distill the prompt into a few keywords plus any ticket IDs, then query. Output is ranked JSON (`id, title, summary, status, tickets, dir, updated, path, score`). A ticket ID (e.g. `ROX-1234`) is an exact match forced to the top. Scope defaults to current-work; add `--all` or `--include current,future,previous`. Status filter defaults to `active`; use `--status all` to include done/blocked.
- `~/ai/work.py list` — overview of active current-work (title, status, tickets, date). Add `--all` for every dir, `--json` for machine output.

Scoring is IDF-weighted term overlap (rare terms matter more), with title/tags weighted above the summary. The default score threshold is 0.5 (`SCORE_THRESHOLD` in `work.py`).

### Matching a prompt to existing work
1. Distill the prompt into keywords (+ ticket IDs) and run `~/ai/work.py query "<terms>"`.
2. If a result clears the threshold, read its `path` and resume from there.
3. For a fuzzy-only match (no exact ticket hit), confirm with the user before resuming.
4. If nothing clears the threshold, treat it as new work.

### On startup
1. Run `~/ai/work.py list` for the active current-work overview.
2. If multiple topics exist, list them and ask the user what they want to work on.
3. If a single topic exists, confirm with the user before resuming.
4. Mention outstanding future-work items (`~/ai/work.py list --include future`) so nothing is forgotten.

### Topic file format
Each `~/ai/current-work/<topic>.md` must start with the frontmatter block shown above (`status` + `tags`), then contain:
- **Summary**: Brief description of the work (1-2 sentences)
- **Code locations**: Primary repos/directories where code changes happen
- **PRs**: Full GitHub PR URLs (e.g. `https://github.com/owner/repo/pull/123`). **Always** add PR URLs here when creating or discovering PRs related to the work. This is critical — external tooling parses these URLs.
- **Supporting docs**: Directory for design docs, notes, related files (if any)
- **Status**: Current state, next steps, blockers
- **Last updated**: Date of last activity

-------------- Example topic file starts --------------
```markdown
---
status: active
tags:
  - tailored-profiles
  - compliance
  - custom-rules
---
# Tailored Profiles (ROX-23456)

## Summary
Adding support for tailored compliance profiles in StackRox, allowing users to customize rules.

## Code locations
- Main: ~/go/src/github.com/stackrox/stackrox
- Related: ~/sw/compliance-operator

## PRs
- https://github.com/stackrox/stackrox/pull/12345

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
- Completing/cancelling work:
  - If archiving, move the work item doc(s) to `~/ai/previous-work/` (do not keep archived items in `~/ai/current-work/`)
  - Use a clear archived filename that includes topic and date (for example: `archived-<topic>-YYYY-MM-DD.md`)
  - If not archiving, delete the file(s)
- When user types "bye" indicating they will close the session

### Future work

Track ideas, follow-ups, and deferred tasks in `~/ai/future-work/<topic>.md`. These are things identified as worth doing but not actively being worked on right now.

#### When to create a future-work item
- The user explicitly asks to note something for later (e.g. "we should do X at some point", "remind me to look into Y", "add this as a follow-up")
- While working on a feature, you or the user identify something that is out of scope but should be done later (e.g. a related refactor, a missing test, a tech debt item, an edge case to handle)
- A review surfaces a suggestion that won't be addressed in the current PR

When identifying follow-ups during active work, **proactively suggest** creating a future-work item — don't silently let it slip.

#### Future-work file format

Each `~/ai/future-work/<topic>.md` must start with the frontmatter block (`status: future` + `tags`), then contain:
- **Summary**: What needs to be done and why (1-3 sentences)
- **Origin**: How this was identified — link to the current-work topic, PR, or conversation where it came up
- **Context**: Relevant code locations, files, or references needed to pick this up later
- **Priority**: `low` / `medium` / `high` — rough sense of urgency
- **Created**: Date the item was recorded

-------------- Example future-work file starts --------------
```markdown
---
status: future
tags:
  - compliance
  - csv-export
  - streaming
  - memory
---
# Refactor compliance CSV export to streaming

## Summary
The current CSV export loads all results into memory before writing. For large clusters this could OOM. Should switch to a streaming writer.

## Origin
Identified while working on compliance-csv-control-ref-fix (ROX-29876). Not in scope for that PR.

## Context
- Code: ~/go/src/github.com/stackrox/stackrox/central/compliance/export/csv.go
- Related PR: https://github.com/stackrox/stackrox/pull/12345

## Priority
medium

## Created
2026-05-29
```
-------------- Example future-work file ends --------------

#### Lifecycle
- When picking up a future-work item for active development, move it to `~/ai/current-work/` and expand it with the full current-work format (status, PRs, etc.)
- Periodically (e.g. on startup when listing current work, or when the user asks), mention outstanding future-work items so nothing is forgotten
- Delete items that are no longer relevant or have been completed as part of other work

#### On startup
After checking `~/ai/current-work/`, also check `~/ai/future-work/`. If items exist, briefly list them after the current-work summary so the user has visibility.
