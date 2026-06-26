---
block: fix
order: 4
needs: [plan]
mutates: source
gate-after: false
---

# FIX — Apply the Fix

**Goal**: Execute every task in the fix plan. Touch only what the plan lists.

**Input**: Read `03-plan.md`. Apply each task in order.

**Do:**

1. Mark each task `[→]` before starting, `[x]` when done.

2. **Regression test first (red).** If the plan has a regression-test task, do it first:
   write the test, run it, and confirm it FAILS for the right reason (the bug's symptom,
   not a setup error). A test that passes before the fix isn't exercising the bug — fix
   the test until it's genuinely red. Then proceed to the code change so it goes green.

3. Make the minimal code change (Edit/Write). Do not touch anything not listed in the
   plan. If you notice a related issue while editing, note it in the plan as `OUT OF
   SCOPE — <description>` and leave it alone.

4. After all tasks, run a quick build / type-check to catch compile-time errors:
   ```bash
   # Go:     go build ./...
   # Node:   tsc --noEmit  (or npm run build)
   # Rust:   cargo check
   # Python: ruff check <changed files>
   ```

5. Fix compilation or type errors before continuing — these are part of the fix, not
   failures. If fixing them requires changing files outside the plan, add those as tasks
   in `03-plan.md` with a note `(added during fix: <reason)` and check them off.

Print: `[5/7] FIX done`
