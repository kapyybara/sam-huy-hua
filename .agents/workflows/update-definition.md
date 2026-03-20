---
description: Update Saul SDK definitions (models, services, functions, and errors). Trigger when user wants to add a new model, create a new service, edit a backend error, change field types, or says "update definition".
---

# Update Definition Workflow

Workflow này thay đổi SDK definition trên Saul server. Vì API **overwrite toàn bộ**, ta cần fetch array → modify theo yêu cầu → gói vào payload PUT lên lại.

## Steps

1. Đọc nội dung skill `saul-definition` để hiểu data architecture.

// turbo
2. Fetch definitions hiện tại từ server:
   ```bash
   bash .agent/scripts/definition.sh get > /tmp/saul-current-definitions.json
   ```

3. Xem nội dung file json tải ở `/tmp/saul-current-definitions.json`. Hãy bóc xuất mảng `data.modules` ra làm việc.

4. Modify modules array theo yêu cầu:
   - **Thêm module mới**: Thêm object module vào array modules
   - **Sửa module**: Tìm module theo `name`, sửa `models`/`errors`/`services`
   - **Xóa module**: Loại module ra khỏi array
   - **Thêm model vào module**: Tìm module, thêm object vào `models[]`
   - **Thêm service function**: Tìm module → service → thêm vào `functions[]`
   - **Thêm error**: Thêm vào `errors[]` của module VÀ thêm vào `errorTypes[]` của function liên quan
   
   Lưu file JSON đã gói sẵn wrapper vào file `/tmp/saul-updated-definitions.json`:
   ```json
   { "definition": { "modules": [...] } }
   ```

5. PUT cấu trúc definition mới lên server:
   ```bash
   bash .agent/scripts/definition.sh update /tmp/saul-updated-definitions.json
   ```

// turbo
6. Verify bằng cách GET lại xem thay đổi đã được áp dụng:
   ```bash
   bash .agent/scripts/definition.sh get | jq '.data.modules | length'
   ```

## Lưu ý

- Mọi `module` field trong models, errors, services, functions phải khớp chính xác với `name` của module cha khai báo ở ngoài cùng.
- Khi thêm model reference (`type: "Model"`), model đó phải tồn tại trong definitions.
