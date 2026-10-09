ARG AZLINUX_VERSION=2023

FROM public.ecr.aws/amazonlinux/amazonlinux:${AZLINUX_VERSION}

ARG PG_MAJOR=17
ARG AL_RELEASE=latest
ARG KUBECTL_VERSION=v1.36.1

# Get system updates and install essential packages (crypto tools too)
RUN dnf -y update && \
    dnf -y install \
        crypto-policies \
        crypto-policies-scripts \
        shadow-utils \
        openssl \
        ca-certificates \
        --nodocs \
    && dnf clean all && \
    rm -rf /var/cache/dnf /var/cache/yum /var/lib/dnf /var/lib/yum /var/tmp/dnf* /var/tmp/yum* /tmp/dnf* /tmp/yum*

RUN set -eu; \
    dnf install -y curl-minimal ca-certificates; \
    dnf clean all; \
    case "$(uname -m)" in \
      x86_64) KUBECTL_ARCH=amd64 ;; \
      aarch64) KUBECTL_ARCH=arm64 ;; \
      *) echo "Unsupported architecture"; exit 1 ;; \
    esac; \
    KUBECTL_VERSION="${KUBECTL_VERSION:-$(curl -fsSL https://dl.k8s.io/release/stable.txt)}"; \
    KUBECTL_URL="https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${KUBECTL_ARCH}"; \
    KUBECTL_TMP="$(mktemp -d)"; \
    cd "$KUBECTL_TMP"; \
    curl -fsSLO "${KUBECTL_URL}/kubectl"; \
    curl -fsSLO "${KUBECTL_URL}/kubectl.sha256"; \
    echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check; \
    install -m 0755 kubectl /usr/local/bin/kubectl; \
    cd /; \
    rm -rf "$KUBECTL_TMP"; \
    kubectl version --client

# Create gen3 user
RUN groupadd -g 1000 gen3 && \
    useradd -m -s /bin/bash -u 1000 -g gen3 gen3

# FIPS-Ready:
RUN update-crypto-policies --set FIPS

# Hardening: Clean up root's shell history
RUN rm -f /root/.bash_history /root/.wget-hsts

# Set minimal environment variables
ENV \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8

# Slim down the PATH
ENV PATH="/usr/local/bin:/usr/bin:/bin"

# Mask unused services (like sshd and cron)
RUN systemctl mask --runtime sshd || true \
    && systemctl mask --runtime cron || true

# Set a restrictive default umask (027)
RUN echo "umask 027" >> /etc/profile

# Install minimal psql client version
RUN dnf -y install \
  --releasever="${AL_RELEASE}" \
  --setopt=install_weak_deps=False \
  --setopt=tsflags=nodocs \
  postgresql${PG_MAJOR} && dnf clean all

# Final directory cleanups
RUN rm -rf /tmp/* /var/tmp/* /var/log/*

CMD ["/bin/bash"]
