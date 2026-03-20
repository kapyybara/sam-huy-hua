---
description: Scaffold a complete new Magisk feature end-to-end (Data Layer → Commands → UI Views → API). Trigger when user wants to add a new ProjectData management module, says "create a new feature", "scaffold a feature", "add new manager", or mentions building a new section of the Builder sidebar.
---

# Create Magisk Feature (Master Workflow)

Workflow tổng điều phối toàn bộ quá trình tạo một Magisk feature mới từ đầu đến cuối.

---

## Step 1: Collect Parameters

Hỏi user cung cấp các biến sau (hoặc tự suy luận từ context nếu đã rõ):

```
FEATURE_NAME    = "<PascalCase>"          # vd: ThemeModel
FEATURE_LOWER   = "<camelCase plural>"    # vd: themeModels
FEATURE_KEBAB   = "<kebab-case>"          # vd: theme-model
MENU_ICON       = "<element-plus icon>"  # vd: Brush, Palette, Grid
NEEDS_API       = true | false            # có cần Saul API backend không?
```

Xác nhận lại tất cả params với user trước khi tiếp tục.

---

## Step 2: Data Layer

Thực hiện workflow `/magisk-feature-data-layer` với các params đã thu thập.

Sau khi hoàn thành, report kết quả cho user (files đã tạo/sửa).

---

## Step 3: Commands & Undo-Redo

Thực hiện workflow `/magisk-feature-commands` với các params đã thu thập.

Sau khi hoàn thành, report kết quả.

---

## Step 4: UI Views & Navigation

Thực hiện workflow `/magisk-feature-views` với các params đã thu thập.

Sau khi hoàn thành, report kết quả.

---

## Step 5: API Integration (Điều kiện: NEEDS_API = true)

Nếu `NEEDS_API = true`, thực hiện workflow `/magisk-feature-api`.
Nếu `NEEDS_API = false`, bỏ qua bước này.

---

## Step 6: Backend Controller (Điều kiện: NEEDS_API = true)

> Thực hiện **sau** `/magisk-feature-api` vì bước đó đã chạy codegen và sinh lại `saul-server.ts` với abstract class mới.

Nếu `NEEDS_API = false`, bỏ qua bước này.

Dùng skill **`backend-controller`** để implement controller cho `<FEATURE_NAME>`.

Đọc skill tại: `.agents/skills/backend-controller/SKILL.md`

Sau khi tạo xong, report file đã tạo cho user.

---

## Step 7: TypeScript Build Check

// turbo
```bash
cd /Users/tienpham/dev/fidt/magisk/apps/magisk && bun run build 2>&1 | tail -40
```

Kiểm tra output: không có TypeScript errors. Nếu có lỗi, fix ngay trước khi tiếp tục.

---

## Step 8: UI Verification

Dùng browser subagent mở `http://localhost:5173`, navigate vào Builder, kiểm tra:
- Icon mới hiển thị trong sidebar FirstLevelNavigation
- Click icon → load đúng Manager panel (cột trái)
- Click icon → load đúng EditorView (cột phải)
- Button "Add new" tạo được item, item xuất hiện trong list

Report kết quả verify cho user.
