---
name: ideate
description: The fuzzy front end before devloop. Turn a vague spark — a problem, a domain, or a half-formed idea — into a validated product direction worth building. Diverge (generate many distinct ideas) → Converge (cluster and score honestly) → Sharpen (one-page brief for the top pick) → Decide (name the riskiest assumption and its cheapest test, then hand off to /devloop). Takes a free-form prompt and produces a concrete direction, not a pile of options.
argument-hint: <a problem, a domain, or a rough idea>
allowed-tools: Read Write Bash Grep AskUserQuestion Skill WebSearch WebFetch
---

## What this is

`ideate` is the step *before* `devloop`. devloop assumes you know what to build; `ideate`
finds the thing worth building. It takes a spark — a problem, a market, a domain, or a
half-formed "wouldn't it be cool if…" — and runs it through four phases:

```
FRAME → DIVERGE → CONVERGE → SHARPEN → DECIDE → (hand off to /devloop)
```

The output is **one chosen direction** with its riskiest assumption named and the cheapest
test to de-risk it — not a tidy list of ten options you still have to choose between.
Choosing is the job.

---

## Operating principles

1. **Diverge before you converge.** During DIVERGE, do not judge, filter, or rank. Mixing
   the two kills the weird ideas, and the weird ideas are the point. Judgment starts in
   CONVERGE, not before.
2. **Quantity is a feature.** A divergence with three ideas is a failure of imagination.
   Push for breadth across genuinely different *kinds* of solutions, not three flavors of
   the same one.
3. **Anchor to a person and a job, never a feature.** Every idea answers "who is stuck, on
   what, and what do they do today instead?" An idea that starts with a technology or a
   feature is a solution hunting for a problem — flag it.
4. **Score honestly; kill your darlings.** The most exciting idea and the best idea are
   often not the same. Use the rubric, write the real numbers, and let a boring winner win.
5. **The deliverable is a decision, not a menu.** End with one direction. If the user must
   pick between two, you haven't converged — score harder or ask.
6. **The goal isn't to build — it's to find the cheapest way to be proven wrong.** Ideation
   ends at the riskiest assumption and a test for it, not at a build plan. Building is
   `devloop`'s job, and only after the assumption survives.
7. **Terse artifacts.** Bullets, not prose. No preamble, no restating the prompt.

---

## Setup (run once)

1. If `$ARGUMENTS` is empty, use **AskUserQuestion** to ask *"What's the spark — a problem,
   a domain, or a rough idea?"* Wait for the answer.
   - **Right skill?** `ideate` is for *deciding what to build*. If the user already knows
     what they want to build and just wants it built, say so in one line and point them to
     `/devloop`. Proceed with `ideate` only if the direction is genuinely open.
2. Derive a kebab-case slug from the spark (max 40 chars, e.g. `"tools for indie game devs"`
   → `tools-indie-game-devs`).
3. `mkdir -p .ideate` and write the running session file `.ideate/<slug>.md` with a
   `# Ideate: <slug>` heading and the verbatim spark under `## Spark`.
4. Print: `── ideate: <slug> ──` and begin at FRAME.

Append each phase's output to `.ideate/<slug>.md` as you go, so the session is resumable and
the brief is ready to hand to `/devloop`.

---

## Phase 1 — FRAME

**Goal:** turn the spark into a sharp problem statement before generating anything.

Pin down, in at most a few bullets each:

- **Who** — the specific person or segment who feels this. "Everyone" is not an answer.
- **Pain / job** — what are they trying to get done, and what makes it hard or annoying
  today? What do they do *instead* right now (the real competitor — often a spreadsheet,
  a manual workaround, or nothing)?
- **Why now** — what changed (tech, cost, regulation, behavior, a new platform) that makes
  this worth doing today and not five years ago? If nothing changed, note that — it's a risk.
- **Constraints & intent** — solo/small build vs. funded? Time horizon? Any hard
  boundaries (platform, budget, must-use stack, ethical lines)? Is the user optimizing for
  a business, a side project, a learning exercise, or fun? This calibrates DIVERGE.

Ask the **1–2 highest-leverage questions only** via AskUserQuestion if the spark leaves a
gap that would send DIVERGE in the wrong direction (e.g. unknown audience or unknown
intent). Otherwise infer and state your assumptions in one line. Don't interrogate — this
is not `/clarify`.

**Output** → append `## Frame` with the bullets above.

Print: `[1/5] FRAME done`

---

## Phase 2 — DIVERGE

**Goal:** generate many genuinely different ideas. No judging.

