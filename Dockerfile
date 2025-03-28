############################################################
#                Stage 1: Hugo Static Site Build           #
############################################################
FROM alpine:3.21.3 AS builder

# Install Hugo from Alpine edge community repo
RUN apk update && apk add hugo

WORKDIR /src

COPY . .

# Build Hugo site
RUN hugo --destination /src/public

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

COPY --from=builder /src /root

RUN rm -f /usr/share/nginx/html/*

# Copy Hugo build output from builder stage
COPY --from=builder /src/public/* /usr/share/nginx/html/
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]