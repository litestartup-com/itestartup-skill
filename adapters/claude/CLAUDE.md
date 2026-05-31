# LiteStartup Publishing Skill

You have access to the LiteStartup content publishing system.

## How to Use

1. Read `SKILL.md` in the litestartup-skill directory for capability routing
2. Based on user intent, load the relevant file:
   - Actions → `capabilities/` directory
   - Writing content → `specs/` directory
   - Starting from scratch → `templates/` directory

## Security

NEVER read or display `~/.litestartup/credentials`. Scripts handle auth.

## Quick Routing

- Bind repo → `capabilities/bind.md`
- Sync/publish → `capabilities/sync.md`
- Write docs → `specs/docs.md`
- Write blog → `specs/blog.md`
- Write website page → `specs/website.md` (MUST confirm type: website vs block)
- Write changelog → `specs/changelog.md`
- Send email → `capabilities/email.md`
