## Critical guidelines
- Don't guess, provide answers based on facts: research the code, or whatever you need to do.
- If you can't find facts but have a hypothesis, make it crystal clear that it's just a hypothesis. Think and suggest ways to prove it. If possible do it yourself.
- Before generating code or researching something, query the AI library first: `~/ai/library/query.py "search terms"`. See [AI Library](#ai-library) below.
- Review vs fix: When the user asks for a review (e.g. "review this", "review changes"), only review and report findings. Do not change code, apply fixes, or implement suggestions unless the user explicitly asks you to fix, implement, or apply changes.
- When reviewing commits/PRs, be thorough, direct, pragmatic, diligent. Ignore the relationship between the PR author and the user (don't try to be nice because the user created the PR). Act as a colleague who cares about correctness and best practices and is a bit picky, grouping the review conclusions in groups of importance.
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
- **PRs**: Full GitHub PR URLs (e.g. `https://github.com/owner/repo/pull/123`). **Always** add PR URLs here when creating or discovering PRs related to the work. This is critical — the AI PR Manager uses these URLs to monitor PRs.
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
- **Always** record PR URLs in the corresponding `~/ai/current-work/<topic>.md` file under the `## PRs` section when creating a PR or discovering an existing one related to the work.


When a pre-commit hook (e.g. linter) blocks a commit, first check whether the
failure was caused by our changes:

- Compare the failing lines against `git diff master HEAD` — if the issue
  exists in the base branch and is not in lines we touched, it is pre-existing.
- Pre-existing issues: do **not** fix them. Commit with `--no-verify` instead.
- Issues introduced by our changes: fix them before committing.

When writing scripts:
- Check first whether other scripts that achieve the same/similar goal exist
- See [AI Library](#ai-library) below

Follow these steps (never skip unless unfeasible, let user know):

### 1. Understand before acting

Read the code you are about to change and its tests. Trace the call chain far enough to know what breaks if you get it wrong. Do not start implementation until you can explain the current behavior.

### 2. Implement incrementally

Make one logical change at a time. After each change, run the relevant unit tests before moving on. If a test fails, fix it before adding more changes. Do the same with E2E tests (see "Test against a real deployment"). Do not batch multiple unrelated changes into one step.

### 3. Test against a real deployment

Unit tests are necessary but not sufficient. Test the changes thoroughly by deploying the modified product to a cluster. If you can't access a cluster, request a kubeconfig reference from the user. Inform the user that you will replace the images running in the cluster.

- Build the product:
	- Use `make image` if possible
	- Otherwise build with `GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build`, and use `crane mutate --append` to mutate an existing image (from the running cluster)
- Push to quay.io or ttl.sh (this is open source software).
- Deploy by patching the deployment image and waiting for rollout.
- Exercise the changed code path through the API or UI and confirm the output is correct. Run any relevant E2E tests if applicable.
- If the change affects migrator or DB schema, build and deploy migrator from the same source.

### 4. Review with parallel agents

After implementation and testing, review the changes using independent agents before shipping. This step also applies after receiving any review feedback (from bots, humans, or other tools) — re-run the review to verify fixes and catch anything new. You should have a skill/command for this.

After the review finishes, back to step 1 to iterate on the fixes.

### 5. Produce proof

Before declaring a change complete, generate concrete evidence that it works. Proof must be attachable to a PR description — not committed to the repo.

Examples of good proof:
- Screenshot or rendered image of output (e.g., CSV rendered as a table image, UI screenshot).
- Curl output showing the new API behavior.
- Test run output showing pass/fail results.
- Diff of before/after output.

Use whatever tools are available (matplotlib, imagemagick, browser screenshots) to transform raw output into a visual that a reviewer can verify at a glance.


### 6. Ship

- Commit with a clear message explaining *why*, not *what*.
- Rebase on latest main before pushing.
- Create or update the PR description following the repo's PR template.
- Attach proof to the PR description.
- Do not force-push without confirming first.

### 7. Address external review feedback

After pushing, watch the PR for automated checks and review comments from bots/humans:
- Read every comment.
- Fix legitimate issues in code (back to step 1).
- Reply to each comment on GitHub explaining what was changed or why you disagree.
- Do not silently ignore comments.


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
- Do not hard-wrap lines at a fixed column width in PR descriptions — write each paragraph as a single line and let GitHub handle text wrapping in the rendered view
- When editing PR descriptions, use `gh api repos/{owner}/{repo}/pulls/{number} -X PATCH -f body='...'` instead of `gh pr edit --body` to avoid the GraphQL "Projects (classic) is being deprecated" error


## Documentation instructions

When documenting progress/results:
- Check first what files may have been used previously and prefer reusing those where possible, refactoring as needed.
- Be concise and stick to facts, cite sources, data, code etc to back your claims.
- Use consistent file names: check what's there first, and if you really need to create a new file follow the existing conventions regarding placement and naming.

