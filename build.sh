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
