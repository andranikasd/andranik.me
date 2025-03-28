############################################################
#                Stage 1: Hugo Static Site Build           #
############################################################
FROM alpine:3.21.3 AS build

# Install Hugo from Alpine edge community repo
RUN apk add --no-cache \
    --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community \
    hugo

WORKDIR /opt/HugoApp
COPY . .

# Build Hugo site
RUN hugo --environment production

############################################################
#            Stage 2: Secure and Patched NGINX Runtime     #
############################################################
FROM nginx:stable-alpine3.20

# Patch CVEs in runtime image
RUN apk update && apk upgrade --no-cache \
    libexpat \
    libxml2 \
    libxslt && \
    rm -rf /var/cache/apk/*

# Set working directory to NGINX's web root
WORKDIR /usr/share/nginx/html
RUN rm -rf /usr/share/nginx/html/*

# Copy built site
COPY --from=build /opt/HugoApp/public .

# Copy secure NGINX configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose HTTP port
EXPOSE 80

# Healthcheck
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget --spider -q http://localhost || exit 1

# Optional: override entrypoint to avoid permission warnings
ENTRYPOINT ["nginx", "-g", "daemon off;"]
