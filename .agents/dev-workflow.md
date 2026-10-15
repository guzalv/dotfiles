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
- See `~/.agents/ai-library.md`

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
