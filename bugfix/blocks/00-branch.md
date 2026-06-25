---
block: branch
order: 0
needs: []
mutates: git
gate-after: false
---

# BRANCH — Create fix branch

**Goal**: Set up the fix branch from the project base.

The branch name is `fix/<descriptor>`, where `<descriptor>` is the slug with its leading
`bug-` removed (slug `bug-jwt-refresh` → branch `fix/jwt-refresh`). Bugfix always uses the
`fix/` prefix; it does NOT read or write `branch-prefix` in `.devloop/config.md` — that
field belongs to devloop and must not be touched here.

**Do:**

1. Resolve the base branch. `.devloop/config.md` is shared with devloop:
   - If it exists, read `base-branch` from it. Leave every other field untouched.
   - If it is absent, detect the base branch:
     ```bash
     git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/origin/||'
     ```
     If that fails, ask the user. Then create the config with **only** the base branch:
     ```
     # Devloop project config
     base-branch: <detected>
     ```

2. Check git status. If dirty, ask: stash, commit, or abort.

3. Create or switch to the fix branch:
   ```bash
   git fetch origin
   git checkout -b fix/<descriptor> origin/<base-branch>   # if branch is new
   # or:
   git checkout fix/<descriptor>                            # if it already exists
   ```

4. Write `.devloop/<slug>/00-branch.md`:
   ```markdown
   # Branch
   branch: fix/<descriptor>
   base-branch: <base-branch>
   ```

Print: `[1/7] BRANCH done`
