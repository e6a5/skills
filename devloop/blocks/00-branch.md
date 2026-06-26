---
block: branch
order: 0
needs: []
mutates: git
gate-after: false
---

# BRANCH — Git Workflow Setup

**Goal**: Land on the correct feature branch in the primary repo before any work begins.

## Step 0 — Confirm this is a git repo

```bash
git rev-parse --git-dir 2>/dev/null || echo "NOT_A_REPO"
```
If `NOT_A_REPO`, ask the user whether to `git init` here or point devloop at a different
path. Do not proceed until the cwd is a git repo.

## Step 0a — Read project git config

If `.devloop/config.md` exists, read it and extract `base-branch` and `branch-prefix`.

## Step 0b — Detect or ask if config is missing or incomplete

If config is absent or incomplete, detect candidate base branches:
```bash
git branch -r | grep -E 'HEAD|master|main|dev|develop|staging|release' | head -20
git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/origin/||'
```

Propose a base branch from the output. If ambiguous, use **AskUserQuestion** to let the
user pick, then ask the preferred branch prefix (`feature/`, `feat/`, `fix/`, none).
Save answers to `.devloop/config.md`.

## Step 0c — Create and switch to the feature branch

Check `git status --short`. If dirty, ask the user: stash, commit, or abort.

Feature branch name: `<prefix><slug>`.
```bash
git branch --list <branch-name>
```
- **Does not exist** → `git fetch origin && git checkout -b <branch-name> origin/<base-branch>`
- **Already exists** → `git checkout <branch-name>` and print `resuming existing branch <branch-name>`

## Output — `.devloop/<slug>/00-branch.md`

```markdown
## Branch info
primary-repo: <absolute path>
base-branch: <base>
feature-branch: <branch-name>
status: new | resumed

## Cross-repo branches
(filled in as cross-repo tasks execute)
```

Print: `[1/9] BRANCH done — on <branch-name> (from <base-branch>)`
