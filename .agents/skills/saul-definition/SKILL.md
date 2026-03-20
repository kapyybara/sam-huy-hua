---
name: saul-definition
description: Manage SDK definitions (models, services, functions, errors) on Saul server. Use this skill whenever the user wants to add a model, modify fields, create new services, change error codes, adjust backend API interfaces, or edit saul schemas. Trigger even if they simply describe a new data concept or route that needs to be synchronized with the backend.
compatibility: Requires Saul server running (usually localhost:3000)
---

# Saul Definition Skill

Skill này hướng dẫn cách tương tác với **Saul server API** để quản lý cấu trúc dữ liệu nền tảng là SDK definitions — bao gồm việc cấu hình các modules, models, services, functions, và errors.

---

## Step 1: Lấy Definitions hiện tại (Fetch)

Server hoạt động trên nguyên tắc **OVERWRITE HOÀN TOÀN**. Do đó bước 1 luôn là lấy dữ liệu trước.
Tải xuống cấu hình JSON mới nhất bằng cách gọi script tương tác Saul backend:

```bash
bash .agent/scripts/definition.sh get > /tmp/saul-current.json
```

File nhận được sẽ có format chuẩn theo BaseType struct:
```json
{
  "success": true,
  "data": { "modules": [...] }
}
```

---

## Step 2: Cấu hình Data Logic theo User Requirement

Xử lý `modules` payload trong file `/tmp/saul-current.json`.
Bạn có thể thao tác tuỳ ý trong mảng này:
- Định nghĩa lại `ModelDefinition[]` trong module
- Cập nhật Data type của Field ứng với BaseType values
- Định tuyến `ServiceFunction` trong object array `services`

*(Nếu bạn không nắm rõ cách định dạng Data Type và BaseType values, rẽ nhánh tham chiếu: `→ Xem references/type-reference.md`)*

*(Nếu bạn cần ví dụ tổ chức nguyên một module khép kín từ Model, Service sang Error, rẽ nhánh tham chiếu: `→ Xem references/sample-module.json`)*

---

## Step 3: Tạo payload cập nhật và Submit

Sau khi bạn đã build lại mảng `modules` một cách hoàn hảo, bọc chúng vào trong object payload có trường bắt buộc `definition`, sau đó ghi vào một file (Ví dụ: `/tmp/saul-updated.json`).

```json
{
  "definition": {
    "modules": [
      {
        "name": "user",
        "models": [],
        "errors": [],
        "services": []
      }
    ]
  }
}
```

Cuối cùng upload cấu trúc mới lên backend thông qua script:
```bash
bash .agent/scripts/definition.sh update /tmp/saul-updated.json
```

---

## Quy Tắc Bắt Buộc (Critical Rules)

- Lệnh gọi update `.agent/scripts/definition.sh update` sẽ **XOÁ SẠCH TOÀN BỘ** dữ liệu cũ và cập nhật toàn bộ bằng khối payload bạn gửi lên. Gửi thiếu Module là mất Module.
- Field `name` của model/error phải unique hoàn toàn trong khối.
- Model references bắt buộc phải tồn tại trong project thì mới tham chiếu `type: "Model"` được.
