# Claude Skills

[Claude Code](https://claude.com/claude-code) skills built on one
[coding philosophy](https://github.com/e6a5/agents/blob/main/AGENTS.md): do one thing well,
favor simplicity, write for the next reader.

| Skill | What it does | Invoke |
|-------|--------------|--------|
| **devloop** | Full dev loop: branch → plan (gate) → implement → test → quality → cleanup & docs → review. Handles cross-repo work. | `/devloop <what to build>` |
| **philo** | Review code against the philosophy. Add `fix` for a guided fix loop. | `/philo [fix] [path]` |
| **clarify** | Ask the 2–3 most important questions about a request before any work begins. Called automatically by devloop; also usable standalone. | `/clarify <request>` |
| **learn** | Claude's institutional memory. Saves non-obvious lessons after completing work; recalls relevant past experience before planning. Called automatically by devloop. | `/learn` · `/learn recall <description>` |

## Install

A skill is a folder with a `SKILL.md`. Claude Code loads them from `~/.claude/skills/`
(personal, all projects) or `<repo>/.claude/skills/` (per project). No build step.

```bash
# from this directory
cp -R devloop philo clarify learn ~/.claude/skills/
```

Restart Claude Code and type `/` to see them. Works in the CLI, desktop app, and IDE
extensions.

## Across devices

Track this folder in git, then on each machine:

```bash
git clone <your-repo-url> ~/skills
ln -sfn ~/skills/devloop  ~/.claude/skills/devloop
ln -sfn ~/skills/philo    ~/.claude/skills/philo
ln -sfn ~/skills/clarify  ~/.claude/skills/clarify
ln -sfn ~/skills/learn    ~/.claude/skills/learn
```

`git pull` to update everywhere.

## Uninstall

```bash
rm -rf ~/.claude/skills/devloop ~/.claude/skills/philo ~/.claude/skills/clarify ~/.claude/skills/learn
```
