ARG AZLINUX_VERSION=2023

FROM public.ecr.aws/amazonlinux/amazonlinux:${AZLINUX_VERSION}

# Install dependencies testing
RUN dnf update -y && dnf update --security -y && dnf install -y \
    python3-pip vim \
    python3-setuptools \
    && dnf clean all \
    && rm -rf /var/cache/yum
