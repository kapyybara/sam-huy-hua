---
description: End-to-end pipeline — load definitions, update them, and generate typed server & client code with Saul. Trigger when user wants to do a full code generation pass, modify definitions, or says "run the full saul pipeline". 
---

# Full Pipeline Workflow

Workflow tổng hợp: Change Definition → Generate Server Code → Generate Client Code → Save Files.

## Steps

1. Đọc nội dung 2 skill sau để hiểu API:
   - `saul-definition`
   - `saul-codegen`

---

### Phase 1: Update Definition

// turbo
2. Fetch definitions hiện tại:
   ```bash
   bash .agent/scripts/definition.sh get > /tmp/saul-current-modules.json
   ```

3. Xem definitions hiện tại từ file `/tmp/saul-current-modules.json`.
   Lưu ý: Bạn phải bóc tách lấy field `data.modules` khi làm việc với file JSON này.

4. Modify modules theo yêu cầu user, lưu vào `/tmp/saul-updated-definitions.json` với dạng bọc API wrap:
   ```json
   { "definition": { "modules": [...] } }
   ```

5. PUT definition mới:
   ```bash
   bash .agent/scripts/definition.sh update /tmp/saul-updated-definitions.json
   ```

// turbo
6. Verify definition đã update:
   ```bash
   bash .agent/scripts/definition.sh get | jq '.data.modules | .[].name'
   ```

---

### Phase 2: Generate Server Code

// turbo
7. Fetch modules mới nhất để chuẩn bị cho codegen:
   ```bash
   bash .agent/scripts/definition.sh get | jq '.data.modules' > /tmp/saul-final-modules.json
   ```

8. Generate server code:
   ```bash
   bash .agent/scripts/codegen.sh server /tmp/saul-final-modules.json <SERVER_OUTPUT_PATH>
   ```

---

### Phase 3: Generate Client Code

9. Generate client code:
   ```bash
   bash .agent/scripts/codegen.sh client /tmp/saul-final-modules.json <CLIENT_OUTPUT_PATH>
   ```

---

### Phase 4: Verify

// turbo
10. Kiểm tra files đã tạo:
    ```bash
    echo "=== Server Code ===" && wc -l <SERVER_OUTPUT_PATH> && head -10 <SERVER_OUTPUT_PATH>
    echo "=== Client Code ===" && wc -l <CLIENT_OUTPUT_PATH> && head -10 <CLIENT_OUTPUT_PATH>
    ```

11. Cleanup temp files:
    ```bash
    rm -f /tmp/saul-current-modules.json /tmp/saul-updated-definitions.json /tmp/saul-final-modules.json
    ```

## Placeholders

Thay thế các placeholder bằng absolute file path trước khi chạy:
- `<SERVER_OUTPUT_PATH>` — Nơi lưu file server code (ví dụ: `./generated/server.ts`)
- `<CLIENT_OUTPUT_PATH>` — Nơi lưu file client code (ví dụ: `./generated/client.ts`)
