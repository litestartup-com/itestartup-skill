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

### 1. Create a public git repo

Create a new public repository on GitHub/GitLab/Gitee for your content.

### 2. Install Litestartup Skill

Clone this repo and copy the adapter file for your editor:

| Editor | Copy from | Copy to |
|--------|-----------|----------|
| Windsurf | `adapters/windsurf/.windsurfrules` | `.windsurfrules` (workspace root) |
| Cursor | `adapters/cursor/litestartup.mdc` | `.cursor/rules/litestartup.mdc` |
| Claude Code | `adapters/claude/CLAUDE.md` | `CLAUDE.md` (workspace root) |
| Codex | `adapters/codex/AGENTS.md` | `AGENTS.md` (workspace root) |

### 3. Get API Key

Log in to [LiteStartup Dashboard](https://app.litestartup.com) → Settings → API Keys → Create with `system.publish` scope (add `notification` / `email` scope if you need to send emails).

### 4. Bind repo

In your AI editor:

```
> Bind this repo to my LiteStartup account.
```

### 5. Initialize content

```
> Initialize this content repo for my project. Create a homepage, a blog post, and a quickstart doc.
```

### 6. Sync and publish

```
> Sync all my content to production.
```

### 7. Ongoing workflow

Keep your content up to date alongside your code:

```
> Our pricing changed to $12/mo. Update the pricing page and write a changelog entry.
> Write a blog post about our new API v2 release. Then sync it.
> Send a notification email about the new feature.
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

## Links

- **Website**: https://www.litestartup.com/products/litestartup-skill
- **Documentation**: https://www.litestartup.com/docs/en/features/litestartup-skill
- **Support**: support@litestartup.com
- **GitHub**: https://github.com/litestartup-com/litestartup-skill

## License

MIT
