# claude-skills

A collection of custom skills for [Claude Code](https://docs.anthropic.com/en/docs/claude-code).

## What are Claude Code Skills?

Skills are reusable instructions that extend Claude's behavior. They can be always-on (automatically applied) or invoked manually. Each skill lives in its own folder with a `SKILL.md` file containing the instructions.

## Available Skills

| Skill | Description |
|-------|-------------|
| [contextual-placeholders](./contextual-placeholders/) | Automatically use contextual placeholder images from Unsplash, Picsum, and other services instead of gray boxes when building UI components |

## Installation

To use a skill, symlink its folder to your Claude Code skills directory:

```bash
# Create the skills directory if it doesn't exist
mkdir -p ~/.claude/skills

# Symlink the skill you want to use
ln -s /path/to/claude-skills/contextual-placeholders ~/.claude/skills/contextual-placeholders
```

For example, if you cloned this repo to `~/Developer/personal/claude-skills`:

```bash
ln -s ~/Developer/personal/claude-skills/contextual-placeholders ~/.claude/skills/contextual-placeholders
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
