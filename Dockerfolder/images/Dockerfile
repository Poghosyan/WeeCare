FROM php:8.1.16-fpm-alpine as base

RUN apk update && apk add openrc --no-cache

RUN apk add supervisor

RUN apk add nginx \
    && mkdir -p /home/app/src /run/nginx /var/cache/nginx /var/tmp/nginx /var/log/php /run/php \
    && ln -s /home/app/src /home/app/www \
    && chown -R nginx:nginx /var/lib/nginx /var/cache/nginx /var/log/nginx /var/tmp/nginx /run/nginx /var/log/php /run/php /home/app

COPY --chown=nginx:nginx ./nginx/conf.d/default.conf /etc/nginx/conf.d

USER www-data

EXPOSE 9000

FROM base as local
