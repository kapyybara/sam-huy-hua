---
name: backend-controller
description: Viết backend controller cho Magisk sau khi đã có saul-server.ts (sau bước run codegen / full-pipeline). Dùng khi user muốn implement service class, viết business logic cho API endpoint, tạo file controller trong apps/backend/src/controllers/magisk/, hoặc sau khi chạy xong /magisk-feature-api. Trigger khi user nói "viết controller", "implement service", "tạo backend handler", "implement API", hoặc khi Step 6 của create-magisk-feature cần thực hiện.
---

# Backend Controller Skill

Implement một Saul service controller trong `apps/backend/src/controllers/magisk/` bằng cách extend abstract class đã được codegen sinh ra trong `saul-server.ts`.

> **Điều kiện tiên quyết**: `saul-server.ts` đã được generate (sau khi chạy `/magisk-feature-api` hoặc `/full-pipeline`). Controller phải extend abstract class từ file đó.

---

## Step 1: Đọc Abstract Class từ saul-server.ts

Mở và đọc file:
```
apps/backend/src/saul-server.ts
```

Tìm `class <FeatureName>Service` trong namespace `magisk`. Ghi lại:
- Tên đầy đủ: `magisk.<FeatureName>Service`
- Danh sách tất cả **abstract methods** với đúng signature (tên, params, return type)

---

## Step 2: Tạo Controller File

Tạo file mới tại:
```
apps/backend/src/controllers/magisk/<FeatureName>Service.ts
```

> **Lưu ý**: Saul tự discover controller theo thư mục `controllers/magisk/`. Không cần đăng ký thêm ở đâu cả.

### Template chuẩn (minimal):

```typescript
import { magisk } from "../../saul-server";

export class Magisk<FeatureName>Service extends magisk.<FeatureName>Service {
    async <methodName>(<params>): Promise<any> {
        // TODO: implement business logic
        throw new Error("Not implemented");
    }
}
```

### Template với service layer (khi cần business logic phức tạp):

```typescript
import { magisk } from "../../saul-server";
import { <DomainService> } from "../../services/<domain>.service";

export class Magisk<FeatureName>Service extends magisk.<FeatureName>Service {
    async getAll(): Promise<any> {
        const svc = new <DomainService>()
        return await svc.getAll()
    }

    async getById(p_id: any): Promise<any> {
        const svc = new <DomainService>()
        const item = await svc.getById(p_id)
        if (!item) {
            throw new magisk.<NOT_FOUND_ERROR>()
        }
        return item
    }

    async create(p_data: any): Promise<any> {
        const svc = new <DomainService>()
        return await svc.create(p_data)
    }

    async update(p_id: any, p_data: any): Promise<any> {
        const svc = new <DomainService>()
        return await svc.update(p_id, p_data)
    }

    async delete(p_id: any): Promise<any> {
        const svc = new <DomainService>()
        return await svc.delete(p_id)
    }
}
```

---

## Step 3: Quy tắc bắt buộc

| # | Quy tắc |
|---|---------|
| 1 | **Tên class**: `Magisk<FeatureName>Service` extends `magisk.<FeatureName>Service` |
| 2 | **Tên file**: `<FeatureName>Service.ts` (PascalCase, khớp tên class trong saul-server) |
| 3 | **Vị trí**: `apps/backend/src/controllers/magisk/` — Saul auto-discover, không cần register thêm |
| 4 | **Không sửa** `saul-server.ts` — đây là generated file |
| 5 | **Override đủ** tất cả abstract methods (TypeScript sẽ báo lỗi nếu thiếu) |
| 6 | **Throw Saul errors** khi cần: `throw new magisk.<ERROR_NAME>()` (xem errors trong saul-server.ts) |
| 7 | Business logic phức tạp → tách sang `apps/backend/src/services/` (xem pattern ở `ProjectService.ts`) |
| 8 | Static service instances → Khai báo là `static` trên class nếu cần tái dùng (xem `MagiskProjectService.ingressService`) |

---

## Step 4: Ví dụ thực tế

### Ví dụ minimal (DeploymentService):
```typescript
// apps/backend/src/controllers/magisk/DeploymentService.ts
import { magisk } from "../../saul-server";

export class DeploymentService extends magisk.DeploymentService {
    async publish(p_data: any): Promise<any> {
        return 'oke'
    }
}
```

### Ví dụ đầy đủ (MagiskProjectService):
```typescript
// apps/backend/src/controllers/magisk/ProjectService.ts
import { magisk } from "../../saul-server";
import { ProjectService } from "../../services/project.service";

export class MagiskProjectService extends magisk.ProjectService {
    static ingressService = new IngressService(process.env.NAMESPACE)

    async createProject(p_project: any): Promise<any> {
        const projectService = new ProjectService()
        return await projectService.createProject(p_project)
    }

    async getProject(p_id: any): Promise<any> {
        const projectService = new ProjectService()
        const data = await projectService.getProject(p_id)
        if (!data.id) {
            throw new magisk.PROJECT_NOT_FOUND()
        }
        return data
    }
}
```

---

## Step 5: Verify

Sau khi tạo xong, chạy TypeScript check:
```bash
cd /Users/tienpham/dev/fidt/magisk/apps/backend && bun run build 2>&1 | tail -20
```

Không có TypeScript errors = thành công. Report file đã tạo cho user.
