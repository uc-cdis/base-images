ARG AZLINUX_VERSION=2023

FROM public.ecr.aws/amazonlinux/amazonlinux:${AZLINUX_VERSION}

# install any available security and bugfix updates
RUN dnf -y update
# Install packages \
RUN dnf -y install crypto-policies crypto-policies-scripts openssl dracut-fips && \
    fips-mode-setup --enable --no-bootcfg && \
    touch /etc/system-fips && \
    fips-finish-install --complete \
    dnf clean all && \
    rm -rf /var/cache/yum \
    rm -rf /var/lib/yum \
    rm -rf /var/tmp/yum-* \
    rm -rf /tmp/yum* \
    rm -rf /var/tmp/dnf* \
    rm -rf /tmp/dnf*

ENV OPENSSL_FIPS=1 \
    OPENSSL_FORCE_FIPS_MODE=1 \
    LC_ALL=C.UTF-8
