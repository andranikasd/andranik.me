############################################################
#                Stage 1: Hugo Static Site Build           #
############################################################
FROM alpine:3.21.3 AS build

# Install Hugo from Alpine edge community repo
# - Hugo is only needed during build, so we use a separate stage
RUN apk add --no-cache \
    --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community \
    hugo

# Set working directory for Hugo project
WORKDIR /opt/HugoApp

# Copy project files into container
COPY . .

# Build Hugo site for production into /public directory
RUN hugo --environment production


############################################################
#         Stage 2: NGINX Web Server (Patched)              #
#    Serve the static Hugo site and patch known CVEs       #
############################################################
FROM nginx:stable-alpine3.20

# Upgrade vulnerable libraries in-place to address CVEs
# - We do NOT switch the base image
# - Only upgrade packages with known issues (minimal risk)
RUN apk update && apk upgrade --no-cache \
    # CVE-2024-8176
    libexpat \
    # CVE-2024-56171, CVE-2025-24928, CVE-2025-27113
    libxml2 \
    # CVE-2024-55549, CVE-2025-24855
    libxslt

# Set working directory to NGINX's default web root
WORKDIR /usr/share/nginx/html

# Copy built static site from previous stage
COPY --from=build /opt/HugoApp/public .

# Expose HTTP port
EXPOSE 80

HEALTHCHECK CMD curl -f http://localhost:80 || exit 1
