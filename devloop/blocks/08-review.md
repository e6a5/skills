---
block: review
order: 8
needs: [cleanup]
mutates: source
gate-after: false
---

# REVIEW — Final Summary Review

**Goal**: Self-review all changes across all touched repos and produce the final verdict.

**Input**: Read `base-branch` from `00-branch.md`. The pipeline does not commit, so the
change lives in the working tree — diff it against the base (two-dot), registering
intent-to-add first so new untracked files appear:
```bash
git add -N .              # make untracked new files visible in the diff
git diff <base-branch>    # working tree vs base (NOT ...HEAD — HEAD has no commits yet)
```
Run this in the primary repo and in each dependency repo listed in `00-branch.md`. Read
`06-quality.md` and `07-cleanup.md` for already-surfaced findings and the docs written
(don't re-litigate).

**Check each changed file for:**
1. Every change maps to a planned task (no scope creep).
2. Philosophy violations — CRITICAL: single responsibility broken or errors swallowed;
   HIGH: misleading logic, unnecessary complexity, magic values.
3. Security issues — injection, unvalidated input, exposed secrets, insecure defaults.
4. Dead code or unnecessary abstraction.
5. Generated-file noise (codegen version bumps, unrelated regen) — flag as LOW.

## Output — `.devloop/<slug>/08-review.md` (present to the user)

```markdown
## Changes summary
### [primary] <repo-name>
- <file> — <what changed and why>
### [<alias>] <repo-name>
- <file> — <what changed and why>

## Issues
- [CRITICAL|HIGH|LOW] [<repo>] <file>:<line> — <description>

## Verdict: CLEAN | ISSUES FOUND
```

If `ISSUES FOUND` (CRITICAL or HIGH):
```
Review found N issue(s). Options:
  "fix"   — apply fixes now
  "skip"  — accept as-is and finish
  "stop"  — abort
```
If "fix": apply fixes, re-run diffs, re-check. Repeat until CLEAN or the user stops.

Print: `[9/9] REVIEW done`

When CLEAN (or accepted), return to the master file's **Done** section to print the
completion summary.