---
name: litestartup
description: |
  Publish blog posts, website pages, online docs, changelogs and send emails
  through LiteStartup (https://litestartup.com) using your local git repo
  as the source of truth. Designed for indie makers who want to update their
  SaaS public content without leaving the AI editor.
trigger_keywords:
  - "ls publish" / "publish to litestartup"
  - "ls sync" / "sync to litestartup"
  - "ls bind" / "bind to litestartup"
  - "ls send" / "send via litestartup"
  - "update changelog" / "update docs"
  - "deploy blog post" / "update website"
version: 0.2.0
---

# LiteStartup Skill

## Overview

You can help the user manage LiteStartup resources via this skill.
LiteStartup turns markdown files in a git repo into live web content:
blog posts, website pages, online docs, and changelogs.

## Security Model

**CRITICAL: API keys MUST NEVER appear in conversation context.**

- Keys are stored in `~/.litestartup/credentials` (one line, the raw key)
- Scripts read the key file directly; you ONLY invoke the script
- NEVER run `cat ~/.litestartup/credentials` or display key values
- If authentication fails, instruct user to re-run `scripts/ls-bind.sh`

## Prerequisites

Before any action, check for `litestartup.yaml` in the workspace.
If found → that directory is the LS content repo.
If missing → guide user through binding first.

## Capabilities

### 1. Bind repo (`scripts/ls-bind.sh`)

Trigger: user says "bind to litestartup" or no `litestartup.yaml` exists.
Steps:
  1. Ask user to paste their LS API key (scope: system.publish)
  2. Run `scripts/ls-bind.sh`
  3. Script saves key to `~/.litestartup/credentials`
  4. Script calls `POST /client/v2/repo-sync/bind` with repo URL
  5. Creates `litestartup.yaml` in repo root

### 2. Sync content (`scripts/ls-sync.sh`)

Trigger: user says "publish", "sync", "deploy", or after writing content.
Steps:
  1. Locate the directory containing `litestartup.yaml`
  2. Validate frontmatter of changed .md files
  3. `cd <content-repo> && git add -A && git commit -m "<msg>" && git push`
  4. Run `scripts/ls-sync.sh`
  5. Script calls `POST /client/v2/repo-sync/trigger`
  6. Report results (inserted/updated/skipped/conflicts)

### 3. Generate content from code repo

Trigger: user says "update changelog", "write blog about release"
Steps:
  1. Read git log from the CODE repo (not the content repo)
  2. Generate changelog/blog markdown with proper frontmatter
  3. Write to the CONTENT repo under the appropriate directory
  4. Run sync (Capability 2)

### 4. Send email (`scripts/ls-send-email.sh`)

Trigger: user says "send email", "send newsletter"
Steps:
  1. Compose email content (NOT saved to git)
  2. Ask user to confirm recipient/subject
  3. Run `scripts/ls-send-email.sh`
  4. Script calls `POST /client/v2/emails` or `/newsletters/send`

### 5. Check status (`scripts/ls-status.sh`)

Trigger: user asks "what's synced?" or "ls status"
Steps:
  1. Run `scripts/ls-status.sh`
  2. Display binding info, last sync time, sync count

---

## Content Repo Structure

```
<content-repo>/
├── litestartup.yaml          ← REQUIRED (binding config)
├── blog/*.md                 ← Blog posts (markdown → HTML by server)
├── website/*.html            ← Website pages (raw HTML with Tailwind)
├── changelog/*.md            ← Version changelogs (markdown → HTML by server)
└── docs/                     ← Documentation (LiteDocs format, markdown)
    ├── config.json           ← Docs site configuration
    ├── en/                   ← Default language directory
    │   ├── _nav.md           ← Top navigation tabs
    │   ├── _sidebar.md       ← Left sidebar menu
    │   ├── index.md          ← Docs home page
    │   ├── guide/            ← Section directory
    │   │   ├── _sidebar.md   ← Section-specific sidebar (overrides parent)
    │   │   ├── index.md      ← Section index
    │   │   └── quick-start.md
    │   └── api/
    │       └── ...
    └── zh/                   ← Additional language (optional)
        ├── _nav.md
        ├── _sidebar.md
        └── index.md
```

---

## Docs Writing Rules (IMPORTANT — follow exactly)

### docs/config.json (required)

```json
{
  "site": {
    "title": "My Docs",
    "description": "Documentation for My SaaS"
  },
  "locales": {
    "default": "en",
    "available": ["en"]
  },
  "theme": {
    "primary_color": "#3b82f6",
    "dark_mode": true
  },
  "footer": {
    "copyright": "© 2026 My Company"
  }
}
```

### docs/{lang}/_nav.md (top navigation tabs)

Each line is a tab. Active tab is auto-detected by URL prefix match.
Clicking a tab loads its section and the section's `_sidebar.md`.

```markdown
- [Guide](index.md)
- [API Reference](api/index.md)
- [Development](development/index.md)
```

**Rules:**
- Links point to `index.md` of each section
- One line per tab
- Format: `- [Label](path.md)`

### docs/{lang}/_sidebar.md (left sidebar menu)

```markdown
- [Introduction](index.md)
- **Getting Started**
  - [Quick Start](guide/quick-start.md)
  - [Configuration](guide/configuration.md)
- **Features**
  - [Themes](guide/themes.md)
  - [Multi-Doc](guide/multi-doc.md)
- **Reference**
  - [config.json](reference/config.md)
```

**Rules:**
- `**Bold Text**` = collapsible group header (default collapsed)
- `  - [Label](path.md)` = child item (2-space indent)
- Links are relative to the language directory
- Groups with active child auto-expand
- API method badges: `- <get>[List Users](api/users-list.md)`

### docs/{lang}/{section}/_sidebar.md (section-specific sidebar)

When a section directory (e.g., `development/`) has its own `_sidebar.md`,
it **replaces** the parent sidebar for pages within that section.
Links inside are relative to the section directory:

```markdown
- [Overview](index.md)
- **Architecture**
  - [Project Structure](architecture.md)
  - [Theme System](theme-system.md)
```

The system automatically prefixes these paths with the section name.

### docs/{lang}/*.md (document pages)

Every doc page has YAML frontmatter:

```yaml
---
title: Quick Start
description: Set up in 2 minutes
order: 1
---

# Quick Start

Content here in standard Markdown...
```

**Frontmatter fields:**
- `title` — Page title (required, used in browser tab + TOC)
- `description` — SEO description (optional)
- `order` — Sort order in sidebar (optional, lower = first)

**Content rules:**
- Start with `# H1 Title` (matches frontmatter title)
- Use `## H2` for major sections (these appear in right-side TOC)
- Use `### H3` for subsections
- Code blocks with language: ` ```bash `, ` ```json `, etc.
- Callouts: `> [!NOTE]`, `> [!TIP]`, `> [!WARNING]`, `> [!IMPORTANT]`, `> [!CAUTION]`
- Internal links: `[Link Text](path.md)` (relative, .md extension)
- External links: `[Link Text](https://...)` (open in new tab)
- Frontmatter is stripped before rendering (never shown to user)

### URL path convention

Files map to URLs like this:
- `docs/en/index.md` → `/docs/en/`
- `docs/en/guide/quick-start.md` → `/docs/en/guide/quick-start`
- `docs/zh/index.md` → `/docs/zh/`

Language is in the URL path (not query param). Same structure works in both
LiteDocs (Python) and LiteStartup (PHP) renderers.

---

## Blog Writing Rules

### blog/<slug>.md

```yaml
---
title: "My First Post"
date: 2026-05-28
slug: "my-first-post"
tags: ["release", "feature"]
status: "published"
---

Blog content in Markdown. Will be converted to HTML by the server.
```

**Fields:**
- `title` — Required
- `date` — Optional (default: today)
- `slug` — Optional (default: from filename)
- `tags` — Optional array
- `status` — "published" (default) or "draft"

---

## Changelog Writing Rules

### changelog/<version>.md

```yaml
---
title: "v0.2.0"
date: 2026-05-28
tags: ["feature", "bugfix"]
---

## New Features
- Payment integration
- New dashboard layout

## Bug Fixes
- Email sending timeout resolved
```

**Fields:**
- `title` — Version number (required)
- `date` — Release date (required)
- `tags` — Optional: feature, improvement, bugfix, breaking, security, deprecated

---

## Website Pages (HTML, not Markdown)

Website pages are **HTML files** (not markdown). They use the LiteStartup
`parseHtmlTemplate` system which splits pages into header/menu/content/footer.

**CRITICAL**: When syncing to LiteStartup, the HTML goes through `parseHtmlTemplate()`
on the server. Structure MUST match the rules below or rendering will fail.

### Page Types

There are two website page types with **different code structures**:

| Type | Example | Code Structure |
|------|---------|----------------|
| **website** | `index.html` (homepage `/`) | Full independent HTML, must match `index.html` structure |
| **block** | `pricing.html`, `privacy.html` | Child template with placeholders, inherits parent layout |

### ⚠️ Confirmation Rule

**If the user does not explicitly specify the page type, you MUST confirm with the user before proceeding.**
The code structure differs significantly — choosing the wrong one will cause parseHtmlTemplate to fail.

---

### Type: website (Main Page)

**Full independent HTML** — contains complete `<!DOCTYPE html>` to `</html>` structure.
Must match the structure of `index.html`:

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My SaaS | Homepage</title>
    <!-- Full CSS, meta tags, etc. -->
</head>
<body>
    <header>
        <nav>...</nav>
        <!-- Mobile Overlay + Drawer -->
        <div id="mobileOverlay">...</div>
        <div id="mobileDrawer">...</div>
    </header>

    <main>
        <!-- Page content -->
        <section class="py-20 px-6">
            <h1 class="text-4xl font-bold">Hero Section</h1>
        </section>
        <script>/* Page-specific JS */</script>
    </main>

    <footer>...</footer>

    <!-- Shared elements after </footer> -->
    <button id="toTopBtn">...</button>
    <script>/* Shared JS (drawer, scroll, etc.) */</script>
</body>
</html>
```

`parseHtmlTemplate()` splits this into 5 parts:
- `header.phtml` — `<!DOCTYPE html>` to `</head>`
- `menu.phtml` — `<header>...</header>` (full tag)
- `layout.phtml` — Remaining content with placeholders
- `bottom.phtml` — `<footer>...</footer>` (full tag)
- `footer.phtml` — Everything after `</footer>` to end

---

### Type: block (Child/Module Page)

**Inherits header/menu/bottom/footer from parent** via placeholders. Only write the page body:

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pricing | My SaaS</title>
</head>
<body>
    <header><!-- header placeholder --></header>

    <main>
        <!--seo:{"title":"Pricing | My SaaS","description":"Simple pricing","og_title":"Pricing","canonical":"https://www.example.com/pricing"}-->

        <!-- PAGE CONTENT ONLY -->
        <section class="py-20 px-6">
            <h1 class="text-4xl font-bold">Pricing</h1>
            <p class="mt-4 text-lg">Choose your plan...</p>
        </section>

        <script>
            // Page-specific JavaScript (if any)
        </script>
    </main>

    <footer><!-- footer placeholder --></footer>
</body>
</html>
```

At render time, `{{header}}`, `{{menu}}`, `{{bottom}}`, `{{footer}}` are replaced with the parent page's `.phtml` files.

---

### Website Writing Rules (Both Types)

1. **CSS**: Use Tailwind classes or `style=""` inline. NEVER define `<style>` in `<head>` (gets replaced by parent for block type)
2. **JS**: Page-specific JS goes inside `<main>` in `<script>` tags, NEVER outside
3. **SEO comment** (block type only): First child inside `<main>` must be `<!--seo:{JSON}-->` with title/description/og fields
4. **UTM tracking**: Use `{{utm_source}}` in signup/login URLs
5. **Shared classes**: `.card`, `.btn-primary`, `.fade-in` etc. are available from parent `<head>` (block type)
6. **URL**: File `website/pricing.html` → renders at `/pricing`

### SEO Comment Keys (block type)

```
title, description, keywords, canonical,
og_title, og_description, og_url, og_image, og_site_name,
twitter_title, twitter_description, twitter_image, json_ld
```

---

## Error Handling

- 401 → API key expired or invalid. Run `scripts/ls-bind.sh` again.
- 403 → Missing scope. Key needs `system.publish` scope.
- 404 → No binding. Run `scripts/ls-bind.sh` first.
- 409 → Repo already bound (not an error, just info).
- 422 → Sync failed (clone error, etc). Show error message to user.
- 429 → Rate limit. Tell user to wait. Do NOT retry automatically.

## DO NOT

- Read or display API keys from credentials file
- Modify files outside the content repo
- Auto-publish without `git push` first
- Auto-unpublish on file deletion (must be explicit user request)
- Retry failed operations without user consent
- Put docs content in root (must be inside `docs/{lang}/` directory)
- Forget `_sidebar.md` when creating docs (required for navigation)
- Use query params for language in links (use path: `/docs/en/...`)
