#!/bin/bash
set -exo pipefail

if [[ ${target_platform} == "linux-ppc64le" ]]; then
    extra_cmake_args="-DRKCOMMON_NO_SIMD=ON"
fi

cmake -S . -B build -G Ninja \
    ${CMAKE_ARGS} \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_TESTING=ON \
    -DRKCOMMON_STRICT_BUILD=OFF \
    -DRKCOMMON_WARN_AS_ERRORS=OFF \
    -DRKCOMMON_TASKING_SYSTEM=TBB \
    -DRKCOMMON_TBB_ROOT="${PREFIX}" \
    ${extra_cmake_args}

cmake --build build --parallel ${CPU_COUNT}

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR:-}" != "" ]]; then
    ctest -V --test-dir build --parallel ${CPU_COUNT}
fi

cmake --install build
