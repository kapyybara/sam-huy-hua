---
description: Add a new node type to Magisk's Event Handler graph — creates executor, registers in registry, and scaffolds VueFlow UI components. Trigger when user says "thêm node", "add node handler", "tạo node mới cho handler", "new handler node", or wants to extend the event handler graph with a new processing step type.
---

# Add Handler Node

Thêm một node type mới vào Event Handler system của Magisk. Node là bước xử lý trong handler pipeline — nhận `context` chung và bổ sung output vào đó.

**Đọc skill trước khi bắt đầu**: `.agent/skills/handler-node/SKILL.md`

---

## Thông tin cần có

Xác nhận với user:
- **Node type name** (kebab-case, dùng làm identifier): ví dụ `http-request`
- **Node display name** (PascalCase): ví dụ `HttpRequest`
- **Config params**: node cần những input gì từ user? Cái nào support `{{context.x.y}}`?
- **Logic**: node làm gì? (gọi API, transform data, navigate, lưu storage...)

---

## Step 1: Tạo Node Config Interface

Mở `apps/magisk/src/interfaces/ProjectData/EventHandler.ts`.

Thêm interface config cho node mới:

```typescript
export interface <NodeName>NodeConfig {
    // Các params của node
    // Params nào user muốn bind data từ context → type là string để support {{context.x.y}}
}
```

---

## Step 2: Tạo Executor

Tạo file mới `apps/magisk/src/services/handler/nodes/<NodeName>Node.ts`.

```typescript
import type { NodeExecutor } from '../NodeExecutorRegistry'
import type { <NodeName>NodeConfig } from '@/interfaces/ProjectData/EventHandler'
import { resolveTemplate } from '../TemplateResolver'

export const <NodeName>NodeExecutor: NodeExecutor = async (node, context) => {
    const config = node.config as <NodeName>NodeConfig
    // Resolve template syntax: resolveTemplate(config.param, context)
    // Implement logic...
    return result  // → tự động lưu vào context[node.id]
}
```

// turbo

---

## Step 3: Register Executor

Mở `apps/magisk/src/services/handler/NodeExecutorRegistry.ts`.

Thêm import và register:

```typescript
import { <NodeName>NodeExecutor } from './nodes/<NodeName>Node'
NodeExecutorRegistry.register('<node-type-kebab>', <NodeName>NodeExecutor)
```

---

## Step 4: Tạo VueFlow Node Component

Tạo `apps/magisk/src/views/builder/views/EventHandlerEditor/nodes/<NodeName>NodeVF.vue`.

Dùng pattern từ `SaulServiceNodeVF.vue` hoặc `JsLogicNodeVF.vue` làm reference.

Requirements:
- `<Handle type="target">` ở top (input)
- `<Handle type="source">` ở bottom (output)
- Hiển thị node label và preview config key fields

---

## Step 5: Tạo Node Config Panel

Tạo `apps/magisk/src/views/builder/views/EventHandlerEditor/panels/<NodeName>NodeConfig.vue`.

Requirements:
- Form fields cho mỗi config param
- Hint text khi param support `{{context.x.y}}` syntax
- Mutations phải qua Command pattern (có undo/redo)

---

## Step 6: Register vào VueFlow nodeTypes

Mở `apps/magisk/src/views/builder/views/EventHandlerEditor/index.vue` (hoặc viewmodel).

Thêm node type mới vào `nodeTypes` map:

```typescript
import <NodeName>NodeVF from './nodes/<NodeName>NodeVF.vue'

const nodeTypes = {
    // ...existing types...
    '<node-type-kebab>': <NodeName>NodeVF,
}
```

---

## Step 7: Report

List toàn bộ files đã tạo/sửa. Kiểm tra:
- TypeScript không có errors
- Node type kebab-case nhất quán giữa registry và VueFlow nodeTypes
- Template syntax `{{context.x.y}}` được resolve đúng trong executor
