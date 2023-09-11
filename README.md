# Docker PHP-FPM & Nginx 1.24 on Alpine Linux

## Usage

Start the Docker container:

```shell
docker run -p 80:8080 haipham22/nginx-php-fpm
```

See the PHP info on http://localhost, or the static html page on http://localhost/test.html

Or mount your own code to be served by PHP-FPM & Nginx

```shell
docker run -p 80:8080 -v ~/sourcecode:/app haipham22/nginx-php-fpm
```

## Use in local development

PHP configuration `custom.ini`

```ini
[Date]
date.timezone="UTC"
expose_php= Off

[Opcache]
opcache.enable=0
opcache.memory_consumption=64
opcache.interned_strings_buffer=64
opcache.max_accelerated_files=32531
opcache.validate_timestamps=0
opcache.save_comments=1
opcache.fast_shutdown=0
```

Run with docker

```shell
docker run -v "`pwd`/custom.ini:/usr/local/etc/php/conf.d/custom.ini" haipham22/nginx-php-fpm
```

Run with docker compose

```yaml
version: "3"

services:
  app:
    build: .
    image: haipham22/nginx-php-fpm
    volumes:
      - ./custom.ini:/usr/local/etc/php/conf.d/custom.ini
      - ./:/app
    ports:
      - "8080:8080"
```

## Adding composer

If you need [Composer](https://getcomposer.org/) in your project, here's an easy way to add it.

```Dockerfile
FROM haipham22/nginx-php-fpm:latest

# Install composer via install-php-extensions
RUN install-php-extensions composer

# Run composer install to install the dependencies
RUN composer install --optimize-autoloader --no-interaction --no-progress
```

## Add php config to Dockerfile

```Dockerfile
FROM haipham22/nginx-php-fpm:8.2-fpm-alpine

USER root

RUN echo "[Date]" >> "$PHP_INI_DIR/php.ini"
RUN echo "memory_limit = 128M;" >> "$PHP_INI_DIR/php.ini"

# Switch to use a non-root user from here on
USER www-data

# Add application
COPY --chown=www-data . /app/
```

## Configuration

In [config/](config/) you'll find the default configuration files for Nginx, PHP and PHP-FPM.
If you want to extend or customize that you can do so by mounting a configuration file in the correct folder;

Nginx configuration:

```shell
docker run -v "`pwd`/nginx-server.conf:/etc/nginx/conf.d/server.conf" haipham22/nginx-php-fpm
```

PHP configuration:

```shell
docker run -v "`pwd`/php-setting.ini:/usr/local/etc/php/conf.d/settings.ini" haipham22/nginx-php-fpm
```

PHP-FPM configuration:

```shell
docker run -v "`pwd`/php-fpm-settings.conf:/usr/local/etc/php-fpm.d/server.conf" haipham22/nginx-php-fpm
```

## TODO

- [x] Add nginx inside docker
- [x] Change `fastcgi_pass` to `unix` socket instead `TCP` socket
- [ ] Optimize docker image size
- [ ] Add defaults 5xx page html
- [ ] Testing for running

## Acknowledgements

This project started as a fork of https://github.com/TrafeX/docker-php-nginx. Thanks TrafeX!

Different with original repo:

- Use php:xxx-fpm-alpine as base docker images
- Use [mlocati/docker-php-extension-installer](https://github.com/mlocati/docker-php-extension-installer) to easy switch php versions ex 7.3, 7.4, 8.0,...
