# Nginx + php-fpm (v8)

Based on php:8-fpm-alpine3.14, node:17-alpine3.14 (nodejs is not included in most of other nginx-php images...but needed by a lot of php frameworks), with nginx:alpine and richarvey/nginx-php-fpm's Docker script

Tags:
* latest, php8.0.13_node17
* php8_node15
## PHP Modules

In this image it contains following PHP modules:

```
# php -m
[PHP Modules]
bcmath
Core
ctype
curl
date
dom
fileinfo
filter
ftp
gd
hash
iconv
igbinary
imap
intl
json
ldap
libxml
mbstring
memcached
msgpack
mysqli
mysqlnd
openssl
pcre
PDO
pdo_mysql
pdo_sqlite
Phar
posix
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
tokenizer
xml
xmlreader
xmlwriter
Zend OPcache
zip
zlib

[Zend Modules]
Zend OPcache
```

## How to use

For example, use this docker image to deploy a **Laravel 8** project.

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

# start.sh will set desired timezone with $TZ
ENV TZ Asia/Shanghai

# start.sh will replace default web root from /var/www/html to $WEBROOT
ENV WEBROOT /var/www/html/public

# start.sh will use redis as session store with docker container name $PHP_REDIS_SESSION_HOST
ENV PHP_REDIS_SESSION_HOST redis

# start.sh will create laravel storage folder structure if $CREATE_LARAVEL_STORAGE = 1
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

You may check [start.sh](https://github.com/tangramor/nginx-php8-fpm/blob/master/start.sh) for more information about what it can do.


### Develop with this image

Another example to develop with this image for a **Laravel 8** project, you may modify the `docker-compose.yml` of your project.

Make sure you have correct environment parameters set:

```yaml
# For more information: https://laravel.com/docs/sail
version: '3'
services:
    laravel.test:
        image: tangramor/nginx-php8-fpm
        ports:
            - '${APP_PORT:-80}:80'
        environment:
            TZ: 'Asia/Shanghai'
            WEBROOT: '/var/www/html/public'
            PHP_REDIS_SESSION_HOST: 'redis'
            CREATE_LARAVEL_STORAGE: '1'
        volumes:
            - '.:/var/www/html'
        networks:
            - sail
        depends_on:
            - mysql
            # - pgsql
            - redis
            # - selenium

    # selenium:
    #     image: 'selenium/standalone-chrome'
    #     volumes:
    #         - '/dev/shm:/dev/shm'
    #     networks:
    #         - sail

    mysql:
        image: 'mariadb:10'
        #ports:
        #    - '${FORWARD_DB_PORT:-3306}:3306'
        environment:
            MYSQL_ROOT_PASSWORD: '${DB_PASSWORD}'
            MYSQL_DATABASE: '${DB_DATABASE}'
            MYSQL_USER: '${DB_USERNAME}'
            MYSQL_PASSWORD: '${DB_PASSWORD}'
            MYSQL_ALLOW_EMPTY_PASSWORD: 'yes'
        volumes:
            - 'sailmysql:/var/lib/mysql'
        networks:
            - sail
        security_opt:
            - seccomp:unconfined
        healthcheck:
            test: ["CMD", "mysqladmin", "ping"]

#    pgsql:
#        image: postgres:13
#        ports:
#            - '${FORWARD_DB_PORT:-5432}:5432'
#        environment:
#            PGPASSWORD: '${DB_PASSWORD:-secret}'
#            POSTGRES_DB: '${DB_DATABASE}'
#            POSTGRES_USER: '${DB_USERNAME}'
#            POSTGRES_PASSWORD: '${DB_PASSWORD:-secret}'
#        volumes:
#            - 'sailpostgresql:/var/lib/postgresql/data'
#        networks:
#            - sail
#        healthcheck:
#          test: ["CMD", "pg_isready", "-q", "-d", "${DB_DATABASE}", "-U", "${DB_USERNAME}"]

    redis:
        image: 'redis:alpine'
        #ports:
        #    - '${FORWARD_REDIS_PORT:-6379}:6379'
        volumes:
            - 'sailredis:/data'
        networks:
            - sail
        healthcheck:
          test: ["CMD", "redis-cli", "ping"]

    memcached:
        image: 'memcached:alpine'
        ports:
            - '11211:11211'
        networks:
            - sail

    mailhog:
        image: 'mailhog/mailhog:latest'
        ports:
            - '${FORWARD_MAILHOG_PORT:-1025}:1025'
            - '${FORWARD_MAILHOG_DASHBOARD_PORT:-8025}:8025'
        networks:
            - sail

networks:
    sail:
        driver: bridge

volumes:
    sailmysql:
        driver: local
#    sailpostgresql:
#        driver: local
    sailredis:
        driver: local
```
