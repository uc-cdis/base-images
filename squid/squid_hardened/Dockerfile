# Use the assumed hardened base image
FROM quay.io/cdis/amazonlinux-base:hardened

# Define environment variables
ENV SQUID_USER="squid" \
    SQUID_CACHE_DIR="/var/cache/squid" \
    SQUID_LOG_DIR="/var/log/squid" \
    SQUID_SYSCONFIG_DIR="/etc/squid" \
    SQUID_PID_DIR="/var/run/squid" \
    SQUID_VERSION="squid-6.7-1.amzn2023.0.1"

# Install required packages (squid, openssl-devel, and which).
RUN dnf install -y openssl-devel ${SQUID_VERSION} which && \
    dnf clean all && \
    rm -rf /var/cache/dnf


# This file should be replaced by a Helm-mounted volume containing the full config (ACLs, etc.).
RUN echo "pid_filename ${SQUID_PID_DIR}/squid.pid" > /etc/squid/squid.conf && \
    echo "http_port 3128" >> /etc/squid/squid.conf

# Copy in the corrected entrypoint script (which must be in the build context)
COPY entrypoint.sh /usr/sbin/entrypoint.sh
RUN chmod +x /usr/sbin/entrypoint.sh

# Expose Squid Ports
EXPOSE 3128/tcp
EXPOSE 3129/tcp
EXPOSE 3130/tcp

# Define volumes
VOLUME ${SQUID_LOG_DIR} ${SQUID_CACHE_DIR} ${SQUID_PID_DIR} ${SQUID_SYSCONFIG_DIR}

# Privilege dropping is handled securely inside the entrypoint script with 'exec su'.
ENTRYPOINT ["/usr/sbin/entrypoint.sh"]