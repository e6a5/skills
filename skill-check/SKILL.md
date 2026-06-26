---
name: skill-check
description: Validate a skill before committing it — is it valuable or slop? Runs a 5-point rubric (differential value, non-obvious content, trigger precision, no overlap, mechanically sound), prescribes the A/B prompts that prove it changes behavior, and returns PASS / NEEDS-WORK / SLOP. Read-only. Use before adding or updating any skill so the library grows by value, not by accretion.
argument-hint: [path-to-skill-dir]  (no args = check new/changed skills in the current git diff)
allowed-tools: Read Bash Grep Glob
---

## What this is

A gate for the skills library. Every installed skill is context that gets loaded and a
`description` that competes for trigger attention, so **a bad skill costs more than no
skill** — it fires at the wrong time or burns tokens without changing what Claude does.
This skill decides whether a candidate earns its place.

The verdict is one of:

- **PASS** — earns its place; commit it.
- **NEEDS-WORK** — valuable core, fixable defects; lists them.
- **SLOP** — encodes what Claude already does, or duplicates another skill; cut or rethink.

Read-only. It judges and prescribes; it never edits the skill.

---

## The one test that matters: differential value

A skill is valuable **only if Claude behaves meaningfully better with it than without it on
the same prompt.** If the output is the same either way, the skill is encoding what Claude
already does — that is the definition of slop, regardless of how polished it reads.

This is the single hardest check to fake and the one most often skipped, so it is **Step 4**
and it can block a PASS on its own.

---

## Step 1 — Resolve target(s)

Parse `$ARGUMENTS`:

- If it names a directory (or a `SKILL.md` path), that is the target.
- If empty, find skills that are new or changed in the working tree and check each.

!`
ARG="${ARGUMENTS}"
resolve() {  # echoes the SKILL.md path for a dir-or-file arg
  if [ -f "$1" ]; then echo "$1"
  elif [ -f "$1/SKILL.md" ]; then echo "$1/SKILL.md"
  fi
}
if [ -n "$ARG" ]; then
  P="$(resolve "$ARG")"
  [ -n "$P" ] && echo "TARGET: $P" || echo "NOT-FOUND: $ARG (no SKILL.md there)"
else
  echo "No path given — scanning git for new/changed SKILL.md files:"
  { git status --porcelain 2>/dev/null | grep -E 'SKILL\.md' ;
    # untracked skill dirs (e.g. ?? ideate/) — surface their SKILL.md
    git status --porcelain 2>/dev/null | grep -E '^\?\? ' | awk '{print $2}' \
      | while read -r d; do [ -f "${d}SKILL.md" ] && echo "?? ${d}SKILL.md"; done ; } \
    | awk '{print $NF}' | sort -u
  echo "(pass a path to check one specifically)"
fi
`

If nothing resolves, say so and stop. Otherwise run Steps 2–6 **per target**.

---

## Step 2 — Gather the mechanical facts (per target)

Replace `SKILL_PATH` below with the target path. This dumps everything the automatable
checks need: frontmatter fields, name/folder agreement, description length, the sibling
skills it references (and whether they exist), block-file references, and embedded shell.

