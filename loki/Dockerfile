FROM quay.io/cdis/golang-build-base:master

ENV LOKI_VERSION=2.9.1

RUN mkdir -p /etc/loki/

RUN curl -L -v --retry 5 https://github.com/grafana/loki/releases/download/v{LOKI_VERSION}loki-linux-amd64.zip -o loki-linux-amd64.zip && \
    unzip loki-linux-amd64.zip && \
    mv loki-linux-amd64 /usr/bin/loki && \
    chmod +x /usr/bin/loki

RUN curl -fLo loki-config.yaml https://raw.githubusercontent.com/grafana/loki/main/cmd/loki/loki-docker-config.yaml && \
    mv loki-config.yaml /etc/loki/local-config.yaml

RUN  yum install shadow-utils -y

RUN groupadd -g 10001 loki && \
    useradd -u 10001 loki -g loki
RUN mkdir -p /loki/rules && \
    mkdir -p /loki/rules-temp && \
    chown -R loki:loki /etc/loki /loki

USER 10001
EXPOSE 3100
ENTRYPOINT [ "/usr/bin/loki" ]
CMD ["-config.file=/etc/loki/local-config.yaml"]