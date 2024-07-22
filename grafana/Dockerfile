FROM quay.io/cdis/amazonlinux-base:master

ENV GRAFANA_VERSION=11.1.0  \
    GF_PATHS_CONFIG="/etc/grafana/grafana.ini" \
    GF_PATHS_DATA="/var/lib/grafana" \
    GF_PATHS_HOME="/usr/share/grafana" \
    GF_PATHS_LOGS="/var/log/grafana" \
    GF_PATHS_PLUGINS="/var/lib/grafana/plugins" \
    GF_PATHS_PROVISIONING="/etc/grafana/provisioning"

RUN dnf install -y wget && \
    wget -q -O gpg.key https://rpm.grafana.com/gpg.key && \
    rpm --import gpg.key

COPY grafana.repo /etc/yum.repos.d/

RUN  yum install shadow-utils -y

RUN groupadd -g 472 grafana && \
    useradd -u 472 grafana -g grafana && \
    usermod -aG 0 grafana

RUN dnf install -y grafana-${GRAFANA_VERSION} && \
    chown -R grafana:grafana /usr/share/grafana /etc/grafana

USER grafana
WORKDIR /usr/share/grafana
CMD "/usr/sbin/grafana-server --config=/etc/grafana/grafana.ini --homepath=/usr/share/grafana"