########################################
# -------- Stage 1: Hugo Build --------
########################################
FROM alpine:3.21.3 AS builder

RUN apk update && apk upgrade && \
    apk add --no-cache \
      --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community \
      hugo

WORKDIR /src
COPY . .
RUN hugo --environment production --destination /public


#############################################
# -------- Stage 2: LinuxServer NGINX -------
#############################################
FROM lscr.io/linuxserver/nginx:1.26.3

# Ensure writable config volume exists and content can be generated
VOLUME /config

# Copy static site and nginx config
COPY --from=builder /public /usr/share/nginx/html/
COPY nginx.conf /config/nginx/site-confs/default

# Adjust permissions for non-root (UID 101 in LinuxServer image)
RUN chown -R 101:101 /usr/share/nginx/html /config && \
    chmod -R 755 /usr/share/nginx/html && \
    chmod -R a-w /usr/share/nginx/html

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget --spider -q http://localhost || exit 1