!`
SKILL_PATH="REPLACE_ME"   # ← set to the target from Step 1
DIR="$(dirname "$SKILL_PATH")"
echo "── $SKILL_PATH ──"

echo; echo "[frontmatter]"
awk 'NR==1&&$0=="---"{f=1;next} f&&$0=="---"{exit} f{print}' "$SKILL_PATH"

echo; echo "[name vs folder]"
NAME=$(awk -F': *' '/^name:/{print $2; exit}' "$SKILL_PATH")
FOLDER=$(basename "$DIR")
echo "name=$NAME folder=$FOLDER  $([ "$NAME" = "$FOLDER" ] && echo OK || echo 'MISMATCH')"

echo; echo "[required frontmatter keys]"
for k in name description argument-hint allowed-tools; do
  grep -q "^$k:" "$SKILL_PATH" && echo "  $k: present" || echo "  $k: MISSING"
done

echo; echo "[description length]"
DESC=$(awk -F': *' '/^description:/{ $1=""; print substr($0,2); exit}' "$SKILL_PATH")
WC=$(printf '%s' "$DESC" | wc -w | tr -d ' ')
echo "  $WC words  $([ "$WC" -gt 60 ] && echo '(LONG — competes for trigger attention; tighten)' || ([ "$WC" -lt 8 ] && echo '(THIN — may never trigger)' || echo OK))"

echo; echo "[skill references — only backtick-wrapped /name invocations]"
# The house convention is `/name` in backticks; match only those to avoid catching
# prose ("manual/concierge") and paths ("/tmp"). Known Claude Code built-ins are OK.
ROOT="$(cd "$DIR/.." && pwd)"
BUILTINS=" code-review simplify commit clarify learn verify run init review security-review loop schedule "
grep -oE '`/[a-z][a-z0-9-]+`' "$SKILL_PATH" | tr -d '`' | sort -u | while read -r ref; do
  n=${ref#/}; [ "$n" = "$FOLDER" ] && continue
  if [ -d "$ROOT/$n" ] || [ -d "$HOME/.claude/skills/$n" ]; then echo "  $ref → repo skill OK"
  elif printf '%s' "$BUILTINS" | grep -q " $n "; then echo "  $ref → built-in OK"
  else echo "  $ref → NO SUCH SKILL (broken ref — verify)"; fi
done

echo; echo "[block-file references]"
grep -oE 'blocks/[A-Za-z0-9._-]+\.md' "$SKILL_PATH" | sort -u | while read -r b; do
  [ -f "$DIR/$b" ] && echo "  $b OK" || echo "  $b MISSING"
done
[ -d "$DIR/blocks" ] && echo "  (blocks/ dir present: $(ls "$DIR/blocks" | wc -l | tr -d ' ') files)"

echo; echo "[embedded shell — syntax-check fenced bash blocks]"
awk '/^```bash$/{f=1;next} /^```$/{f=0} f' "$SKILL_PATH" > /tmp/_sc_bash.$$ 2>/dev/null
if [ -s /tmp/_sc_bash.$$ ]; then bash -n /tmp/_sc_bash.$$ && echo "  fenced bash: syntax OK" || echo "  fenced bash: SYNTAX ERROR ↑"; else echo "  (no fenced bash blocks)"; fi
grep -qE '^!`' "$SKILL_PATH" && echo "  note: has !\`…\` inline-exec block(s) — eyeball these by hand (not syntax-checked here)"
rm -f /tmp/_sc_bash.$$
`

Also gather sibling descriptions for the overlap check in Step 3:

!`ROOT="$(cd "$(dirname REPLACE_ME)/.." && pwd)"; for d in "$ROOT"/*/; do printf '%s: ' "$(basename "$d")"; awk -F': *' '/^description:/{ $1=""; print substr($0,2); exit}' "$d/SKILL.md" 2>/dev/null; done`

---

## Step 3 — Score the rubric (read the SKILL.md, then judge)

Read the target's `SKILL.md` in full. Score each point **PASS / WEAK / FAIL** with a
one-line reason that quotes the skill where possible. Use the Step 2 facts for 3 and 5.

1. **Non-obvious content** — Does it encode a specific gate, sequence, severity rubric,
   convention, or domain fact? Or is it "write clean code / be thorough" wrapped in
   ceremony? Generic exhortation Claude already follows → FAIL.
2. **Trigger precision** — Does the `description` name concrete triggers and a clear
   boundary, without colliding with another skill's? Vague (never fires) or sprawling
   (over-fires, bloats context) → WEAK/FAIL. Use the length read from Step 2.
3. **No overlap** — Compare its job against every sibling description (gathered above). If
   another skill — or a Claude Code built-in like `/code-review`, `/simplify` — already owns
   this job, that duplication is itself slop. Owning one distinct job → PASS.
4. **Mechanically sound** — From Step 2: frontmatter complete, name==folder, every `/skill`
   and `blocks/*.md` reference resolves, fenced bash passes `bash -n`, inline `!`…` blocks
   eyeballed. Any MISSING/MISMATCH/SYNTAX ERROR/broken ref → FAIL until fixed.

(Differential value is scored separately in Step 4.)

---

## Step 4 — Differential value: prescribe the A/B test

You cannot certify a PASS from reading alone — confirm the skill changes behavior.

1. Derive **2–3 concrete prompts** that *should* trigger this skill, straight from its
   `description` and `argument-hint` (realistic, not toy).
2. For each, **state in one or two lines what Claude's *default* behavior would be** without
   the skill — be concrete and honest, do not strawman the baseline.
3. Name **what the skill adds on top** — the specific anti-default behavior (a gate, an
   ordering, a rubric, a refusal) that the baseline lacks.
4. Render the verdict:
   - If the skill's additions are real anti-defaults → **differential: PASS**.
   - If the baseline already produces substantially the same output → **differential: FAIL
     → SLOP**, no matter how polished the prose.
   - If you genuinely cannot tell from reasoning → **differential: UNPROVEN**; output the
     exact prompts for the user to run both ways, and withhold a PASS until they do.

Present the prompts so the user can actually run them:

```
A/B test — run each WITH the skill and WITHOUT it, compare:
  1. <prompt>   default: <what plain Claude does>   skill adds: <the anti-default>
  2. ...
```

---

## Step 5 — Verdict (per target)

Combine. The differential result and any Step-4-FAIL or mechanical-FAIL gate the outcome:

- **SLOP** — differential FAIL, or duplicates an existing skill. Recommend cut or rethink;
  name what it would have to encode to stop being slop.
- **NEEDS-WORK** — differential PASS/UNPROVEN but one or more points are WEAK/FAIL. List
  each defect as a concrete, ordered fix.
- **PASS** — differential PASS and points 1–4 all PASS (minor WEAKs allowed if named).

```
── skill-check: <name> ──

Differential:  PASS | FAIL | UNPROVEN — <one line>
1 Non-obvious: PASS|WEAK|FAIL — <reason>
2 Trigger:     PASS|WEAK|FAIL — <reason>
3 No overlap:  PASS|WEAK|FAIL — <reason>
4 Mechanical:  PASS|WEAK|FAIL — <reason>

VERDICT: PASS | NEEDS-WORK | SLOP
Fixes (if any):
  1. <concrete fix>
A/B to run: <the prompts from Step 4, if UNPROVEN>
```

Do not edit the skill. If the verdict is NEEDS-WORK, the fixes are the user's to apply (or
to ask you to apply outside this read-only skill).

---

## Step 6 — Multiple targets

If Step 1 found several, repeat Steps 2–5 for each and end with a one-line roll-up:
`<name>: PASS · <name>: NEEDS-WORK · <name>: SLOP`.
