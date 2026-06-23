---
block: req
order: 2
needs: [arch]
mutates: none
gate-after: false
---

# REQ — Requirements Analysis

**Goal**: Turn the request + architecture context into clear, testable requirements.

**Input**: Read `00-input.md` and `01-arch.md`.

**Do:**
- Define what "done" looks like.
- List functional requirements (what the system must do).
- List non-functional requirements (performance, security, backward-compatibility).
- Identify edge cases and failure modes.
- If a requirement is ambiguous and cannot be reasonably inferred, use
  **AskUserQuestion** to resolve it.

## Output — `.devloop/<slug>/02-requirements.md`

```markdown
## Functional requirements
- [FR-1] ...

## Non-functional requirements
- [NFR-1] ...

## Edge cases
- ...

## Acceptance criteria
- [ ] <verifiable criterion>
```

Print: `[2/8] REQ done`
