FROM quay.io/cdis/golang-build-base:master

ARG MIMIR_VERSION="mimir-2.12.0"
ENV MIMIR_VERSION ${MIMIR_VERSION}

RUN curl -fLo mimir "https://github.com/grafana/mimir/releases/download/$MIMIR_VERSION/mimir-linux-amd64" && \
    mv mimir /bin/mimir && \
    chmod +x /bin/mimir

RUN  yum install shadow-utils -y

RUN groupadd -g 10001 mimir && \
    useradd -u 10001 mimir -g mimir
RUN chown mimir:mimir /bin/mimir

USER 10001
EXPOSE 8080

ENTRYPOINT [ "/bin/mimir" ]