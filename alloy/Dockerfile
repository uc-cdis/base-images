FROM quay.io/cdis/golang-build-base:master

ENV ALLOY_VERSION=1.0.0

RUN dnf install -y wget && \
    wget -q -O gpg.key https://rpm.grafana.com/gpg.key && \
    rpm --import gpg.key

COPY grafana.repo /etc/yum.repos.d/

RUN dnf install -y alloy-${ALLOY_VERSION}

COPY config.alloy /etc/alloy/config.alloy

USER alloy
ENTRYPOINT ["/bin/alloy"]
ENV ALLOY_DEPLOY_MODE=docker
CMD ["run", "/etc/alloy/config.alloy", "--storage.path=/var/lib/alloy/data"]