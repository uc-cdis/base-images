FROM quay.io/cdis/amazonlinux-base:master

RUN dnf install -y wget && \
    wget -q -O gpg.key https://rpm.grafana.com/gpg.key && \
    rpm --import gpg.key

COPY grafana.repo /etc/yum.repos.d/

RUN dnf install -y grafana && \
    chown -R grafana:grafana /usr/share/grafana

USER grafana
WORKDIR /usr/share/grafana
CMD grafana-server