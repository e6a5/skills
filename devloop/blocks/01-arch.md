---
block: arch
order: 1
needs: [branch]
mutates: none
gate-after: false
---

# ARCH — Architecture Understanding

**Goal**: Map every area this request will touch — including dependencies in other repos.

**Do:**
- Read `CLAUDE.md`/`AGENTS.md`, key config and entry-point files, and the top-level
  directory structure.
- Identify every file, package, service, or module this request will touch in the
  primary repo.
- **Actively look for cross-repo dependencies**: IDL/proto/schema definitions, shared
  libraries, API gateway configs, auth services, generated code originating elsewhere,
  dependency-replace directives (`go.mod replace`, `package.json` workspaces, path deps),
  vendored packages, etc.
- Note patterns and constraints (auth model, DB schema, API contracts, versioning, test
  conventions, codegen steps).
- Note what is out of scope.

## Output — `.devloop/<slug>/01-arch.md`

```markdown
## Relevant areas
- <path> — <what it does and why it matters>

## Cross-repo dependencies
- [alias: <name>] <repo-name> at <path or "unknown"> — <what changes there and why>
(Omit this section if there are none.)

## Patterns & constraints
- <pattern or constraint>

## Out of scope
- <what this request does NOT touch>
```

Print: `[1/8] ARCH done`
