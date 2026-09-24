#!/bin/bash
set -euo pipefail
set -x
root_dir=$(realpath "$(dirname "$0")")
cd "$root_dir/php"
onig_dir=$(realpath "$(find . -maxdepth 1 -type d -name 'onig-*' -print -quit)")
cd "$onig_dir"
./Configure --prefix="$onig_dir/dist-install" --exec-prefix="$onig_dir/dist-install"
make install
cp dist-install/lib/libonig.dylib ../libonig.dylib
install_name_tool -id libonig.dylib ../libonig.dylib
install_name_tool -change "$onig_dir/dist-install/lib/libonig.dylib" libonig.dylib ../libonig.dylib
