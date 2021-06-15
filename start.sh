#!/bin/bash

# Disable Strict Host checking for non interactive git clones

# Set custom webroot
if [ ! -z "$WEBROOT" ]; then
 sed -i "s#root /var/www/html;#root ${WEBROOT};#g" /etc/nginx/conf.d/default.conf
else
 webroot=/var/www/html
fi

# Enable custom nginx config files if they exist
if [ -f /var/www/html/conf/nginx.conf ]; then
  cp /var/www/html/conf/nginx.conf /etc/nginx/nginx.conf
fi

if [ -f /var/www/html/conf/nginx-site.conf ]; then
  cp /var/www/html/conf/nginx-site.conf /etc/nginx/conf.d/default.conf
fi

if [ -f /var/www/html/conf/nginx-site-ssl.conf ]; then
  cp /var/www/html/conf/nginx-site-ssl.conf /etc/nginx/conf.d/default-ssl.conf
fi

# Prevent config files from being filled to infinity by force of stop and restart the container
lastlinephpconf="$(grep "." /usr/local/etc/php-fpm.conf | tail -1)"
if [[ $lastlinephpconf == *"php_flag[display_errors]"* ]]; then
 sed -i '$ d' /usr/local/etc/php-fpm.conf
fi

# Display PHP error's or not
if [[ "$ERRORS" != "1" ]] ; then
 echo php_flag[display_errors] = off >> /usr/local/etc/php-fpm.d/www.conf
else
 echo php_flag[display_errors] = on >> /usr/local/etc/php-fpm.d/www.conf
fi

# Display Version Details or not
if [[ "$HIDE_NGINX_HEADERS" == "0" ]] ; then
 sed -i "s/server_tokens off;/server_tokens on;/g" /etc/nginx/nginx.conf
else
 sed -i "s/expose_php = On/expose_php = Off/g" /usr/local/etc/php-fpm.conf
fi

# Pass real-ip to logs when behind ELB, etc
if [[ "$REAL_IP_HEADER" == "1" ]] ; then
 sed -i "s/#real_ip_header X-Forwarded-For;/real_ip_header X-Forwarded-For;/" /etc/nginx/conf.d/default.conf
 sed -i "s/#set_real_ip_from/set_real_ip_from/" /etc/nginx/conf.d/default.conf
 if [ ! -z "$REAL_IP_FROM" ]; then
  sed -i "s#172.16.0.0/12#$REAL_IP_FROM#" /etc/nginx/conf.d/default.conf
 fi
fi

# Do the same for SSL sites
if [ -f /etc/nginx/conf.d/default-ssl.conf ]; then
 if [[ "$REAL_IP_HEADER" == "1" ]] ; then
  sed -i "s/#real_ip_header X-Forwarded-For;/real_ip_header X-Forwarded-For;/" /etc/nginx/conf.d/default-ssl.conf
  sed -i "s/#set_real_ip_from/set_real_ip_from/" /etc/nginx/conf.d/default-ssl.conf
  if [ ! -z "$REAL_IP_FROM" ]; then
   sed -i "s#172.16.0.0/12#$REAL_IP_FROM#" /etc/nginx/conf.d/default-ssl.conf
  fi
 fi
fi

# Set the desired timezone
if [ ! -z "" ]; then
  echo "date.timezone="$TZ > /usr/local/etc/php/conf.d/timezone.ini
  rm -f /etc/localtime && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
fi

# Display errors in docker logs
if [ ! -z "$PHP_ERRORS_STDERR" ]; then
  echo "log_errors = On" >> /usr/local/etc/php/conf.d/docker-vars.ini
  echo "error_log = /dev/stderr" >> /usr/local/etc/php/conf.d/docker-vars.ini
fi

# Increase the memory_limit
if [ ! -z "$PHP_MEM_LIMIT" ]; then
 sed -i "s/memory_limit = 128M/memory_limit = ${PHP_MEM_LIMIT}M/g" /usr/local/etc/php/conf.d/docker-vars.ini
fi

# Increase the post_max_size
if [ ! -z "$PHP_POST_MAX_SIZE" ]; then
 sed -i "s/post_max_size = 100M/post_max_size = ${PHP_POST_MAX_SIZE}M/g" /usr/local/etc/php/conf.d/docker-vars.ini
fi

# Increase the upload_max_filesize
if [ ! -z "$PHP_UPLOAD_MAX_FILESIZE" ]; then
 sed -i "s/upload_max_filesize = 100M/upload_max_filesize= ${PHP_UPLOAD_MAX_FILESIZE}M/g" /usr/local/etc/php/conf.d/docker-vars.ini
fi

# Use redis as session storage
if [ ! -z "$PHP_REDIS_SESSION_HOST" ]; then
 sed -i 's/session.save_handler = files/session.save_handler = redis\nsession.save_path = "tcp:\/\/'${PHP_REDIS_SESSION_HOST}':6379"/g' /usr/local/etc/php/php.ini
fi

# Enable xdebug
XdebugFile='/usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini'
if [[ "$ENABLE_XDEBUG" == "1" ]] ; then
  if [ -f $XdebugFile ]; then
        echo "Xdebug enabled"
  else
        echo "Enabling xdebug"
        echo "If you get this error, you can safely ignore it: /usr/local/bin/docker-php-ext-enable: line 83: nm: not found"
        # see https://github.com/docker-library/php/pull/420
    docker-php-ext-enable xdebug
    # see if file exists
    if [ -f $XdebugFile ]; then
        # See if file contains xdebug text.
        if grep -q xdebug.remote_enable "$XdebugFile"; then
            echo "Xdebug already enabled... skipping"
        else
            echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > $XdebugFile # Note, single arrow to overwrite file.
            echo "xdebug.remote_enable=1 "  >> $XdebugFile
            echo "xdebug.remote_host=host.docker.internal" >> $XdebugFile
            echo "xdebug.remote_log=/tmp/xdebug.log"  >> $XdebugFile
            echo "xdebug.remote_autostart=false "  >> $XdebugFile # I use the xdebug chrome extension instead of using autostart
            # NOTE: xdebug.remote_host is not needed here if you set an environment variable in docker-compose like so `- XDEBUG_CONFIG=remote_host=192.168.111.27`.
            #       you also need to set an env var `- PHP_IDE_CONFIG=serverName=docker`
        fi
    fi
  fi
else
    if [ -f $XdebugFile ]; then
        echo "Disabling Xdebug"
      rm $XdebugFile
    fi
fi


# Run custom scripts
if [[ "$RUN_SCRIPTS" == "1" ]] ; then
  if [ -d "/var/www/html/scripts/" ]; then
    # make scripts executable incase they aren't
    chmod -Rf 750 /var/www/html/scripts/*; sync;
    # run scripts in number order
    for i in `ls /var/www/html/scripts/`; do /var/www/html/scripts/$i ; done
  else
    echo "Can't find script directory"
  fi
fi

# cp -Rf /var/www/html/config.orig/* /var/www/html/config/

if [[ "$CREATE_LARAVEL_STORAGE" == "1" ]] ; then
  mkdir -p /var/www/html/storage/{logs,app/public,framework/{cache/data,sessions,testing,views}}
  chown -Rf nginx.nginx /var/www/html/storage
  adduser -s /bin/bash -g 82 -D sail
fi

# sed -i 's/error_log \/dev\/stderr info;//g' /etc/supervisord.conf

# Start supervisord and services
exec /usr/bin/supervisord -n -c /etc/supervisord.conf
