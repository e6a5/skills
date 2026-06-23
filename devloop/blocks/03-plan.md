---
block: plan
order: 3
needs: [req]
mutates: none
parallel-safe: false
gate-after: true
---

# PLAN — Task Planning

**Goal**: Break requirements into ordered, concrete tasks. Cross-repo dependencies
become explicit tasks, ordered before the tasks that depend on them.

**Input**: Read `00-input.md`, `01-arch.md`, `02-requirements.md`.

**Rules:**
- Order tasks by dependency: cross-repo tasks that unlock later work come first.
- For each task: short name, file(s) affected, what changes.
- Use `[CROSS-REPO: <alias>]` for tasks in another repo, followed by a `[SYNC]` task that
  pulls the result back into the primary repo (regenerate bindings, bump a version, etc.).
- Flag schema/migration/contract changes as `[HIGH-RISK]`.
- Do NOT write code yet.

## Output — `.devloop/<slug>/03-plan.md`

```markdown
## Tasks
- [ ] T1: <name> — <file(s)> — <what changes>
- [ ] T2: [CROSS-REPO: <alias>] <name> — <repo>/<file(s)> — <what changes>
- [ ] T3: [SYNC] <sync step> — <command> — pulls T2's output into primary repo
- [ ] T4: <name depending on T2+T3> — <file(s)> — <what changes>

## Risk flags
- <task ID>: <why>

## Cross-repo map
- <alias>: <absolute path or "unknown — will ask">
```

Print: `[3/9] PLAN done`

---

## GATE — Plan Approval

Present the full `03-plan.md` content:

```
── devloop: plan ready ──

<03-plan.md content>

Reply with:
  "go"              — proceed with implementation
  "edit T<N>: ..."  — revise a specific task
  "stop"            — abort the loop
```

**Wait for the user's reply. Do not touch any source file until you receive "go".**
If the user requests edits: update `03-plan.md`, re-present, wait again. Repeat until
"go" or "stop".
