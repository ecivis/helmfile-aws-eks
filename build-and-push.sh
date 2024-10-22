#!/usr/bin/env bash

set -e

registry="docker.io/ecivis"
repository="helmfile-aws-eks"
tag="${1:-$(date +%Y%m%d01)}"
builder="local"

docker buildx inspect "${builder}" > /dev/null 2>&1 || \
  docker buildx create --name "${builder}" --node local --platform linux/arm64,linux/amd64

docker buildx build --builder "${builder}" --platform=linux/amd64,linux/arm64 --push \
  --tag "${registry}/${repository}:${tag}" --file Dockerfile .
