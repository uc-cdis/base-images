ARG AZLINUX_VERSION=2

FROM public.ecr.aws/amazonlinux/amazonlinux:${AZLINUX_VERSION}

# Install dependencies
RUN yum update -y && yum update --security -y && yum install -y \
    python3-pip git vim gcc dracut-fips openssl\
    && yum clean all \
    && rm -rf /var/cache/yum
