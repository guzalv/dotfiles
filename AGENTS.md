## Critical guidelines
- Don't guess, provide answers based on facts: research the code, or whatever you need to do.
- If you can't find facts but have a hypothesis, make it crystal clear that it's just a hypothesis. Think and suggest ways to prove it. If possible do it yourself.
- Don't generate code if a suitable program exists already, see [helpers](#reusable-helpers-system) below.
- When you have to figure out something complex-ish, like what's the API path to get some data from some service, check first if there's a helper that explains it. See [helpers](#reusable-helpers-system) below.
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
- See "Reusable Helpers System" below


## Reusable Helpers System

Location: `~/ai/helpers/`

Prevents re-inventing code and re-discovering procedures across sessions.

### Finding helpers

**Before generating code or figuring something out, check for existing helpers:**

```bash
cat ~/ai/helpers/index.json
```

The index is lean - only contains what you need for decision-making:
```json
{"id": "git/parse-jira-from-branch", "summary": "Extracts JIRA issue ID from git branch name.", "tags": ["git", "jira"]}
```

- `id` doubles as the path (without extension)
- Read each `summary` and `tags`, and think if any of those matches or could be adapted to match your needs.
- If a helper matches: read the file at `~/ai/helpers/<id>.*`, use it
- If no match: proceed, then document your work (see below)

### When to create a helper

Create a helper when you:
- Write reusable code (not project-specific business logic)
- Figure out a cumbersome multi-step process
- Spend significant effort discovering how something works

**Script vs procedure:**
- **Script**: Automatable, deterministic steps
- **Procedure** (`.md`): Requires judgment, GUI, or not worth automating

### Creating a helper

1. **Write the file** in `~/ai/helpers/<category>/<name>.<ext>`
   - Use existing categories (`git/`, `k8s/`, `auth/`, `text/`, `misc/`) or create new ones
   - Include metadata and usage in the file itself (see formats below)

2. **Add to index.json** (only decision-relevant fields):
   ```json
   {"id": "category/name", "summary": "One sentence: what + when.", "tags": ["keywords"]}
   ```

### Script format

```bash
#!/usr/bin/env bash
# @type: script
# @language: bash
# @created: YYYY-MM-DD
#
# Short description of what this does.
#
# USAGE: script-name.sh <required> [optional]
# OUTPUT: What it prints/returns
#
# EXAMPLES:
#   $ script-name.sh foo
#   expected output

set -euo pipefail
# implementation
```

### Procedure format

```markdown
---
type: procedure
created: YYYY-MM-DD
---
# Title

## When to use
Context for when this applies.

## Steps
1. First step
2. Second step

## Automation potential
Could this become a script? What's blocking it?
```

### Maintenance

- Update files directly; the index only has id/summary/tags
- Remove obsolete helpers from both index and filesystem


## Pull Request Guidelines

- Always create PRs as drafts first using the `--draft` flag with `gh pr create`
- Mark as ready for review only when explicitly requested by the user


## Documentation instructions

When documenting progress/results:
- Check first what files may have been used previously and prefer reusing those where possible, refactoring as needed.
- Be concise and stick to facts, cite sources, data, code etc to back your claims.
- Use consistent file names: check what's there first, and if you really need to create a new file follow the existing conventions regarding placement and naming.

