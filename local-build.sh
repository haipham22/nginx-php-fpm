#!/usr/bin/env sh
docker buildx build --build-arg PHP_FPM_VERSION=${PHP_VERSION}-fpm-alpine --platform linux/amd64,linux/arm64 . -t haipham22/nginx-php-fpm:${PHP_VERSION}-fpm-alpine --push