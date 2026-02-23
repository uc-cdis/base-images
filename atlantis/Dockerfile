FROM ghcr.io/runatlantis/atlantis:v0.40.0

USER root

ARG TERRAGRUNT_VERSION=v0.63.6
ARG INFRACOST_VERSION=v0.10.40

# terragrunt
RUN curl -fsSL -o /usr/local/bin/terragrunt \
    "https://github.com/gruntwork-io/terragrunt/releases/download/${TERRAGRUNT_VERSION}/terragrunt_linux_amd64" \
  && chmod +x /usr/local/bin/terragrunt

# infracost
RUN curl -fsSL -o /usr/local/bin/infracost \
    "https://raw.githubusercontent.com/infracost/infracost/master/scripts/install.sh" | VERSION=${INFRACOST_VERSION} sh\
  && chmod +x /usr/local/bin/infracost

USER atlantis