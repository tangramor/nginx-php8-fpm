# Nginx + php-fpm (v8) + nodejs

Based on php:8.3.6-fpm-alpine3.19, node:22.1.0-alpine3.19 (nodejs is not included in most of other nginx-php images...but needed by a lot of php frameworks), with nginx:alpine and richarvey/nginx-php-fpm's Docker script

* Since `php8.3.6_node22.1.0`, PHP `imagick` module is added.
* Since `php8.2.8_node20.5.0`, PHP `mongodb` module is added and `GD` module's JPEG and FreeType support are enabled.
* Since `php8.1.8_node18.4.0`, PHP `amqp` module is added.
* Since `php8.1.10_node18.8.0`, PHP `swoole` module is added.
* Since `php8.1.12`, added `_withoutNodejs` build for some pure PHP API frameworks like [Lumen](https://lumen.laravel.com)

**Tags:**
* latest, php8.3.6_node22.1.0, php8.3.6_withoutNodejs (2024-05-06 alpine3.19)
* php8.3.4_node21.7.2, php8.3.4_withoutNodejs (2024-04-07 alpine3.19)
* php8.3.3_node21.6.2, php8.3.3_withoutNodejs (2024-03-04 alpine3.19)
* php8.3.2_node21.6.1, php8.3.2_withoutNodejs (2024-02-10 alpine3.19)
* php8.3.1_node21.5.0, php8.3.1_withoutNodejs (2024-01-03 alpine3.18)
* php8.3.0_node21.3.0, php8.3.0_withoutNodejs (2023-12-04 alpine3.18) **Note: PHP version is 8.3 now!**
* php8.2.12_node21.1.0, php8.2.12_withoutNodejs (2023-11-03 alpine3.18)
* php8.2.11_node20.8.0, php8.2.11_withoutNodejs (2023-10-09 alpine3.18)
* php8.2.10_node20.6.0, php8.2.10_withoutNodejs (2023-09-08 alpine3.18)
* php8.2.8_node20.5.0, php8.2.8_withoutNodejs (2023-08-03 alpine3.17)
* php8.2.7_node20.3.1, php8.2.7_withoutNodejs (2023-07-03 alpine3.17)
* php8.2.6_node20.2.0, php8.2.6_withoutNodejs (2023-06-07 alpine3.17)
* php8.2.5_node20.1.0, php8.2.5_withoutNodejs (2023-05-08 alpine3.17)
* php8.2.4_node19.8.1, php8.2.4_withoutNodejs (2023-04-10 alpine3.17)
* php8.2.3_node19.7.0, php8.2.3_withoutNodejs (2023-03-06 alpine3.17)
* php8.2.2_node19.6.0, php8.2.2_withoutNodejs (2023-02-06 alpine3.17)
* php8.2.0_node19.3.0, php8.2.0_withoutNodejs (2023-01-05 alpine3.17) **Note: PHP version is 8.2 now!**
* php8.1.13_node19.2.0, php8.1.13_withoutNodejs (2022-12-06 alpine3.16)
* php8.1.12_node19.0.0, php8.1.12_withoutNodejs (2022-11-07 alpine3.16)
* php8.1.11_node18.10.0 (2022-10-13 alpine3.16)
* php8.1.10_node18.8.0 (2022-09-06 alpine3.16)
* php8.1.9_node18.7.0 (2022-08-11 alpine3.16)
* php8.1.8_node18.4.0 (2022-07-08 alpine3.16)
* php8.1.6_node18.2.0 (2022-06-06 alpine3.15)
* php8.1.5_node18.1.0 (2022-05-07)
* php8.1.4_node17.8 (2022-04-10)
* php8.1.3_node17 (2022-03-07)
* php8.0.13_node17 (2022-03-07)
* php8_node15 (2022-03-07)

**NOTE** If you are upgrading from PHP **8.0 to 8.1**, **8.1 to 8.2** or **8.2 to 8.3**, you may need to run `composer update` to upgrade php packages, because some packages under 8.0/8.1/8.2 are not supported in 8.1/8.2/8.3

```
# php -v
PHP 8.3.6 (cli) (built: Apr 11 2024 18:27:49) (NTS)
Copyright (c) The PHP Group
Zend Engine v4.3.6, Copyright (c) Zend Technologies
    with Zend OPcache v8.3.6, Copyright (c), by Zend Technologies

# node -v
v22.1.0

# nginx -v
nginx version: nginx/1.25.5
```

## PHP Modules

In this image it contains following PHP modules:

```
# php -m
[PHP Modules]
amqp
bcmath
Core
ctype
curl
date
dom
exif
fileinfo
filter
gd
gettext
hash
iconv
igbinary
imagick
imap
intl
json
ldap
libxml
mbstring
memcached
mongodb
msgpack
mysqli
mysqlnd
openssl
pcre
PDO
pdo_mysql
pdo_pgsql
pdo_sqlite
pgsql
Phar
posix
random
readline
redis
Reflection
session
SimpleXML
soap
sockets
sodium
SPL
sqlite3
standard
swoole
tokenizer
xml
xmlreader
xmlwriter
Zend OPcache
zip
zlib

[Zend Modules]
Zend OPcache

# php -r "echo sprintf(\"GD SUPPORT %s\n\", json_encode(gd_info()));"
GD SUPPORT {"GD Version":"bundled (2.1.0 compatible)","FreeType Support":true,"FreeType Linkage":"with freetype","GIF Read Support":true,"GIF Create Support":true,"JPEG Support":true,"PNG Support":true,"WBMP Support":true,"XPM Support":false,"XBM Support":true,"WebP Support":true,"BMP Support":true,"AVIF Support":false,"TGA Read Support":true,"JIS-mapped Japanese Font Support":false}
```

## How to use

For example, use this docker image to deploy a **Laravel 10** project.

Dockerfile:

```dockerfile
FROM tangramor/nginx-php8-fpm

# copy source code
COPY . /var/www/html

# If there is a conf folder under /var/www/html, the start.sh will
# copy conf/nginx.conf to /etc/nginx/nginx.conf
# copy conf/nginx-site.conf to /etc/nginx/conf.d/default.conf
# copy conf/nginx-site-ssl.conf to /etc/nginx/conf.d/default-ssl.conf

# copy ssl cert files
COPY conf/ssl /etc/nginx/ssl

# China alpine mirror: mirrors.ustc.edu.cn
ARG APKMIRROR=""

# start.sh will set desired timezone with $TZ
ENV TZ Asia/Shanghai

# China php composer mirror: https://mirrors.cloud.tencent.com/composer/
ENV COMPOSERMIRROR=""
# China npm mirror: https://registry.npmmirror.com
ENV NPMMIRROR=""

# start.sh will replace default web root from /var/www/html to $WEBROOT
ENV WEBROOT /var/www/html/public

# start.sh will use redis as session store with docker container name $PHP_REDIS_SESSION_HOST
ENV PHP_REDIS_SESSION_HOST redis

# start.sh will create laravel storage folder structure if $CREATE_LARAVEL_STORAGE = 1
ENV CREATE_LARAVEL_STORAGE "1"

# download required node/php packages, 
# some node modules need gcc/g++ to build
RUN if [[ "$APKMIRROR" != "" ]]; then sed -i "s/dl-cdn.alpinelinux.org/${APKMIRROR}/g" /etc/apk/repositories ; fi\
    && apk add --no-cache --virtual .build-deps gcc g++ libc-dev make \
    # set preferred npm mirror
    && cd /usr/local \
    && if [[ "$NPMMIRROR" != "" ]]; then npm config set registry ${NPMMIRROR}; fi \
    && npm config set registry $NPMMIRROR \
    && cd /var/www/html \
    # install node modules
    && npm install \
    # install php composer packages
    && if [[ "$COMPOSERMIRROR" != "" ]]; then composer config -g repos.packagist composer ${COMPOSERMIRROR}; fi \
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

You may check [start.sh](https://github.com/tangramor/nginx-php8-fpm/blob/master/start.sh) for more information about what it can do.


### Develop with this image

Another example to develop with this image for a **Laravel 10** project, you may modify the `docker-compose.yml` of your project.

Here we only modified fields `image` and `environment` under `services -> laravel.test`.

Make sure you have correct environment parameters set:

```yaml
# For more information: https://laravel.com/docs/sail
version: '3'
services:
    laravel.test:
        image: tangramor/nginx-php8-fpm
        extra_hosts:
            - 'host.docker.internal:host-gateway'
        ports:
            - '${APP_PORT:-80}:80'
            - '${VITE_PORT:-5173}:${VITE_PORT:-5173}'
        environment:
            TZ: 'Asia/Shanghai'
            WEBROOT: '/var/www/html/public'
            PHP_REDIS_SESSION_HOST: 'redis'
            CREATE_LARAVEL_STORAGE: '1'
            COMPOSERMIRROR: 'https://mirrors.cloud.tencent.com/composer/'
            NPMMIRROR: 'https://registry.npm.taobao.org'
        volumes:
            - '.:/var/www/html'
        networks:
            - sail
        depends_on:
            - mysql
            - redis
            - meilisearch
            - mailpit
            - selenium
    mysql:
        image: 'mysql/mysql-server:8.0'
        ports:
            - '${FORWARD_DB_PORT:-3306}:3306'
        environment:
            MYSQL_ROOT_PASSWORD: '${DB_PASSWORD}'
            MYSQL_ROOT_HOST: '%'
            MYSQL_DATABASE: '${DB_DATABASE}'
            MYSQL_USER: '${DB_USERNAME}'
            MYSQL_PASSWORD: '${DB_PASSWORD}'
            MYSQL_ALLOW_EMPTY_PASSWORD: 1
        volumes:
            - 'sail-mysql:/var/lib/mysql'
            - './vendor/laravel/sail/database/mysql/create-testing-database.sh:/docker-entrypoint-initdb.d/10-create-testing-database.sh'
        networks:
            - sail
        healthcheck:
            test:
                - CMD
                - mysqladmin
                - ping
                - '-p${DB_PASSWORD}'
            retries: 3
            timeout: 5s
    redis:
        image: 'redis:alpine'
        ports:
            - '${FORWARD_REDIS_PORT:-6379}:6379'
        volumes:
            - 'sail-redis:/data'
        networks:
            - sail
        healthcheck:
            test:
                - CMD
                - redis-cli
                - ping
            retries: 3
            timeout: 5s
    meilisearch:
        image: 'getmeili/meilisearch:latest'
        ports:
            - '${FORWARD_MEILISEARCH_PORT:-7700}:7700'
        environment:
            MEILI_NO_ANALYTICS: '${MEILISEARCH_NO_ANALYTICS:-false}'
        volumes:
            - 'sail-meilisearch:/meili_data'
        networks:
            - sail
        healthcheck:
            test:
                - CMD
                - wget
                - '--no-verbose'
                - '--spider'
                - 'http://localhost:7700/health'
            retries: 3
            timeout: 5s
    mailpit:
        image: 'axllent/mailpit:latest'
        ports:
            - '${FORWARD_MAILPIT_PORT:-1025}:1025'
            - '${FORWARD_MAILPIT_DASHBOARD_PORT:-8025}:8025'
        networks:
            - sail
    selenium:
        image: selenium/standalone-chrome
        extra_hosts:
            - 'host.docker.internal:host-gateway'
        volumes:
            - '/dev/shm:/dev/shm'
        networks:
            - sail
networks:
    sail:
        driver: bridge
volumes:
    sail-mysql:
        driver: local
    sail-redis:
        driver: local
    sail-meilisearch:
        driver: local
```

### Add extra PHP modules

You may use this image as the base image to build your own. For example, to add `mongodb` module in images before **php8.2.8_node20.5.0**:

- Create a `Dockerfile`

```dockerfile
FROM tangramor/nginx-php8-fpm:php8.2.7_node20.3.1

RUN apk add --no-cache --update --virtual .phpize-deps $PHPIZE_DEPS \
    && apk add --no-cache --update --virtual .all-deps $PHP_MODULE_DEPS \
    && pecl install mongodb \
    && docker-php-ext-enable mongodb \
    && rm -rf /tmp/pear \
    && apk del .all-deps .phpize-deps \
    && rm -rf /var/cache/apk/* /tmp/* /var/tmp/*
```

- Build image

```bash
docker build -t my-nginx-php8-fpm .
```
