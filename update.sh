#!/usr/bin/env bash
set -e
VERSION=$1

if [ ! -z "$BCH_VERSION" ]; then
  echo "Missing version"
  exit;
fi

TEMPLATE=docker.template
rm -rf $VERSION
mkdir -p $VERSION
DOCKERFILE=$VERSION/Dockerfile
eval "echo \"$(cat "${TEMPLATE}")\"" > $DOCKERFILE

docker build -f ./$VERSION/Dockerfile -t bitsler/docker-digibyte:latest -t bitsler/docker-digibyte:$VERSION .

docker push bitsler/docker-digibyte:latest
docker push bitsler/docker-digibyte:$VERSION