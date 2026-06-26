---
block: review
order: 6
needs: [verify]
mutates: source
gate-after: false
---

# REVIEW — Final Diff Review

**Goal**: Run an independent quality pass, then self-review the fix diff and produce the
final verdict.

**Input**: Read `base-branch` from `00-branch.md`. The pipeline does not commit, so the
fix lives in the working tree — diff it against the base (two-dot), registering
intent-to-add first so any new file (e.g. the regression test) appears:
```bash
git add -N .              # make untracked new files visible in the diff
git diff <base-branch>    # working tree vs base (NOT ...HEAD — HEAD has no commits yet)
```
Read `02-investigate.md` (root cause) and `03-plan.md` (fix plan).

## Step 1 — Independent quality pass

Checks the implementing agent can't reliably run on its own. Bugfix has no separate
`quality` block, so the lightweight pass lives here.

- **Philosophy** — run `/philo fix` on the uncommitted changes. Apply fixes as the skill
  directs (it asks before each). This catches swallowed errors and complexity the fix may
  have introduced.
- **Security (only when the fix touches a sensitive surface)** — if the diff touches auth,
  input parsing, crypto, file/path handling, SQL/queries, or secrets, run
  `/security-review` on the branch. Any finding blocks proceeding until the user makes an
  explicit choice. Skip with `N/A` otherwise — don't run it for a one-line off-by-one fix.

Fold the outcomes into the `## Issues` list below (don't double-report ones already fixed).

## Step 2 — Self-review

**Check each changed file for:**

1. **Scope** — every change maps to a task in `03-plan.md`. No unrequested changes.
2. **Correctness** — the fix addresses the root cause from `02-investigate.md`, not just
   the symptom. A symptom fix that masks the root cause is a CRITICAL issue.
3. **Similar paths** — scan the codebase for the same pattern that caused the bug.
   Identical code in adjacent files or sibling functions is likely affected too. Flag each
   as LOW so the user can decide whether to fix now or open a follow-up.
4. **Philosophy** — CRITICAL: errors swallowed, logic inverted; HIGH: unnecessary
   complexity introduced, wrong layer of abstraction.
5. **Security** — injection, unvalidated input, exposed secrets, insecure defaults.

## Output — `.devloop/<slug>/06-review.md`

```markdown
## Independent pass
- Philosophy (`/philo fix`): CLEAN | N fixed
- Security (`/security-review`): N/A | CLEAN | N findings

## Changes summary
- `<file>` — <what changed and why it fixes the root cause>

## Issues
- [CRITICAL|HIGH|LOW] `<file>:<line>` — <description>

## Similar paths (potential same bug elsewhere)
- `<file>:<line>` — <same pattern — may need the same fix>
(Omit section if none found.)

## Verdict: CLEAN | ISSUES FOUND
```

If `ISSUES FOUND` (CRITICAL or HIGH):
```
Review found N issue(s). Options:
  "fix"   — apply fixes now
  "skip"  — accept as-is and finish
  "stop"  — abort
```
If "fix": apply fixes, re-check. Repeat until CLEAN or the user stops.

Print: `[7/7] REVIEW done`

Return to SKILL.md **Done** section to print the completion summary.
