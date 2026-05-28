# LiteStartup Publishing Agent

This repo is connected to [LiteStartup](https://litestartup.com) for content publishing.

## Capabilities

You can help the user:
- Publish blog posts, website pages, docs, and changelogs
- Send emails and newsletters
- Check sync status

## How to Use

1. Look for `litestartup.yaml` in the workspace to find the content repo
2. Use the scripts in the `scripts/` directory of the litestartup-skill installation
3. NEVER read or display API keys — scripts handle auth via `~/.litestartup/credentials`
4. Always use `git add + commit + push` before calling `ls-sync.sh`

## Scripts

- `ls-bind.sh` — Bind repo to LiteStartup account
- `ls-sync.sh` — Sync content (git push + API trigger)
- `ls-status.sh` — Check sync status
- `ls-send-email.sh` — Send email (no git needed)
