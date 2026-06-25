---
block: verify
order: 5
needs: [fix]
mutates: none
gate-after: false
---

# VERIFY — Verify the Fix & Check Regressions

**Goal**: Confirm the bug is gone and nothing else broke.

**Input**: Read `01-repro.md` for the planned regression test / minimal reproduction.
Read `03-plan.md` for the affected files and packages.

**Do:**

1. **Primary check (green)** — run the regression test written in `fix`. It was red before
   the fix; it must be green now. If repro recorded no automated test, run the minimal
   reproduction instead. Either way, if it still fails this is a blocking failure —
   escalate to the scheduler.

2. **Regression check** — run tests scoped to affected packages:
   ```bash
   # Go:     go test ./affected/pkg/...
   # Node:   npm test -- --testPathPattern=<pattern>
   # Rust:   cargo test <filter>
   # Python: pytest <path>
   ```
   If the full suite is fast (< 60s), run it all.

3. **Type / lint check** — on changed files:
   ```bash
   # Go:     go vet ./...
   # Node:   tsc --noEmit
   # Python: ruff check <files>
   ```

4. For each failing regression test:
   - Determine if the failure is caused by the fix (blocking — loop back) or pre-existing
     and unrelated (note it, don't block).
   - Never mask a pre-existing failure silently — record it so the user is aware.

## Output — `.devloop/<slug>/05-verify.md`

```markdown
## Primary check (regression test green)
- `<test command>` → PASS | FAIL   (was red before fix)

## Regression tests
- `<command>` → PASS | FAIL | SKIP (pre-existing, unrelated)

## Type / lint
- `<command>` → PASS | FAIL

## Pre-existing failures (not caused by this fix)
- `<test name>` — <why it's pre-existing>

## Status: PASS | FAIL
```

On `FAIL` (primary check or fix-caused regression): the scheduler will offer:
- `fix` — loop back to `fix` with the failure appended to context
- `skip` — accept as-is
- `stop` — abort

Print: `[6/7] VERIFY done`
