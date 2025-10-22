# Base image version
ARG PHP_FPM_VERSION=8.1-fpm-alpine

FROM php:${PHP_FPM_VERSION}

LABEL maintainer="Hải Phạm <contact@haipham.net>"
LABEL description="Lightweight container with Nginx 1.24 & PHP based on Alpine Linux."

# Set environment variables
ENV PORT=8080

# for public path, ex: /app/public
ENV APP_ROOT="/app"

# Setup document root
RUN mkdir -p /app
WORKDIR /app

# Install PHP extensions and required packages
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions && \
    sync && \
    install-php-extensions ctype curl dom gd intl mbstring mysqli opcache openssl phar session xml memcached xmlreader && \
    apk add --no-cache curl nginx supervisor && \
    rm -rf /var/cache/apk/*

# Configure nginx
COPY config/nginx.conf /etc/nginx/nginx.conf
COPY config/conf.d /etc/nginx/conf.d/

# Configure PHP-FPM
COPY config/php-fpm.d/zz-docker.conf /usr/local/etc/php-fpm.d/zz-docker.conf
COPY config/php-fpm.d/fpm-pool.conf /usr/local/etc/php-fpm.d/www.conf
COPY config/php.ini /usr/local/etc/php/conf.d/custom.ini

# Configure supervisord
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Fix permissions
RUN chown -R www-data:www-data /app /run /var/lib/nginx /var/log/nginx

# Add application source
COPY --chown=www-data src/ /app/

# Expose the port
EXPOSE $PORT

# Start services
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Healthcheck - use PORT (not PHP_FPM_VERSION)
HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:${PORT}/fpm-ping || exit 1
