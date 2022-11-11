#!/bin/bash
set -e

WORKSPACE=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
source $WORKSPACE/utils.sh

BLD=
OUT=
VERSION=
PACKAGETYPE=
TESTINSTALL=

while [[ $# -gt 0 ]]; do
  case $1 in
    --package-type)
      PACKAGETYPE="$2"
      shift 2
      ;;
    --build)
      BLD="$2"
      shift 2
      ;;
    --output)
      OUT="$2"
      shift 2
      ;;
    -v|--version)
      VERSION="$2"
      shift 2
      ;;
    --test-install)
      TESTINSTALL=YES
      shift
      ;;
    *)
      >&2 echo "Unknown argument $1"
      exit 1
      ;;
  esac
done

require_arg "$PACKAGETYPE" "Package type"
require_arg "$BLD" "Build directory"
require_arg "$OUT" "Output directory"
require_arg "$VERSION" "Version"

VERSION_MAJOR=${VERSION%%.*}
PREFIX=/opt/gcc-$VERSION_MAJOR
PACKAGE_NAME=gcc$VERSION_MAJOR

function hello_world() {
  "$PREFIX/bin/g++" -std=c++2b -fopenmp "$WORKSPACE/test.cpp" -o /tmp/a.out
  /tmp/a.out
}

function build_rpm() {
  # We should be able to replace _sourcedir by buildroot and not do anything during %install, but on some distributions (eg: centos7), rpmbuild starts by removing buildroot.
  run rpmbuild -bb "$WORKSPACE/gcc.spec" \
    --define "_binary_payload w4.gzdio" \
    --define "_rpmfilename %%{NAME}-%%{VERSION}-%%{RELEASE}.%%{ARCH}.rpm" \
    --define "_rpmdir /tmp/RPMS" \
    --define "_sourcedir $BLD/root" \
    --define "_name $PACKAGE_NAME" \
    --define "_prefix $PREFIX" \
    --define "_version $VERSION" \
    --define "_release 1" \
    --verbose

  [ "$TESTINSTALL" = YES ] && rpm -ivh /tmp/RPMS/*.rpm && hello_world

  mv /tmp/RPMS/*.rpm "$OUT"
}

function build_deb() {
  mkdir "$BLD/root/DEBIAN"
  cat << EOF > "$BLD/root/DEBIAN/control"
Package: gcc$VERSION_MAJOR
Version: $VERSION-1
Section: devel
Depends: libmpc3, libmpfr6, libc6-dev, binutils
Priority: optional
Architecture: amd64
Description: GCC, the GNU Compiler Collection
EOF

  dpkg-deb --build "$BLD/root" /tmp

  [ "$TESTINSTALL" = YES ] && dpkg -i /tmp/*.deb && hello_world

  mv /tmp/*.deb "$OUT/"
}

if [ "$PACKAGETYPE" = rpm ]; then
  build_rpm
elif [ "$PACKAGETYPE" = deb ]; then
  build_deb
else
  >&2 echo "Unsupported package type: $PACKAGETYPE"
  exit 1
fi
