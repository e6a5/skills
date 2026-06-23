---
block: cleanup
order: 8
needs: [quality]
mutates: source
parallel-safe: false
gate-after: false
---

# CLEANUP — Tidy Up & Document

**Goal**: Leave the tree clean and the change documented so anyone — technical or not —
can understand what this task did and how to use anything new it introduced. Runs after
`quality` (so it tidies the final, quality-checked code) and before `review` (so `review`
validates the cleaned, documented state). Mutates source, so it runs alone.

**Input**: Read `00-input.md`, `03-plan.md`, `07-quality.md`, and the final
`git diff HEAD` of the primary repo and each cross-repo branch in `00-branch.md`.

## Step 8a — Clean up the diff

Scan the diff for anything that isn't part of the solution and remove it (principle 1):
- Debug prints, temporary logging, commented-out code, and scratch files added while working.
- TODO/FIXME markers you introduced and already resolved.
- Unused imports, variables, and dead branches left by the change.
- Formatting churn in untouched regions — keep the diff minimal and on-topic.

Then run the project's formatter/linter so the diff is clean (`gofmt`/`go vet`,
`prettier`/`eslint --fix`, `cargo fmt`, `ruff format`, etc.). Ensure `.devloop/` is
git-ignored so handoff artifacts aren't committed; add it to `.gitignore` if missing.

If the diff is already clean and nothing needs removing: write `N/A — diff already clean`.

## Step 8b — Write the docs

Write documentation for **two audiences in one place**:

- **What & why (plain language)** — what this task delivers, in terms a non-technical
  reader (PM, support, a brand-new teammate) understands. No jargon, no internal names.
  2–4 sentences.
- **How to use / integrate (technical)** — *only if the task exposed something new*: a
  new endpoint, command, config flag, env var, or library API. Give the call shape,
  inputs/outputs, a copy-paste example, and any migration or config step needed to adopt
  it. If the task exposed no new surface (e.g. an internal bug fix): write
  `N/A — no new surface`.

Place the doc where the repo already keeps docs — detect the convention and follow it
(principle: consistency): a section in `README.md`, a file under `docs/`, a `CHANGELOG.md`
entry, or an ADR. If the repo has no docs location, create `docs/<slug>.md`. Keep it
terse (principle 2) — link to code rather than pasting it.

Apply the same to each cross-repo branch that exposed something new.

## Output — `.devloop/<slug>/08-cleanup.md`

```markdown
## Cleanup
- Removed: <items> | N/A — diff already clean
- Formatter/lint: <command> → clean
- .gitignore: `.devloop/` present | added

## Docs written
- [primary] <doc location> — what & why + <integration section | N/A — no new surface>
- [<alias>] <doc location> — ...

## Status: DONE
```

Print: `[8/9] CLEANUP done`
