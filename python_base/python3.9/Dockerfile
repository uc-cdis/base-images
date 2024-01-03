ARG AZLINUX_BASE_VERSION=master
FROM 707767160287.dkr.ecr.us-east-1.amazonaws.com/gen3/amazonlinux-base:${AZLINUX_BASE_VERSION}

RUN pip3 install gunicorn ddtrace

# Add demo app
COPY ./app /app
WORKDIR /app
USER nobody

CMD ["gunicorn"]
