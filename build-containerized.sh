#!/bin/bash

WORKSPACE=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
source $WORKSPACE/utils.sh

ENV=
SRC=
VERSION=
J=

function usage() {
  echo "$0 --env <sles15.3|sles15.4|debian11> --source <source directory> -v|--version <version> [-j <number>]"
}

while [[ $# -gt 0 ]]; do
  case $1 in
    --env)
      ENV="$2"
      shift 2
      ;;
    --source)
      SRC="$2"
      shift 2
      ;;
    -v|--version)
      VERSION="$2"
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

require_arg "$ENV" "Env"
require_arg "$SRC" "Source directory"
require_arg "$VERSION" "Version"

if [[ "$ENV" =~ ^sles ]]; then
  CC=gcc-11
  CXX=g++-11
fi

if [[ "$ENV" =~ ^sles15.5 ]]; then
  CC=gcc-12
  CXX=g++-12
fi

if [[ "$ENV" =~ ^sles ]]; then
  PACKAGETYPE=rpm
else
  PACKAGETYPE=deb
fi

docker build -t $ENV-gcc-builder docker -f docker/$ENV.dockerfile

mkdir -p {cache,output}/$ENV

./start-build-container.sh --source "$SRC" --env $ENV -- \
  -i --rm --workdir /data $ENV-gcc-builder \
  bash << EOF

function build {
  ./build-local.sh \
    --source /src \
    --build /build \
    --cache /cache \
    --version $VERSION \
    ${CC:+--cc} $CC \
    ${CXX:+--cxx} $CXX \
    ${J:+-j} $J
}

function buildpackage {
  ./build-package.sh --package-type $PACKAGETYPE --build /build --output /output --version $VERSION --test-install
}

set -e

build

buildpackage

EOF
