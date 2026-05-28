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
  - "update changelog"
  - "deploy blog post"
  - "update website"
version: 0.1.0
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

## Repo Layout Convention

```
<content-repo>/
├── litestartup.yaml      ← REQUIRED (binding config)
├── website/*.md          ← Website pages
├── blog/*.md             ← Blog posts
├── docs/**/*.md          ← Documentation
├── changelog/*.md        ← Version changelogs
└── .gitignore            ← Should ignore drafts/email-*
```

## Frontmatter Requirements

### blog/<slug>.md
```yaml
---
title: "Post Title"          # required
date: 2026-05-28             # optional (default: today)
slug: "post-slug"            # optional (default: filename)
tags: ["tag1", "tag2"]       # optional
status: "published"          # draft | published (default: published)
---
```

### website/<page>.md
```yaml
---
slug: "about"                # required
layout: "default"            # optional
seo_title: "..."             # optional
seo_description: "..."       # optional
---
```

### docs/<path>.md
```yaml
---
title: "Doc Title"           # required
order: 10                    # optional (sort order)
nav_group: "Getting Started" # optional
---
```

### changelog/<version>.md
```yaml
---
title: "v0.2.0"                          # required
date: 2026-05-28                         # required
tags: ["feature", "bugfix"]              # optional
---
```

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
