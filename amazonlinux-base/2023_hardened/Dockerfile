ARG AZLINUX_VERSION=2023

FROM public.ecr.aws/amazonlinux/amazonlinux:${AZLINUX_VERSION}

# Get system updates and install essential packages (crypto tools too)
RUN dnf -y update && \
    dnf -y install \
        crypto-policies \
        crypto-policies-scripts \
        openssl \
        ca-certificates \
        --nodocs \
    && dnf clean all && \
    rm -rf /var/cache/dnf /var/cache/yum /var/lib/dnf /var/lib/yum /var/tmp/dnf* /var/tmp/yum* /tmp/dnf* /tmp/yum*

# FIPS-Ready:
RUN update-crypto-policies --set FIPS

# Hardening: Clean up root's shell history
RUN rm -f /root/.bash_history /root/.wget-hsts

# Set minimal environment variables
ENV \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8

# Slim down the PATH
ENV PATH="/usr/local/bin:/usr/bin:/bin"

# Mask unused services (like sshd and cron)
RUN systemctl mask --runtime sshd || true \
    && systemctl mask --runtime cron || true

# Set a restrictive default umask (027)
RUN echo "umask 027" >> /etc/profile

# Final directory cleanups
RUN rm -rf /tmp/* /var/tmp/* /var/log/*

CMD ["/bin/bash"]