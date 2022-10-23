#!/bin/bash

docker build -t debian11-gcc-builder docker -f docker/debian11.dockerfile

GCC_VERSION=12.2.0
GCC_VERSION_MAJOR=${GCC_VERSION%%.*}
SRC=$PWD/gcc-$GCC_VERSION
PREFIX=/opt/gcc-$GCC_VERSION_MAJOR
PACKAGE_NAME=gcc$GCC_VERSION_MAJOR

mkdir -p {cache,output}/debian11

time docker run -i --rm \
    -v $PWD:/data:ro \
    -v $SRC:/src:ro \
    -v $PWD/cache/debian11:/cache \
    -v $PWD/output/debian11:/output \
    debian11-gcc-builder bash \
    -s - << EOF
set -e
mkdir /build
cd /build
export CCACHE_DIR=/cache/ccache
CC='ccache gcc' CXX='ccache g++' /src/configure \
    --prefix=$PREFIX \
    --disable-bootstrap \
    --disable-multilib \
    --enable-languages=c,c++,lto \
    --enable-threads=posix \
    --enable-tls \
    --disable-nls
make -j4
make DESTDIR=/build/root -j4 install-strip

mkdir /build/root/DEBIAN
cat << EOC > /build/root/DEBIAN/control
Package: gcc-$GCC_VERSION_MAJOR
Version: $GCC_VERSION-1
Section: devel
Depends: libmpc3, libmpfr6, libc6-dev, binutils
Priority: optional
Architecture: amd64
Maintainer: cyrille.faucheux@gmail.com
Description: GCC, the GNU Compiler Collection
EOC

dpkg-deb --build /build/root /tmp

dpkg -i /tmp/*.deb

env -C /tmp $PREFIX/bin/g++ -std=c++2b -fopenmp /data/test.cpp
LD_LIBRARY_PATH=$PREFIX/lib64:$LD_LIBRARY_PATH /tmp/a.out

mv /tmp/*.deb /output/
EOF
