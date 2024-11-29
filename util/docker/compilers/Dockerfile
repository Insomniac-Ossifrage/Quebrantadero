# Distro Information
ARG DISTRO_VERSION="24.04"
FROM ubuntu:${DISTRO_VERSION}

# Ubuntu Variables
ARG DEBIAN_FRONTEND="noninteractive"

# CMake Variables
ARG CMAKE_DISTRO_NAME="noble main"

# Compiler Variables
ARG GCC_VERSION="14"
ARG CLANG_VERSION="19"
ARG CLANG_COMPONENTS="all"

ENV TZ="Europe/Madrid"

# Install Utilities
RUN apt-get update && apt-get install -y apt lsb-release wget software-properties-common gnupg

# Install Debug & Build Tools
RUN apt-get update && apt-get install -y gdb ninja-build make

# Install CMake
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates gpg wget \
    && ( \
        test -f /usr/share/doc/kitware-archive-keyring/copyright \
        || wget -O - "https://apt.kitware.com/keys/kitware-archive-latest.asc" 2>/dev/null | gpg --dearmor - | tee /usr/share/keyrings/kitware-archive-keyring.gpg \
    ) \
    && echo "deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ ${CMAKE_DISTRO_NAME}" | tee /etc/apt/sources.list.d/kitware.list \
    && apt-get update && apt-get install -y --no-install-recommends cmake

# Install GCC
RUN apt-get update && apt-get install -y g++-${GCC_VERSION} \
    && update-alternatives \
    --verbose \
    --install /usr/bin/gcc   gcc  /usr/bin/gcc-${GCC_VERSION} ${GCC_VERSION} \
    --slave   /usr/bin/g++   g++  /usr/bin/g++-${GCC_VERSION}

# Install Clang
# TODO: Move to script file
RUN wget "https://apt.llvm.org/llvm.sh" \
    && chmod +x ./llvm.sh \
    && ./llvm.sh ${CLANG_VERSION} ${CLANG_COMPONENTS} \
    && update-alternatives \
        --install /usr/bin/clang                clang                /usr/bin/clang-${CLANG_VERSION} ${CLANG_VERSION} \
        --slave   /usr/bin/clang++              clang++              /usr/bin/clang++-${CLANG_VERSION}  \
        --slave   /usr/bin/clang-format         clang-format         /usr/bin/clang-format-${CLANG_VERSION}  \
        --slave   /usr/bin/clang-cpp            clang-cpp            /usr/bin/clang-cpp-${CLANG_VERSION} \
        --slave   /usr/bin/clang-cl             clang-cl             /usr/bin/clang-cl-${CLANG_VERSION} \
        --slave   /usr/bin/clangd               clangd               /usr/bin/clangd-${CLANG_VERSION} \
        --slave   /usr/bin/clang-tidy           clang-tidy           /usr/bin/clang-tidy-${CLANG_VERSION} \
        --slave   /usr/bin/clang-check          clang-check          /usr/bin/clang-check-${CLANG_VERSION} \
        --slave   /usr/bin/clang-query          clang-query          /usr/bin/clang-query-${CLANG_VERSION} \
        --slave   /usr/bin/asan_symbolize       asan_symbolize       /usr/bin/asan_symbolize-${CLANG_VERSION} \
        --slave   /usr/bin/bugpoint             bugpoint             /usr/bin/bugpoint-${CLANG_VERSION} \
        --slave   /usr/bin/dsymutil             dsymutil             /usr/bin/dsymutil-${CLANG_VERSION} \
        --slave   /usr/bin/lld                  lld                  /usr/bin/lld-${CLANG_VERSION} \
        --slave   /usr/bin/ld.lld               ld.lld               /usr/bin/ld.lld-${CLANG_VERSION} \
        --slave   /usr/bin/lld-link             lld-link             /usr/bin/lld-link-${CLANG_VERSION} \
        --slave   /usr/bin/llc                  llc                  /usr/bin/llc-${CLANG_VERSION} \
        --slave   /usr/bin/lli                  lli                  /usr/bin/lli-${CLANG_VERSION} \
        --slave   /usr/bin/obj2yaml             obj2yaml             /usr/bin/obj2yaml-${CLANG_VERSION} \
        --slave   /usr/bin/opt                  opt                  /usr/bin/opt-${CLANG_VERSION} \
        --slave   /usr/bin/sanstats             sanstats             /usr/bin/sanstats-${CLANG_VERSION} \
        --slave   /usr/bin/verify-uselistorder  verify-uselistorder  /usr/bin/verify-uselistorder-${CLANG_VERSION} \
        --slave   /usr/bin/wasm-ld              wasm-ld              /usr/bin/wasm-ld-${CLANG_VERSION} \
        --slave   /usr/bin/yaml2obj             yaml2obj             /usr/bin/yaml2obj-${CLANG_VERSION}

