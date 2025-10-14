ARG AZLINUX_BASE_VERSION=hardened

FROM 707767160287.dkr.ecr.us-east-1.amazonaws.com/gen3/amazonlinux-base:${AZLINUX_BASE_VERSION}

LABEL name="python-build-base"
LABEL version="3.13"

ENV PYTHONUNBUFFERED=1 \
    PYTHONIOENCODING=UTF-8 \
    POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_IN_PROJECT=1 \
    POETRY_VIRTUALENVS_CREATE=1

# Install python build dependencies with minimal docs/locales
RUN dnf -y update && \
    dnf -y install --nodocs --setopt=install_weak_deps=False git python3.13 python3.13-pip python3.13-devel && \
    dnf clean all && \
    rm -rf /var/cache/dnf /var/cache/yum /var/lib/dnf /var/lib/yum /var/tmp/dnf* /var/tmp/yum* /tmp/dnf* /tmp/yum* \
    && rm -rf /usr/share/doc/* /usr/share/man/* /usr/share/info/* /usr/share/locale/*

# Ensure python3 points to python3.13
RUN ln -sf /usr/bin/python3.13 /usr/bin/python3 && \
    ln -sf /usr/bin/pip3.13 /usr/bin/pip3

# Create empty virtualenv
RUN python3 -m venv /venv

ENV PATH="/venv/bin:$PATH" \
    VIRTUAL_ENV="/venv"