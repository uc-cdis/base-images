ARG AZLINUX_VERSION=2023

FROM public.ecr.aws/amazonlinux/amazonlinux:${AZLINUX_VERSION}

# Update system
RUN dnf -y update && \
    dnf -y install \
        crypto-policies \
        crypto-policies-scripts \
        openssl \
        ca-certificates \
        --nodocs \
    && dnf clean all && \
    rm -rf /var/cache/dnf /var/cache/yum /var/lib/dnf /var/lib/yum /var/tmp/dnf* /var/tmp/yum* /tmp/dnf* /tmp/yum*

# Hardening: Remove root's shell history for cleaner base
RUN rm -f /root/.bash_history /root/.wget-hsts

# Set minimal environment variables for future containers
ENV \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8

# Reduce PATH to standard system binaries only (no /usr/local/sbin or /root)
ENV PATH="/usr/local/bin:/usr/bin:/bin"

# Disable SSH, cron, and other unused services
RUN systemctl mask --runtime sshd || true \
    && systemctl mask --runtime cron || true

# Set the default umask (helps restrict default permissions for files created by next layers/users)
RUN echo "umask 027" >> /etc/profile

# Additional STIG-inspired directory cleanups
RUN rm -rf /tmp/* /var/tmp/* /var/log/*


CMD ["/bin/bash"]