## Tracking progress

Track ongoing work in `~/ai/current-work/<topic>.md` files to enable seamless session resumption.

Do this only when it makes sense. If the prompt is a question that you know the answer to, skip this.

### On startup
1. Check `~/ai/current-work/` for existing topic files
2. If multiple topics exist, list them and ask the user what they want to work on
3. If a single topic exists, confirm with the user before resuming

### Topic file format
Each `~/ai/current-work/<topic>.md` should contain:
- **Summary**: Brief description of the work (1-2 sentences)
- **Code locations**: Primary repos/directories where code changes happen
- **PRs**: Full GitHub PR URLs (e.g. `https://github.com/owner/repo/pull/123`). **Always** add PR URLs here when creating or discovering PRs related to the work. This is critical — external tooling parses these URLs.
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

Each `~/ai/future-work/<topic>.md` should contain:
- **Summary**: What needs to be done and why (1-3 sentences)
- **Origin**: How this was identified — link to the current-work topic, PR, or conversation where it came up
- **Context**: Relevant code locations, files, or references needed to pick this up later
- **Priority**: `low` / `medium` / `high` — rough sense of urgency
- **Created**: Date the item was recorded

-------------- Example future-work file starts --------------
```markdown
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
