FROM node:25.2.1-alpine3.23 AS nodejs

FROM tangramor/nginx-php8-fpm:php8.5.0_withoutNodejs

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
