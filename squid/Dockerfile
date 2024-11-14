ARG AZLINUX_BASE_VERSION=master
FROM 707767160287.dkr.ecr.us-east-1.amazonaws.com/gen3/amazonlinux-base:${AZLINUX_BASE_VERSION}

# FROM quay.io/cdis/amazonlinux-base:master

ENV SQUID_USER="squid" \
    SQUID_CACHE_DIR="/var/cache/squid" \
    SQUID_LOG_DIR="/var/log/squid" \
    SQUID_SYSCONFIG_DIR="/etc/squid" \
    SQUID_PID_DIR="/var/run/squid" \
    SQUID_VERSION="squid-6.7-1.amzn2023.0.1"

# Update package lists and install the latest packages
RUN dnf update -y && dnf upgrade -y && \
    dnf -y install openssl-devel

# Create a non-root user for Squid with a strong random password
RUN useradd -m -s /bin/bash squid

# Install required packages
RUN dnf install ${SQUID_VERSION} -y

# Copy in entrypoint script
COPY entrypoint.sh /usr/sbin/entrypoint.sh

# Run updates 
RUN dnf update -y && dnf upgrade -y

# Expose Squid Ports
EXPOSE 3128/tcp
EXPOSE 3129/tcp
EXPOSE 3130/tcp

VOLUME ${SQUID_LOG_DIR} ${SQUID_CACHE_DIR} ${SQUID_PID_DIR} ${SQUID_SYSCONFIG_DIR}

ENTRYPOINT ["/usr/sbin/entrypoint.sh"]