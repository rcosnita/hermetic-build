#!/usr/bin/env bash
set -eo pipefail

if [[ $(arch) == "aarch64" || $(arch) == "arm64" ]]; then
  export OS_ARCH=arm64
else
  export OS_ARCH=amd64
fi

docker build -t rcosnita/hermetic-build:1.0.0-remote \
    --build-arg TARGETARCH=${OS_ARCH} \
    -f cpp/build/remote-development.dockerfile \
    .

docker run --cap-add sys_ptrace \
    -p 0.0.0.0:2222:22 \
    --privileged \
    -it --rm \
    rcosnita/hermetic-build:1.0.0-remote
