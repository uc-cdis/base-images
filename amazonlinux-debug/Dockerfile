ARG AZLINUX_BASE_VERSION=master

FROM 707767160287.dkr.ecr.us-east-1.amazonaws.com/gen3/amazonlinux-base:${AZLINUX_BASE_VERSION}
#FROM quay.io/cdis/amazonlinux-base:${AZLINUX_BASE_VERSION}

COPY add-kubectl-rpm.sh ./home

RUN chmod +x ./home/add-kubectl-rpm.sh && ./home/add-kubectl-rpm.sh

RUN yum -y install jq kubectl bind-utils

USER 10001