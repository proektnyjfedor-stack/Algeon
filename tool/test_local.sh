#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
# The command-line toolchain can run Flutter tests without opening Xcode.
if [[ "$(uname -s)" == Darwin && -d /Library/Developer/CommandLineTools ]]; then
  algeon_toolchain_dir=$(mktemp -d)
  trap 'rm -f "$algeon_toolchain_dir/xcrun"; rmdir "$algeon_toolchain_dir"' EXIT
  cat > "$algeon_toolchain_dir/xcrun" <<'WRAPPER'
#!/bin/sh
DEVELOPER_DIR=/Library/Developer/CommandLineTools exec /usr/bin/xcrun "$@"
WRAPPER
  chmod +x "$algeon_toolchain_dir/xcrun"
  PATH="$algeon_toolchain_dir:$PATH" DEVELOPER_DIR=/Library/Developer/CommandLineTools flutter test "$@"
else
  flutter test "$@"
fi
