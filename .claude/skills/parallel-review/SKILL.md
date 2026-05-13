---
name: parallel-review
description: >
  Launch two independent review agents in parallel to review branch or PR
  changes for correctness, consistency, and production readiness.
argument-hint: "[PR-number]"
arguments: [target]
disable-model-invocation: true
allowed-tools:
  - "Bash(git diff *)"
  - "Bash(git log *)"
  - "Bash(git rev-parse *)"
  - "Bash(gh pr diff *)"
  - "Bash(gh pr view *)"
  - Read
  - Agent
effort: xhigh
---

## Git context

Default branch: !`git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/origin/||' || echo master`
Current branch: !`git rev-parse --abbrev-ref HEAD`

Branch diff stat:
```!
BASE=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/origin/||' || echo master)
git diff "$BASE"...HEAD --stat 2>/dev/null
```

## Identify what changed

If `$target` is provided, it is a PR number — use `gh pr diff $target`.
Otherwise, use the branch diff above and `git diff <default-branch>...HEAD`.

Read each changed file in full to understand context.

## Spawn exactly two review agents

Launch exactly **2** agents in parallel using the Agent tool with `subagent_type: "general-purpose"`. Do NOT use codebase-analyzer, Explore, or any other agent type.

Both agents MUST receive the **exact same prompt**. Do NOT split the review into specialized topics (e.g., "correctness agent" and "testing agent"). The point is two independent, identical passes over the same changes to catch what one reviewer might miss.

Fill in the bracketed sections of the template below, then send the resulting prompt — verbatim and identically — to both agents:

````
You are reviewing code changes for correctness, consistency, and production
readiness. Read every changed file listed below in full, then report your
findings.

## Changed files

[list every changed file path, one per line]

## What changed

[1-3 sentence summary of what this change does and why]

## Project guidelines

[paste any project-specific guidelines, or "None"]

## Review checklist

Evaluate each file against these criteria:

**Correctness**
- Does the code do what it claims?
- Off-by-one errors, nil/null risks, race conditions?
- Error paths handled correctly?
- Edge cases covered?

**Consistency**
- Follows the project's existing patterns (naming, error handling, structure)?
- No unnecessary style changes mixed with functional changes?

**Testing**
- Tests cover behavior, not implementation details?
- Edge cases tested?
- Assertions specific enough? Could tests pass for wrong reasons?
- Run the existing test suite for affected packages. Report what passed and
  what failed. If tests fail, include the failure output.

**Production readiness**
- Hardcoded values that should be configurable?
- Timeouts, retries, limits reasonable?
- Observability (logging, metrics) for new behavior?
- Backwards compatibility concerns?

## What to skip

- Formatting nitpicks (that's for formatters).
- Refactors beyond the scope of this change.
- Personal style preferences.

## Evidence standard

Every finding MUST include hard proof. No vague claims.

- **Quote the code.** Include the exact file path, line number, and the
  relevant code snippet.
- **Run tests when possible.** A claim like "this could break X" is weak —
  a test command showing a failure is strong.
- **Show, don't speculate.** "This nil check is missing" must point to the
  exact line. "This race condition exists" must show both access points.
- **No findings without evidence.**

## Output

Group findings by severity:
- **Critical** — blocks shipping: logic errors, data loss risks, security issues.
- **Medium** — should fix: inconsistencies, missing edge cases, unclear code.
- **Low** — nice to have: minor improvements, suggestions.

For each finding: file path + line number, code snippet, what the issue is, test output if applicable.

If you find no issues, say so explicitly.
````

## Synthesize and act

After both agents return:
- Merge findings from both agents. Deduplicate.
- Group by severity:
  - **Critical**: Should be fixed immediately. These block shipping.
  - **Medium**: Should be fixed unless explicitly deferred.
  - **Low**: Note for the user, let them decide.
