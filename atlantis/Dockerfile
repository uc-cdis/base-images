FROM ghcr.io/runatlantis/atlantis:v0.40.0

USER root

ARG TERRAGRUNT_VERSION=v0.63.6
ARG INFRACOST_VERSION=v0.10.40
ARG TF_VERSION=1.5.7

# terragrunt
RUN curl -fsSL -o /usr/local/bin/terragrunt \
    "https://github.com/gruntwork-io/terragrunt/releases/download/${TERRAGRUNT_VERSION}/terragrunt_linux_amd64" \
  && chmod +x /usr/local/bin/terragrunt

# infracost
RUN curl -fsSL -o /usr/local/bin/infracost \
    "https://raw.githubusercontent.com/infracost/infracost/master/scripts/install.sh" | VERSION=${INFRACOST_VERSION} sh\
  && chmod +x /usr/local/bin/infracost


RUN curl -fsSL -o /tmp/terraform.zip \
    "https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip" \
  && unzip -o /tmp/terraform.zip -d /usr/local/bin \
  && rm -f /tmp/terraform.zip \
  && terraform -version

RUN ln -s /usr/local/bin/terraform /usr/local/bin/terraform1.5.7

USER atlantis