# Capability: Sync Content

> **Trigger**: User says "publish", "sync", "deploy", or after writing content.
> **Script**: `scripts/ls-sync.sh [commit_message]`

## Flow

1. Locate directory containing `litestartup.yaml`
2. Validate changed files have correct frontmatter/structure:
   - Blog: check `title` in frontmatter
   - Docs: check `title` + verify `_sidebar.md` exists
   - Website: check structure matches type (website/block)
   - Changelog: check `title` + `date`
3. Run sync:
   ```bash
   scripts/ls-sync.sh "content: add pricing page"
   ```
4. Script performs atomically:
   - `git add -A blog/ website/ docs/ changelog/ litestartup.yaml`
   - `git commit -m "<message>"`
   - `git push`
   - `POST /client/v2/repo-sync/trigger` with commit SHA
5. Report results to user

## Commit Message Convention

Format: `content: <brief description>`

Examples:
- `content: add pricing page`
- `content: update docs quick-start guide`
- `content: publish v0.3.0 changelog`
- `content: new blog post about email features`

## Sync Results

The API returns:
- **inserted** — New files published
- **updated** — Existing files updated
- **skipped** — No changes detected
- **conflicts** — Server has newer edits (manual resolution needed)
- **urls** — Live URLs for published content

## Important Notes

- Website HTML goes through `parseHtmlTemplate()` on server — structure must match
- Docs files are rendered as-is through markdown parser
- Blog/changelog markdown is converted to HTML server-side
- Always git push BEFORE triggering sync API (server pulls from remote)

## Error Scenarios

| Error | Cause | Resolution |
|-------|-------|-----------|
| 404 | No binding | Run `scripts/ls-bind.sh` first |
| 422 | Clone/parse failed | Check file structure matches spec |
| 429 | Rate limited | Wait and retry (but do NOT auto-retry) |
| git push fails | Auth issue | User needs to fix git credentials |
