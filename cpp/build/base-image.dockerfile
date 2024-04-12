FROM --platform=$TARGETPLATFORM rockylinux:9.3.20231119
ARG TARGETARCH
ARG DEV_FOLDER=/home/dev
ARG DEV_USER=develop
ARG CLANG_VERSION=17.0.6
ARG CMAKE_VERSION=3.29.2
ARG NINJA_VERSION=1.12.0

RUN dnf install -y dnf-plugin-config-manager && \
  dnf config-manager --set-enabled crb && \
  dnf install -y epel-release

RUN dnf install -y wget rsync \
  curl-minimal libcurl-devel zip unzip tar ninja-build bison pkg-config \
  git git-clang-format git-lfs \
  cmake make libatomic git-clang-format git-lfs \
  autoconf-archive python3-pip perl-core openssl-devel libstdc++-devel libstdc++-static glibc-static

RUN mkdir ${DEV_FOLDER} && \
  useradd -Ms /bin/bash ${DEV_USER} && \
  chown -R ${DEV_USER}:${DEV_USER} ${DEV_FOLDER}

RUN cd ${DEV_FOLDER} && \
  git clone https://github.com/llvm/llvm-project.git && \
  cd llvm-project && \
  mkdir build && cd build && \
  git checkout llvmorg-${CLANG_VERSION} && \
  if [ "$TARGETARCH" = "arm64" ]; then export LLVM_TARGET=AArch64; else export LLVM_TARGET=X86; fi && \
  cmake -G "Ninja" -DCMAKE_BUILD_TYPE=Release  -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra" -DCMAKE_INSTALL_PREFIX=/usr/local -DLLVM_TARGETS_TO_BUILD=${LLVM_TARGET} ${DEV_FOLDER}/llvm-project/llvm && \
  ninja -j10 && \
  ninja install

RUN cd ${DEV_FOLDER} && \
  git clone https://github.com/ninja-build/ninja.git && \
  cd ninja && \
  git checkout v${NINJA_VERSION} && \
  mkdir build && cd build && \
  cmake ../ && \
  make -j16 && \
  make install

RUN cd ${DEV_FOLDER} && \
  if [ "$TARGETARCH" = "arm64" ]; then export CMAKE_ARCH=aarch64; else export CMAKE_ARCH=x86_64; fi && \
  wget https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-linux-${CMAKE_ARCH}.sh && \
  chmod u+x cmake-${CMAKE_VERSION}-linux-${CMAKE_ARCH}.sh && \
  ./cmake-${CMAKE_VERSION}-linux-${CMAKE_ARCH}.sh --skip-license --prefix=/usr/local

USER ${DEV_USER}
WORKDIR ${DEV_FOLDER}

ENV CXXFLAGS="-std=c++20"
ENV CMAKE_CXX_FLAGS=${CXXFLAGS}

RUN cd ${DEV_FOLDER} && \
  git clone https://github.com/microsoft/vcpkg.git vcpkg && \
  cd vcpkg && \
  git checkout 2024.03.25 && \
  if [ "$TARGETARCH" = "arm64" ]; then export export VCPKG_FORCE_SYSTEM_BINARIES=arm; fi && \  
  ./bootstrap-vcpkg.sh

USER root
WORKDIR ${DEV_FOLDER}

RUN ln -s /usr/bin/gcc /usr/bin/aarch64-linux-gnu-gcc && \
    ln -s /usr/bin/g++ /usr/bin/aarch64-linux-gnu-g++

ADD cpp/build/scripts/install-deps.sh install-deps.sh
RUN chown ${DEV_USER}:${DEV_USER} install-deps.sh && \
  export PATH=${DEV_FOLDER}/vcpkg:${PATH} && \
  dnf install -y kernel-headers && \
  chmod u+x install-deps.sh && \
  ./install-deps.sh ${DEV_FOLDER} ${TARGETARCH}

USER ${DEV_USER}
WORKDIR ${DEV_FOLDER}
ENV PATH=${DEV_FOLDER}/vcpkg:${DEV_FOLDER}/:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/rh/gcc-toolset-13/root/bin
ENV DEV_FOLDER=${DEV_FOLDER}
ENV TARGETARCH=${TARGETARCH}
ENV CC=/usr/local/bin/clang
ENV CXX=/usr/local/bin/clang++