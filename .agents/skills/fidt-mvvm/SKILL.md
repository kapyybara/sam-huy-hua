---
name: fidt-mvvm
description: Implement MVVM trong Magisk Builder app (apps/magisk). FIDT MVVM khác với MVVM chuẩn: ViewModel là static class (không phải instance), không dùng Pinia, EventStore tách riêng khỏi Vue component. Dùng khi user muốn tạo ViewModel, viết EventStore, implement feature mới trong Builder, thêm reactive state, hoặc tổ chức business logic cho một View trong apps/magisk. Trigger khi user nói "tạo viewmodel", "viết eventstore", "thêm reactive state", "implement feature trong builder", "tổ chức MVVM", hoặc "viết business logic cho view".
---

# FIDT MVVM Skill

Kiến trúc MVVM của Magisk Builder — **khác với MVVM chuẩn**: ViewModel là **static class** (không phải instance hay composable), EventStore tách riêng, không dùng Pinia.

---

## Tổng quan 3 layer

```
View (.vue)          →  Template + UI bindings
ViewModel (static)   →  Reactive state + business logic
EventStore           →  watch/lifecycle hooks (tách khỏi .vue)
```

---

## Layer 1: ViewModel — Static Class

### Quy tắc bắt buộc

- **ViewModel là static class** — không instantiate, không inject, không Pinia
- **File**: `src/views/builder/views/<FeatureName>/index.viewmodel.ts`
- **Naming**: `<FeatureName>ViewModel`
- **Reactive state** dùng `ref`, `reactive`, `computed` từ Vue — khai báo trực tiếp trên class

### Template:

```typescript
// src/views/builder/views/<FeatureName>/index.viewmodel.ts
import { computed, reactive, ref } from "vue";
import { ProjectDataModel } from "@/models/ProjectData";
import type { <Entity> } from "@/interfaces/ProjectData";
import { CommandController } from "@/controllers/CommandController";
import { <ActionCommand> } from "@/commands/<Action>.command";

export class <FeatureName>ViewModel {
    // --- Derived state từ ProjectData (read-only, computed) ---
    static items = computed(() => ProjectDataModel.projectData.<entities> || [])

    // --- Local UI state ---
    static selectedId = ref<string | null>(null)
    static isLoading = ref(false)
    static search = ref('')

    // --- Form state dùng reactive (object nhiều field) ---
    static form = reactive<Partial<Entity>>({
        name: '',
        // ...
    })

    // --- Business logic methods ---
    static selectItem(id: string) {
        this.selectedId.value = id
    }

    static saveItem() {
        // validate...
        const command = new <ActionCommand>(this.form)
        CommandController.execute(command)
        this.resetForm()
    }

    static resetForm() {
        this.form.name = ''
        // ...
    }
}
```

### Phân biệt ref vs reactive vs computed:

| Primitive    | Khi nào dùng                        |
|--------------|-------------------------------------|
| `ref<T>()`   | Single value (string, number, null) |
| `reactive<T>()` | Object/form với nhiều field      |
| `computed()` | Derived từ ProjectData hoặc state khác |

### ❌ KHÔNG làm trong ViewModel:
- Mutation trực tiếp vào `ProjectDataModel.projectData` — phải qua Command
- `onMounted`, `watch` — đặt trong EventStore
- Instantiate ViewModel (`new XxxViewModel()`)

---

## Layer 2: EventStore — Lifecycle & Watchers

EventStore chứa **toàn bộ** `watch` và lifecycle hooks của một view. **Không** đặt trong `.vue` file.

### File: `index.eventstore.ts`

```typescript
// src/views/builder/views/<FeatureName>/index.eventstore.ts
import { watch, onMounted, onBeforeUnmount } from "vue";
import { <FeatureName>ViewModel } from "./<FeatureName>/index.viewmodel";
import { <OtherViewModel> } from "@/views/builder/views/<Other>/index.viewmodel";

export const use<FeatureName>EventStore = () => {
    onMounted(() => {
        <FeatureName>ViewModel.loadData()
        <FeatureName>ViewModel.handleKeyEvents()
    })

    onBeforeUnmount(() => {
        <FeatureName>ViewModel.removeKeyEvents()
        <FeatureName>ViewModel.resetForm()
    })

    // Phản ứng khi global state thay đổi
    watch(<OtherViewModel>.someRef, (newVal) => {
        <FeatureName>ViewModel.syncWith(newVal)
    }, { deep: true })
}
```

### Gọi trong root .vue của view:

