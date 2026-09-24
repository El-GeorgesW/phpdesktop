#!/bin/bash
set -euo pipefail
set -x
root_dir=$(realpath "$(dirname "$0")")
cd "$root_dir/php"
jpeg_dir=$(realpath "$(find . -maxdepth 1 -type d -name 'jpeg-*' -print -quit)")
cd "$jpeg_dir"
./Configure --prefix="$jpeg_dir/dist-install" --exec-prefix="$jpeg_dir/dist-install"
make install
cp dist-install/lib/libjpeg.dylib ../libjpeg.dylib
install_name_tool -id libjpeg.dylib ../libjpeg.dylib
install_name_tool -change "$jpeg_dir/dist-install/lib/libjpeg.dylib" libjpeg.dylib ../libjpeg.dylib
