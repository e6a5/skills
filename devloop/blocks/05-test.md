---
block: test
order: 5
needs: [impl]
mutates: none
parallel-safe: true
gate-after: false
---

# TEST — Testing & Verification

**Goal**: Verify the implementation satisfies the acceptance criteria — in all repos
touched. This block only reads source, so it runs in parallel with `e2e`.

**Input**: Read `02-requirements.md` and `03-plan.md`. Read `00-branch.md` for
cross-repo branches.

**Do:**
1. Detect the project's test tooling and run tests scoped to affected packages:
   ```bash
   # Go:     go test ./affected/pkg/...
   # Node:   npm test -- <pattern>
   # Rust:   cargo test <filter>
   # Python: pytest <path>
   ```
2. Run type-check / lint on changed files if available (`go build ./...`, `tsc --noEmit`,
   `cargo check`, `ruff`/`mypy`).
3. For each **dependency repo** in `00-branch.md`, run its relevant tests too.
4. For each acceptance criterion in `02-requirements.md`, verify it is met.

## Output — `.devloop/<slug>/05-test.md`

```markdown
## Commands run
- [primary] `<command>` → PASS | FAIL
- [<alias>] `<command>` → PASS | FAIL

## Acceptance criteria
- [x] <criterion> — verified by: ...
- [ ] <criterion> — FAILED: ...

## Status: PASS | FAIL
```

On `FAIL`, the scheduler will surface the failure after the parallel group completes and
offer: `fix` (loop back to impl), `skip`, or `stop`.

Print: `[5/9] TEST done`
