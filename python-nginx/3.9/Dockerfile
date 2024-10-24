ARG AZLINUX_BASE_VERSION=master

# For local development
# FROM quay.io/cdis/amazonlinux-base:master

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

# install poetry
RUN pip install --upgrade poetry 

# create gen3 user
RUN groupadd -g 1000 gen3 && \
    useradd -m -s /bin/bash -u 1000 -g gen3 gen3

# install nginx
RUN yum install nginx -y && \
    # allows nginx to run on port 80 without being root user
    setcap 'cap_net_bind_service=+ep' /usr/sbin/nginx && \
    chown -R gen3:gen3 /var/log/nginx && \
    # pipe nginx logs to stdout and stderr
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log && \
    mkdir -p /var/lib/nginx/tmp/client_body && \
    chown -R gen3:gen3 /var/lib/nginx/

# copy nginx config
COPY ./nginx.conf /etc/nginx/nginx.conf

