#!/usr/bin/env bash
set -euo pipefail

# Clean and create/re-create the prometheus directory each container start (required by prometheus multiprocess)
rm -rf "${PROMETHEUS_MULTIPROC_DIR}" || true
mkdir -p "${PROMETHEUS_MULTIPROC_DIR}" || {
echo "[prom-entrypoint] ERROR: cannot mkdir ${PROMETHEUS_MULTIPROC_DIR}" >&2
exit 1
}
chown -R gen3:gen3 "${PROMETHEUS_MULTIPROC_DIR}" 2>/dev/null || true
chmod 0775 "${PROMETHEUS_MULTIPROC_DIR}" 2>/dev/null || true

# Hand off to CMD
exec "$@"