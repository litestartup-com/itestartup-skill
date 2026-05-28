# LiteStartup Skill

> Turn your AI coding editor into a SaaS publishing console — bind a git repo, write in markdown, ship to production with one prompt.

## What is this?

A skill package for AI editors (Claude Code, Codex, Cursor, Windsurf) that lets you publish content to [LiteStartup](https://litestartup.com) directly from your editor. No browser, no dashboard, no context switching.

## Features

- **Blog posts** — Write markdown, sync, get a live URL
- **Website pages** — Update your landing page without leaving the editor
- **Documentation** — Maintain docs alongside your code
- **Changelog** — Generate release notes from git history
- **Email** — Send newsletters to subscribers (no git needed)

## Quick Start

### 1. Install the skill

**Claude Code:**
```bash
git clone https://github.com/litestartup/litestartup-skill ~/.claude/skills/litestartup
```

**Windsurf:** Copy `adapters/windsurf/.windsurfrules` to your workspace root.

**Cursor:** Copy `adapters/cursor/.cursorrules` to your workspace root.

### 2. Create a content repo

```bash
mkdir my-site && cd my-site && git init
```

### 3. Bind to LiteStartup

In your AI editor:
```
> Bind this repo to my LiteStartup account
```

The AI will run `scripts/ls-bind.sh`, ask for your API key, and create `litestartup.yaml`.

### 4. Write and publish

```
> Write a blog post about my v0.2.0 release and publish it
```

Done. Live URL in 30 seconds.

## Repo Structure Convention

```
your-content-repo/
├── litestartup.yaml      ← Created by ls-bind.sh
├── website/*.md          ← Website pages
├── blog/*.md             ← Blog posts
├── docs/**/*.md          ← Documentation
└── changelog/*.md        ← Version changelogs
```

## Security

- API keys are **never** exposed to AI — scripts read from `~/.litestartup/credentials`
- All communication over HTTPS
- Scope-limited API keys (`system.publish` only)

## Requirements

- `git`, `curl`, `bash`
- A [LiteStartup](https://litestartup.com) account with an API key (scope: `system.publish`)
- A public GitHub/Gitee/GitLab repository

## License

MIT
