---
name: clarify
description: Surface the 2–3 questions whose answers would most change the plan, then ask them in one shot. Use before planning any non-trivial change to avoid wrong-assumption runs.
argument-hint: <the request to clarify>
allowed-tools: Read Bash AskUserQuestion
---

## Goal

Ask only the questions that matter — ones whose answers would change the approach, scope,
or target. Skip anything that can be reasonably inferred from context or the codebase.

---

## Step 1 — Read context

The request is `$ARGUMENTS`. If running inside devloop, also read `.devloop/*/00-input.md`
for the original input. Skim available context to rule out questions the codebase already
answers:

```bash
ls -1 2>/dev/null | head -20
cat CLAUDE.md AGENTS.md 2>/dev/null | head -60
```

---

## Step 2 — Identify ambiguities

Scan the request for gaps across these categories (in priority order):

1. **Scope** — which services, repos, APIs, or user flows are in vs. out
2. **Ownership / target** — which system, team, or code path owns the change
3. **Constraints** — backward-compatibility, performance budget, security requirements, deadlines
4. **Success** — what "done" looks like beyond the literal request; acceptance criteria not stated

For each candidate question apply this filter: *"If the answer were different, would the
plan change materially?"* Include it if yes. Skip it if the answer can be inferred
with reasonable confidence.

Cap at 3 questions. If more than 3 qualify, pick the 3 most impactful.

---

## Step 3 — Ask or skip

**If 0 questions qualify**: output `CLEAR — no ambiguities; proceeding.` and stop.

**If 1–3 questions qualify**: use **AskUserQuestion** to ask them all in one call.
Phrase each question so it is answerable with a short phrase, not an essay.

---

## Output

Append a `## Clarifications` section to `00-input.md` (or print to stdout if standalone):

```markdown
## Clarifications
- Q: <question> → A: <answer>
```

If CLEAR:

```markdown
## Clarifications
N/A — no ambiguities found.
```
