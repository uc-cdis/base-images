ARG AZLINUX_BASE_VERSION=2023

# FROM 707767160287.dkr.ecr.region.amazonaws.com/amazonlinux/base:${AZLINUX_BASE_VERSION}
FROM public.ecr.aws/amazonlinux/amazonlinux:${AZLINUX_BASE_VERSION}

LABEL name="python-base"
LABEL version="3.9"

ENV POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_IN_PROJECT=1 \
    POETRY_VIRTUALENVS_CREATE=1

# install python build dependencies
RUN dnf update -y \
    && dnf install --setopt=install_weak_deps=False --setopt=tsflags=nodocs -y python3-pip \
    && dnf clean all \
    && rm -rf /var/cache/yum

# create empty virtualenv
RUN python3 -m venv /venv
