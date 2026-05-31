# Skill Development Rules

Rules for maintaining and extending litestartup-skill. Follow strictly when adding or updating any file.

---

## Architecture Invariants

1. **SKILL.md is a router, not a spec.** Keep it under 100 lines. All details go in `specs/` or `capabilities/`.
2. **One file per concern.** Never merge multiple specs or capabilities into one file.
3. **Specs are self-contained.** Each spec file must be independently understandable without reading other files.
4. **Templates are copy-paste ready.** Every template must work as-is when copied to the content repo.

---

## Adding a New Capability

When adding a new action (e.g., "unpublish", "preview"):

1. Create `capabilities/{name}.md`
2. Add a row to the **Capability Router** table in `SKILL.md`
3. If a new script is needed, create `scripts/ls-{name}.sh` (must source `_lib.sh`)
4. Update all adapter files (`adapters/*/`)

### Capability File Structure

```markdown
# Capability: {Name}

> **Trigger**: When user says "..."
> **Script**: `scripts/ls-{name}.sh`

## Flow
[numbered steps]

## Prerequisites
[what must exist before running]

## Error Scenarios
[table: Error | Cause | Resolution]
```

---

## Adding a New Content Type

When adding a new content type (e.g., "landing-page", "widget"):

1. Create `specs/{type}.md`
2. Add a row to the **Content Type** table in `SKILL.md`
3. Create template(s) in `templates/{type}/` (or `templates/{type}.ext` if single file)
4. Update `litestartup.yaml.example` sync paths if applicable
5. Update all adapter files

### Spec File Structure

```markdown
# {Type} Writing Spec

> **When to use**: [trigger condition]
> **File location**: `{dir}/` directory in the content repo.
> **Format**: [file format description]

## Directory Structure / File Convention
[tree or table showing where files go]

## Template
[complete copy-paste example]

## Fields / Rules
[table or numbered list — no ambiguity]

## Checklist Before Sync
[checkbox list of validation items]
```

---

## Updating Existing Specs

1. **Do not break existing templates.** If a format changes, keep backward compatibility or note it as a breaking change.
2. **Update the checklist** if adding new validation rules.
3. **Add examples** for any new feature — show correct AND incorrect usage where applicable.

---

## Templates Rules

- Path: `templates/{type}/` for multi-file types, `templates/{type}.ext` for single-file types
- Every template must include all required fields/structure filled with placeholder values
- Use realistic placeholder content (not "lorem ipsum")
- Comments in templates explain what to replace

---

## Adapter Rules

All adapters must be updated when:
- A new capability or content type is added
- The routing table in SKILL.md changes
- Script names change

Each adapter uses the **native format** of its target editor:
- Windsurf: `.windsurfrules` (plain rules text)
- Cursor: `.mdc` (YAML frontmatter + markdown)
- Claude Code: `CLAUDE.md` (markdown)
- Codex: `AGENTS.md` (markdown)

Adapters should be **lightweight pointers** — they tell the AI where to find details, not duplicate them.

---

## Script Rules

- All scripts source `_lib.sh` for shared functions
- Scripts NEVER echo API keys to stdout
- Scripts must handle errors gracefully with `ls_error()` / `ls_warn()` / `ls_ok()`
- New scripts follow naming: `ls-{verb}.sh` (e.g., `ls-preview.sh`)

---

## Naming Conventions

| Item | Convention | Example |
|------|-----------|---------|
| Capability file | `capabilities/{verb}.md` | `capabilities/sync.md` |
| Spec file | `specs/{content-type}.md` | `specs/docs.md` |
| Script | `scripts/ls-{verb}.sh` | `scripts/ls-sync.sh` |
| Template dir | `templates/{type}/` | `templates/docs/` |
| Template file | `templates/{type}.ext` | `templates/blog-post.md` |

---

## Version Bumping

Update `version` in SKILL.md frontmatter when:
- **Patch** (0.3.x): Fix typos, clarify wording, update examples
- **Minor** (0.x.0): Add new capability or content type
- **Major** (x.0.0): Breaking change to file structure or routing

---

## Quality Checklist (Before Committing)

- [ ] SKILL.md router table is up to date
- [ ] New spec/capability follows the file structure template above
- [ ] Templates are valid and copy-paste ready
- [ ] All adapters reference new capabilities/specs
- [ ] `litestartup.yaml.example` paths are correct
- [ ] No duplicate information across files
- [ ] SKILL.md stays under 100 lines
