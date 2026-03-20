#!/usr/bin/env bash

# .antigravity/scripts/definition.sh
# Tương tác với Saul server API cho việc quản lý definitions

set -e

HOST=${SAUL_HOST:-"http://localhost:3000"}

show_help() {
  echo "Usage: ./definition.sh [command] [args]"
  echo "Commands:"
  echo "  get                   - Lấy toàn bộ definitions hiện tại"
  echo "  get <module_name>     - Lấy definition của 1 module cụ thể"
  echo "  update <file_path>    - Cập nhật (replace) toàn bộ definitions từ JSON file"
  echo "  help                  - Hiển thị hướng dẫn này"
}

command=$1
arg=$2

case "$command" in
  "get")
    if [ -z "$arg" ]; then
      curl -s "$HOST/api/definitions"
    else
      curl -s "$HOST/api/definitions/$arg"
    fi
    ;;

  "update")
    if [ -z "$arg" ]; then
      echo "Error: Thiếu tham số file_path cho cấu trúc definition cần update."
      exit 1
    fi
    curl -s -X PUT "$HOST/api/definitions" \
      -H "Content-Type: application/json" \
      -d @"$arg"
    ;;

  "help" | "")
    show_help
    ;;

  *)
    echo "Unknown command: $command"
    show_help
    exit 1
    ;;
esac
