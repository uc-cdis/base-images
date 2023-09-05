# Stage 1: Build the Go binary
FROM golang:1.20-alpine AS builder

WORKDIR /home/

RUN apk add git\
    && git clone https://github.com/abutaha/aws-es-proxy.git\
    && cd aws-es-proxy\
    && CGO_ENABLED=0 GOOS=linux go build -o aws-es-proxy


FROM quay.io/cdis/golang_base:latest

LABEL name="aws-es-proxy"

WORKDIR /home/
COPY --from=builder /home/aws-es-proxy/aws-es-proxy /usr/local/bin/

ENV PORT_NUM 9200
EXPOSE ${PORT_NUM}

ENTRYPOINT ["aws-es-proxy"] 
CMD ["-h"]
