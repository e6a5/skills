# Claude Skills

> **Slash commands that extend Claude Code**

Type `/` to invoke. Built on one [coding philosophy](https://github.com/e6a5/agents/blob/main/AGENTS.md): do one thing well, favor simplicity, write for the next reader.

---

## Quick Start

```bash
/devloop add user authentication   # plan → implement → test → review
/philo fix                         # review and fix code against the philosophy
/clarify add user authentication   # surface key questions before any work begins
/learn                             # save lessons from the current session
```

---

## Skills

| Skill | What it does | Usage |
|-------|--------------|-------|
| **devloop** | Full dev loop: plan → implement → test → quality → review. Handles cross-repo work. | `/devloop <what to build>` |
| **philo** | Review code against the coding philosophy. Pass `fix` to apply fixes interactively. | `/philo [fix] [path]` |
| **clarify** | Surface the 2–3 key questions before any work begins. | `/clarify <request>` |
| **learn** | Save and recall non-obvious lessons across sessions. | `/learn` · `/learn recall <topic>` |

---

## Install

A skill is a folder with a `SKILL.md`. Claude Code loads them from `~/.claude/skills/` (all projects) or `<repo>/.claude/skills/` (one project). No build step.

```bash
# run from this directory
cp -R devloop philo clarify learn ~/.claude/skills/
```

Restart Claude Code, then type `/` to see them. Works in the CLI, desktop app, and IDE extensions.

---

## Sync across devices

Track this repo in git, then symlink on each machine:

```bash
git clone <your-repo-url> ~/skills
ln -sfn ~/skills/devloop  ~/.claude/skills/devloop
ln -sfn ~/skills/philo    ~/.claude/skills/philo
ln -sfn ~/skills/clarify  ~/.claude/skills/clarify
ln -sfn ~/skills/learn    ~/.claude/skills/learn
```

Run `git pull` to update everywhere.

---

## Uninstall

```bash
rm -rf ~/.claude/skills/devloop ~/.claude/skills/philo ~/.claude/skills/clarify ~/.claude/skills/learn
```
