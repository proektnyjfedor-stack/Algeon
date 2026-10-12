#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
bash tool/build_web.sh --no-tree-shake-icons
printf '\nAlgeon: http://127.0.0.1:8765\nО проекте: http://127.0.0.1:8765/about/\nОстановка сервера: Ctrl+C\n\n'
python3 tool/serve_preview.py
