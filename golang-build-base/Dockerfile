ARG AZLINUX_BASE_VERSION=2023

# FROM 707767160287.dkr.ecr.region.amazonaws.com/amazonlinux/base:${AZLINUX_BASE_VERSION}
FROM public.ecr.aws/amazonlinux/amazonlinux:${AZLINUX_BASE_VERSION}

LABEL name="golang-base"

# install golang
RUN dnf update \
        --assumeyes \
    && dnf install \
        --assumeyes \
        --setopt=install_weak_deps=False \
        --setopt=tsflags=nodocs \
        golang \
    && dnf clean all \
    && rm -rf /var/cache/yum
