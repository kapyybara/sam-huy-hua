#!/usr/bin/env bash

# .antigravity/scripts/codegen.sh
# Gọi API codegen đến Saul server để sinh type/client/server code

set -e

HOST=${SAUL_HOST:-"http://localhost:3000"}

show_help() {
  echo "Usage: ./codegen.sh <target> <modules_json_path> <output_path>"
  echo "Args:"
  echo "  target               - 'server' hoặc 'client'"
  echo "  modules_json_path    - File JSON rỗng mảng modules cần generate (ví dụ: ./modules.json)"
  echo "  output_path          - Nơi lưu kết quả code xuất ra (ví dụ: ./generated.ts)"
  echo "Environment Variables:"
  echo "  SAUL_HOST            - (Optional) Mặc định là http://localhost:3000"
}

if [[ "$1" == "help" || -z "$1" || -z "$2" || -z "$3" ]]; then
  show_help
  exit 0
fi

TARGET=$1
MODULES_PATH=$2
OUTPUT_PATH=$3

# Build request payload locally and send
MODULES=$(cat "$MODULES_PATH")
PAYLOAD=$(jq -n \
  --arg target "$TARGET" \
  --arg lang "typescript" \
  --argjson modules "$MODULES" \
  '{target: $target, lang: $lang, modules: $modules}')

curl -s -X POST "$HOST/api/codegen" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" \
  -o "$OUTPUT_PATH"

echo "Tạo và lưu source code tới $OUTPUT_PATH thành công."
