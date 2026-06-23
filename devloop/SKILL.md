---
name: devloop
description: Full dev loop from idea to done. Architecture → Requirements → Plan → Implement → Test → Quality → Cleanup & Document → Review. Cleanup tidies the diff and writes docs both non-technical and technical readers can follow. Handles cross-repo dependencies by running sub-work in sibling repos and syncing back. Takes a free-form description and chains each block's output to the next.
argument-hint: <describe what you want to build or fix>
allowed-tools: Read Edit Write Bash Grep LSP AskUserQuestion Agent Skill WebSearch WebFetch
---

## What this is

`devloop` runs a development pipeline as a set of **blocks**. Each block is a separate
file in `blocks/`. A block has one job, reads the artifacts of earlier blocks, and
writes its own artifact. This master file is the **scheduler**: it decides the order and
where to stop for user approval.

The design is project-agnostic. Nothing here assumes a language, framework, or RPC
style — each block detects the project's tooling at runtime.

```
BRANCH → ARCH → REQ → PLAN ─(gate)→ IMPL → TEST → QUALITY → CLEANUP → REVIEW → done
```

- Handoff artifacts live in `.devloop/<slug>/` relative to the **primary repo** (cwd).
- Project config lives in `.devloop/config.md` in each repo (persistent across runs).

---

## Operating principles

Every block obeys these. They cut verbosity and wasted work — never correctness.
The code the loop *writes* follows the repo's coding philosophy (enforced by the
`philo` skill, run as `/philo fix` in the quality block); these principles govern how the
loop *runs*.

1. **Solve the stated problem — nothing more.** No speculative features, no unrequested
   refactors, no abstractions for hypothetical futures. Out-of-scope ideas become a
   one-line "Deferred" note, not code.
2. **Artifacts are terse.** Bullets, not prose. Never restate the input or an earlier
   block's output — reference it. No preamble, no filler, no summarising your summary.
3. **Skip what doesn't apply.** A block or step with nothing to do writes one line
   (`N/A — <reason>`) and exits. Never manufacture work to fill a section.
4. **Right-size the loop.** Match depth to the change — see the Setup triage tiers. A
   typo fix does not need a full architecture map.
5. **Spend tokens only to buy correctness.** Extra reads and review passes are for
   catching real defects, not for thoroughness theater.

---

## Block files & their dependencies

Each file in `blocks/` starts with a metadata header the scheduler reads:

```
---
block: <name>
order: <n>
needs: [<block names that must finish first>]
mutates: none | source | git   # what the block changes
gate-after: true | false       # stop for user approval when this block finishes
---
```

| File | block | needs | mutates |
|------|-------|-------|---------|
| `blocks/00-branch.md`  | branch  | —              | git    |
| `blocks/01-arch.md`    | arch    | branch         | none   |
| `blocks/02-req.md`     | req     | arch           | none   |
| `blocks/03-plan.md`    | plan    | req            | none (gate-after) |
| `blocks/04-impl.md`    | impl    | plan           | source, git |
| `blocks/05-test.md`    | test    | impl           | none   |
| `blocks/06-quality.md` | quality | test           | source |
| `blocks/07-cleanup.md` | cleanup | quality        | source |
| `blocks/08-review.md`  | review  | cleanup        | source, git |

---

## Scheduling rules

1. **Run order is a topological sort by `needs`.** A block may start only when every
   block in its `needs` list has completed. Blocks run one at a time, in order.
2. **`quality` waits for `test`** so its independent review sees code that already passed
   tests and can fold in the test outcome.
3. **Gate**: after a block with `gate-after: true` (i.e. `plan`), present the artifact
   and wait for the user's `go` before scheduling any mutating block.
4. **Failure loop-back**: if `test` or `quality` reports a blocking failure and the user
   chooses `fix`, re-run `impl` with the failure context, then re-run the blocks
   downstream of `impl` again.

## State tracking & resumption

The scheduler maintains `.devloop/<slug>/state.md` — a checklist of every block and its
status. This makes runs resumable and drives the failure loop-back.

