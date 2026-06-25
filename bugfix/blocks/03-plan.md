---
block: plan
order: 3
needs: [investigate]
mutates: none
gate-after: true
---

# PLAN — Fix Plan

**Goal**: Define the minimal fix — one task per file that needs to change, nothing more.

**Input**: Read `02-investigate.md` for root cause and affected scope.

**Rules:**
- One task per file. Each task states exactly what to change and why it fixes the root
  cause (not just "fix the bug").
- No refactoring, renaming, or cleanup unless the cleanup IS the fix.
- If the root cause is in a third-party dependency, propose a workaround in the primary
  codebase and note the upstream issue.
- **The first task is always the regression test** from `01-repro.md`'s "Planned
  regression test" — written and confirmed failing (red) before any fix lands. Omit this
  task only if repro recorded that an automated test isn't feasible.

## Output — `.devloop/<slug>/03-plan.md`

```markdown
## Root cause (from investigate)
<one-line>

## Fix tasks
- [ ] `<test file>` — add failing regression test: <scenario it covers> (red before fix)
- [ ] `<file>` — <exact change: e.g. "change < to <= on line 142 in tokenExpired()">
- [ ] `<file>` — <exact change>

## Out of scope
- <explicitly deferred items>
```

---

## GATE — Plan Approval

Present the full `03-plan.md` content:

```
── bugfix: plan ready ──

<03-plan.md content>

Reply with:
  "go"              — proceed with the fix
  "edit T<N>: ..."  — revise a specific task
  "stop"            — abort
```

**Wait for the user's reply. Do not touch any source file until you receive "go".**
If the user requests edits: update `03-plan.md`, re-present, wait again. Repeat until
`go` or `stop`.

Print: `[4/7] PLAN done`
