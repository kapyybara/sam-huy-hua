---
trigger: model_decision
description: Use this rule when writing and running e2e test cases
---

# E2E Testing Developer Guidelines

Conventions for writing End-to-End tests using Playwright Test + TypeScript + Page Object Model in Magisk.

## 1. Tech Stack

| Layer          | Tool                                                |
|----------------|-----------------------------------------------------|
| Test framework | **@playwright/test** (TypeScript)                   |
| Browser        | **Playwright Chromium**                             |
| Pattern        | Page Object Model (POM)                             |
| Specs          | BDD-style Markdown files in `docs/specs/*.md`       |

### Running tests

```bash
# From apps/magisk/
bun run test:e2e           # headless
bun run test:e2e:ui        # interactive UI
bun run test:e2e:headed    # watch browser

# Or directly
bunx playwright test
bunx playwright test tests/e2e/step_defs/feature.spec.ts
```

## 2. Test Output

```
tests/e2e/output/
├── screenshots/docs/    # Feature screenshots for user manual
├── test-results/        # Failure artifacts (screenshots, traces)
└── playwright-report/   # HTML report
```

- Ensure `tests/e2e/output/` is in `.gitignore`.

## 3. Test Execution Flow

- **Parallel by default** — Playwright runs tests in parallel workers.
- **Page Object Method Chaining**: POM methods return `this` to enable chaining.

```typescript
// Example: Chaining
await projectPage.navigate().then(p => p.clickCreate()).then(p => p.shouldBeVisible('modal'))
// Or more readable:
await projectPage.navigate()
await projectPage.clickCreate()
await projectPage.shouldBeVisible('create-modal')
```

## 4. Element Selectors

### Strict Usage of `data-test-id`

- **Mandatory**: Add `data-test-id` to every element targeted by E2E tests.
- **No CSS/XPath**: CSS classes and XPath break when styling changes.
- **Playwright Syntax**: Use `page.getByTestId()` or `this.locator()` via `BasePage`.

```html
<!-- Vue component -->
<button data-test-id="create-project-btn" @click="handleCreate">New Project</button>
```

```typescript
// Page Object
await this.locator('create-project-btn').click()
```

**Config in `playwright.config.ts`:**
```typescript
use: {
  testIdAttribute: 'data-test-id',  // required — default is data-testid
}
```

## 5. Double Referencing (BDD Spec ↔ Code)

### Test → Spec

Every test must include a comment referencing the spec file:

```typescript
test('user can create project', async ({ page }) => {
  /**
   * Ref: docs/specs/projects.md
   * Scenario: Create project with valid name
   */
  // ...
})
```

### Spec → Test

Every scenario in `docs/specs/*.md` must link back to the implementing test:

```markdown
### Scenario: Create project with valid name
> **Implemented by**: `tests/e2e/step_defs/project.spec.ts`

Given the user is on the projects page
When they click "New Project" and fill in a name
Then a new project card appears
```

## 6. Documentation Screenshots

Tests covering user-visible features must capture screenshots for documentation. See the **Screenshot Capture for Documentation** section in the `e2e-test-writer` skill for naming conventions and philosophy.

```typescript
await projectPage.captureForDocs('project', 'list_view')
// → saves to tests/e2e/output/screenshots/docs/project_list_view.png
```
