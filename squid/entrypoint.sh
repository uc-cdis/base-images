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

create_log_dir
create_cache_dir

mkdir -p ${SQUID_PID_DIR} ${SQUID_SYSCONFIG_DIR}
chmod -R 755 ${SQUID_PID_DIR} ${SQUID_SYSCONFIG_DIR}
chown -R ${SQUID_USER}:${SQUID_USER} ${SQUID_PID_DIR} ${SQUID_SYSCONFIG_DIR}

if [[ ! -d ${SQUID_CACHE_DIR}/00 ]]; then
    echo "Initializing cache..."
    $(which squid) -N -f ${SQUID_SYSCONFIG_DIR}/squid.conf -z
fi
echo "Starting squid..."
sleep 500000000
exec $(which squid) -N -d 2 -f ${SQUID_SYSCONFIG_DIR}/squid.conf
