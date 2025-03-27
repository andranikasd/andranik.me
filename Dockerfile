# ------------ Stage 1: Hugo build ------------
FROM alpine:3.21.3 AS builder

RUN apk add --no-cache \
    --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community \
    hugo

WORKDIR /src
COPY . .

RUN hugo --environment production --destination /public


# ------------ Final Stage: BusyBox (no scratch) ------------
FROM busybox:uclibc

COPY --from=builder /public /www

ENTRYPOINT ["httpd", "-f", "-p", "80", "-h", "/www"]
EXPOSE 80
