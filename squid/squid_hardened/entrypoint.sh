#!/bin/bash
set -e

# SQUID_USER, SQUID_CACHE_DIR, SQUID_LOG_DIR, SQUID_PID_DIR, and SQUID_SYSCONFIG_DIR
# are defined in the Dockerfile environment variables.

create_log_dir() {
    mkdir -p ${SQUID_LOG_DIR}
    chmod -R 755 ${SQUID_LOG_DIR}
    chown -R ${SQUID_USER}:${SQUID_USER} ${SQUID_LOG_DIR}
}

create_cache_dir() {
    mkdir -p ${SQUID_CACHE_DIR}
    chown -R ${SQUID_USER}:${SQUID_USER} ${SQUID_CACHE_DIR}
}

create_pid_dir() {
    # CRITICAL: Create the directory the PID file will be written to.
    mkdir -p ${SQUID_PID_DIR}
    # CRITICAL: Set ownership to the non-root user (runs as root here).
    chown -R ${SQUID_USER}:${SQUID_USER} ${SQUID_PID_DIR}
}

initialize_ssl_db() {
    SSL_DB_DIR="${SQUID_CACHE_DIR}/ssl_db"

    rm -rf ${SSL_DB_DIR}
    /usr/lib64/squid/security_file_certgen -c -s ${SSL_DB_DIR} -M 4MB

    # Use environment variables consistently
    chown -R ${SQUID_USER}:${SQUID_USER} ${SSL_DB_DIR}
    chmod -R 755 ${SSL_DB_DIR}
}

# Run setup commands as root to handle chown
create_log_dir
create_cache_dir
create_pid_dir # <--- THIS ENSURES THE DIRECTORY EXISTS
initialize_ssl_db

echo "Starting squid as user ${SQUID_USER}..."
# Drop privileges and launch the main process as the non-root user.
exec su -s /bin/sh ${SQUID_USER} -c "/usr/sbin/squid -N -d 2 -f ${SQUID_SYSCONFIG_DIR}/squid.conf"