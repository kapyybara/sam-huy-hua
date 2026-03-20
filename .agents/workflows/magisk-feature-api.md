---
description: Sync a new Magisk feature with the Saul backend API — updates API definitions and generates server + client TypeScript code. Optional sub-workflow of create-magisk-feature, only needed when feature has a backend API.
---

# Magisk Feature — API Integration (Saul)

Sync entity mới với backend API qua Saul. Cần có: `FEATURE_NAME`.

**Output paths cố định**:
- Server: `apps/backend/src/saul-server.ts`
- Client: `apps/magisk/src/saul-client.ts`

---

## Step 1: Đọc Saul Skills

Đọc 2 skill files để nắm API:
- `apps/magisk/.agent/skills/saul-definition/SKILL.md`
- `apps/magisk/.agent/skills/saul-codegen/SKILL.md`

---

## Step 2: Chạy Full Pipeline

Gọi workflow `/full-pipeline` với context sau:

- **Mục đích**: Thêm model/module Saul cho entity `<FEATURE_NAME>`
- **SERVER_OUTPUT_PATH**: `/Users/tienpham/dev/fidt/magisk/apps/backend/src/saul-server.ts`
- **CLIENT_OUTPUT_PATH**: `/Users/tienpham/dev/fidt/magisk/apps/magisk/src/saul-client.ts`

Trong Phase 1 (Update Definition) của `/full-pipeline`, thêm module/model mới cho `<FEATURE_NAME>` vào definitions.

---

## Step 3: Report

Xác nhận server và client files đã được generate thành công, không có errors.
