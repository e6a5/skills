---
block: investigate
order: 2
needs: [repro]
mutates: none
gate-after: false
---

# INVESTIGATE — Root Cause Analysis

**Goal**: Understand what the feature was supposed to do, trace the exact code path that
fails, and name the root cause in one sentence.

**Input**: Read `01-repro.md`.

---

## Step 1 — Surface feature context

**Check for devloop artifacts** about the affected area:

```bash
ls .devloop/
```

For each slug that looks related to the failing feature, check:
- `.devloop/<slug>/01-arch.md` — architecture decisions and design constraints
- `.devloop/<slug>/02-requirements.md` — acceptance criteria and intended behavior
- `.devloop/<slug>/03-plan.md` — what tasks were implemented and how

Extract the **intended behavior** relevant to this bug. This tells you what correct
behavior looks like before you read a single line of code.

If no devloop artifacts exist for this area, derive expected behavior from code
comments, test descriptions, README, or CLAUDE.md.

**Also run:**
```
/learn recall <bug description>
```
Surface any similar bugs seen in past runs and how they were resolved.

---

## Step 2 — Trace the code path

Starting from the entry point of the minimal reproduction, follow execution:

1. Use `Grep`, `LSP` (go-to-definition, find-references), and `Read` to trace through
   every function, handler, middleware, or module involved.
2. Walk the full path — do not stop at the first suspicious line.
3. Mark where the observed behavior first diverges from the expected behavior. That
   divergence point is where the bug lives.

Common patterns to check:
- Off-by-one in index/boundary conditions
- Nil/null/undefined not guarded
- Wrong variable captured in a closure
- Race condition (goroutine / async / thread)
- Incorrect error handling path (error swallowed or wrong branch taken)
- Stale cache or wrong data layer queried
- Contract mismatch between caller and callee (wrong arg order, wrong unit)

---

## Step 3 — Isolate root cause

Write one sentence that names:
- What is wrong (not just "X fails" — what incorrect state or logic)
- Where it lives (file and line or function)
- Why it produces the observed behavior

Example: `"In auth/refresh.go:142, the token expiry is compared using < instead of <=,
so tokens expire one second early, causing a valid refresh to be rejected."`

---

## Output — `.devloop/<slug>/02-investigate.md`

```markdown
## Feature context
### Devloop artifacts consulted
- <slug> (`01-arch.md`, `02-requirements.md`) — <what this revealed>
(Omit section if no devloop artifacts found.)

### Intended behavior
- <bullet: what the feature should do, derived from artifacts or code>

### Past experience
- (from /learn recall — omit if nothing relevant)

## Code path
- `<file>:<line>` — <what this does in the execution path>
- `<file>:<line>` — <next hop>
- `<file>:<line>` — **divergence point** — <what goes wrong here>

## Root cause
<one sentence: incorrect state/logic, location, why it produces the observed failure>

## Affected scope
- `<file>` — <what must change to fix the root cause>
(Only files the fix will touch. No scope creep.)
```

Print: `[3/7] INVESTIGATE done`
