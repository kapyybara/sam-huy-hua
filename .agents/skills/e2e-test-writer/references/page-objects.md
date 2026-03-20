# Page Objects

Page Objects encapsulate all Playwright interactions for a specific page or component. Tests should never call Playwright APIs directly.

## BasePage

All Page Objects extend `BasePage` (`tests/e2e/pages/BasePage.ts`):

```typescript
import { Page, Locator } from '@playwright/test'

export class BasePage {
  constructor(protected page: Page) {}

  /** Return a locator scoped to data-test-id */
  locator(testId: string): Locator {
    return this.page.getByTestId(testId)
  }

  async click(testId: string): Promise<this> {
    await this.locator(testId).click()
    return this
  }

  async fill(testId: string, value: string): Promise<this> {
    await this.locator(testId).fill(value)
    return this
  }

  async shouldBeVisible(testId: string): Promise<this> {
    await this.locator(testId).waitFor({ state: 'visible' })
    return this
  }

  async shouldHaveText(testId: string, text: string): Promise<this> {
    await this.locator(testId).filter({ hasText: text }).waitFor()
    return this
  }

  /** Capture screenshot for documentation */
  async captureForDocs(feature: string, state: string): Promise<this> {
    const path = `tests/e2e/output/screenshots/docs/${feature}_${state}.png`
    await this.page.screenshot({ path, fullPage: true })
    return this
  }
}
```

## Creating a Page Object

```typescript
// tests/e2e/pages/ProjectPage.ts
import { Page } from '@playwright/test'
import { BasePage } from './BasePage'

export class ProjectPage extends BasePage {
  constructor(page: Page) {
    super(page)
  }

  async navigate() {
    await this.page.goto('/')
    await this.page.waitForLoadState('networkidle')
  }

  async clickCreateButton(): Promise<this> {
    await this.click('create-project-btn')
    return this
  }

  async fillProjectName(name: string): Promise<this> {
    await this.fill('project-name-input', name)
    return this
  }

  async submitCreate(): Promise<this> {
    await this.click('project-create-submit')
    return this
  }

  async getProjectCard(projectId: string): Promise<this> {
    await this.shouldBeVisible(`project-item-${projectId}`)
    return this
  }
}
```

## Strict Mode: Multiple Elements with Same test-id

When multiple components on the page share the same `data-test-id` (e.g., two instances of a reusable dropdown), Playwright's strict mode throws. Use `.first()`:

```typescript
// ❌ Fails if 2+ elements match
await this.locator('export-format-md').click()

// ✅ Selects the first match
await this.locator('export-format-md').first().click()
```

## Page Navigation

Page Objects don't navigate — **they expose navigation methods**. Tests call them explicitly:

```typescript
test('user sees project list', async ({ page }) => {
  const projectPage = new ProjectPage(page)
  await projectPage.navigate()         // ← explicit navigation
  await projectPage.shouldBeVisible('project-list')
})
```

### UI State Matters

If your target element is behind a tab, panel, or modal, click the correct trigger first:

```typescript
async openExportPanel(): Promise<this> {
  await this.click('sidebar-tab-export')
  await this.shouldBeVisible('export-panel')
  return this
}
```

## Waiting for Async Operations

Magisk uses Vue 3 reactivity — state changes are async. Use Playwright's auto-waiting where possible, or `waitFor`:

```typescript
// ✅ waitFor resolves when element appears
await this.locator('success-toast').waitFor({ state: 'visible' })

// ✅ Wait for specific network requests to settle
await this.page.waitForLoadState('networkidle')

// ❌ Avoid fixed delays
await this.page.waitForTimeout(2000)
```
