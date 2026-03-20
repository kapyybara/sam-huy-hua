# Common Pitfalls

These are real issues that cause E2E test failures. Read this before writing tests.

---

## 1. Missing `data-test-id` → TimeoutError

**Symptom:** `TimeoutError: locator.click: Timeout 30000ms exceeded`

**Cause:** The Vue component doesn't have `data-test-id` on the element you're targeting.

**Fix:** Open the Vue component, find the element, add `data-test-id="your-id"`. Vite HMR picks it up immediately.

```html
<!-- ❌ No test ID — Playwright hangs 30s then fails -->
<button @click="handleCreate">New Project</button>

<!-- ✅ Has test ID — Playwright finds it immediately -->
<button data-test-id="create-project-btn" @click="handleCreate">New Project</button>
```

**Prevention:** Always check the Vue component file BEFORE writing the test.

---

## 2. Strict Mode Violation → Multiple Elements Match

**Symptom:** `Error: strict mode violation: getByTestId("export-btn") resolved to 2 elements`

**Cause:** A reusable component appears multiple times on the page. Each instance has the same `data-test-id`.

**Fix:** Use `.first()` or scope the locator to a parent:

```typescript
// ❌ Fails with strict mode violation
await this.locator('export-btn').click()

// ✅ First matching element
await this.locator('export-btn').first().click()

// ✅ Or scope to a parent element
await page.getByTestId('sidebar').getByTestId('export-btn').click()
```

---

## 3. Vue Async Rendering → Element Not Visible Yet

**Symptom:** Element exists in DOM but Playwright can't find or click it immediately after a state change.

**Cause:** Vue 3's reactivity is async — the DOM update happens in the next microtask. Playwright can sometimes be faster than the DOM.

**Fix:** Use Playwright's built-in auto-waiting. If you need extra wait, use `waitFor`:

```typescript
// ✅ waitFor state visible
await page.getByTestId('success-toast').waitFor({ state: 'visible' })

// ✅ Wait for network to settle after an action
await page.click('[data-test-id="save-btn"]')
await page.waitForResponse('**/api/projects/**')

// ❌ Avoid fixed timeouts — they're slow and flaky
await page.waitForTimeout(1000)
```

---

## 4. Tab/Panel Not Active → Element Hidden or Not Rendered

**Symptom:** `TimeoutError` for an element with a `data-test-id` that definitely exists.

**Cause:** The element is inside a tab, accordion, or sidebar panel that isn't currently active. It may not be rendered at all (v-if) or just hidden (v-show).

**Fix:** Click the correct tab/trigger first:

```typescript
// Navigate to builder, then open the correct panel
await page.goto('/builder/project-id')
await page.waitForLoadState('networkidle')

// Default panel is "Layers" — switch to "Properties" first
await page.getByTestId('panel-tab-properties').click()

// Now interact with properties panel
await page.getByTestId('width-input').fill('200')
```

---

## 5. `data-testid` vs `data-test-id` → Nothing Found

**Symptom:** `getByTestId()` finds nothing, even though the attribute exists in the HTML.

**Cause:** Playwright defaults to `data-testid` (no hyphen). This project uses `data-test-id` (with hyphen). This is configured in `playwright.config.ts`:

```typescript
// playwright.config.ts — required!
export default defineConfig({
  use: {
    testIdAttribute: 'data-test-id',
  },
})
```

**Verify:** If tests can't find elements that have `data-test-id` in the HTML, check `playwright.config.ts` for this setting.

---

## 6. Missing `webServer` Config → Tests Run Against Stale or No Server

**Symptom:** Tests fail with `net::ERR_CONNECTION_REFUSED` or get stale HTML from a previous build.

**Cause:** The Vite dev server isn't running when tests start, or Playwright is pointing at the wrong URL.

**Fix:** Either:
a) **Start the dev server first manually** (simplest): `bun dev` in `apps/magisk/`
b) **Configure webServer in `playwright.config.ts`** to auto-start it:

```typescript
webServer: {
  command: 'bun dev',
  url: 'http://localhost:5173',
  reuseExistingServer: !process.env.CI,
}
```

---

## 7. Navigating via URL in Test Code (Not Through POM)

**Symptom:** Tests know too much about URL structure. Brittle when routes change.

**Fix:** Navigation belongs in Page Objects:

```typescript
// ❌ Test navigates directly
test('builder works', async ({ page }) => {
  await page.goto('http://localhost:5173/builder/abc123')
})

// ✅ Page Object handles navigation
test('builder works', async ({ page }) => {
  const builderPage = new BuilderPage(page)
  await builderPage.navigate('abc123')  // URL logic inside POM
})
```

---

## 8. Breaking Existing Vitest Unit Tests

**Symptom:** `bun vitest run` fails after adding Playwright.

**Cause:** Playwright config or new `tests/` files interfere with Vitest config.

**Fix:**
- Keep E2E tests in `tests/e2e/` — Vitest is configured to look in `tests/models/`
- Don't add `.spec.ts` files to `tests/models/` (Vitest picks these up)
- `playwright.config.ts` and Vitest config are separate files — they don't conflict

**Verify:**
```bash
# Vitest (unit tests) — from root
bun vitest run

# Playwright (E2E) — from apps/magisk/
bunx playwright test
```
