#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
flutter build web --release --no-web-resources-cdn "$@"
python3 tool/version_web_build.py
mkdir -p build/web/about
cp web_landing/index.html web_landing/styles.css web_landing/script.js build/web/about/