Optionally run **WebSearch** for signal on the space (existing players, recent shifts,
what's underserved). Use it to find *gaps and adjacencies*, not to copy what exists. Cite
nothing into the ideas — let it inform breadth.

Generate **8–12 distinct ideas**. To force real breadth rather than variations on one
theme, push each idea through a different **lens** — use several of these, don't settle:

- **Jobs-to-be-done** — solve the core job in the most direct possible way.
- **Unbundle** — take one feature of an existing bloated product and do only that, better.
- **Rebundle** — combine two things the user currently juggles into one.
- **Invert** — do the opposite of the industry default (e.g. async instead of real-time,
  manual-curated instead of algorithmic, local-first instead of cloud).
- **Remove a constraint** — "what if cost / setup time / expertise required were zero?"
- **Steal from an adjacent domain** — how does a different industry solve this shape of
  problem, and what transfers?
- **Ride the "why now"** — an idea that only became possible because of the recent shift
  you named in FRAME.
- **10x not 10%** — what would make this dramatically better, not incrementally?

For each idea, one line: **`<name>` — for <who>, <what it does> so they can <job done>.**
That format forces a person and a job into every idea (principle 3).

**Output** → append `## Ideas` as a numbered list of one-liners. Do **not** rank yet.

Print: `[2/5] DIVERGE done — <n> ideas`

---

## Phase 3 — CONVERGE

**Goal:** cluster, then score honestly, and pick a shortlist.

1. **Cluster** the ideas into 2–4 themes; drop near-duplicates (note them as merged).
2. **Score** each surviving idea 1–5 on this rubric, then sum:

   | Criterion | 1 = | 5 = |
   |-----------|-----|-----|
   | **Desirability** | nobody asked for this | people are actively hurting for it |
   | **Feasibility** | needs a breakthrough | buildable now with known tools |
   | **Differentiation** | crowded, me-too | clearly distinct / hard to copy |
   | **Viability** | no path to value/revenue | obvious way it sustains itself |
   | **Fit** | wrong for stated constraints | perfect for who's building & their intent |

   Write the *real* numbers in a table. The point is to surface where a thrilling idea
   scores a 2 on Feasibility or Viability — that's the honest signal (principle 4).

3. Take the **top 1–3** by total. If there's a clear single winner, say so and carry one
   forward. If 2–3 are close, carry them to SHARPEN and let the briefs break the tie.

**Output** → append `## Shortlist` with the scoring table and the 1–3 carried forward, each
with a one-line rationale for surviving.

Print: `[3/5] CONVERGE done`

---

## Phase 4 — SHARPEN

**Goal:** write a one-page brief for each shortlisted idea — enough to commit or kill.

For each (≤1 page, bullets):

```markdown
### <idea name>
- **One-liner** — for <who>, <what> so they can <job>.
- **Problem** — the pain, and what they do today instead.
- **Target user** — the beachhead: the narrowest group who'd use it first.
- **Value proposition** — why this over the status quo, in one sentence.
- **MVP scope** — the smallest thing that delivers the core value. List what's IN; list a
  few tempting things explicitly OUT.
- **Riskiest assumption** — the one belief that, if false, sinks the whole idea
  (usually demand, not feasibility). State it as a falsifiable claim.
- **Cheapest test** — the fastest, smallest way to find out if that assumption holds
  *before* building the MVP (landing page, 5 user conversations, a manual/concierge
  version, a fake-door, a prototype). Days, not months.
```

If 2–3 were carried, end with a one-line **recommendation** of which to pursue and why.

**Output** → append `## Brief(s)`.

Print: `[4/5] SHARPEN done`

---

## Phase 5 — DECIDE

**Goal:** land on one direction and set up the next step.

1. State **the chosen direction** in 2–3 lines: what it is, who it's for, and the single
   riskiest assumption with its cheapest test.
2. Use **AskUserQuestion** to offer the next move:
   - **Validate first** — go run the cheapest test (the recommended default when the
     riskiest assumption is about *demand*). Ideation's job is done; building is premature.
   - **Build the MVP** — hand the MVP scope to `/devloop` to plan and build (appropriate
     when the assumption is feasibility and the demand is already evidenced).
   - **Diverge again** — nothing's compelling; re-run DIVERGE with a tighter or different
     FRAME.
3. If the user chooses **Build the MVP**, invoke `/devloop` with the chosen idea's
   one-liner + MVP scope as the input.

---

## Done

Print:

```
── ideate complete: <slug> ──

Chosen direction: <one line>
Riskiest assumption: <falsifiable claim>
Cheapest test: <the test> (<timeframe>)

Session: .ideate/<slug>.md

Next: <validate | /devloop the MVP | diverge again>
```

Then run `/learn` to capture any non-obvious lessons (a lens that worked, a market
insight, a dead end worth not revisiting).
