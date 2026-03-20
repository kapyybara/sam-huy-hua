---
description: Generate TypeScript client and server code from Saul's definitions. Trigger when user says "generate code for X", "build the saul client SDK", "export saul types", or mentions codegen.
---

# Generate Code Workflow

Workflow này generate TypeScript code từ SDK definitions thông qua backend API và save vào file.

## Steps

1. Đọc nội dung skill `saul-codegen` để hiểu codegen structure.

// turbo
2. Fetch definitions array hiện tại:
   ```bash
   bash .agent/scripts/definition.sh get | jq '.data.modules' > /tmp/saul-modules.json
   ```

3. Xác nhận modules array ở `/tmp/saul-modules.json` đã có data hợp lệ.

4. Hỏi user về:
   - **Target**: `server` hay `client`?
   - **Output path**: Lưu file TypeScript (`.ts`) ở đâu?

5. Gọi codegen API để save output code:
   ```bash
   # Thay TARGET và OUTPUT_PATH dựa vào câu trả lời của user ở bước trên
   bash .agent/scripts/codegen.sh <TARGET> /tmp/saul-modules.json <OUTPUT_PATH>
   ```

// turbo
6. Verify file source code đã được tạo:
   ```bash
   wc -l <OUTPUT_PATH> && head -20 <OUTPUT_PATH>
   ```

7. (Optional) Cleanup temp files:
   ```bash
   rm -f /tmp/saul-modules.json
   ```

## Lưu ý

- Output là raw TypeScript code, KHÔNG phải JSON.
- Đừng quên thay `<TARGET>` và `<OUTPUT_PATH>` bằng input của user trước khi chạy.
