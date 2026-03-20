---
name: magisk-architecture
description: Magisk App — Architecture rules & coding standards. Read this before working on any feature in apps/magisk. Contains mandatory patterns for Commands, ViewModels, Diff Types, Layout, and data mutations. Use when building any feature, adding commands, modifying ProjectData, or creating views in the Magisk Builder app.
---

# Magisk App — Project Rules

Các quy tắc bắt buộc khi phát triển tính năng trong `apps/magisk`. Đây là project Vue 3 + TypeScript với kiến trúc MVVM nghiêm ngặt.

---

## 0. KHÔNG sửa trực tiếp file Saul generated

> **RULE**: `apps/magisk/src/saul-client.ts` và `apps/backend/src/saul-server.ts` là file **auto-generated** — **KHÔNG ĐƯỢC chỉnh sửa thủ công**.

Mọi thay đổi thủ công sẽ bị **ghi đè** lần sau khi chạy codegen. Thay vào đó, hãy dùng workflow phù hợp:

| Mục tiêu | Workflow |
|----------|----------|
| Chỉ cần thay đổi definition (model, service, function, error) | `/update-definition` |
| Chỉ cần regenerate lại code từ definition hiện tại | `/generate-code` |
| Cần cả hai (thay đổi definition + regenerate) | `/full-pipeline` |

---

## 1. KHÔNG mutate state trực tiếp từ Vue component

> **RULE**: Vue components KHÔNG được mutate `ProjectDataModel.projectData` trực tiếp.

Mọi thay đổi dữ liệu phải đi qua luồng:

```
Component → $execute(new XxxCommand()) → applyDiffs() → State
```

**Sai:**
```typescript
// ❌ TRONG COMPONENT
ProjectDataModel.projectData.deployments.push(newDeployment)
```

**Đúng:**
```typescript
// ✅ TRONG COMPONENT
$execute(new AddOrUpdateDeploymentCommand(newDeployment, false, undefined))
```

---

## 2. Command Pattern — Quy tắc tạo Command mới

Mỗi action thay đổi data = 1 Command class trong `src/commands/`.

```typescript
// src/commands/YourAction.command.ts
import type { Command } from './Command.base'
import type { Change } from '@/models/ProjectData/Change'
import { ProjectDataManipulateController } from '@/controllers/ProjectDataManipulate.controller'
import { BuilderViewModel } from '@/views/builder/index.viewmodel'

export class YourActionCommand implements Command {
    name = 'your-action'
    change: Change

    constructor(/* params */) {
        const diff = { type: 'configuration', change: 'add-xxx', ... }

        this.change = {
            diffs: [diff],
            meta: {
                name: 'your-action',
                UIState: BuilderViewModel.getCurrentUIState(), // ← BẮT BUỘC
            }
        }
    }

    execute(): void {
        this.controller.applyDiffs(this.change.diffs, this.change.meta)
    }
}
```

**Bắt buộc**: `meta.UIState` phải được set = `BuilderViewModel.getCurrentUIState()` để undo/redo restore đúng UI.

**Execute từ component/viewmodel:**
```typescript
import { $execute } from '@/composables/useExecute'
$execute(new YourActionCommand(...))
```

---

## 3. Thêm Diff Type mới

Khi thêm feature mới cần Undo/Redo, thực hiện theo thứ tự:

1. **`src/models/ProjectData/Change.ts`**: Thêm vào `ConfigurationDiffType` union + tạo Diff interface
2. **`src/controllers/ProjectDataManipulate.controller.ts`**: Thêm case trong `applyDiff()` và `revertDiff()`
3. **`src/commands/`**: Tạo Command class(es) sử dụng Diff mới

**Reference hoàn chỉnh**: Xem nhóm `Deployment` — `AddDeploymentDiff`, `UpdateDeploymentDiff`, `RemoveDeploymentDiff`.

---

## 4. ViewModel Pattern — Static Class

Magisk dùng **static class làm ViewModel**, không dùng Pinia hay composable state.

```typescript
// Naming: <ViewName>ViewModel hoặc dạng exported functions/refs
export class DeploymentsViewModel {
    static items = computed(() => ProjectDataModel.projectData.deployments || [])
    static selectedId = ref<string | null>(null)

    static selectItem(id: string) { ... }
    static resetForm() { ... }
}
```

| Pattern | Dùng cho |
|---------|----------|
| `static ref<T>()` | Reactive single value |
| `static reactive<T>()` | Reactive object/array |
| `static computed()` | Derived/filtered values |
| `static methods` | Business logic, form handlers |

**File đặt tại**: `src/views/builder/views/<FeatureName>/index.viewmodel.ts`

---

## 5. EventStore Pattern

EventStore chứa toàn bộ `watch` và lifecycle hooks của một view — **không** đặt trong `.vue` file.

