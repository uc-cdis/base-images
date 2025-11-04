FROM quay.io/cdis/golang-build-base:master

ENV LOKI_VERSION=3.0.1

RUN dnf install -y wget && \
    wget -q -O gpg.key https://rpm.grafana.com/gpg.key && \
    rpm --import gpg.key

COPY grafana.repo /etc/yum.repos.d/

RUN  yum install shadow-utils -y

RUN groupadd -g 10001 loki && \
    useradd -u 10001 loki -g loki

RUN dnf install -y loki-${LOKI_VERSION}

COPY loki-config.yaml /etc/loki/local-config.yaml

RUN mkdir -p /loki/rules && \
    mkdir -p /loki/rules-temp && \
    chown -R loki:loki /etc/loki /loki

USER loki
EXPOSE 3100
ENTRYPOINT [ "/usr/bin/loki" ]
CMD ["-config.file=/etc/loki/local-config.yaml"]
