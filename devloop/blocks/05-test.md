---
block: test
order: 5
needs: [impl]
mutates: none
gate-after: false
---

# TEST — Testing & Verification

**Goal**: Verify the implementation satisfies the acceptance criteria — in all repos
touched.

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
3. If the project has an integration/e2e suite (and it runs without a full live stack),
   run the part covering the affected area too. Skip if it needs infra you can't stand up.
4. For each **dependency repo** in `00-branch.md`, run its relevant tests too.
5. For each acceptance criterion in `02-requirements.md`, verify it is met.

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

On `FAIL`, the scheduler will surface the failure and offer: `fix` (loop back to impl),
`skip`, or `stop`.

Print: `[5/8] TEST done`
