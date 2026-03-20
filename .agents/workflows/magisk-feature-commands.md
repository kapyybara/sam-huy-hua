---
description: Scaffold Commands and Diff Types for a new Magisk feature — adds ConfigurationDiffType entries, Diff interfaces, and Command classes for Undo/Redo. Sub-workflow of create-magisk-feature.
---

# Magisk Feature — Commands & Undo-Redo

Thiết lập Diff Types và Command Classes cho feature mới. Cần có: `FEATURE_NAME`, `FEATURE_LOWER`, `FEATURE_KEBAB`.

**Pattern reference**: Xem `AddDeploymentDiff`, `UpdateDeploymentDiff`, `RemoveDeploymentDiff` trong `Change.ts` và `AddOrUpdateDeployment.command.ts`, `RemoveDeployment.command.ts`.

---

## Step 1: Update ConfigurationDiffType

Mở `apps/magisk/src/models/ProjectData/Change.ts`.

Thêm 3 entries mới vào union type `ConfigurationDiffType`:
```ts
| 'add-<FEATURE_KEBAB>'
| 'update-<FEATURE_KEBAB>'
| 'remove-<FEATURE_KEBAB>'
```

---

## Step 2: Tạo Diff Interfaces

Trong cùng file `Change.ts`, thêm 3 interfaces mới (sau phần Deployment diffs):

```ts
// ---- <FEATURE_NAME> diffs ----

export interface Add<FEATURE_NAME>Diff extends ConfigurationDiff {
    change: 'add-<FEATURE_KEBAB>'
    <FEATURE_LOWER_SINGLE>: <FEATURE_NAME>
}

export interface Update<FEATURE_NAME>Diff extends ConfigurationDiff {
    change: 'update-<FEATURE_KEBAB>'
    <FEATURE_LOWER_SINGLE>: <FEATURE_NAME>
    old<FEATURE_NAME>?: <FEATURE_NAME>
}

export interface Remove<FEATURE_NAME>Diff extends ConfigurationDiff {
    change: 'remove-<FEATURE_KEBAB>'
    <FEATURE_LOWER_SINGLE>: <FEATURE_NAME>
}
```

Import type `<FEATURE_NAME>` từ `@/interfaces/ProjectData`.

---

## Step 3: Tạo Command Classes

Tạo 2 files trong `apps/magisk/src/commands/`:

### `AddOrUpdate<FEATURE_NAME>.command.ts`

Implement pattern từ `AddOrUpdateDeployment.command.ts`:
- Constructor nhận `item: <FEATURE_NAME>`, `isUpdate: boolean`, `old<FEATURE_NAME>?: <FEATURE_NAME>`
- Build `Add<FEATURE_NAME>Diff` hoặc `Update<FEATURE_NAME>Diff` tương ứng
- `execute()` gọi `ProjectDataManipulateController.applyDiffs()`

### `Remove<FEATURE_NAME>.command.ts`

Implement pattern từ `RemoveDeployment.command.ts`:
- Constructor nhận item cần xóa
- Build `Remove<FEATURE_NAME>Diff`
- `execute()` gọi `ProjectDataManipulateController.applyDiffs()`

---

## Step 4: Report

List toàn bộ files đã tạo/sửa. Kiểm tra import types đúng, không có TypeScript errors.
