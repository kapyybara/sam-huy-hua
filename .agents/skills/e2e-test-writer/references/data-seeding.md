# Data Seeding

Magisk connects to a local backend API. Unlike Python/pytest projects, there's no direct DB access — seed test data via the API or mock at the network layer.

## Strategy 1: Real Backend Data (Recommended for Happy Path)

The simplest approach: run tests against the local backend that's already running. Works great for read-only tests or tests that create data via the real UI flow.

```typescript
test.beforeEach(async ({ page }) => {
  // Just navigate — backend is already running at localhost:3008
  await page.goto('/')
  await page.waitForLoadState('networkidle')
})
```

**When to use:** Smoke tests, read flows, UI validation.

---

## Strategy 2: API Seeding via REST (For Predictable State)

Create test data before the test via HTTP, then clean up after.

```typescript
import { test as base, expect } from '@playwright/test'

const API = 'http://localhost:3008'
const TEST_PROJECT_NAME = 'E2E-Test-Project-' + Date.now()

// Extend test with a fixture that creates + destroys a project
const test = base.extend<{ testProjectId: string }>({
  testProjectId: async ({ request }, use) => {
    // Setup: create project via API
    const response = await request.post(`${API}/api/projects`, {
      data: { name: TEST_PROJECT_NAME }
    })
    const project = await response.json()

    await use(project.id)

    // Teardown: delete project after test
    await request.delete(`${API}/api/projects/${project.id}`)
  },
})

test('builder opens for seeded project', async ({ page, testProjectId }) => {
  await page.goto(`/builder/${testProjectId}`)
  await expect(page.getByTestId('builder-canvas')).toBeVisible()
})
```

**When to use:** Tests that need specific data shapes, or when existing data is unpredictable.

---

## Strategy 3: API Mocking via `page.route()` (For Edge Cases)

Use Playwright's `route()` to intercept and mock API calls. Doesn't require backend to be running.

```typescript
test('shows empty state when no projects exist', async ({ page }) => {
  // Mock the projects list endpoint
  await page.route('**/api/projects', route => {
    route.fulfill({
      status: 200,
      contentType: 'application/json',
      body: JSON.stringify([])
    })
  })

  await page.goto('/')
  await expect(page.getByTestId('empty-state-message')).toBeVisible()
})

test('shows error when API is down', async ({ page }) => {
  await page.route('**/api/**', route => {
    route.fulfill({ status: 500 })
  })

  await page.goto('/')
  await expect(page.getByTestId('global-error-banner')).toBeVisible()
})
```

**When to use:** Error states, loading states, data edge cases, offline behavior.

---

## Key Rules

1. **Prefer real data for happy-path** — routing mocks hide real integration bugs
2. **Isolate seeded data** — prefix names with `E2E-Test-` or timestamp so tests don't collide
3. **Always teardown** — delete test data after; use `test.afterEach` or fixture cleanup
4. **Don't depend on specific project IDs** — IDs change between environments; query by name or attribute
5. **Don't share state between tests** — each test must be independently runnable
