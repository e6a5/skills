---
block: impl
order: 4
needs: [plan]
mutates: source, git
parallel-safe: false
gate-after: false
---

# IMPL — Implementation

**Goal**: Execute every task in the plan, in order. Cross-repo tasks run a sub-loop
inside the dependency repo.

**Input**: Read all previous blocks. For each task in `03-plan.md`, follow the matching
procedure below.

## Standard task
1. Mark `[→]` in `03-plan.md`.
2. Make the change (Edit/Write/Bash).
3. Mark `[x]` in `03-plan.md`.

## `[CROSS-REPO: <alias>]` task

Work that must happen in a different repo first.

**A — Resolve the repo path.** Look up `<alias>` in `.devloop/config.md` under `repos:`.
If missing or the path doesn't exist, ask the user for the absolute path and save it.

**B — Read (or create) the dependency repo's config.**
```bash
cat <repo-path>/.devloop/config.md 2>/dev/null || echo "NO_CONFIG"
```
If absent, detect its base-branch and branch-prefix as in the `branch` block, Step 0b,
and save to `<repo-path>/.devloop/config.md`.

**C — Branch in the dependency repo.**
```bash
cd <repo-path> && git status --short
```
If dirty, ask: stash, commit, or abort. Use the same `<prefix><slug>` branch name as the
primary repo (keeps branches aligned).
- Does not exist → `git fetch origin && git checkout -b <branch-name> origin/<base-branch>`
- Already exists → `git checkout <branch-name>`

Append to `.devloop/<slug>/00-branch.md` in the **primary repo**:
```
- <alias> (<repo-path>): <branch-name> (from <base-branch>)
```

**D — Execute the task** in `<repo-path>` using Edit/Write/Bash.

**E — Build and verify** in the dependency repo. Detect the tooling and run its build:
```bash
# Go:    go build ./...
# Node:  npm run build   (or pnpm/yarn)
# Rust:  cargo build
# Proto: buf build
# Python: python -m build  /  ruff check
```
If the build fails, fix it before returning — never leave the dependency repo broken.

**F — Return** to the primary repo (`cd <primary-repo-path>`) and mark the task `[x]`.

## `[SYNC]` task

Pulls the dependency repo's output into the primary repo.
1. Mark `[→]`.
2. Run the sync command (regenerate bindings, bump a dep, reinstall a local package):
   ```bash
   make <codegen-target>      # regenerate bindings from updated IDL
   go get <module>@<version>  # pick up new version
   npm install                # pick up updated local package
   ```
3. Verify the expected generated/updated files are present.
4. Mark `[x]`.

## After all tasks

Print: `[4/9] IMPL done`
