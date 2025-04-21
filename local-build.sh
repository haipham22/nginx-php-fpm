#!/usr/bin/env sh

PHP_VERSION=$1
if [ -z "$PHP_VERSION" ]; then
  echo "Usage: $0 <php-version>"
  exit 1
fi

docker buildx build \
    --build-arg  PHP_FPM_VERSION=${PHP_VERSION}-fpm-alpine \
    --platform linux/amd64,linux/arm64 .  \
    -t haipham22/nginx-php-fpm:${PHP_VERSION}-fpm-alpine \
    --push