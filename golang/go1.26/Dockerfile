ARG AZLINUX_BASE_VERSION=hardened

ARG GO_VERSION=1.26.0

# ==============================================================================
# STAGE 1: BUILDER
# ==============================================================================
FROM quay.io/cdis/amazonlinux-base:${AZLINUX_BASE_VERSION} AS builder

ARG GO_VERSION

# Temporary root access to install extraction tools
USER root

# Install minimal tools needed for extraction
RUN dnf -y install --nodocs tar gzip && \
    dnf clean all

# Download and Extract Go
RUN curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" \
    | tar -xz -C /usr/local

# Create the workspace structure
RUN mkdir -p /go/{bin,pkg,src}

# ==============================================================================
# STAGE 2:  RUNTIME
# ==============================================================================
FROM quay.io/cdis/amazonlinux-base:${AZLINUX_BASE_VERSION}

ARG GO_VERSION
LABEL name="golang${GO_VERSION}" \
        version="${GO_VERSION}"

# 1. Environment Configuration
ENV GOPATH=/go
ENV PATH=$GOPATH/bin:/usr/local/go/bin:$PATH

# 2. Persistence (Profile Script)
# Create this BEFORE switching users
RUN echo 'export PATH=$PATH:/usr/local/go/bin:/go/bin' > /etc/profile.d/go.sh && \
    chmod 644 /etc/profile.d/go.sh

# 3. Artifact Transfer & Minimization
COPY --from=builder --chown=1000:1000 /usr/local/go /usr/local/go
COPY --from=builder --chown=1000:1000 /go /go

# 4. Final Permission Hardening
# 750 = Owner (gen3) has full access. Group (gen3) has Read/Execute. World has NONE.
RUN chmod -R 750 /usr/local/go

#5. Ensure git is installed
RUN dnf -y install --nodocs git && \
    dnf clean all && \
    rm -rf /var/cache/dnf /var/cache/yum


# 6. Drop Privileges
USER gen3
WORKDIR /go

# 7. Verification
RUN go version

CMD ["/bin/bash"]