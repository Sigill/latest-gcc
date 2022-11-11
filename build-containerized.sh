#!/bin/bash

WORKSPACE=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
source $WORKSPACE/utils.sh

ENV=
SRC=
VERSION=
J=

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
    *)
      >&2 echo "Unknown argument $1"
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
set -e

./build-local.sh \
  --source /src \
  --build /build \
  --cache /cache \
  --version $VERSION \
  ${CC:+--cc} $CC \
  ${CXX:+--cxx} $CXX \
  ${J:+-j} $J

./build-package.sh --package-type $PACKAGETYPE --build /build --output /output --version $VERSION
EOF
