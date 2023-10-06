ARG AZLINUX_VERSION=2023

FROM public.ecr.aws/amazonlinux/amazonlinux:${AZLINUX_VERSION}

# install any available security and bugfix updates
RUN dnf update -y \
    && dnf update --security --bugfix -y \
    && dnf clean all \
    && rm -rf /var/cache/yum