```vue
<script setup lang="ts">
import { use<FeatureName>EventStore } from "./index.eventstore";

use<FeatureName>EventStore()  // Gọi 1 lần duy nhất ở root component
</script>
```

---

## Layer 3: Vue Component (.vue) — Thin UI Layer

Component chỉ làm template binding và gọi ViewModel methods. **Không** chứa business logic.

```vue
<script setup lang="ts">
import { <FeatureName>ViewModel } from "./<FeatureName>/index.viewmodel";
import { use<FeatureName>EventStore } from "./index.eventstore";

// Chỉ gọi EventStore ở root component của view
use<FeatureName>EventStore()
</script>

<template>
  <div>
    <!-- Binding trực tiếp vào static refs/computed của ViewModel -->
    <div v-for="item in <FeatureName>ViewModel.items" :key="item.id">
      {{ item.name }}
    </div>

    <!-- Gọi method ViewModel khi có action -->
    <button @click="<FeatureName>ViewModel.saveItem()">Save</button>

    <!-- Two-way binding vào reactive form -->
    <input v-model="<FeatureName>ViewModel.form.name" />
  </div>
</template>
```

> **Child components**: Không gọi EventStore, chỉ import ViewModel để binding.

---

## Thay đổi Data — Luồng bắt buộc

```
Component → CommandController.execute(new XxxCommand()) → applyDiffs() → ProjectData state
```

**Sai:**
```typescript
// ❌ Mutation trực tiếp từ component hoặc ViewModel
ProjectDataModel.projectData.items.push(newItem)
```

**Đúng:**
```typescript
// ✅ Trong ViewModel method
import { CommandController } from "@/controllers/CommandController";
import { AddItemCommand } from "@/commands/AddItem.command";

static saveItem() {
    const command = new AddItemCommand(this.form)
    CommandController.execute(command)  // hoặc $execute() từ composable
}
```

> Xem thêm skill `magisk-architecture` để biết cách tạo Command + Diff Type.

---

## Keyboard Events trong ViewModel

```typescript
// Khai báo trong ViewModel
static keyEvents: { event: string, callback: EventListener }[] = []

static handleKeyEvents() {
    const callback = (e: KeyboardEvent) => {
        if (e.key === 'Delete') this.deleteSelected()
    }
    this.keyEvents.push({ event: 'keydown', callback })
    document.addEventListener('keydown', callback)
}

static removeKeyEvents() {
    this.keyEvents.forEach(e => document.removeEventListener(e.event, e.callback))
    this.keyEvents = []
}
```

Gọi trong EventStore:
```typescript
onMounted(() => <FeatureName>ViewModel.handleKeyEvents())
onBeforeUnmount(() => <FeatureName>ViewModel.removeKeyEvents())
```

---

## Cấu trúc thư mục một Feature

```
src/views/builder/views/<FeatureName>/
├── index.vue                    ← Root component (gọi EventStore)
├── index.viewmodel.ts           ← Static ViewModel class
├── index.eventstore.ts          ← watch + lifecycle
└── <SubView>/
    ├── index.vue
    └── index.viewmodel.ts       ← Sub-ViewModel nếu phức tạp
```

---

## Quick Reference

| Cần làm | Pattern |
|---------|---------|
| Reactive list từ ProjectData | `static items = computed(() => ProjectDataModel.projectData.xxx \|\| [])` |
| Selected ID | `static selectedId = ref<string \| null>(null)` |
| Form nhiều field | `static form = reactive<Partial<T>>({...})` |
| Khi user click action | Gọi `CommandController.execute(new XxxCommand(...))` trong method |
| React khi state khác thay đổi | Dùng `watch()` trong EventStore |
| Cleanup khi unmount | `onBeforeUnmount()` trong EventStore |
| Keyboard shortcut | `handleKeyEvents()` + `removeKeyEvents()` trong ViewModel, gọi từ EventStore |

---

## Ví dụ thực tế: DeploymentsViewModel

→ Xem file: `apps/magisk/src/views/builder/views/SettingsView/modules/Deployments/index.viewmodel.ts`

Pattern hoàn chỉnh: computed list, reactive form, saveItem, deleteItem, resetForm.

## Ví dụ thực tế: RoutingViewModel + EventStore

→ Xem:
- `apps/magisk/src/views/builder/views/SettingsView/modules/Routing/index.viewmodel.ts`
- `apps/magisk/src/views/builder/views/RoutingSidebar/index.eventstore.ts`

Pattern: watch trên ViewModel khác để sync UI state.
