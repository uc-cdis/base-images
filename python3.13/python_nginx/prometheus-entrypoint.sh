#!/usr/bin/env bash
set -euo pipefail

# Prometheus multiprocess mode requires a writable empty dir at startup.
# This script runs before CMD so that the directory is guaranteed to exist and clean.

# export PROMETHEUS_MULTIPROC_DIR="${PROMETHEUS_MULTIPROC_DIR:-/var/tmp/prometheus_metrics}"

# Fail if the Prometheus multiprocessing directory is empty or root.
if [[ -z "${PROMETHEUS_MULTIPROC_DIR}" || "${PROMETHEUS_MULTIPROC_DIR}" == "/" ]]; then
  echo "[prometheus-entrypoint] ERROR: invalid PROMETHEUS_MULTIPROC_DIR='${PROMETHEUS_MULTIPROC_DIR}'" >&2
  exit 1
fi

mkdir -p "${PROMETHEUS_MULTIPROC_DIR}"

# Clear stale multiprocess files from dir
find "${PROMETHEUS_MULTIPROC_DIR}" -mindepth 1 -maxdepth 1 -exec rm -rf {} +

# chmod 0775 "${PROMETHEUS_MULTIPROC_DIR}" 2>/dev/null || true

exec "$@"
