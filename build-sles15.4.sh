#!/bin/bash

docker build -t sles-15.4-gcc-builder docker -f docker/sles15.4.dockerfile

GCC_VERSION=12.2.0
GCC_VERSION_MAJOR=${GCC_VERSION%%.*}
SRC=$PWD/gcc-$GCC_VERSION
PREFIX=/opt/gcc-$GCC_VERSION_MAJOR
PACKAGE_NAME=gcc$GCC_VERSION_MAJOR

mkdir -p {cache,output}/sles15.4

time docker run -i --rm \
    -v $PWD:/data:ro \
    -v $SRC:/src:ro \
    -v $PWD/cache/sles15.4:/cache \
    -v $PWD/output/sles15.4:/output \
    sles-15.4-gcc-builder bash \
    -s - << EOF
set -e
mkdir /build
cd /build
export CCACHE_DIR=/cache
CC='ccache gcc-11' CXX='ccache g++-11' /src/configure \
    --prefix=$PREFIX \
    --disable-bootstrap \
    --disable-multilib \
    --enable-languages=c,c++,lto \
    --enable-threads=posix \
    --enable-tls \
    --disable-nls
make -j4
make DESTDIR=/build/root -j4 install-strip

rpmbuild -bb /data/gcc$GCC_VERSION_MAJOR.spec --define "_sourcedir /build/root" --define "_rpmfilename $PACKAGE_NAME-%%{VERSION}-%%{RELEASE}.rpm" --verbose

rpm -ivh /usr/src/packages/RPMS/*.rpm

env -C /tmp $PREFIX/bin/g++ -std=c++17 -fopenmp /data/test.cpp
/tmp/a.out

mv /usr/src/packages/RPMS/*.rpm /output/
EOF
