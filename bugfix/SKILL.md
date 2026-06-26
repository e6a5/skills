---
name: bugfix
description: Bug fix loop. Reproduce → Investigate (reads devloop artifacts for feature context) → Plan → Fix → Verify → Review. Connects with devloop artifacts to understand expected behavior before finding the root cause.
argument-hint: <describe the bug or paste the error>
allowed-tools: Read Edit Write Bash Grep LSP AskUserQuestion Agent Skill WebSearch WebFetch
---

## What this is

`bugfix` runs a focused pipeline for fixing bugs:

```
BRANCH → REPRO → INVESTIGATE → PLAN (gate) → FIX → VERIFY → REVIEW → done
```

- Artifacts live in `.devloop/<slug>/` — the same directory devloop uses, so existing
  feature artifacts are visible and the investigate block can read them.
- Pipeline is intentionally narrow: no requirements doc, no cleanup phase. Just
  understand → fix → verify.

---

## Operating principles

All devloop operating principles apply, plus:

6. **Fix only the bug.** Root cause is the target. Surrounding ugliness is out of scope
   unless it caused the bug.
7. **Reproduce before fixing.** Never apply a fix to a bug you haven't reproduced.
   `repro` is mandatory — if it can't trigger the bug, stop and ask the user.
8. **Red before green.** Encode the bug as a failing regression test, watch it fail for
   the right reason, then make the fix turn it green. The fix is done only when that test
   passes and the surrounding suite is green. (When an automated test truly isn't feasible,
   fall back to the minimal manual reproduction — but that's the exception, not the norm.)

---

## Block files & their dependencies

| File | block | needs | mutates |
|------|-------|-------|---------|
| `blocks/00-branch.md` | branch | — | git |
| `blocks/01-repro.md` | repro | branch | none |
| `blocks/02-investigate.md` | investigate | repro | none |
| `blocks/03-plan.md` | plan | investigate | none (gate-after) |
| `blocks/04-fix.md` | fix | plan | source |
| `blocks/05-verify.md` | verify | fix | none |
| `blocks/06-review.md` | review | verify | source |

---

## Scheduling rules

1. **Run order** is a topological sort by `needs`. Blocks run one at a time, in order.
2. **Gate**: after `plan`, present root cause + fix tasks and wait for user `go` before
   any mutating block.
3. **Failure loop-back**: if `verify` reports a blocking failure and the user chooses
   `fix`, reset `fix` and `verify` to `[ ]` and re-run from `fix` with the failure
   context appended.
4. **Stuck detection**: before starting any block, check its `attempts` count in
   `state.md`. If `attempts ≥ 2` and the block is still `[ ]`, stop and ask:

   > "Stuck on `<block>` (attempted <n> times). What next?"
   > - **Retry with context summary** — write a ≤8-bullet summary of completed blocks to
   >   `.devloop/<slug>/context-summary.md`, prepend it to this block, then retry.
   > - **Skip this block** — mark it `[-]` and continue.
   > - **Abort** — stop; print the completion footer with a note that `<block>` was abandoned.

---

## State tracking & resumption

`.devloop/<slug>/state.md`:

```markdown
# Run state
slug: <slug>
type: bugfix
updated: <timestamp>

- [ ] branch       attempts:0
- [ ] repro        attempts:0
- [ ] investigate  attempts:0
- [ ] plan         attempts:0
- [ ] fix          attempts:0
- [ ] verify       attempts:0
- [ ] review       attempts:0
```

- **After a block completes**, mark its line `[x]` and move the `← next` marker.
- **On invocation**, if `state.md` already exists for this slug, resume from the first
  unchecked block. Tell the user: `resuming <slug> at <block>`.
- **On failure loop-back**, reset `fix` and every block after it to `[ ]`. Do NOT reset
  attempt counts — they accumulate across retries.

To run a block: **Read `blocks/<file>.md` and follow it exactly.**

---

## Setup (run once, before any block)

1. If `$ARGUMENTS` is empty, use **AskUserQuestion** to ask *"Describe the bug — what
   happens vs. what should happen?"* Wait for the answer.
   - **Right loop?** A bug is a *defect in existing behavior* — something that worked or
     was meant to work now does the wrong thing. If the input is really a new capability
     or enhancement ("add…", "support…", "make it also…"), say so in one line and suggest
     `/devloop` instead; proceed with `bugfix` only if the user confirms.
2. Derive a kebab-case **descriptor** from the input (max 40 chars). The artifact
   **slug** is `bug-<descriptor>`; the **fix branch** is `fix/<descriptor>` (no `bug-`).
   Example: `"JWT refresh crashes on expiry"` → descriptor `jwt-refresh-crashes-on-expiry`,
   slug `bug-jwt-refresh-crashes-on-expiry`, branch `fix/jwt-refresh-crashes-on-expiry`.
3. `mkdir -p .devloop/<slug>` and write `.devloop/<slug>/00-input.md`:
   ```
   # Bug report
   <the user's original description verbatim>
   ```
4. **Clarify (fresh runs only)**: if `state.md` does not yet exist, run `/clarify` with
   the input. It surfaces the few unknowns that would most change the fix — for a bug
   those are usually the reproduction steps, the exact error observed, and any related
   devloop slug / PR / commit. It appends answers to `00-input.md` as `## Clarifications`.
   (The `repro` block also handles missing repro detail, so this is a cheap early pass,
   not the only chance to gather it.) On resume, skip this step.
5. If `state.md` already exists, resume per **State tracking** above.
   Otherwise create it with all blocks unchecked.
6. Print: `── bugfix: <slug> ──`
7. Begin scheduling from `branch`.

---

## Done

When `review` is CLEAN (or the user accepted), print:

```
── bugfix complete: <slug> ──

Branch:      fix/<descriptor> → <base-branch>
Root cause:  <one-line from 02-investigate.md>
Fix:         <one-line from 03-plan.md>

Artifacts: .devloop/<slug>/
  00-input.md        bug report + clarifications
  state.md           run state
  00-branch.md       branch setup
  01-repro.md        reproduction steps + minimal test/command
  02-investigate.md  root cause analysis + feature context
  03-plan.md         fix plan (all tasks checked)
  05-verify.md       verification results
  06-review.md       final review verdict

Next:
  1. Open PR: fix/<descriptor> → <base-branch>
```

Then run `/learn` to capture non-obvious lessons from this run.