```markdown
# Run state
slug: <slug>
tier: quick | full
updated: <timestamp>

- [x] branch
- [-] arch      (skipped: quick tier)
- [ ] req      ← next
- [ ] plan
- [ ] impl
- [ ] test
- [ ] quality
- [ ] cleanup
- [ ] review
```

- `[-]` marks a block skipped by the tier; treat it as satisfied when resolving the
  `needs` of later blocks (e.g. `req` proceeds though `arch` is `[-]`).
- **After a block completes**, mark its line `[x]` and move the `← next` marker.
- **On invocation**, if `state.md` already exists for this slug, read it and resume from
  the first unchecked block instead of starting at `branch`. Tell the user:
  `resuming <slug> at <block>`.
- **On failure loop-back** (rule 6), reset `impl` and every block after it to `[ ]`, then
  re-schedule from `impl`.

To run a block: **Read `blocks/<file>.md` and follow it exactly.** The block file is the
source of truth for its own steps and output format.

---

## Config format

`.devloop/config.md` in any repo (created/updated by the `branch` block):

```markdown
# Devloop project config

base-branch: <branch>
branch-prefix: <prefix or "none">

# Quality gate depth: low | medium | high
#   low    — philosophy check + breaking-change detection only
#   medium — above + independent code-review pass (default)
#   high   — above + security review
quality-depth: medium

repos:
  <alias>: <absolute-path-to-repo>
```

`repos` grows as cross-repo dependencies are discovered. Each alias (e.g. `proto`,
`auth`, `gateway`) is referenced by tasks with `[CROSS-REPO: alias]`.

---

## Setup (run once, before any block)

1. If `$ARGUMENTS` is empty, use **AskUserQuestion** to ask *"What do you want to build
   or fix?"* Wait for the answer.
2. Derive a kebab-case slug from the input (max 40 chars, e.g. `"add JWT refresh"` →
   `add-jwt-refresh`).
3. `mkdir -p .devloop/<slug>` and write `.devloop/<slug>/00-input.md`:
   ```
   # Input
   <the user's original request verbatim>
   ```
4. **Triage the request into a tier** (principle 4) and record it in `state.md`:
   - **`quick`** — a localized fix or tweak: no new public surface, no contract/schema/
     migration change, no cross-repo work. Skip `arch` (mark it `[-]`); fold requirements
     into a 2–3 line `plan`; force `quality-depth: low` for this run. The plan gate still
     applies.
   - **`full`** — new features, cross-repo work, contract/schema/migration changes, or
     anything you can't confidently scope. Run every block at the configured depth.
   - When unsure, pick `full`. State the chosen tier in one line and why.
5. If `.devloop/<slug>/state.md` already exists, resume per **State tracking** above.
   Otherwise create it with every block unchecked (mark tier-skipped blocks `[-]`).
6. Print: `── devloop: <slug> (<tier>) ──`
7. Begin scheduling from the first unchecked block (`branch` on a fresh run).

---

## Done

When `review` is CLEAN (or the user accepted), print:

```
── devloop complete: <slug> ──

Primary branch:  <feature-branch> (from <base-branch>)
Cross-repo PRs needed:
  - [<alias>] <branch-name> → <base-branch> in <repo-path>

Artifacts: .devloop/<slug>/
  00-input.md          original request
  state.md             block-by-block run state (for resumption)
  00-branch.md         branch setup (all repos)
  01-arch.md           architecture map + cross-repo deps
  02-requirements.md   requirements + acceptance criteria
  03-plan.md           tasks (all checked)
  05-test.md           test results (all repos)
  06-quality.md        quality gate summary
  06-quality-review.md independent review findings (if medium/high)
  07-cleanup.md        cleanup actions + docs written (location + audience)
  08-review.md         final review verdict (all repos)

<one short paragraph summarising what was built and any notable decisions>

Next:
  1. Open PR: <feature-branch> → <base-branch> in primary repo
  2. Open PR for each dependency repo (merge those first so the primary PR builds)
```
