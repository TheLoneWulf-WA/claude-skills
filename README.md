# claude-skills

A collection of custom skills for [Claude Code](https://docs.anthropic.com/en/docs/claude-code).

## What are Claude Code Skills?

Skills are reusable instructions that extend Claude's behavior. They can be always-on (automatically applied) or invoked manually. Each skill lives in its own folder with a `SKILL.md` file containing the instructions.

## Available Skills

| Skill | Description |
|-------|-------------|
| [contextual-placeholders](./contextual-placeholders/) | Automatically use contextual placeholder images from Unsplash, Picsum, and other services instead of solid color boxes when building UI components |

## Installation

### Quick Install (via OpenSkills)

```bash
npx openskills install TheLoneWulf-WA/claude-skills
npx openskills sync
```

This installs all skills from this repo to `~/.claude/skills/`.

### Manual Install

Clone the repo and symlink the skill you want:

```bash
git clone https://github.com/TheLoneWulf-WA/claude-skills.git
mkdir -p ~/.claude/skills
ln -s /path/to/claude-skills/contextual-placeholders ~/.claude/skills/contextual-placeholders
```

## Creating Your Own Skills

Each skill is a folder containing a `SKILL.md` file with this format:

```markdown
---
name: skill-name
description: What the skill does and when to use it (max 1024 chars)
---

# Skill Title

[Instructions for Claude go here]
```

**Name requirements:**
- Lowercase letters, numbers, and hyphens only
- Maximum 64 characters
- Cannot contain "anthropic" or "claude"

**Description requirements:**
- Maximum 1024 characters
- Should explain what it does AND when to use it

## License

MIT
