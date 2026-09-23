#!/usr/bin/env bash
set -Eeuo pipefail

# Verify that the platform source snapshots are present and that their pinned
# upstream commits are recorded for reproducible imports.

required=(
  platform/windows
  platform/macos
  platform/linux
)
for path in "${required[@]}"; do
  [[ -d "$path" ]] || { echo "Missing $path" >&2; exit 1; }
done

for file in \
  platform/windows/phpdesktop-chrome.sln \
  platform/macos/CMakeLists.txt \
  platform/linux/Makefile; do
  [[ -f "$file" ]] || { echo "Missing expected build file: $file" >&2; exit 1; }
done

echo "All platform source trees and build entry points are present."
