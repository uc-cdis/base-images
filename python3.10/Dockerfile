ARG AZLINUX_BASE_VERSION=3.13-pythonnginx
FROM quay.io/cdis/amazonlinux-base:${AZLINUX_BASE_VERSION} AS base

LABEL name="python-nginx-build-base"
LABEL version="3.10"

USER root

ENV PYTHONUNBUFFERED=1 \
    PYTHONIOENCODING=UTF-8 \
    POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_IN_PROJECT=1 \
    POETRY_VIRTUALENVS_CREATE=1


# Install python build dependencies
RUN dnf groupinstall "Development Tools" -y \
    && dnf install openssl-devel bzip2-devel libffi-devel zlib-devel -y \
    && curl -O https://www.python.org/ftp/python/3.10.13/Python-3.10.13.tgz \
    && tar xzf Python-3.10.13.tgz \
    && cd Python-3.10.13 \
    && ./configure --enable-optimizations \
    && make altinstall \
    && cd .. \
    && rm -rf Python-3.10.13*
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

# Install pipx
RUN python3.10 -m pip install pipx && \
    python3.10 -m pipx ensurepath


USER gen3
# Install Poetry via pipx
RUN pipx install 'poetry<2.0'
ENV PATH="/home/gen3/.local/bin:${PATH}"
USER root

# This is a copy of the python3.9 nginx.conf
COPY nginx.conf /etc/nginx/nginx.conf
