# Capability: Bind Repo

> **Trigger**: User says "bind to litestartup", "connect repo", or no `litestartup.yaml` found.
> **Script**: `scripts/ls-bind.sh`

## Flow

1. Ask user to provide their LiteStartup API key (scope: `system.publish`)
2. Run `scripts/ls-bind.sh`
3. Script performs:
   - Saves key to `~/.litestartup/credentials`
   - Detects git remote URL
   - Calls `POST /client/v2/repo-sync/bind` with repo URL
   - Creates `litestartup.yaml` in repo root
4. Confirm success: "Repo bound to LiteStartup. You can now sync content."

## Prerequisites

- Git repo initialized with a remote (GitHub/GitLab/Gitee)
- Valid API key with `system.publish` scope

## Error Scenarios

| Error | Cause | Resolution |
|-------|-------|-----------|
| 401 | Invalid/expired API key | Ask user to get a new key from LiteStartup dashboard |
| 409 | Repo already bound | Not an error — tell user they're already connected |
| No git remote | Repo has no remote URL | Ask user to `git remote add origin <url>` first |

## Security

- NEVER display the API key in conversation
- NEVER run `cat ~/.litestartup/credentials`
- The script handles all key storage internally
