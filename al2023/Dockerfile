FROM public.ecr.aws/amazonlinux/amazonlinux:latest

# Install dependencies
RUN yum update -y && yum update --security -y \
    && yum clean all \
    && rm -rf /var/cache/yum
