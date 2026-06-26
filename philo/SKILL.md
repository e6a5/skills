---
name: philo
description: Review code against the coding philosophy — single responsibility, simplicity, readability, fail loud, consistency. Read-only by default; pass "fix" to fix CRITICAL/HIGH violations in a guided loop. Use when asked to review code quality, check if code follows the philosophy, or clean it up.
argument-hint: [fix] [file-or-path]  (no args = review current git diff; "fix" = guided fix loop)
allowed-tools: Read Edit Bash Grep
---

## Coding Philosophy

> Do one thing and do it well. Favor simplicity over cleverness. Write code for readability and long-term maintainability.

1. **Single responsibility** — each function/module has one clear purpose; prefer composition and small pure functions over God objects. — *CRITICAL if broken.*
2. **Simplicity over engineered** — simplest solution that solves today's problem; no speculative abstractions, no premature optimization, no unnecessary indirection. — *HIGH.*
3. **Readable & maintainable first** — optimize for the next reader; explicit over magic; comments explain *why* not *what*; no misleading names or magic values. — *HIGH.*
4. **Fail loud, test early** — surface errors fast with types, assertions, and tests; keep error messages actionable; never swallow errors or use panics where errors belong. — *CRITICAL if errors are silenced.*
5. **Consistency beats brilliance** — follow existing style and conventions; if you diverge, document why. — *LOW (skip — not worth blocking on).*

**Severity:** CRITICAL = single responsibility broken or errors silenced/swallowed.
HIGH = misleading logic, unnecessary complexity, magic values, unactionable errors.
LOW/MINOR = style, naming nits, consistency — skip entirely.

---

## Step 1 — Mode and target

Parse `$ARGUMENTS`:
- If the first word is `fix`, run in **FIX mode** (loop below). Drop it; the rest is the target.
- Otherwise run in **REVIEW mode** (read-only — never edit, even though Edit is allowed).
- The remaining argument, if any, is a **file or repo path**.

Collect the code to inspect:

!`
ARGS="${ARGUMENTS}"; FIRST="${ARGS%% *}"
[ "$FIRST" = "fix" ] && ARGS="${ARGS#fix}" && ARGS="${ARGS# }"
TARGET="$ARGS"
# `git add -N` registers intent-to-add so untracked NEW files show up in `git diff`
# (without it, a change made entirely of new files produces an empty diff). It only
# touches the index, not the working tree — no source is edited.
if [ -n "$TARGET" ] && [ -f "$TARGET" ]; then
  echo "=== File: $TARGET ===" && cat "$TARGET"
elif [ -n "$TARGET" ] && [ -e "$TARGET/.git" ]; then
  echo "=== $TARGET (uncommitted: git diff HEAD + untracked) ===" && (cd "$TARGET" && git add -N . >/dev/null 2>&1; git diff HEAD 2>/dev/null)
elif git rev-parse --git-dir >/dev/null 2>&1; then
  git add -N . >/dev/null 2>&1
  echo "=== $(pwd) (uncommitted: git diff HEAD + untracked) ===" && git diff HEAD 2>/dev/null
else
  for d in */; do
    [ -e "$d/.git" ] || continue
    diff=$(cd "$d" && git add -N . >/dev/null 2>&1; git diff HEAD 2>/dev/null)
    [ -n "$diff" ] && echo "=== REPO: $d ===" && echo "$diff"
  done
fi
`

---

## Step 2 — Review and classify (both modes)

Read the code above. Apply principles 1–4 only (5 is LOW — skip). Produce a numbered list:

```
[CRITICAL] 1. <file>:<line> — <principle> — <one-line description>
[HIGH]     2. <file>:<line> — <principle> — <one-line description>
```

If no CRITICAL or HIGH violations exist, output `ALL CLEAR — no CRITICAL or HIGH violations found.` and stop.

---

## Step 3 — REVIEW mode output

For each violation: name the principle, quote the specific code, explain why it breaks the
principle, and suggest a concrete fix. Skip principles with no violations — don't pad with
praise. End with a one-line verdict: **PASS** | **MINOR ISSUES** | **NEEDS WORK** plus a
one-sentence reason. **Do not edit any file in this mode.** Stop here.

---

## Step 4 — FIX mode: user gate (REQUIRED before any edit)

Present the full list with each item's code snippet and diagnosis, then:

```
Found N violation(s). Review before fixes begin:

[list each item with snippet + diagnosis]

Ready to fix? Reply with:
  - "go"               — fix all items in order (CRITICALs first)
  - "skip N"           — skip item(s) by number (e.g. "skip 2, 3")
  - per-item guidance  — inline (e.g. "1: extract to helper  2: return error not panic")
  - "stop"             — abort
```

**Wait for the reply. Do not edit until you receive it.**

## Step 5 — FIX mode: apply fixes

Work through approved items top-down (CRITICALs first). For each:
1. If the user gave inline guidance, use it; otherwise ask **"How should item N be fixed?"** and wait.
2. Apply with Edit, scoped to the violation only — do not refactor surrounding code.
3. Confirm the fix, move on.

## Step 6 — FIX mode: re-review

Re-run Step 1's collection and Step 2's classification.
- If new CRITICAL/HIGH violations appear (introduced by fixes), loop from Step 4.
- If ALL CLEAR, output `LOOP COMPLETE — no CRITICAL or HIGH violations remain.` and stop.
