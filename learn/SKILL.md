---
name: learn
description: Claude's institutional memory. Save mode: after completing work, extract non-obvious lessons, decisions, and pitfalls worth remembering across future runs. Recall mode: before planning, surface relevant past experience. Claude decides what to save — no user prompts.
argument-hint: [recall <description>]  (no args = save mode)
allowed-tools: Read Write Bash Grep
---

## Storage

All entries live in `~/.claude/learned/`:
- `INDEX.md` — one line per entry, scanned first for relevance
- `YYYY-MM-DD-<slug>.md` — full entry

`INDEX.md` line format:
```
- YYYY-MM-DD | <slug> | [tag1, tag2] | <one-line summary of the key lesson>
```

---

## Save mode (no args)

**Goal**: Extract what's non-obvious and worth remembering. Skip everything standard.

### Step 1 — Collect context

Look for devloop artifacts first:
```bash
ls .devloop/*/00-input.md .devloop/*/03-plan.md .devloop/*/06-quality.md .devloop/*/08-review.md 2>/dev/null | tail -4
```
If found, read them. Otherwise read:
```bash
git log --oneline -5 2>/dev/null
git diff $(git merge-base HEAD origin/HEAD 2>/dev/null || echo HEAD~1)...HEAD 2>/dev/null | head -200
```

### Step 2 — Judge what's worth saving

Apply this filter to everything observed: *"Would this surprise a competent developer
who knows the language and framework but not this specific codebase?"*

Worth saving:
- Constraints that weren't obvious from the request and changed the approach
- Decisions where multiple reasonable options existed — record which was chosen and why
- Pitfalls: things that broke, edge cases that bit, infra that behaved unexpectedly
- Patterns that solved the problem cleanly and could be reused

Not worth saving:
- Standard language/framework patterns any dev would know
- Anything already documented in CLAUDE.md or AGENTS.md
- Task-specific details that won't generalize to future work

**If nothing passes the filter**: print `SKIP — nothing non-obvious to record.` and stop.

### Step 3 — Write the entry

Derive a slug from the work (e.g. `add-jwt-refresh`, `rate-limit-middleware`).

Write `~/.claude/learned/YYYY-MM-DD-<slug>.md`:

```markdown
---
date: YYYY-MM-DD
slug: <slug>
tags: [tag1, tag2]
project: <project name or "unknown">
---

## What was done
<1–2 sentences>

## Lessons
- **<title>**: <what happened, why it matters, what to do next time>

## Key decisions
- Chose X over Y — <reason> (omit if no meaningful tradeoffs)

## Watch out for
- <pitfall or gotcha> (omit if none)
```

Append to `~/.claude/learned/INDEX.md` (create if absent):
```
- YYYY-MM-DD | <slug> | [tags] | <one-line summary>
```

Print: `SAVED — ~/.claude/learned/YYYY-MM-DD-<slug>.md`

---

## Recall mode (`recall <description>`)

**Goal**: Surface the 2–3 most relevant past lessons before work begins. Fast — read
the index first, only open full entries that look relevant.

### Step 1 — Scan the index

```bash
cat ~/.claude/learned/INDEX.md 2>/dev/null || echo "NO_ENTRIES"
```

If `NO_ENTRIES`: print `NO PAST EXPERIENCE — first run of this type.` and stop.

### Step 2 — Match relevant entries

Read the index lines. For each, ask: *"Does this entry's domain, tags, or summary
overlap with what we're about to build?"* Look for: same tech stack, same problem
domain, same architectural pattern, same kind of risk.

Select the top 2–3 matches. Read their full entry files.

### Step 3 — Output

Print a concise block — caller pastes this into the arch/plan context:

```
── past experience ──
- [YYYY-MM-DD | <slug>] <lesson title>: <one sentence — the actionable takeaway>
- [YYYY-MM-DD | <slug>] <lesson title>: <one sentence>
(omit entries with no useful overlap)
```

If no entries are relevant after reading them: print `NO RELEVANT PAST EXPERIENCE.`
