FROM quay.io/cdis/amazonlinux:latest
#testing a change

RUN pip3 install gunicorn ddtrace

# Add demo app
COPY ./app /app
WORKDIR /app
USER nobody

CMD ["gunicorn"]