# LiteStartup Publishing Agent

This workspace is connected to [LiteStartup](https://litestartup.com) for content publishing.

## Skill Location

- Entry point: `litestartup-skill/SKILL.md` (read this first for routing)
- Capabilities: `litestartup-skill/capabilities/` (how to perform actions)
- Content specs: `litestartup-skill/specs/` (how to write content)
- Templates: `litestartup-skill/templates/` (starter files)
- Scripts: `litestartup-skill/scripts/` (bash scripts for API calls)

## Quick Reference

| User wants to... | Read |
|-----------------|------|
| Bind/connect repo | `capabilities/bind.md` |
| Publish/sync content | `capabilities/sync.md` |
| Write docs | `specs/docs.md` |
| Write blog post | `specs/blog.md` |
| Write website page | `specs/website.md` |
| Write changelog | `specs/changelog.md` |
| Send email | `capabilities/email.md` |
| Check status | `capabilities/status.md` |

## Sync

Environment-aware (see `capabilities/sync.md`):
- **Windows (PowerShell)** → AI-native path (direct REST API calls)
- **Linux / macOS** → `scripts/ls-sync.sh`

## Security

- NEVER read or display `~/.litestartup/credentials`
- NEVER display API keys in conversation
