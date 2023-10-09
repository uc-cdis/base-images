ARG AZLINUX_BASE_VERSION=master

FROM 707767160287.dkr.ecr.us-east-1.amazonaws.com/gen3/amazonlinux-base:${AZLINUX_BASE_VERSION}

LABEL name="python-build-base"
LABEL version="3.9"

ENV PYTHONUNBUFFERED=1 \
    PYTHONIOENCODING=UTF-8 \
    POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_IN_PROJECT=1 \
    POETRY_VIRTUALENVS_CREATE=1

# install python build dependencies
RUN dnf update \
        --assumeyes \
    && dnf install \
        --assumeyes \
        --setopt=install_weak_deps=False \
        --setopt=tsflags=nodocs \
        git \
        python3-pip \
    && dnf clean all \
    && rm -rf /var/cache/yum

# create empty virtualenv
RUN python3 -m venv /venv
