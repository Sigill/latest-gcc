#!/bin/bash
set -e

WORKSPACE=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
source $WORKSPACE/utils.sh

SRC=
BLD=
CACHE=
VERSION=
CC=
CXX=
J=

function usage() {
  echo "$0 --source <source-dir> --build <build-dir> --cache <cache dir> -v|--version <version> [--cc <c compiler>] [--cxx <cxx compiler>] [-j <number>]"
}

while [[ $# -gt 0 ]]; do
  case $1 in
    --source)
      SRC="$2"
      shift 2
      ;;
    --build)
      BLD="$2"
      shift 2
      ;;
    --cache)
      CACHE="$2"
      shift 2
      ;;
    -v|--version)
      VERSION="$2"
      shift 2
      ;;
    --cc)
      CC="$2"
      shift 2
      ;;
    --cxx)
      CXX="$2"
      shift 2
      ;;
    -j)
      J="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      >&2 echo "Unknown argument $1"
      >&2 usage
      exit 1
      ;;
  esac
done

require_arg "$SRC" "Source directory"
require_arg "$BLD" "Build directory"
require_arg "$CACHE" "Cache directory"
require_arg "$VERSION" "Version"

VERSION_MAJOR=${VERSION%%.*}
PREFIX=/opt/gcc-$VERSION_MAJOR

mkdir -p "$BLD"
cd "$BLD"

export CCACHE_DIR="$CACHE/ccache"

CC="ccache ${CC:-gcc}" CXX="ccache ${CXX:-g++}" "$SRC/configure" \
    --prefix=$PREFIX \
    --disable-bootstrap \
    --disable-multilib \
    --enable-languages=c,c++,lto \
    --enable-threads=posix \
    --enable-tls \
    --disable-nls

make -j${J:-$(nproc)}
