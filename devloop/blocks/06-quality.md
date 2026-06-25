---
block: quality
order: 6
needs: [test]
mutates: source
gate-after: false
---

# QUALITY — Independent Quality Gates

**Goal**: Verify the output with checks the implementing agent cannot run on itself —
independent review, philosophy compliance, and breaking-change detection. Runs after
`test` so it sees the final code and the test outcome. May apply fixes, so it runs alone.

**Input**: Read `quality-depth` from `.devloop/config.md` (default `medium`). Read
`00-branch.md` and `05-test.md`. Run all checks for the configured depth even
if one finds issues.

## Q1 — Philosophy compliance (all depths)

Run `/philo fix` on the primary repo's uncommitted changes. Apply fixes as the skill
directs (it asks before each fix). Repeat for each cross-repo branch in `00-branch.md`
(`/philo fix <repo-path>`).

## Q2 — Breaking-change detection (all depths; only when a contract changed)

If the plan changed a wire/API contract (proto, OpenAPI, GraphQL schema), run the
appropriate breaking-change check against the base branch, e.g.:
```bash
cd <contract-repo-path>
buf breaking --against '.git#branch=<base-branch>'      # proto
# or an OpenAPI/GraphQL diff tool the project uses
```
On violations, present them and ask: `accept` (note in review), `fix` (loop back to
impl), or `stop`.

## Q3 — Security review (depth: high only)

Invoke `/security-review` on the branch. Append findings to `06-quality-review.md`. Any
security finding blocks proceeding until the user makes an explicit choice.

## Output — `.devloop/<slug>/06-quality.md`

```markdown
## Quality gate results
### Q1 — Philosophy: CLEAN | N violations fixed
### Q2 — Contract breaking: N/A | CLEAN | N violations (accepted/fixed)
### Q3 — Security: N/A | CLEAN | N findings

## Overall: PASS | PASS-WITH-NOTES | BLOCKED
```

If `BLOCKED` (unfixed CRITICAL): do not proceed to `review` until resolved.

Print: `[6/8] QUALITY done`

