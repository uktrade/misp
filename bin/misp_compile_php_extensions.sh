#!/usr/bin/env bash
# Copyright (C) 2022 National Cyber and Information Security Agency of the Czech Republic
# Unfortunately, PHP packages from CentOS repos missing some required extensions, so we have to build them
set -e
set -o xtrace

download_and_check () {
  curl --proto '=https' --tlsv1.3 -sS --location --fail -o package.tar.gz $1
  echo "$2 package.tar.gz" | sha256sum -c
  tar zxf package.tar.gz --strip-components=1
  rm -f package.tar.gz
}

mkdir /build/php-modules/

# Compile igbinary
mkdir /tmp/igbinary
cd /tmp/igbinary
download_and_check https://github.com/igbinary/igbinary/archive/refs/tags/3.2.7.tar.gz 21863908348f90a8a895c8e92e0ec83c9cf9faffcfd70118b06fe2dca30eaa96
phpize
./configure --silent CFLAGS="-O2 -g" --enable-igbinary
make -j$(nproc)
make install # `make install` is necessary, so redis extension can be compiled with `--enable-redis-igbinary`
mv modules/*.so /build/php-modules/

# Compile zstd library and zstd extension
mkdir /tmp/zstd
cd /tmp/zstd
download_and_check https://github.com/kjdev/php-ext-zstd/archive/bf7931996aac9d14ba550783c12070442445d6f2.tar.gz 64d8000c6580ea97d675fc43db6a2a1229e9ad06185c24c60fd4b07e73852fce
cd zstd
download_and_check https://github.com/facebook/zstd/archive/refs/tags/v1.5.2.tar.gz f7de13462f7a82c29ab865820149e778cbfe01087b3a55b5332707abf9db4a6e
cd ..
phpize
./configure --silent
make --silent -j$(nproc)
mv modules/*.so /build/php-modules/

# Compile redis
mkdir /tmp/redis
cd /tmp/redis
download_and_check https://github.com/phpredis/phpredis/archive/refs/tags/5.3.7.tar.gz 6f5cda93aac8c1c4bafa45255460292571fb2f029b0ac4a5a4dc66987a9529e6
phpize
./configure --silent --enable-redis-igbinary --enable-redis-zstd
make -j$(nproc)
mv modules/*.so /build/php-modules/

# Compile ssdeep
mkdir /tmp/ssdeep
cd /tmp/ssdeep
download_and_check https://github.com/php/pecl-text-ssdeep/archive/refs/tags/1.1.0.tar.gz 256c5c1d6b965f1c6e0f262b6548b1868f4857c5145ca255031a92d602e8b88d
phpize
./configure --silent --with-ssdeep=/usr --with-libdir=lib64
make -j$(nproc)
mv modules/*.so /build/php-modules/

# Compile brotli
mkdir /tmp/brotli
cd /tmp/brotli
download_and_check https://github.com/kjdev/php-ext-brotli/archive/refs/tags/0.13.1.tar.gz 1eca1af3208e2f6551064e3f26e771453def588898bfc25858ab1db985363e47
phpize
./configure --silent --with-libbrotli
make -j$(nproc)
mv modules/*.so /build/php-modules/

# Compile snuffleupagus
mkdir /tmp/snuffleupagus
cd /tmp/snuffleupagus
download_and_check https://github.com/jvoisin/snuffleupagus/archive/refs/tags/v0.7.1.tar.gz 0dfc3b82d77d20f7d6f8fbea9c23d28a081d14376984db42fad6b4a2216d9981
cd src
phpize
./configure --silent --enable-snuffleupagus
make -j$(nproc)
mv modules/*.so /build/php-modules/

# Remove debug from binaries
strip /build/php-modules/*.so
