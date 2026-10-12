#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
# Compile outside synchronized folders. Reusing build/web lets stale service
# worker inputs and iCloud conflict copies enter Flutter's build graph.
algeon_web_stage=$(mktemp -d "${TMPDIR:-/tmp}/algeon-web-build.XXXXXX")
trap 'rm -rf -- "$algeon_web_stage"' EXIT
flutter build web --release --no-web-resources-cdn "$@" --output "$algeon_web_stage"
python3 tool/version_web_build.py --web-root "$algeon_web_stage"
mkdir -p "$algeon_web_stage/about"
cp web_landing/index.html web_landing/styles.css web_landing/script.js "$algeon_web_stage/about/"
python3 tool/prepare_web_release.py --source "$algeon_web_stage" --output build/web
