#!/bin/bash
set -e

create_log_dir() {
    mkdir -p ${SQUID_LOG_DIR}
    chmod -R 755 ${SQUID_LOG_DIR}
    chown -R ${SQUID_USER}:${SQUID_USER} ${SQUID_LOG_DIR}
}

create_cache_dir() {
    mkdir -p ${SQUID_CACHE_DIR}
    chown -R ${SQUID_USER}:${SQUID_USER} ${SQUID_CACHE_DIR}
}

initialize_ssl_db() {
    rm -rf ${SQUID_CACHE_DIR}/ssl_db
    /usr/lib64/squid/security_file_certgen -c -s ${SQUID_CACHE_DIR}/ssl_db -M 4MB
    chown -R squid:squid /var/cache/squid/ssl_db
    chmod -R 755 /var/cache/squid/ssl_db
}

create_log_dir
create_cache_dir
initialize_ssl_db

echo "Starting squid..."
exec $(which squid) -N -d 2 -f ${SQUID_SYSCONFIG_DIR}/squid.conf
