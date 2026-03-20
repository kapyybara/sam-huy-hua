---
description: Scaffold UI Views for a new Magisk feature — adds sidebar icon, routing, Navigation panel (left), EditorView panel (main), and registers components in the layout plugin. Sub-workflow of create-magisk-feature.
---

# Magisk Feature — UI Views & Navigation

Thiết lập toàn bộ UI layer cho feature mới. Cần có: `FEATURE_NAME`, `FEATURE_LOWER`, `FEATURE_KEBAB`, `MENU_ICON`.

**Pattern reference**:
- Navigation entry: `src/views/builder/views/FirstLevelNavigation/` (cách `data` entry được thêm)
- Panel views + viewmodel: `src/views/builder/views/SettingsView/modules/Deployments/`

---

## Step 1: Thêm Sidebar Icon

Mở `apps/magisk/src/views/builder/views/FirstLevelNavigation/index.viewmodel.ts`.

Import icon `<MENU_ICON>` từ `@element-plus/icons-vue`, thêm item mới vào mảng `menuItems`:
```ts
{
    name: '<FEATURE_LOWER>',
    label: '<FEATURE_NAME>',
    icon: {
        source: 'el-icon',
        component: <MENU_ICON>
    },
}
```

---

## Step 2: Thêm Navigation Routing

Mở `apps/magisk/src/views/builder/views/FirstLevelNavigation/index.vue`.

Thêm case mới vào `switch` trong `getNavCommand()`:
```ts
case '<FEATURE_LOWER>':
    states.push(['secondLeft', { component: 'FirstLevelNavigation', props: { activeItem: '<FEATURE_LOWER>' }, model: null }])
    states.push(['left', { component: '<FEATURE_NAME>Navigation', props: {}, model: null }])
    states.push(['main', { component: '<FEATURE_NAME>EditorView', props: {}, model: null }])
    states.push(['right', { component: 'none', props: {}, model: null }])
    break
```

Cũng update kiểu prop `activeItem` để thêm `'<FEATURE_LOWER>'` vào union type.

---

## Step 3: Tạo Navigation Panel (Cột Trái)

Tạo thư mục `apps/magisk/src/views/builder/views/<FEATURE_NAME>Navigation/` với 2 files:

### `index.viewmodel.ts`
- `selectedItemId = ref<string | null>(null)`
- `searchQuery = ref<string>('')`
- `filteredItems = computed(...)` — lọc từ `ProjectDataModel.projectData.<FEATURE_LOWER>`
- `selectItem(id)`, `resetManager()` functions
- CRUD methods: `addItem()`, `removeItem(id)` — gọi Commands đã tạo

### `index.vue`
- List hiển thị `filteredItems`
- Input search
- Button "Add new" gọi `addItem()`
- Click item gọi `selectItem(id)`, highlight active item
- Button xóa cho từng item

---

## Step 4: Tạo Editor View (Cột Chính)

Tạo thư mục `apps/magisk/src/views/builder/views/<FEATURE_NAME>EditorView/` với 2 files:

### `index.viewmodel.ts`
- `currentItem = computed(...)` — lấy item đang được chọn từ `selectedItemId`
- Methods `updateItem(field, value)` — gọi `Update<FEATURE_NAME>Command`

### `index.vue`
- Hiển thị form chỉnh sửa chi tiết khi `currentItem` có giá trị
- Hiển thị empty state khi chưa chọn item
- Các input fields trigger `updateItem()`

---

## Step 5: Register Components trong Plugin

Mở `apps/magisk/src/plugins/magiskLayoutCoponent.ts`.

Thêm 2 imports và 2 `app.component(...)`:
```ts
import <FEATURE_NAME>Navigation from '@/views/builder/views/<FEATURE_NAME>Navigation/index.vue'
import <FEATURE_NAME>EditorView from '@/views/builder/views/<FEATURE_NAME>EditorView/index.vue'

// Trong install():
app.component('<FEATURE_NAME>Navigation', <FEATURE_NAME>Navigation)
app.component('<FEATURE_NAME>EditorView', <FEATURE_NAME>EditorView)
```

---

## Step 6: Report

List toàn bộ files đã tạo/sửa. Xác nhận component registration đúng với tên dùng trong routing (Step 2).
