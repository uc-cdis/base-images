FROM quay.io/cdis/amazonlinux-base:master

ENV GRAFANA_VERSION=11.1.0

RUN dnf install -y wget && \
    wget -q -O gpg.key https://rpm.grafana.com/gpg.key && \
    rpm --import gpg.key

COPY grafana.repo /etc/yum.repos.d/

RUN dnf install -y grafana-${GRAFANA_VERSION} && \
    chown -R grafana:grafana /usr/share/grafana

USER grafana
WORKDIR /usr/share/grafana
CMD grafana-server