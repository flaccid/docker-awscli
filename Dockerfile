FROM alpine:3.11

MAINTAINER Chris Fordham <chris@fordham.id.au>

RUN addgroup -g 450 -S aws && \
    adduser -s /bin/sh -SD -G aws aws && \
    apk add \
      --update \
      --no-cache \
      --repository http://dl-cdn.alpinelinux.org/alpine/edge/community \
      aws-cli

USER aws

ENTRYPOINT ["/usr/bin/aws"]
