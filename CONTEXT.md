# Multi-Domain Repo Binding — Task Document

> **Date**: 2026-06-04
> **Status**: In Progress
> **Version bump**: 0.3.0 → 0.4.0 (Minor — new capability)

---

## Goal

Support one account (API key) managing multiple content repos bound to different custom domains.
Users can list domains, bind a repo to a chosen domain, and unbind — all from `ls-bind.sh`.

## Domain Lifecycle (existing)

```
Registration → app_website generates initial domain_slug (e.g. "domain-bab4cade...")
                                    │
1st custom domain (os_domains) ─────┘ reuses initial slug  (DomainService L86-89)
2nd+ custom domain (os_domains) ──── generates new unique slug (DomainService L91)
```

**Key tables**:
- `os_domains` — infrastructure domains (holds `domain_slug`)
- `app_domains` — app-layer subdomains (references `os_domains.id`)
- `os_publish_repos` — repo bindings (`domain_slug` ties repo → domain)

## Design

### 1. New Backend Endpoint: `GET /client/v2/repo-sync/domains`

Returns all team domains + binding status.

**Response**:
```json
{
  "code": 200,
  "data": {
    "domains": [
      {
        "domain": "litestartup.com",
        "subdomain": "mail",
        "full_domain": "mail.litestartup.com",
        "domain_slug": "domain-bab4cade...",
        "is_default": true,
        "binding": {
          "binding_id": 6,
          "repo_url": "https://github.com/org/repo.git",
          "last_synced_at": "2026-06-02 15:30:00",
          "sync_count": 12
        }
      },
      {
        "domain": "another.com",
        "domain_slug": "do4cjlixsg...",
        "is_default": false,
        "binding": null
      }
    ]
  }
}
```

**Files**: `RepoSyncController::domains()`, `PublishRepoRepository::findAllByTeam()`, `api-client.php` route.

### 2. Updated `ls-bind.sh`

```
ls-bind.sh [--domain <name_or_slug>] [--unbind] [repo_url]
```

**Bind flow**:
- 1 domain → auto-select, zero interaction
- N domains + no `--domain` → list domains, prompt selection
- N domains + `--domain X` → exact match, no prompt

**Unbind flow**:
- `--unbind` → reads `litestartup.yaml` → `DELETE /repo-sync/binding`
- `--unbind --domain X` → unbind specific domain

### 3. Updated `litestartup.yaml`

New `domain` field for readability:
```yaml
version: 1
binding_id: 6
domain: litestartup.com
domain_slug: domain-bab4cade...
endpoint: https://api.litestartup.com
repo_url: https://github.com/org/repo.git
sync:
  blog:
    path: "blog/**/*.md"
  website:
    path: "website/**/*.html"
  docs:
    path: "docs/**/*.md"
  changelog:
    path: "changelog/**/*.md"
```

### 4. Updated `_lib.sh`

New helper: `ls_list_domains()` — calls `GET /repo-sync/domains`, returns JSON.

### 5. Updated docs

- `capabilities/bind.md` — flow includes domain selection + unbind
- `SKILL.md` — version 0.4.0

## File Change List

| Project | File | Change |
|---------|------|--------|
| litestartup | `config/routes/api-client.php` | Add `GET /repo-sync/domains` |
| litestartup | `src/Controller/RepoSyncController.php` | Add `domains()` method |
| litestartup | `src/Database/PublishRepoRepository.php` | Add `findAllByTeam()` |
| litestartup-skill | `scripts/ls-bind.sh` | `--domain`, `--unbind`, interactive selection |
| litestartup-skill | `scripts/_lib.sh` | `ls_list_domains()` |
| litestartup-skill | `capabilities/bind.md` | Update flow |
| litestartup-skill | `templates/litestartup.yaml.example` | Add `domain` field |
| litestartup-skill | `SKILL.md` | Version 0.4.0 |

## NOT doing

- No separate `ls-domains.sh` or `capabilities/domains.md`
- No `ls-sync.sh` changes (reads `domain_slug` from yaml as-is)
- No DB schema changes (`os_publish_repos` already has `domain_slug`)
