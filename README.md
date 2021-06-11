# Nginx + php-fpm (v8)

Based on php:8-fpm-alpine, node:15-alpine3.13, nginx:alpine and richarvey/nginx-php-fpm's script

## How to use

For example, use this docker image to deploy a **Laravel 8** project.

Dockerfile:

```
FROM tangramor/nginx-php8-fpm

# copy source code
COPY . /var/www/html

# copy ssl cert files
COPY conf/ssl /etc/nginx/ssl

# replace default web root
ENV WEBROOT "/var/www/html/public"

# use redis as session store with docker container name "redis"
ENV PHP_REDIS_SESSION_HOST "redis"

# create laravel storage folder structure
ENV CREATE_LARAVEL_STORAGE "1"

# download required node/php packages, 
# some node modules need gcc/g++ to build
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk add --no-cache --virtual .build-deps gcc g++ libc-dev make \
    # set preferred npm mirror
    && cd /usr/local \
    && npm config set registry https://registry.npm.taobao.org \
    && cd /var/www/html \
    # install node modules
    && npm install \
    # install php composer packages
    && composer install \
    # clean
    && apk del .build-deps \
    # build js/css
    && npm run dev \
    # set .env
    && cp .env.test .env \
    # change /var/www/html user/group
    && chown -Rf nginx.nginx /var/www/html
```
