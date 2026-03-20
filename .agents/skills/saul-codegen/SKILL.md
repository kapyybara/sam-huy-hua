---
name: saul-codegen
description: Generate TypeScript code from SDK definitions on the Saul server and save it to a file. Use this skill whenever the user wants to generate code, create SDK output, build the client API, sync types from backend, or "run codegen". Trigger even if the user just asks to "build saul" or "export the api types".
compatibility: Requires Saul server running (usually localhost:3000)
---

# Saul Codegen Skill

Skill này hướng dẫn cách tương tác với Saul server để **generate TypeScript code** (Client và Server) từ SDK definitions và **save kết quả vào file**.

---

## Step 1: Chuẩn bị thông tin lấy payload Definitions

Server yêu cầu bạn gửi lên các definitions mới nhất thông qua mảng JSON gọi là `modules`.
1. Hãy gọi script định nghĩa để lấy được mảng modules chuẩn bị payload (nếu bạn chưa có sẵn trên memory):
`bash .agent/scripts/definition.sh get > /tmp/modules.json`
*(Lưu ý: payload chuẩn phải là mảng Array Object, bạn tự cắt lọc JSON field từ file)*

---

## Step 2: Xác định môi trường đích (Target)

Hỏi user hoặc xác định mục tiêu export:
- Target: `server` (Sinh mã logic backend: Schema, Controller stub, Type validation, Endpoint handlers)
- Target: `client` (Sinh frontend fetch SDK tự động gọi API an toàn kiểu dáng class method)
- Output: Nơi lưu trữ file TypeScript xuất ra sau quá trình này (Ví dụ: `src/generated.ts`).

---

## Step 3: Sinh mã và ghi xuống bộ nhớ 

Gửi payload JSON đã chuẩn bị lên Endpoint `/api/codegen` bằng cách gọi script tự động:

```bash
# Cấu trúc: bash .agent/scripts/codegen.sh <TARGET> <MODULES_JSON_PATH> <OUTPUT_PATH>

bash .agent/scripts/codegen.sh client /tmp/modules.json ./src/saulClient.ts
```

*Lưu ý: Đầu ra từ API sẽ là Dòng Mở Rộng streaming (không phải JSON mà là raw typescript source block code) vì vậy script `codegen.sh` xử lý tốt nhất việc ghi tải thẳng xuống đích.*

---

## Output Format khác nhau theo Target

### target: `"server"`
Sinh ra:
- Namespace cho mỗi module (`export namespace user { ... }`)
- Model types (`export type User = z.infer<typeof UserSchema>`)
- Zod schemas 
- Error classes (`export class UserNotFound extends Error {...}`)
- Abstract service classes (`export abstract class UserService { abstract getUser(...): Promise<User> }`)

### target: `"client"`
Sinh ra:
- Namespace cho mỗi module
- Model types + Zod schemas + Error classes
- **SaulSDK class** — HTTP client với typed methods để gọi lên server `const sdk = saul.init("http://localhost:3000") ; const user = await sdk.user.getUser("123");`
