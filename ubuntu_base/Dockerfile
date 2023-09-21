FROM ubuntu:22.04

# Install updates
RUN apt-get update && apt-get upgrade -y \
    && apt-get install -y \
      curl \
      unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && rm -rf /var/tmp/*

# Install dependencies
# aws cli v2 - needed for storing files in s3 during usersync k8s job
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && /bin/rm -rf awscliv2.zip ./aws
