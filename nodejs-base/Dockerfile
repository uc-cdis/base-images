ARG AZLINUX_BASE_VERSION=master

# For local development
FROM quay.io/cdis/amazonlinux-base:${AZLINUX_BASE_VERSION}

# FROM 707767160287.dkr.ecr.us-east-1.amazonaws.com/gen3/amazonlinux-base:${AZLINUX_BASE_VERSION}

LABEL name="nodejs-build-base"

# Install dependencies
RUN dnf install git tar --assumeyes

ENV NVM_DIR=/home/gen3/.nvm
ENV NODE_VERSION=v16.20.2
ENV NODE_PATH=$NVM_DIR/versions/node/$NODE_VERSION/lib/node_modules
ENV PATH=$NVM_DIR/versions/node/$NODE_VERSION/bin:$PATH

# Create gen3 user
RUN groupadd -g 1000 gen3 && \
    useradd -m -s /bin/bash -u 1000 -g gen3 gen3

USER gen3

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash \
    && . $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

USER root
