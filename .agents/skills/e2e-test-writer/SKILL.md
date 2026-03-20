---
name: e2e-test-writer
description: Write E2E tests for Magisk using Playwright Test and the Page Object Model pattern (TypeScript). Use this skill whenever you need to create, modify, or debug E2E tests, add new test scenarios, create Page Objects, or add data-test-id attributes to Vue components. Also activate when users ask to "write an E2E test", "add Playwright tests", "create page objects", "seed test data", or "fix E2E test failures". Always use this skill before writing any code in the tests/e2e/ directory.
---

# E2E Test Writer

Write reliable, maintainable E2E tests for Magisk using **Playwright Test** + **TypeScript** + **Page Object Model**.

## Before You Write Any Test

> Before writing test code, you MUST complete these prerequisite steps.
> Skipping them is the #1 cause of test failures.

### Step 1: Ensure data-test-id Attributes Exist

Check the Vue components you plan to interact with. Every interactive element targeted by your test **must** have a `data-test-id` attribute. If it doesn't exist, add it to the component first.

```html
<!-- ✅ Correct: explicit test ID -->
<button data-test-id="create-project-btn" @click="handleCreate">New Project</button>

<!-- ✅ Dynamic test IDs for lists -->
<el-dropdown-item
  v-for="project in projects"
  :key="project.id"
  :data-test-id="`project-item-${project.id}`"
/>

<!-- ❌ Wrong: no test ID — Playwright will time out -->
<button @click="handleCreate">New Project</button>
```

**Why this matters:** Playwright's `getByTestId()` returns nothing if the attribute is missing. The test will hang for 30 seconds, then fail with a `TimeoutError`.

### Step 2: Understand Test Data Strategy

Magisk connects to a local backend (`http://localhost:3008`). Choose the right data strategy:

- **Use real backend data** — fastest for happy-path tests; requires server running
- **Mock API via `page.route()`** — for edge cases, error states, or offline tests
- **Create data via API call in fixture** — for tests that need fresh, predictable state

Read `references/data-seeding.md` for patterns.

### Step 3: No Auth Required

Magisk runs locally without SSO/OAuth. Just navigate to `http://localhost:5173` directly — no authentication fixture needed.

---

## Project Structure

```
apps/magisk/
├── playwright.config.ts       # Playwright config: base URL, reporters, webServer
└── tests/
    ├── e2e/
    │   ├── pages/             # Page Object Model classes
    │   │   ├── BasePage.ts    # Base class with shared helpers
    │   │   └── [Feature]Page.ts
    │   └── step_defs/         # Test files
    │       └── [feature].spec.ts
    └── models/                # Existing Vitest unit tests (do NOT touch)
        └── MagiskEditor/
```

---

## The Three Layers

Every E2E test has three layers. Always build bottom-up: data → pages → tests.

### Layer 1: Test Data (`step_defs/[feature].spec.ts` or fixtures)

See `references/data-seeding.md` for details and examples.

### Layer 2: Page Objects (`pages/`)

See `references/page-objects.md` for details and examples.

### Layer 3: Test Functions (`step_defs/[feature].spec.ts`)

See `references/test-functions.md` for details and examples.

---

## Common Pitfalls and How to Avoid Them

Read `references/common-pitfalls.md` — it covers the exact issues we've hit and the fixes.

---

## Screenshot Capture for Documentation

> E2E tests = User Acceptance Tests. What the test sees must be what users see.
> Screenshots from tests are the **ground truth** for user documentation.

Every test that covers a **user-visible feature** must capture screenshots at key interaction states. These screenshots flow directly into the user manual via the `docs-writing` skill.

### Where to Save

```text
tests/e2e/output/screenshots/docs/{feature}_{state}.png
```

**Naming convention:** `{feature}_{state}.png`
- `project_list_view.png`
- `project_create_modal.png`
- `builder_canvas_loaded.png`

### How to Capture in Page Objects

Add screenshot helper inherited from `BasePage`:

```typescript
// In your page object
await this.captureForDocs('project', 'list_view')
```

```typescript
// BasePage implementation
async captureForDocs(feature: string, state: string) {
  const path = `tests/e2e/output/screenshots/docs/${feature}_${state}.png`
  await this.page.screenshot({ path, fullPage: true })
}
```

Call during test flows at key UI states:

```typescript
test('user can create project', async ({ page }) => {
  const projectPage = new ProjectPage(page)

  await projectPage.navigate()
  await projectPage.captureForDocs('project', 'list_view')

  await projectPage.clickCreateButton()
  await projectPage.captureForDocs('project', 'create_modal_open')

  await projectPage.fillAndSubmit('My Project')
  await projectPage.captureForDocs('project', 'created_success')
})
```

### Philosophy

- **No workarounds.** If a screenshot looks wrong, the UI is wrong — fix the UI, not the test.
- **Test state = user state.** Tests must navigate through real user flows.
- **Screenshots are authoritative.** If the docs show something different from the test screenshot, the docs are wrong.

---

## Running Tests

```bash
# From apps/magisk/
bun run test:e2e

# Or directly via playwright
cd apps/magisk && bunx playwright test

# Single spec file
bunx playwright test tests/e2e/step_defs/project.spec.ts

# With UI (interactive)
bunx playwright test --ui

# Headed mode (watch browser)
bunx playwright test --headed
```

---

## Checklist: Before Submitting a Test PR

1. ☐ Every targeted element has `data-test-id` in the Vue component
2. ☐ Page Objects inherit from `BasePage` and use `this.locator()`
3. ☐ No raw `page.click()` / `page.locator('.css')` in test code — only through POM
4. ☐ Tests pass with dev server running: `bun run test:e2e`
5. ☐ Test docstrings reference the BDD spec file and scenario
6. ☐ `.first()` used when multiple elements share a `data-test-id`
7. ☐ UI state verified (correct tab active, modal open) before interacting
8. ☐ Screenshots captured at key UI states for documentation
9. ☐ Existing Vitest unit tests not broken: run `bun vitest run` from root
