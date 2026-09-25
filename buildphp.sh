#!/bin/bash

# Build PHP 8.5 with portable extensions enabled:
# mysqli, PDO SQLite, OpenSSL, iconv, zlib, GD (PNG/JPEG),
# mbstring, DOM/XML, tokenizer, fileinfo, FTP, sockets, cURL and ZIP.
#
# Put PHP and the dependency sources below in php/:
# openssl-*/, libiconv-*/, libxml2-*/, sqlite-*/, zlib-*/,
# libpng-*/, jpeg-*/, onig-*/, and php-8.5.*.
# Homebrew curl and libzip are required for --with-curl and --with-zip.

set -euo pipefail
set -x

root_dir=$(realpath "$(dirname "$0")")
php_root="$root_dir/php"

if [[ ! -d "$php_root" ]]; then
    echo "php/ directory doesn't exist"
    exit 1
fi

source_dir() {
    local pattern="$1"
    local result
    result=$(find "$php_root" -maxdepth 1 -type d -name "$pattern" -print -quit)
    if [[ -z "$result" ]]; then
        echo "Can't find $pattern directory" >&2
        exit 1
    fi
    realpath "$result"
}

openssl_dir=$(source_dir 'openssl-*')
iconv_dir=$(source_dir 'libiconv-*')
libxml2_dir=$(source_dir 'libxml2-*')
sqlite_dir=$(source_dir 'sqlite-*')
zlib_dir=$(source_dir 'zlib-*')
png_dir=$(source_dir 'libpng-*')
jpeg_dir=$(source_dir 'jpeg-*')
onig_dir=$(source_dir 'onig-*')
php_dir=$(source_dir 'php-8.5.*')

if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew is required to build cURL and ZIP support"
    exit 1
fi
curl_dir=$(brew --prefix curl)
libzip_dir=$(brew --prefix libzip)

rm -f "$php_root/php-cgi" "$php_root/php.ini"
cp "$sqlite_dir/dist-install/lib/libsqlite3.dylib" "$php_dir/libsqlite3.dylib"

export EXTRA_CFLAGS="-Wno-unused-command-line-argument -lresolv"
export OPENSSL_CFLAGS="-I$openssl_dir/dist-install/include"
export OPENSSL_LIBS="-L$openssl_dir/dist-install/lib -lcrypto -lssl"
export LIBXML_CFLAGS="-I$libxml2_dir/dist-install/include -I$libxml2_dir/dist-install/include/libxml2"
export LIBXML_LIBS="-L$libxml2_dir/dist-install/lib -lxml2"
export SQLITE_CFLAGS="-I$sqlite_dir/dist-install/include"
export SQLITE_LIBS="-L$sqlite_dir/dist-install/lib -lsqlite3"
export ZLIB_CFLAGS="-I$zlib_dir/dist-install/include"
export ZLIB_LIBS="-L$zlib_dir/dist-install/lib -lz"
export PNG_CFLAGS="-I$png_dir/dist-install/include"
export PNG_LIBS="-L$png_dir/dist-install/lib -lpng"
export JPEG_CFLAGS="-I$jpeg_dir/dist-install/include"
export JPEG_LIBS="-L$jpeg_dir/dist-install/lib -ljpeg"
export ONIG_CFLAGS="-I$onig_dir/dist-install/include"
export ONIG_LIBS="-L$onig_dir/dist-install/lib -lonig"
export CURL_CFLAGS="-I$curl_dir/include"
export CURL_LIBS="-L$curl_dir/lib -lcurl"
export LIBZIP_CFLAGS="-I$libzip_dir/include"
export LIBZIP_LIBS="-L$libzip_dir/lib -lzip"

