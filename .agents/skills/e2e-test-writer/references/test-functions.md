# Test Functions

Test functions live in `tests/e2e/step_defs/[feature].spec.ts` using Playwright Test's `test()` + `expect()`.

## Structure

```typescript
/**
 * E2E tests for [Feature Name].
 *
 * Spec: docs/specs/[feature].md
 *
 * Validates:
 *   - User Story 1: [description]
 *   - User Story 2: [description]
 */
import { test, expect } from '@playwright/test'
import { ProjectPage } from '../pages/ProjectPage'


test.describe('[Feature Name]', () => {

  test.beforeEach(async ({ page }) => {
    // Navigate to starting point before each test
    await page.goto('/')
    await page.waitForLoadState('networkidle')
  })

  test('user can create a new project', async ({ page }) => {
    /**
     * Ref: docs/specs/project.md
     * Scenario: Create project with valid name
     *
     * Given the user is on the project list page
     * When  they click "New Project" and fill in a name
     * Then  a new project card appears in the list
     */
    const projectPage = new ProjectPage(page)

    // When
    await projectPage.clickCreateButton()
    await projectPage.captureForDocs('project', 'create_modal_open')
    await projectPage.fillProjectName('My Test Project')
    await projectPage.submitCreate()

    // Then
    await projectPage.captureForDocs('project', 'created_success')
    await expect(page.getByTestId('project-list')).toContainText('My Test Project')
  })

})
```

## Key Conventions

### 1. BDD Double-Referencing

Every test docstring must reference the BDD spec file. Every BDD spec scenario should link back to the test file. This creates bidirectional traceability.

### 2. Page Object Wrapping

Always wrap Playwright's `page` in a Page Object at the start of the test:

```typescript
// ✅ POM wraps all interactions
const projectPage = new ProjectPage(page)
await projectPage.clickCreateButton()

// ❌ Raw page calls in test code
await page.getByTestId('create-project-btn').click()
```

### 3. Use Fixtures for Shared Setup

For shared state (e.g., pre-created project), use `test.extend()` fixtures:

```typescript
// tests/e2e/fixtures.ts
import { test as base } from '@playwright/test'
import { ProjectPage } from './pages/ProjectPage'

type Fixtures = {
  projectPage: ProjectPage
}

export const test = base.extend<Fixtures>({
  projectPage: async ({ page }, use) => {
    const projectPage = new ProjectPage(page)
    await projectPage.navigate()
    await use(projectPage)
  },
})

export { expect } from '@playwright/test'
```

Then use in tests:
```typescript
import { test, expect } from '../fixtures'

test('project list loads', async ({ projectPage }) => {
  await projectPage.shouldBeVisible('project-list')
})
```

### 4. Assert Meaningful Things

```typescript
// ✅ Verify actual content
await expect(page.getByTestId('project-name')).toHaveText('My Project')
await expect(page.getByTestId('project-list')).toBeVisible()
await expect(page).toHaveURL(/\/builder\//)

// ❌ Just checking it didn't crash
expect(true).toBe(true)
```

### 5. API Mocking for Edge Cases

For error states or edge cases, mock the API response:

```typescript
test('shows error when API fails', async ({ page }) => {
  // Mock a failing API call
  await page.route('**/api/projects', route => {
    route.fulfill({ status: 500, body: 'Internal Server Error' })
  })

  await page.goto('/')
  await expect(page.getByTestId('error-message')).toBeVisible()
})
```

## Running Tests

```bash
# All E2E tests
cd apps/magisk && bunx playwright test

# Single file
bunx playwright test tests/e2e/step_defs/project.spec.ts

# Filter by test name
bunx playwright test -k "create project"

# Interactive UI mode
bunx playwright test --ui

# Headed (watch the browser)
bunx playwright test --headed

# Debug mode
bunx playwright test --debug
```
