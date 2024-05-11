#!/usr/bin/env bash
set -eo pipefail

VCPKG_LOCATION=${1}
VCPKG_CMD=vcpkg
TARGETARCH=${2:-arm64}

if [ "$TARGETARCH" = "arm64" ]; then
    export OS_ARCH=arm64
else
    export OS_ARCH=x64
fi

if [[ $(arch) == "aarch64" ]]; then
  echo "Enabling arm architecture"
  export VCPKG_FORCE_SYSTEM_BINARIES=arm
fi

export LD_LIBRARY_PATH=${VCPKG_LOCATION}/installed/${OS_ARCH}-linux/lib:${LD_LIBRARY_PATH}
export OPENSSL_ROOT_DIR=${VCPKG_LOCATION}/packages/openssl_${OS_ARCH}-linux
export OPENSSL_INCLUDE_DIR=${VCPKG_LOCATION}/packages/openssl_${OS_ARCH}-linux/include

${VCPKG_CMD} install curl
${VCPKG_CMD} install jwt-cpp
${VCPKG_CMD} install protobuf grpc
${VCPKG_CMD} install gtest
${VCPKG_CMD} install rapidjson
${VCPKG_CMD} install librdkafka librdkafka[snappy] librdkafka[zlib] librdkafka[zstd]
${VCPKG_CMD} install libuuid
${VCPKG_CMD} install ms-gsl
${VCPKG_CMD} install gflags
${VCPKG_CMD} install spdlog
${VCPKG_CMD} install yaml-cpp
${VCPKG_CMD} install cli11
${VCPKG_CMD} install opentelemetry-cpp[otlp-grpc]
${VCPKG_CMD} install arrow[csv] arrow[filesystem] arrow[json] arrow[parquet] arrow[flight] arrow[flightsql]
