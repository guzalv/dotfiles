## Critical guidelines
- Don't guess, provide answers based on facts: research the code, or whatever you need to do.
- If you can't find facts but have a hypothesis, make it crystal clear that it's just a hypothesis. Think and suggest ways to prove it. If possible do it yourself.
- Inform the user that you have read and understood the guidelines in this file.

## Tracking progress

Track ongoing work in `~/.ai/current-work/<topic>.md` files to enable seamless session resumption.

### On startup
1. Check `~/.ai/current-work/` for existing topic files
2. If multiple topics exist, list them and ask the user what they want to work on
3. If a single topic exists, confirm with the user before resuming

### Topic file format
Each `~/.ai/current-work/<topic>.md` should contain:
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


## Pull Request Guidelines

- Always create PRs as drafts first using the `--draft` flag with `gh pr create`
- Mark as ready for review only when explicitly requested by the user


## Documentation instructions

When documenting progress/results:
- Check first what files may have been used previously and prefer reusing those where possible, refactoring as needed.
- Be concise and stick to facts, cite sources, data, code etc to back your claims.
- Use consistent file names: check what's there first, and if you really need to create a new file follow the existing conventions regarding placement and naming.

