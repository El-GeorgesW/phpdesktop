#!/bin/bash
set -euo pipefail
set -x
root_dir=$(realpath "$(dirname "$0")")
cd "$root_dir/php"
png_dir=$(realpath "$(find . -maxdepth 1 -type d -name 'libpng-*' -print -quit)")
cd "$png_dir"
./Configure --prefix="$png_dir/dist-install" --exec-prefix="$png_dir/dist-install"
make -j"$(sysctl -n hw.ncpu)" install
cp dist-install/lib/libpng.dylib ../libpng.dylib
install_name_tool -id libpng.dylib ../libpng.dylib
install_name_tool -change "$png_dir/dist-install/lib/libpng.dylib" libpng.dylib ../libpng.dylib
install_name_tool -change /usr/lib/libz.1.dylib libz.1.dylib ../libpng.dylib
