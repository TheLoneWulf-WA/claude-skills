#!/bin/bash

# Install a specific skill from this repo
# Usage: curl -sL https://raw.githubusercontent.com/TheLoneWulf-WA/claude-skills/main/install.sh | bash -s <skill-name>

set -e

SKILL_NAME=$1
REPO="TheLoneWulf-WA/claude-skills"
BRANCH="main"
SKILLS_DIR="$HOME/.claude/skills"

# Check if skill name was provided
if [ -z "$SKILL_NAME" ]; then
  echo "Usage: curl -sL https://raw.githubusercontent.com/$REPO/$BRANCH/install.sh | bash -s <skill-name>"
  echo ""
  echo "Available skills:"
  echo "  - contextual-placeholders"
  echo "  - solana-dev"
  exit 1
fi

# Create the skill directory
mkdir -p "$SKILLS_DIR/$SKILL_NAME"

# Download the SKILL.md
echo "Installing $SKILL_NAME..."
curl -sL "https://raw.githubusercontent.com/$REPO/$BRANCH/$SKILL_NAME/SKILL.md" \
  -o "$SKILLS_DIR/$SKILL_NAME/SKILL.md"

# Verify the download worked
if [ -s "$SKILLS_DIR/$SKILL_NAME/SKILL.md" ]; then
  echo "Installed $SKILL_NAME to $SKILLS_DIR/$SKILL_NAME"
else
  echo "Error: Failed to download $SKILL_NAME. Check the skill name and try again."
  rm -rf "$SKILLS_DIR/$SKILL_NAME"
  exit 1
fi