```typescript
// src/views/builder/views/YourView/index.eventstore.ts
export const useYourViewEventStore = () => {
    onMounted(() => { ... })
    onBeforeUnmount(() => { ... })
    watch(someRef, handler, { deep: true })
}
```

Gọi một lần trong `<script setup>` của root component của view.

---

## 6. Layout & Điều hướng Panel

Builder có 4 slots: `secondLeft` (48px), `left` (300px), `main` (flex), `right` (300px).

Để chuyển panel hiển thị, dùng `BulderUINavigateCommand`:

```typescript
import { BulderUINavigateCommand } from '@/commands/BulderUINavigate.command'
import type { BuilderStateUI, UnitLayoutState } from '@/interfaces/BuilderStateUI'

const states: [keyof BuilderStateUI, UnitLayoutState][] = [
    ['left', { component: 'YourNavigation', props: {}, model: null }],
    ['main', { component: 'YourEditorView', props: {}, model: null }],
    ['right', { component: 'none', props: {}, model: null }],
]
$execute(new BulderUINavigateCommand(states))
```

Component name trong `component` field phải khớp với tên đã register trong `src/plugins/magiskLayoutCoponent.ts`.

---

## 7. Register Global Layout Components

View mới muốn được mount động trong layout system **phải** được register trong:

```typescript
// src/plugins/magiskLayoutCoponent.ts
import YourView from '@/views/builder/views/YourView/index.vue'

app.component('YourView', YourView)
```

---

## 8. Thêm Feature vào ProjectData

Khi thêm entity mới vào ProjectData, cần update **đủ 4 nơi** theo thứ tự:

| # | File | Việc cần làm |
|---|------|--------------|
| 1 | `src/interfaces/ProjectData/<Entity>.ts` | Tạo interface |
| 2 | `src/interfaces/ProjectData/index.ts` | Export + thêm field vào `ProjectData` |
| 3 | `src/models/ProjectData.ts` | Thêm field default vào `projectData` reactive |
| 4 | `src/utils/projectData.ts` | Thêm field trong `serializeProjectForSave` và `deserializeProjectAfterLoad` |

**Reference**: Xem `Deployment.ts`, field `deployments` trong `ProjectData.ts` và `projectData.ts`.

---

## 9. Keyboard Events — Quản lý listeners

Không dùng `addEventListener` trực tiếp trong component. Đăng ký trong ViewModel:

```typescript
static keyEvents: { event: string, callback: EventListener }[] = []

static handleKeyEvents() {
    const callback = (e: KeyboardEvent) => { ... }
    this.keyEvents.push({ event: 'keydown', callback })
    document.addEventListener('keydown', callback)
}

static removeKeyEvents() {
    this.keyEvents.forEach(e => document.removeEventListener(e.event, e.callback))
    this.keyEvents = []
}
```

Gọi `handleKeyEvents()` trong `onMounted`, `removeKeyEvents()` trong `onBeforeUnmount` — thường đặt trong EventStore.

---

## 10. Quick Reference

| Cần làm | Xem ở đâu |
|---------|-----------|
| Thêm Command mới | `src/commands/AddOrUpdateDeployment.command.ts` |
| Thêm Diff Type | `src/models/ProjectData/Change.ts` (nhóm Deployment) |
| Thêm navigation sidebar item | `FirstLevelNavigation/index.viewmodel.ts` + `index.vue` |
| Thêm Settings tab | `SettingsNavigation/index.viewmodel.ts` + `SettingsView/modules/` |
| Register layout component | `src/plugins/magiskLayoutCoponent.ts` |
| Serialize/deserialize data | `src/utils/projectData.ts` |
| Global reactive state | `src/models/ProjectData.ts` |
| Undo/Redo engine | `src/controllers/ProjectDataManipulate.controller.ts` |
| Execute command | `import { $execute } from '@/composables/useExecute'` |

---

## Cấu trúc thư mục

```
apps/magisk/src/
├── commands/           # Command classes (1 file = 1 action)
├── composables/        # Vue Composables tái sử dụng
├── controllers/        # Business logic (static classes)
├── interfaces/         # TypeScript interfaces
│   └── ProjectData/    # ProjectData entity interfaces
├── models/             # Reactive state
│   ├── ProjectData.ts          # Main reactive state
│   └── ProjectData/Change.ts   # Diff types & interfaces
├── plugins/            # Vue plugins (magiskLayoutCoponent.ts)
├── utils/              # Pure functions (projectData.ts: serialize/deserialize)
└── views/builder/
    ├── index.viewmodel.ts         # BuilderViewModel (global UI state)
    ├── index.eventstore.ts        # useBuilderEventStore
    └── views/
        ├── FirstLevelNavigation/  # Icon sidebar (thêm nav item ở đây)
        ├── SettingsNavigation/    # Settings tabs
        ├── SettingsView/modules/  # Settings panels (Deployments, Routing...)
        └── <FeatureName>*/       # Feature Navigation + EditorView pairs
```
