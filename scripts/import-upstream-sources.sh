#!/usr/bin/env bash
set -Eeuo pipefail

# Import the source branches used by the upstream project into isolated platform
# directories. This deliberately imports source history by snapshot; CEF/PHP
# archives are downloaded by the platform build systems and are not vendored.

UPSTREAM_URL="${UPSTREAM_URL:-https://github.com/cztomczak/phpdesktop.git}"
WINDOWS_REF="${WINDOWS_REF:-chrome130}"
MACOS_REF="${MACOS_REF:-mac130}"
LINUX_REF="${LINUX_REF:-linux70}"

if [[ ! -d .git ]]; then
  echo "Run this script from the root of a Git checkout." >&2
  exit 1
fi

git remote get-url upstream >/dev/null 2>&1 || git remote add upstream "$UPSTREAM_URL"
git fetch --no-tags upstream "$WINDOWS_REF" "$MACOS_REF" "$LINUX_REF"

# Keep platform trees separate because the upstream branches have incompatible
# build systems and CEF APIs.
for spec in \
  "platform/windows:$WINDOWS_REF" \
  "platform/macos:$MACOS_REF" \
  "platform/linux:$LINUX_REF"; do
  prefix="${spec%%:*}"
  ref="${spec#*:}"
  rm -rf "$prefix"
  mkdir -p "$prefix"
  git archive --format=tar "upstream/$ref" | tar -xf - -C "$prefix"
  printf '%s\t%s\n' "$prefix" "$(git rev-parse "upstream/$ref")"
done

cat <<'EOF'
Sources imported. Review licenses and run each platform's build instructions
before committing generated CEF/PHP artifacts.
EOF
