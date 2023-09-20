ARG AZLINUX_VERSION=2023

FROM public.ecr.aws/amazonlinux/amazonlinux:${AZLINUX_VERSION}

# Install dependencies
RUN dnf update -y && dnf update --security -y && dnf install -y \
    python3-pip git vim gcc \
    && dnf clean all \
    && rm -rf /var/cache/yum
