# LiteStartup Skill

> Publish blog, docs, website, and changelog directly from your AI-powered editor. Write content, run one prompt, go live in seconds.

## What is this?

A modular skill package for AI editors (Cursor, Claude Code, Codex, Windsurf) that lets you publish blog, docs, website, and changelog to https://yourdomain.com directly from your AI editor.

## Architecture

```
litestartup-skill/
├── SKILL.md                ← Entry point: capability router (AI reads this first)
├── capabilities/           ← How to perform actions
│   ├── bind.md            ← Bind repo to LiteStartup
│   ├── sync.md            ← Sync content to production
│   ├── email.md           ← Send emails/newsletters
│   └── status.md          ← Check sync status
├── specs/                  ← How to write content (format rules)
│   ├── docs.md            ← Documentation (Litestartup Docs markdown)
│   ├── blog.md            ← Blog posts (markdown)
│   ├── changelog.md       ← Release changelogs (markdown)
│   └── website.md         ← Website pages (HTML + Tailwind)
├── templates/              ← Ready-to-use starter files
│   ├── docs/              ← config.json, _nav.md, _sidebar.md, index.md, page.md
│   ├── website/           ← block-page.html, full-page.html
│   ├── blog-post.md
│   ├── changelog-entry.md
│   └── litestartup.yaml.example
├── scripts/                ← Bash scripts (handle API calls + auth)
│   ├── _lib.sh
│   ├── ls-bind.sh
│   ├── ls-sync.sh
│   ├── ls-status.sh
│   └── ls-send-email.sh
└── adapters/               ← Per-editor integration files
    ├── windsurf/.windsurfrules
    ├── cursor/litestartup.mdc
    ├── claude/CLAUDE.md
    └── codex/AGENTS.md
```

## Quick Start

### 1. Install

**Windsurf:** Copy `adapters/windsurf/.windsurfrules` to workspace root.

**Cursor:** Copy `adapters/cursor/litestartup.mdc` to `.cursor/rules/`.

**Claude Code:** Copy `adapters/claude/CLAUDE.md` to workspace root.

**Codex:** Place `adapters/codex/AGENTS.md` in workspace root.

### 2. Create your content repo

Create a new git repository for your content (e.g., `my-litestartup-content`).

### 3. Bind repo

In your AI editor: `> Bind my-litestartup-content repo to my LiteStartup account`

### 3. Publish

```
> Write a blog post about our v0.3.0 release and publish it
> Update the pricing page
> Add a Quick Start guide to docs
```

## Design Principles

1. **Modular** — Each capability/spec is a standalone file. Add new ones without bloating existing files.
2. **Router-based** — SKILL.md is a lightweight index. AI loads only what's needed per task.
3. **Agent-agnostic** — Core logic in SKILL.md + specs/ + capabilities/. Adapters translate to each editor's format.
4. **Spec-driven** — Content rules are precise, with tables and checklists — no ambiguity.
5. **Template-first** — Every content type has a ready-to-copy template file.

## Security

- API keys NEVER appear in AI conversation
- `~/.litestartup/credentials` is read only by scripts
- Scope-limited keys (`system.publish` only)

## Requirements

- `git`, `curl`, `bash`
- A [LiteStartup](https://litestartup.com) account with API key
- A public (not private) git repository (GitHub/GitLab/Gitee)

## License

MIT
