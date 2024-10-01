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

# apply_backward_compatibility_fixes() {
#     if [[ -f ${SQUID_SYSCONFIG_DIR}/squid.user.conf ]]; then
#         rm -rf ${SQUID_SYSCONFIG_DIR}/squid.conf
#         ln -sf ${SQUID_SYSCONFIG_DIR}/squid.user.conf ${SQUID_SYSCONFIG_DIR}/squid.conf
#     fi
# }

create_log_dir
create_cache_dir
# apply_backward_compatibility_fixes

# if [[ ! -d ${SQUID_CACHE_DIR}/00 ]]; then
#     echo "Initializing cache..."
#     $(which squid) -N -f ${SQUID_SYSCONFIG_DIR}/squid.conf -z
# fi


rm -rf ${SQUID_CACHE_DIR}/ssl_db
/usr/lib64/squid/security_file_certgen -c -s ${SQUID_CACHE_DIR}/ssl_db -M 4MB
chown -R squid:squid /var/cache/squid/ssl_db
chmod -R 755 /var/cache/squid/ssl_db

echo "Starting squid..."
exec $(which squid) -N -d 2 -f ${SQUID_SYSCONFIG_DIR}/squid.conf
