ARG AZLINUX_BASE_VERSION=hardened
FROM quay.io/cdis/amazonlinux-base:${AZLINUX_BASE_VERSION}

LABEL name="python-nginx-build-base"
LABEL version="3.13"

ENV PYTHONUNBUFFERED=1 \
    PYTHONIOENCODING=UTF-8 \
    POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_IN_PROJECT=1 \
    POETRY_VIRTUALENVS_CREATE=1

RUN dnf -y update && \
    dnf -y install --nodocs --setopt=install_weak_deps=False git python3.13 python3.13-pip python3.13-devel libcap nginx \
    && dnf clean all \
    && rm -rf /var/cache/dnf /var/lib/dnf /var/tmp/dnf* /tmp/dnf* \
    && rm -rf /usr/share/doc/* /usr/share/man/* /usr/share/info/* /usr/share/locale/*

# Set python3 as python3.13 by default
RUN ln -sf /usr/bin/python3.13 /usr/bin/python3 && \
    ln -sf /usr/bin/pip3.13 /usr/bin/pip3

# Install pipx using Python 3.13
RUN python3.13 -m pip install --upgrade pip && \
    python3.13 -m pip install pipx && \
    python3.13 -m pipx ensurepath

# Harden nginx: allow port 80 for non-root, manage ownership
RUN setcap 'cap_net_bind_service=+ep' /usr/sbin/nginx && \
    chown -R gen3:gen3 /var/log/nginx && \
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log && \
    mkdir -p /var/lib/nginx/tmp/client_body && \
    chown -R gen3:gen3 /var/lib/nginx/

USER gen3
RUN pipx install 'poetry>=1.7,<2.0'
ENV PATH="/home/gen3/.local/bin:${PATH}"
USER root
COPY nginx.conf /etc/nginx/nginx.conf

# Final cleanup for STIG/minimize image
RUN rm -rf /tmp/* /var/tmp/* /var/log/*

USER gen3
CMD ["nginx", "-g", "daemon off;"]