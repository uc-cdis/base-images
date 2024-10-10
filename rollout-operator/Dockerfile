FROM quay.io/cdis/golang-build-base:master AS build

ENV ROLLOUT_VERSION=0.13.0

ARG TARGETOS=linux
ARG TARGETARCH=amd64
ARG BUILDTARGET=rollout-operator

RUN git config --global http.lowSpeedLimit 0 && \
    git config --global http.lowSpeedTime 999 && \
    git clone https://github.com/grafana/rollout-operator.git --branch v${ROLLOUT_VERSION} --depth 1 /src/rollout-operator

WORKDIR /src/rollout-operator

RUN GOOS=${TARGETOS} GOARCH=${TARGETARCH} make ${BUILDTARGET}

FROM quay.io/cdis/amazonlinux-base:master AS final

COPY --from=build /src/rollout-operator/rollout-operator /bin/rollout-operator

RUN yum install shadow-utils -y && \
    groupadd -g 10001 rollout-operator && \
    useradd -u 10001 rollout-operator -g rollout-operator

RUN chown -R rollout-operator:rollout-operator /bin/

USER rollout-operator
ENTRYPOINT [ "/bin/rollout-operator" ]