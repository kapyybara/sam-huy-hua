---
name: handler-node
description: Scaffold a new Event Handler node type for Magisk's Event Handler system. Use when user wants to add a new node type to the handler graph, says "thêm node mới", "tạo handler node", "add handler node", "create a new node type for event handler", or mentions extending the handler graph with a new processing step. This node system is the extensible executor registry that powers Magisk's runtime event handling.
---

# Magisk — Handler Node

Tạo một node type mới cho Event Handler graph của Magisk. Mỗi node là một bước xử lý trong handler pipeline, nhận `context` (shared object tích lũy từ tất cả node trước) và trả về output được merge vào context.

---

## Architecture Overview

```
EventHandler graph
  └─► HandlerExecutor chạy tuần tự
        ├─► Node 1: execute → context[node1.id] = output
        ├─► Node 2: đọc {{context.node1.field}} → context[node2.id] = output
        └─► Node N...
```

**Key rules:**
- Node KHÔNG nhận input từ node liền trước mà đọc từ **context global**
- Params của node dùng template syntax `{{context.nodeId.field}}`
- Return value của executor tự động được lưu vào `context[node.id]`
- Core engine (`HandlerExecutor.ts`) KHÔNG cần sửa khi thêm node mới
- Edge trong graph chỉ define thứ tự chạy, không define data flow

---

## Step 1: Tạo Node Config Interface

Trong `apps/magisk/src/interfaces/ProjectData/EventHandler.ts`, thêm interface config:

```typescript
export interface <NodeName>NodeConfig {
    // Fields config của node — values có thể dùng {{context.x.y}} template
    someParam: string        // ví dụ
    anotherParam?: string
}
```

---

## Step 2: Tạo Node Executor

Tạo file `apps/magisk/src/services/handler/nodes/<NodeName>Node.ts`:

```typescript
import type { NodeExecutor } from '../NodeExecutorRegistry'
import type { <NodeName>NodeConfig } from '@/interfaces/ProjectData/EventHandler'
import { resolveTemplate } from '../TemplateResolver'

export const <NodeName>NodeExecutor: NodeExecutor = async (node, context) => {
    const config = node.config as <NodeName>NodeConfig

    // Resolve template syntax trong các param
    const resolvedParam = resolveTemplate(config.someParam, context)

    // === Logic của node ở đây ===
    const result = await doSomething(resolvedParam)

    // Return value → tự động lưu vào context[node.id]
    return result
}
```

**Lưu ý:**
- Executor là `async function` — có thể `await` bất cứ thứ gì
- Import `resolveTemplate` để xử lý `{{context.x.y}}` trong params
- Return value sẽ được `HandlerExecutor` merge vào `context[node.id]`
- Không cần sửa `HandlerExecutor.ts` hay bất kỳ core file nào khác

---

## Step 3: Register vào NodeExecutorRegistry

Mở `apps/magisk/src/services/handler/NodeExecutorRegistry.ts`, thêm:

```typescript
import { <NodeName>NodeExecutor } from './nodes/<NodeName>Node'

// Trong phần register (cuối file hoặc init function):
NodeExecutorRegistry.register('<node-type-kebab>', <NodeName>NodeExecutor)
```

`'<node-type-kebab>'` phải khớp với `node.type` trong graph data.

---

## Step 4: Update NodeType Union (optional, for type safety)

Trong `apps/magisk/src/interfaces/ProjectData/EventHandler.ts`, update `NodeType`:

```typescript
// Thêm type mới vào union (nếu muốn strict typing, không bắt buộc vì type là open string)
export type KnownNodeType =
    | 'saul-service'
    | 'js-logic'
    | '<node-type-kebab>'   // ← thêm vào đây
    | string
```

---

## Step 5: Tạo VueFlow Node Component (UI)

Tạo `apps/magisk/src/views/builder/views/EventHandlerEditor/nodes/<NodeName>NodeVF.vue`:

```vue
<script setup lang="ts">
import { Handle, Position } from '@vue-flow/core'
import type { HandlerNode } from '@/interfaces/ProjectData/EventHandler'

defineProps<{ data: HandlerNode }>()
</script>

<template>
    <div class="handler-node <node-type-kebab>-node">
        <Handle type="target" :position="Position.Top" />
        
        <div class="node-header">
            <span class="node-icon"><!-- icon --></span>
            <span class="node-label">{{ data.label || '<Node Display Name>' }}</span>
        </div>
        
        <div class="node-body">
            <!-- Preview thông tin config nếu cần -->
        </div>
        
        <Handle type="source" :position="Position.Bottom" />
    </div>
</template>
```

---

## Step 6: Tạo Node Config Panel (UI)

Tạo `apps/magisk/src/views/builder/views/EventHandlerEditor/panels/<NodeName>NodeConfig.vue`:

```vue
<script setup lang="ts">
import type { HandlerNode, <NodeName>NodeConfig } from '@/interfaces/ProjectData/EventHandler'

const props = defineProps<{ node: HandlerNode }>()
const config = computed(() => props.node.config as <NodeName>NodeConfig)
// Emit updates thông qua Command pattern để có undo/redo
</script>

<template>
    <div class="node-config-panel">
        <h3><NodeName> Config</h3>
        <!-- Form fields cho từng config param -->
        <!-- Hint: dùng {{context.nodeId.field}} trong input values -->
    </div>
</template>
```

---

## Step 7: Register Node trong VueFlow

Trong `EventHandlerEditor/index.vue` (hoặc viewmodel), thêm node type vào VueFlow node types map:

```typescript
import <NodeName>NodeVF from './nodes/<NodeName>NodeVF.vue'

const nodeTypes = {
    'saul-service': SaulServiceNodeVF,
    'js-logic': JsLogicNodeVF,
    '<node-type-kebab>': <NodeName>NodeVF,   // ← thêm vào đây
}
```

---

## Checklist

- [ ] Interface config trong `EventHandler.ts`
- [ ] Executor file `services/handler/nodes/<NodeName>Node.ts`
- [ ] Register trong `NodeExecutorRegistry.ts`
- [ ] VueFlow node component `*NodeVF.vue`
- [ ] Node config panel `*NodeConfig.vue`
- [ ] Register trong VueFlow nodeTypes map
