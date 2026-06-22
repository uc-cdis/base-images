#!/usr/bin/env bash
set -euo pipefail

# Prometheus multiprocess mode requires a writable, empty directory at startup.
# Without cleaning this directory, stale .db files from a prior process accumulate
# and cause incorrect metric values across container restarts.
#
# This script runs before the application CMD so that:
#   1. The directory is guaranteed to exist (handles override or volume-mount cases).
#   2. Any stale multiprocess .db files from a previous run are cleared.
#   3. Permissions are set so the gen3 process can write new files.
#
# Services that override ENTRYPOINT are responsible for replicating this behavior.

export PROMETHEUS_MULTIPROC_DIR="${PROMETHEUS_MULTIPROC_DIR:-/var/tmp/prometheus_metrics}"

if [[ -z "${PROMETHEUS_MULTIPROC_DIR}" || "${PROMETHEUS_MULTIPROC_DIR}" == "/" ]]; then
  echo "[prometheus-entrypoint] ERROR: invalid PROMETHEUS_MULTIPROC_DIR='${PROMETHEUS_MULTIPROC_DIR}'" >&2
  exit 1
fi

mkdir -p "${PROMETHEUS_MULTIPROC_DIR}"

# Clear stale multiprocess files (contents only; preserve the directory itself
# so volume mounts are not disrupted).
find "${PROMETHEUS_MULTIPROC_DIR}" -mindepth 1 -maxdepth 1 -exec rm -rf {} +

chmod 0775 "${PROMETHEUS_MULTIPROC_DIR}" 2>/dev/null || true

exec "$@"
