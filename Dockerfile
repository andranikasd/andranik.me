############################################################
#                Stage 1: Hugo Static Site Build           #
############################################################
FROM alpine:3.21.3 AS build

# Install Hugo from Alpine edge community repo
RUN apk add --no-cache \
    --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community \
    hugo

# Set working directory for Hugo project
WORKDIR /opt/HugoApp

# Copy project files into container
COPY . .

# Build Hugo site for production
RUN hugo --environment production


############################################################
#         Stage 2: NGINX Runtime        #
############################################################
FROM nginx:stable-alpine3.20

# Upgrade specific vulnerable packages without altering base image
RUN apk update && apk upgrade --no-cache \
    libexpat \
    libxml2 \
    libxslt && \
    rm -rf /var/cache/apk/*

# Create non-root user and group
RUN addgroup -S hugo && adduser -S hugo -G hugo

# Set working directory to NGINX's web root and clear it
WORKDIR /usr/share/nginx/html
RUN rm -rf /usr/share/nginx/html/*

# Copy static content from builder stage
COPY --from=build /opt/HugoApp/public .

# Set ownership to non-root user
RUN chown -R hugo:hugo /usr/share/nginx/html

# Harden file permissions: readable by nginx, immutable (no write access)
RUN chmod -R 755 /usr/share/nginx/html && \
    chmod -R a-w /usr/share/nginx/html

# Switch to non-root user
USER hugo

# Expose HTTP port
EXPOSE 80

# Healthcheck to ensure NGINX is serving
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget --spider -q http://localhost:80 || exit 1

# NOTE: Runtime security enhancements (add to your `docker run`):
#   --read-only \
#   --cap-drop=ALL \
#   --security-opt no-new-privileges:true
