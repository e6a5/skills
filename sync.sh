#!/usr/bin/env bash
# Sync this repo's skills into ~/.claude/skills/.
# Pulls latest, then copies every skill folder (one with a SKILL.md).
# Copies, not symlinks — Claude Code doesn't follow symlinked skill dirs.
# Set CLAUDE_SKILLS_DIR to install somewhere else.
set -euo pipefail
cd "$(dirname "$0")"

dest="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
git pull --ff-only || true
mkdir -p "$dest"

for skill in */SKILL.md; do
  name="$(dirname "$skill")"
  rsync -a --delete "$name/" "$dest/$name/"
  echo "✓ $name"
done

echo "Done → $dest. Restart Claude Code to pick up changes."
