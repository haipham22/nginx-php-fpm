ARG PHP_FPM_VERSION=8.1-fpm-alpine

FROM php:${PHP_FPM_VERSION}
LABEL Maintainer="Hải Phạm <contact@haipham.net>"
LABEL Description="Lightweight container with Nginx 1.24 & PHP based on Alpine Linux."

# Setup document root
RUN mkdir -p /app

WORKDIR /app

# https://github.com/mlocati/docker-php-extension-installer
# Install packages and remove default server definition
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/

RUN chmod +x /usr/local/bin/install-php-extensions && \
    sync && \
    install-php-extensions ctype curl dom gd intl mbstring mysqli opcache openssl phar session xml memcached xmlreader && \
    apk add --no-cache curl nginx supervisor && \
    rm -rf /var/cache/apk/*

# Configure nginx - http
COPY config/nginx.conf /etc/nginx/nginx.conf
# Configure nginx - default server
COPY config/conf.d /etc/nginx/conf.d/

# Configure PHP-FPM
COPY config/php-fpm.d/zz-docker.conf /usr/local/etc/php-fpm.d/zz-docker.conf
COPY config/php-fpm.d/fpm-pool.conf /usr/local/etc/php-fpm.d/www.conf
COPY config/php.ini /usr/local/etc/php/conf.d/custom.ini

# Configure supervisord
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Make sure files/folders needed by the processes are accessable when they run under the www-data user
RUN chown -R www-data.www-data /app /run /var/lib/nginx /var/log/nginx

# Switch to use a non-root user from here on
# USER www-data

# Add application
COPY --chown=www-data src/ /app/

# Expose the port nginx is reachable on
EXPOSE 8080

# Let supervisord start nginx & php-fpm
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Configure a healthcheck to validate that everything is up&running
HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8080/fpm-ping
