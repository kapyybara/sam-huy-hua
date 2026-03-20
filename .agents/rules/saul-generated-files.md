# Agent Rules

## 🚫 KHÔNG ĐƯỢC sửa trực tiếp các file generated

Hai file sau được **auto-generated bởi Saul codegen** và **KHÔNG ĐƯỢC chỉnh sửa thủ công**:

- `apps/magisk/src/saul-client.ts` — TypeScript client SDK (generated)
- `apps/backend/src/saul-server.ts` — TypeScript server types (generated)

Mọi thay đổi thủ công vào hai file trên **sẽ bị ghi đè** lần sau khi chạy codegen và gây mất dữ liệu.

---

## ✅ Quy trình đúng để thay đổi Saul API

Thay vì sửa trực tiếp, hãy dùng một trong các workflow sau:

### Chỉ cần thay đổi definitions (models, services, functions, errors)
→ Dùng workflow `/update-definition`
- File: `.agents/workflows/update-definition.md`
- Khi nào dùng: Thêm/sửa/xóa model, service, function, error trong Saul SDK

### Chỉ cần re-generate code từ definitions hiện tại
→ Dùng workflow `/generate-code`
- File: `.agents/workflows/generate-code.md`
- Khi nào dùng: Definitions đã đúng, chỉ cần regenerate lại `saul-client.ts` hoặc `saul-server.ts`

### Cần thay đổi definitions VÀ regenerate code
→ Dùng workflow `/full-pipeline`
- File: `.agents/workflows/full-pipeline.md`
- Khi nào dùng: End-to-end — update definition + generate cả server lẫn client code

---

## Tóm tắt quyết định

```
Muốn thay đổi saul-client.ts hoặc saul-server.ts?
        │
        ├─ Chỉ cần regenerate (definitions ok)?  → /generate-code
        │
        ├─ Cần sửa definition trước?             → /update-definition → /generate-code
        │                                           hoặc gộp luôn   → /full-pipeline
        │
        └─ ❌ KHÔNG được sửa file trực tiếp
```
