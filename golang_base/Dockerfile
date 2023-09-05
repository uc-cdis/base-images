ARG AZLINUX_VERSION=latest

FROM public.ecr.aws/amazonlinux/amazonlinux:${AZLINUX_VERSION}

LABEL name="golang-base" \
    version="latest"

# Set environment variables
ENV GOROOT=/usr/local/go \
    GOPATH=/go 
# Install necessary packages
RUN yum install -y wget tar gzip golang

# Set the working directory
WORKDIR $GOPATH