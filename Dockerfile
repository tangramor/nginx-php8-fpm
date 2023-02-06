FROM node:19.6.0-alpine3.17 AS nodejs

FROM tangramor/nginx-php8-fpm:php8.2.2_withoutNodejs

LABEL org.opencontainers.image.authors="Wang Junhua(tangramor@gmail.com)"
LABEL org.opencontainers.image.url="https://www.github.com/tangramor/nginx-php8-fpm"

# China alpine mirror: mirrors.ustc.edu.cn
ARG APKMIRROR=dl-cdn.alpinelinux.org

USER root

WORKDIR /var/www/html

# China npm mirror: https://registry.npmmirror.com
ENV NPMMIRROR=""

COPY --from=nodejs /opt /opt
COPY --from=nodejs /usr/local /usr/local

COPY start.sh /start.sh

EXPOSE 443 80

CMD ["/start.sh"]
