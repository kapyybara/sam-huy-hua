---
description: Develop new feature based on bdd spec
---

Skills required: backend-dev, frontend-dev, e2e-test-writer

Implement selected bdd spec

1. Write e2e Playwright test cases following spec docs in `tests/e2e/step_defs/` folder
2. Run tests (Red)
3. Write code to pass the test (Green)
   - **Nếu là Magisk feature mới** (cần data layer, views, commands): follow `/create-magisk-feature` để scaffold đúng cấu trúc
   - **Nếu là bug fix hoặc cải tiến có sẵn**: implement trực tiếp theo spec
4. Suggest refactor and confirm with user, then implement refactor (Refactor)

While running tests, write code, refactor, you can utilize browser for FE tasks to manually inspect, reproduce, debug