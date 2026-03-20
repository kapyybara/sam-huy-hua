---
name: docs-writing
description: >
  Write user-facing documentation for kcode-v3 using VuePress 2.
  Covers user manual structure, screenshot capture, image path resolution,
  sidebar configuration, changelog writing, and VuePress-specific pitfalls.
  Use when writing user manuals, feature documentation, changelogs,
  or troubleshooting VuePress rendering issues. Also activate when
  users ask to "write docs", "document a feature", "add a user manual page",
  "fix docs images", or "update the changelog".
---

# Documentation Writing Skill

Write clear, screenshot-rich user documentation for kcode-v3 using VuePress 2.

## When to Use

- Writing a new user manual page for a feature
- Adding screenshots to documentation
- Writing changelog entries
- Fixing broken images or links in VuePress
- Updating sidebar navigation

## Documentation Stack

| Component | Technology |
|-----------|-----------|
| Framework | VuePress 2 (Vue 3 based) |
| Bundler | Vite |
| Theme | `@vuepress/theme-default` (dark mode) |
| Location | `docs/user_manual/` |
| Dev server | `bun dev` → `http://localhost:8081/docs/` |

---

## Project Structure

```
docs/user_manual/
├── .vuepress/
│   └── config.ts          # VuePress config: base, navbar, sidebar
├── index.md               # Homepage — organized by concept phases
├── mermaid_layout.md       # Root-level pages (if any)
├── docs/                   # Documentation pages
│   ├── sso.md
│   ├── mermaid_layout.md
│   ├── export_artifacts.md
│   └── images/             # Screenshots for docs/ pages
│       ├── concept.png
│       ├── export_*.png
│       └── sso/            # Subfolder per feature
│           └── *.png
├── images/                 # Screenshots for root-level pages
│   └── mermaid_*.png
├── Dockerfile
├── nginx.conf
└── package.json
```

---

## Workflow: Writing a New Documentation Page

### Step 1: Take Screenshots

**Prefer screenshots from E2E test runs** — they reflect the actual user experience and are the ground truth for documentation.

1. Check `tests/output/screenshots/docs/` for existing E2E screenshots
2. Copy suitable screenshots to `docs/user_manual/docs/images/`
3. Only capture manually via browser subagent when E2E screenshots don't exist yet

If capturing manually:

1. Navigate to the feature in the running app
2. Capture key interaction states (before click, dropdown open, result)
3. Save screenshots to `docs/user_manual/docs/images/`

**Naming convention:** `{feature}_{state}.png` (same convention as defined in the `e2e-test-writer` skill)

### Step 2: Write the Markdown Page

Create a new `.md` file in `docs/user_manual/docs/`:

```markdown
# Feature Title

Brief description of what the feature does.

## Supported Options / Formats

| Option | Description |
|--------|-------------|
| **JSON** | Raw structured data |
| **Excel** | Spreadsheet format |

## How to Use Feature

1. Navigate to the project
2. Click the **Button Name** in the toolbar

![Description of what the screenshot shows](./images/feature_screenshot.png)

3. Next step...
```

### Step 3: Update Sidebar Config

Edit `.vuepress/config.ts` to add the new page to the sidebar:

```typescript
sidebar: [
    {
        text: 'Section Name',
        children: [
            '/docs/new_page.md',
        ],
    },
],
```

### Step 4: Update index.md

Add a link to the new page in the appropriate concept section of `index.md`.

### Step 5: Audit via Browser

Navigate to `http://localhost:8081/docs/` and verify:
- Page renders without Vite import errors
- All images load (no alt text shown instead of images)
- Sidebar navigation works
- Links between pages resolve correctly

---

## Critical Rules: Image Paths in VuePress

> This is the #1 source of bugs. Get this wrong and Vite will show a red error overlay.

### The Rule

VuePress/Vite treats image paths in markdown as **module imports**. A bare path like `images/foo.png` is treated as a module name, not a relative file path. You MUST use explicit relative paths.

### Correct Paths by File Location

**From `docs/*.md` → images in `docs/images/`:**
```markdown
<!-- ✅ Correct: explicit relative path -->
![Screenshot](./images/screenshot.png)

<!-- ❌ Wrong: treated as module import, Vite error -->
![Screenshot](images/screenshot.png)
```

**From `docs/*.md` → images in root `images/` (one level up):**
```markdown
<!-- ✅ Correct: go up one directory -->
![Screenshot](../images/screenshot.png)

<!-- ❌ Wrong: will look in docs/images/ which doesn't have this file -->
![Screenshot](./images/screenshot.png)
```

**From `index.md` (root) → images in `docs/images/`:**
```markdown
<!-- ✅ Correct: explicit relative path into docs/ -->
![Concept](./docs/images/concept.png)

<!-- ❌ Wrong: Vite import error -->
![Concept](docs/images/concept.png)
```

### Link Paths Follow the Same Rule

```markdown
<!-- ✅ Correct -->
- [SSO / Login](./docs/sso.md)

<!-- ❌ Wrong: VuePress warns "broken link" -->
- [SSO / Login](docs/sso.md)
```

### Quick Reference

| From file | To target | Path prefix |
|-----------|----------|-------------|
| `docs/page.md` | `docs/images/x.png` | `./images/x.png` |
| `docs/page.md` | `images/x.png` (root) | `../images/x.png` |
| `index.md` (root) | `docs/images/x.png` | `./docs/images/x.png` |
| `index.md` (root) | `docs/page.md` | `./docs/page.md` |

---

## Sidebar Configuration

The sidebar is configured in `.vuepress/config.ts`. Group pages by concept area:

```typescript
sidebar: [
    {
        text: 'Getting Started',
        children: [
            '/docs/sso.md',
        ],
    },
    {
        text: 'Display / Export',
        children: [
            '/docs/mermaid_layout.md',
            '/docs/export_artifacts.md',
        ],
    },
],
```

**Rules:**
- Sidebar paths use **absolute paths** from the VuePress root (start with `/`)
- Each `text` group becomes a collapsible section in the sidebar
- The page's `# H1` heading becomes the sidebar item label
- Add new pages to both the sidebar AND `index.md`

---

## Writing Changelogs

Changelogs live in `docs/changelogs/` and document completed features.

### File Naming

```
docs/changelogs/YYYYMMDD_feature_name.md
```

### Template

```markdown
# Feature Name

## Summary

One paragraph describing what was added/changed.

## Implementation Details

### Component 1 — Description
- What was created/modified
- Key technical details

### Component 2 — Description
- ...

## Discussion Log

1. **User**: What they requested
2. **Agent**: What was done
3. **User**: Feedback or redirection
4. ...
```

**Rules:**
- Include both implementation details AND the discussion log
- Discussion log captures the decision-making process (why, not just what)
- Use bold for speaker labels, numbered list for chronological order

---

## Checklist: Before Finishing Documentation

1. ☐ All image paths use `./` or `../` prefix (never bare `images/`)
2. ☐ All links use `./` prefix from root `index.md`
3. ☐ New page added to `.vuepress/config.ts` sidebar
4. ☐ New page linked from `index.md` in the correct concept section
5. ☐ Browser audit passes — no Vite errors, all images render
6. ☐ Sidebar shows correct structure with all pages
7. ☐ Screenshots saved to `docs/images/` with descriptive names
