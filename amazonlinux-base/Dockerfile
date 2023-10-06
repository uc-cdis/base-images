ARG AZLINUX_VERSION=2023

FROM public.ecr.aws/amazonlinux/amazonlinux:${AZLINUX_VERSION}

# install any available security and bugfix updates
RUN dnf update \
        --assumeyes \
    && dnf update \
        --security \
        --bugfix \
        --assumeyes \
    && dnf clean all \
    && rm -rf /var/cache/yum
