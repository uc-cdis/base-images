ARG AZLINUX_BASE_VERSION=feat_improv

FROM 707767160287.dkr.ecr.region.amazonaws.com/gen3/amazonlinux-base:${AZLINUX_BASE_VERSION}

LABEL name="golang-build-base"

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
