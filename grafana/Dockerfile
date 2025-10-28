FROM quay.io/cdis/amazonlinux-base:latest

ENV GRAFANA_VERSION=12.2.1

RUN dnf install -y wget && \
    wget -q -O gpg.key https://rpm.grafana.com/gpg.key && \
    rpm --import gpg.key

COPY grafana.repo /etc/yum.repos.d/

RUN  yum install shadow-utils -y

RUN groupadd -g 472 grafana && \
    useradd -u 472 grafana -g grafana

RUN dnf install -y grafana-${GRAFANA_VERSION} && \
    chown -R grafana:grafana /usr/share/grafana /etc/grafana

USER grafana
WORKDIR /usr/share/grafana
CMD grafana-server
