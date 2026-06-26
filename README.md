# Claude Skills

> **Slash commands that extend Claude Code**

Type `/` to invoke. Built on one [coding philosophy](https://github.com/e6a5/agents/blob/main/AGENTS.md): do one thing well, favor simplicity, write for the next reader.

---

## Quick Start

```bash
/ideate tools for indie game devs  # diverge → converge → sharpen → pick a direction
/devloop add user authentication   # plan → implement → test → review
/bugfix JWT refresh crashes         # reproduce → investigate → fix → verify
/philo fix                         # review and fix code against the philosophy
/clarify add user authentication   # surface key questions before any work begins
/learn                             # save lessons from the current session
```

---

## Skills

| Skill | What it does | Usage |
|-------|--------------|-------|
| **ideate** | Fuzzy front end before building: diverge → converge → sharpen → pick one direction with its riskiest assumption and cheapest test. Hands off to devloop. | `/ideate <problem, domain, or rough idea>` |
| **devloop** | Full dev loop: plan → implement → test → quality → review. Handles cross-repo work. | `/devloop <what to build>` |
| **bugfix** | Bug fix loop: reproduce → investigate (reads devloop artifacts for context) → plan → fix → verify → review. | `/bugfix <describe the bug>` |
| **philo** | Review code against the coding philosophy. Pass `fix` to apply fixes interactively. | `/philo [fix] [path]` |
| **clarify** | Surface the 2–3 key questions before any work begins. | `/clarify <request>` |
| **learn** | Save and recall non-obvious lessons across sessions. | `/learn` · `/learn recall <topic>` |

---

> **Dependency:** `devloop` and `bugfix` call `/clarify` (setup) and `/learn` (recall + save); `ideate` hands off to `/devloop` and calls `/learn`. Install them all together — the commands below do — or those steps will be skipped/fail.

## Install & sync

A skill is a folder with a `SKILL.md`. Claude Code loads them from `~/.claude/skills/` (all projects) or `<repo>/.claude/skills/` (one project). No build step.

Use **`sync.sh`** — it pulls the latest commits, then copies every skill folder into `~/.claude/skills/`:

```bash
git clone <your-repo-url> ~/skills && cd ~/skills
./sync.sh        # pull latest, then copy all skills
```

Re-run `./sync.sh` any time to pick up updates (set `CLAUDE_SKILLS_DIR` to install elsewhere). Then restart Claude Code and type `/` to see the skills. Works in the CLI, desktop app, and IDE extensions.

Copies, not symlinks: Claude Code's skill discovery doesn't reliably follow symlinked directories. Each skill is mirrored into its own subfolder, so your other skills are never touched. (Deleting a skill from the repo won't auto-uninstall it — `rm -rf ~/.claude/skills/<name>` to remove.)

---

## Uninstall

```bash
rm -rf ~/.claude/skills/ideate ~/.claude/skills/devloop ~/.claude/skills/bugfix ~/.claude/skills/philo ~/.claude/skills/clarify ~/.claude/skills/learn
```
