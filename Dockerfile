# ------------ Stage 1: Build Hugo site ------------
    FROM klakegg/hugo:0.122.0-ext-alpine AS builder

    # Set working directory
    WORKDIR /src
    
    # Copy everything except what's in .dockerignore
    COPY . .
    
    # Build the site
    RUN hugo --minify
    
    # ------------ Stage 2: Serve with Nginx ------------
    FROM nginx:alpine
    
    # Clean default Nginx config
    RUN rm -rf /usr/share/nginx/html/*
    
    # Copy Hugo build output from builder stage
    COPY --from=builder /src/public /usr/share/nginx/html
    
    # Expose port
    EXPOSE 80
    
    # Start nginx
    CMD ["nginx", "-g", "daemon off;"]
    