###############################################
# ------------ Stage 1: Hugo Build ------------
###############################################
FROM alpine:3.21.3 AS builder

RUN apk update && apk upgrade && \
    apk add --no-cache \
    --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community \
    hugo

WORKDIR /src
COPY . .

RUN hugo --environment production --destination /public

#############################################
# -------- Stage 2: Hardened NGINX ----------
#############################################
FROM nginx:1.25-alpine

# Clean up default files and prevent entrypoint scripts from running
RUN rm -rf /usr/share/nginx/html/* \
    && rm -rf /docker-entrypoint.d/* \
    && mkdir -p /var/cache/nginx /var/run/nginx

# Copy built static site and config
COPY --from=builder /public /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf

# Set correct ownership/permissions for NGINX non-root user
RUN chown -R nginx:nginx /usr/share/nginx/html /var/cache/nginx /var/run/nginx && \
    chmod -R 755 /usr/share/nginx/html && \
    chmod -R a-w /usr/share/nginx/html

USER nginx

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget --spider -q http://localhost || exit 1

CMD ["nginx", "-g", "daemon off;"]