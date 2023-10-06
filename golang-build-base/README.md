# Golang build base image [`..`](↩)

## Example usage

```
FROM 707767160287.dkr.ecr.us-east-1.amazonaws.com/gen3/golang-build-base:master as base

ARG TARGETOS
ARG TARGETARCH

ENV appname=someapp

ENV CGO_ENABLED=0
ENV GOOS=${TARGETOS}
ENV GOARCH=${TARGETARCH}

FROM base as builder
RUN dnf install -y go \
    && dnf clean all \
    && rm -rf /var/cache/yum/

WORKDIR $GOPATH/src/github.com/uc-cdis/someapp/

COPY go.mod .
COPY go.sum .

RUN go mod download

COPY . .

RUN GITCOMMIT=$(git rev-parse HEAD) \
    GITVERSION=$(git describe --always --tags) \
    && go build \
    -ldflags="-X 'github.com/uc-cdis/someapp/version.GitCommit=${GITCOMMIT}' -X 'github.com/uc-cdis/someapp/version.GitVersion=${GITVERSION}'" \
    -o /someapp

FROM scratch
COPY --from=builder /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem /etc/ssl/certs/ca-certificates.crt
COPY --from=builder /someapp /someapp
CMD ["/someapp"]

```
