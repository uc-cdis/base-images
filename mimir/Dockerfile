FROM quay.io/cdis/golang-build-base:master

ARG MIMIR_VERSION="mimir-2.12.0"
ENV MIMIR_VERSION ${MIMIR_VERSION}

RUN curl -fLo mimir "https://github.com/grafana/mimir/releases/download/$MIMIR_VERSION/mimir-linux-amd64" && \
    mv mimir /bin/mimir && \
    chmod +x /bin/mimir

ENTRYPOINT [ "/bin/mimir" ]