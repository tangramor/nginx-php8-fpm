# Nginx + php-fpm (v8)

Based on php:8-fpm-alpine, node:15-alpine3.13, nginx:alpine and richarvey/nginx-php-fpm's script

## How to use

For example, use this docker image to deploy a **Laravel 8** project.

Dockerfile:

```
FROM tangramor/nginx-php8-fpm

# copy source code
COPY . /var/www/html

# replace default web root
ENV WEBROOT "/var/www/html/public"

# download required node/php packages, 
# some node modules need gcc/g++ to build
RUN apk add --no-cache --virtual .build-deps gcc g++ libc-dev make \
    && npm install \
    && composer install \
    && apk del .build-deps \
    && npm run dev \
    && mkdir -p /var/www/html/storage/{logs,app/public,framework/{cache/data,sessions,testing,views}} \
    && chown -Rf nginx.nginx /var/www/html
```
