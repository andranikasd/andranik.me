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
# -------- Stage 2: Minimal NGINX ----------
#############################################
FROM linuxserver/nginx:1.26.3

# Remove default site and entrypoint scripts
RUN rm -rf /usr/share/nginx/html/* /docker-entrypoint.d/* && \
    mkdir -p /var/cache/nginx /var/run/nginx

# Copy built site and custom config
COPY --from=builder /public /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf

# Set secure permissions for read-only content and writable runtime dirs
RUN chown -R nginx:nginx /usr/share/nginx/html /var/cache/nginx /var/run/nginx && \
    chmod -R 755 /usr/share/nginx/html && \
    chmod -R a-w /usr/share/nginx/html

# Drop to non-root user
USER nginx

# Expose port 80 and define container health check using wget
EXPOSE 80

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget --spider -q http://localhost || exit 1

CMD ["nginx", "-g", "daemon off;"]
