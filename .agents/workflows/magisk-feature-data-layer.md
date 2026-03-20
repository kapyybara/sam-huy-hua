---
description: Scaffold the Data Layer for a new Magisk feature — creates the TypeScript interface, updates ProjectData root type, reactive model default state, and serialize/deserialize logic. Sub-workflow of create-magisk-feature.
---

# Magisk Feature — Data Layer

Thiết lập toàn bộ data layer cho feature mới. Cần có: `FEATURE_NAME`, `FEATURE_LOWER`, `FEATURE_KEBAB`.

**Pattern reference**: Xem `src/interfaces/ProjectData/Deployment.ts` và cách `deployments` được thêm vào toàn bộ hệ thống.

---

## Step 1: Tạo Interface File

Tạo file `apps/magisk/src/interfaces/ProjectData/<FEATURE_NAME>.ts`.

Định nghĩa interface chính cho entity với ít nhất các fields: `id: string`, `name: string`, và các field business logic phù hợp với feature.

**Xem pattern**: `src/interfaces/ProjectData/Deployment.ts`

---

## Step 2: Update Root ProjectData Interface

Mở `apps/magisk/src/interfaces/ProjectData/index.ts`:

1. Thêm dòng export: `export * from './<FEATURE_NAME>'`
2. Import type mới: `import type { <FEATURE_NAME> } from './<FEATURE_NAME>'`
3. Thêm field vào `ProjectData` interface: `<FEATURE_LOWER>: <FEATURE_NAME>[]`

---

## Step 3: Update Reactive Model Default State

Mở `apps/magisk/src/models/ProjectData.ts`.

Thêm field vào object `projectData` reactive:
```ts
<FEATURE_LOWER>: [],
```

**Xem pattern**: field `deployments: []` đã có trong file này.

---

## Step 4: Update Serialize / Deserialize

Mở `apps/magisk/src/utils/projectData.ts`:

**Trong `serializeProjectForSave`**: Thêm field:
```ts
<FEATURE_LOWER>: project.<FEATURE_LOWER> || [],
```

**Trong `deserializeProjectAfterLoad`**: Thêm field vào return object:
```ts
<FEATURE_LOWER>: data.<FEATURE_LOWER> || [],
```

---

## Step 5: Report

List toàn bộ files đã tạo/sửa và xác nhận không có TypeScript errors trong các files này.
