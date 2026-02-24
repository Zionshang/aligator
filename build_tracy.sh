#!/usr/bin/env bash
set -euo pipefail

# Keep parallelism conservative to avoid system freeze.
JOBS=4

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

cmake -S build/_deps/tracy-src/csvexport -B build/tracy-csvexport
cmake --build build/tracy-csvexport -j"${JOBS}"
