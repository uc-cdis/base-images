FROM quay.io/cdis/golang-build-base:master AS build

ENV ROLLOUT_VERSION=0.13.0

ARG TARGETOS=linux
ARG TARGETARCH=amd64
ARG BUILDTARGET=rollout-operator

# RUN git clone https://github.com/grafana/rollout-operator.git --branch v${ROLLOUT_VERSION} --depth 1 /src/rollout-operator

RUN curl -L -o rollout-operator.tar.gz https://github.com/grafana/rollout-operator/archive/refs/tags/v${ROLLOUT_VERSION}.tar.gz && \
    mkdir /src/rollout-operator && \
    tar -xzvf rollout-operator.tar.gz -C /src/rollout-operator --strip-components=1 && \
    rm rollout-operator.tar.gz


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