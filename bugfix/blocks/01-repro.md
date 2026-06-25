---
block: repro
order: 1
needs: [branch]
mutates: none
gate-after: false
---

# REPRO — Reproduce the Bug

**Goal**: Trigger the bug reliably and capture the exact failure. Every subsequent block
depends on this — do not proceed if reproduction is not confirmed.

**Input**: Read `00-input.md` for the description and clarifications.

**Do:**

1. Derive reproduction steps from the clarifications. If the steps are vague, infer the
   most direct way to trigger the failure (e.g. run the relevant test, call the endpoint,
   execute the command).

2. Run the reproduction:
   ```bash
   # Examples:
   go test ./... -run TestFoo
   curl -X POST http://localhost:8080/api/auth/refresh ...
   python -m pytest tests/test_auth.py::test_refresh
   ```
   Capture the full error output (stack trace, wrong value, crash dump).

3. Reduce to a **minimal reproduction**: the smallest test, command, or input that
   reliably triggers the bug.

4. **Design the regression test (the "red").** This block must not write source — the
   plan gate comes first — so here you only *design* it: name the test file and the case,
   and state the assertion that should hold once fixed (so it would fail on today's code,
   for the right reason). The `fix` block writes it first (confirms red), then makes the
   fix turn it green; `verify` runs it. This test is the permanent guard against the bug
   returning.
   - If an automated test genuinely isn't feasible (UI rendering, infra-dependent, timing),
     record a minimal manual command instead and say why a test wasn't written.

5. If you cannot trigger the bug after a reasonable attempt (different env, flags,
   data), stop here and use **AskUserQuestion** to ask for more specific steps before
   proceeding. Do not guess at a fix without a confirmed reproduction.

## Output — `.devloop/<slug>/01-repro.md`

```markdown
## Steps to reproduce
1. <step>
2. <step>

## Observed behavior
```
<exact error output, wrong value, or description of incorrect behavior>
```

## Expected behavior
<what should happen instead>

## Planned regression test (red)
- location: `<test file>::<test name>`  |  none — <why a test isn't feasible>
- asserts: <the expected behavior the test will check>
- run with: `<command that will run just this test>`

## Minimal reproduction
```bash
<command, endpoint call, or script that triggers the bug on today's code>
```

## Reproduction: CONFIRMED | COULD NOT REPRODUCE
<if COULD NOT REPRODUCE — what was tried and why it didn't work>
```

Print: `[2/7] REPRO done`