cd "$php_dir"
./configure -v \
    --prefix="$php_dir/dist-install" \
    --exec-prefix="$php_dir/dist-install" \
    --with-mysqli \
    --with-pdo-sqlite="$sqlite_dir/dist-install" \
    --with-openssl \
    --with-iconv="$iconv_dir/dist-install" \
    --with-zlib="$zlib_dir/dist-install" \
    --enable-gd \
    --with-jpeg="$jpeg_dir/dist-install" \
    --enable-mbstring \
    --enable-dom \
    --enable-xml \
    --enable-tokenizer \
    --enable-fileinfo \
    --enable-ftp \
    --enable-sockets \
    --with-curl="$curl_dir" \
    --with-zip="$libzip_dir"
make -j"$(sysctl -n hw.ncpu)" install

cp "$php_dir/dist-install/bin/php-cgi" "$php_root/php-cgi"
cp "$root_dir/php.ini" "$php_root/php.ini"
cp "$curl_dir/lib/libcurl.4.dylib" "$php_root/libcurl.4.dylib"
cp "$libzip_dir/lib/libzip.5.dylib" "$php_root/libzip.5.dylib"
ln -sf libz.1.3.1.dylib "$php_root/libz.1.dylib"

cd "$php_root"
install_name_tool -rpath "$openssl_dir/dist-install/lib" '@loader_path/.' php-cgi
install_name_tool -delete_rpath "$iconv_dir/dist-install/lib" php-cgi
install_name_tool -delete_rpath "$libxml2_dir/dist-install/lib" php-cgi
install_name_tool -delete_rpath "$sqlite_dir/dist-install/lib" php-cgi
install_name_tool -delete_rpath "$zlib_dir/dist-install/lib" php-cgi
install_name_tool -delete_rpath "$png_dir/dist-install/lib" php-cgi
install_name_tool -delete_rpath "$jpeg_dir/dist-install/lib" php-cgi
install_name_tool -delete_rpath "$onig_dir/dist-install/lib" php-cgi
install_name_tool -change "$openssl_dir/dist-install/lib/libcrypto.3.dylib" libcrypto.3.dylib php-cgi
install_name_tool -change "$openssl_dir/dist-install/lib/libssl.3.dylib" libssl.3.dylib php-cgi
install_name_tool -change "$iconv_dir/dist-install/lib/libiconv.2.dylib" libiconv.2.dylib php-cgi
install_name_tool -change "$libxml2_dir/dist-install/lib/libxml2.2.dylib" libxml2.2.dylib php-cgi
install_name_tool -change "$sqlite_dir/dist-install/lib/libsqlite3.dylib" libsqlite3.dylib php-cgi
install_name_tool -change "$zlib_dir/dist-install/lib/libz.1.dylib" libz.1.dylib php-cgi
install_name_tool -change "$png_dir/dist-install/lib/libpng16.16.dylib" libpng.dylib php-cgi
install_name_tool -change "$jpeg_dir/dist-install/lib/libjpeg.9.dylib" libjpeg.dylib php-cgi
install_name_tool -change "$onig_dir/dist-install/lib/libonig.5.dylib" libonig.dylib php-cgi
install_name_tool -change "$curl_dir/lib/libcurl.4.dylib" libcurl.4.dylib php-cgi
install_name_tool -change "$libzip_dir/lib/libzip.5.dylib" libzip.5.dylib php-cgi

# Normalize dependencies whose upstream install names vary between releases.
install_name_tool -change libiconv.2.dylib '@loader_path/libiconv.2.dylib' php-cgi
install_name_tool -change "$libxml2_dir/dist-install/lib/libxml2.16.dylib" '@loader_path/libxml2.2.dylib' php-cgi
install_name_tool -change libz.1.dylib '@loader_path/libz.1.3.1.dylib' php-cgi
install_name_tool -change libz.1.3.1.dylib '@loader_path/libz.1.3.1.dylib' php-cgi
install_name_tool -change libiconv.2.dylib '@loader_path/libiconv.2.dylib' libxml2.2.dylib
install_name_tool -change libz.1.dylib '@loader_path/libz.1.3.1.dylib' libpng.dylib
install_name_tool -change libz.1.3.1.dylib '@loader_path/libz.1.3.1.dylib' libsqlite3.dylib
