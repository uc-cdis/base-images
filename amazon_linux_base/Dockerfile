ARG AZLINUX_VERSION=latest

FROM public.ecr.aws/amazonlinux/amazonlinux:${AZLINUX_VERSION}

# Install dependencies 
RUN dnf update -y && dnf update --security -y && dnf install -y \
    python3-pip \
    python3-setuptools \
    && dnf clean all \
    && rm -rf /var/cache/yum
