#!/usr/bin/env bash
set -euo pipefail

# Prefer Conda, fallback to Python venv.
PREFIX="${CONDA_PREFIX:-${VIRTUAL_ENV:-}}"
if [[ -z "${PREFIX}" ]]; then
  echo "Error: no active virtual environment. Activate conda/venv first." >&2
  exit 1
fi

# Keep parallelism conservative to avoid system freeze.
JOBS=4

cmake -S . -B build \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DALIGATOR_TRACY_ENABLE=ON \
  -DDOWNLOAD_TRACY=ON \
  -DBUILD_BENCHMARKS=OFF \
  -DINSTALL_DOCUMENTATION=OFF

cmake --build build --clean-first -j"${JOBS}"
cmake --install build

echo "Installed aligator to: ${PREFIX}"

# Build downloaded Tracy profiler with X11 backend (disable Wayland path).
TRACY_PROFILER_SRC="build/_deps/tracy-src/profiler"
TRACY_PROFILER_BUILD="build/tracy-profiler-build"

if [[ -d "${TRACY_PROFILER_SRC}" ]]; then
  # imgui_impl_glfw.cpp uses X11 APIs directly in LEGACY mode, so explicitly
  # provide the X11 link set when building the profiler on Linux.
  TRACY_PROFILER_LD_FLAGS=""
  if [[ "$(uname -s)" == "Linux" ]]; then
    TRACY_PROFILER_LD_FLAGS="-lX11 -lXrandr -lXi -lXinerama -lXcursor"
  fi

  cmake -S "${TRACY_PROFILER_SRC}" -B "${TRACY_PROFILER_BUILD}" \
    -DCMAKE_BUILD_TYPE=Release \
    -DLEGACY=ON \
    -DCMAKE_EXE_LINKER_FLAGS="${TRACY_PROFILER_LD_FLAGS}"
  cmake --build "${TRACY_PROFILER_BUILD}" -j"${JOBS}"
  echo "Tracy profiler built at: ${TRACY_PROFILER_BUILD}/tracy-profiler"
else
  echo "Warning: Tracy source not found at ${TRACY_PROFILER_SRC}" >&2
fi
