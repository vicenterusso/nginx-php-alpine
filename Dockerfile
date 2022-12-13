FROM alpine:3.15

LABEL Maintainer="Vicente Russo Neto <vicente.russo@gmail.com>" \
      Description="Lightweight container with Nginx 1.20.2 & PHP 7.4.30 based on Alpine Linux 3.15."

# Install packages and remove default server definition
RUN apk --no-cache add \
  php7 \
  php7-fpm \
  php7-opcache \
  php7-mysqli\
  php7-pgsql \
  php7-pdo_pgsql \
  php7-pecl-redis \
  php7-pecl-mongodb \
  php7-pecl-imagick \
  php7-pecl-mcrypt \
  php7-json\
  php7-openssl \
  php7-curl\
  php7-bcmath \
  php7-calendar \
  php7-zlib\
  php7-intl \
  php7-xml \
  php7-phar\
  php7-intl\
  php7-dom \
  php7-xmlreader \
  php7-ctype \
  php7-session \
  php7-mbstring\
  php7-gd\
  git \
  nginx\
  supervisor \
  tzdata \
  curl


# Add Locales
RUN apk add --no-cache --update musl musl-utils musl-locales tzdata
ENV TZ=America/Sao_Paulo
RUN cp /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime

RUN echo 'export LC_ALL=pt_BR.UTF-8' >> /etc/profile.d/locale.sh && \
  sed -i 's|LANG=C.UTF-8|LANG=pt_BR.UTF-8|' /etc/profile.d/locale.sh

ENV LANG=pt_BR.UTF-8
ENV LC_COLLATE=pt_BR

# Configure nginx
COPY config/nginx.conf /etc/nginx/nginx.conf
COPY nginx-apps-conf/iceasa-api.conf /etc/nginx/conf.d/iceasa-api.conf;
COPY nginx-apps-conf/iceasa-frontend.conf /etc/nginx/conf.d/iceasa-frontend.conf;

RUN mkdir -p /var/www/html

# Configure PHP-FPM
COPY config/fpm-pool.conf /etc/php7/php-fpm.d/www.conf
COPY config/php.ini /etc/php7/conf.d/custom.ini

# Configure supervisord
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Setup document root
RUN mkdir -p /var/www

# Add user for application
#RUN adduser -SDu 1000 www www
RUN adduser -D -g 'www' www

# # Make sure files/folders needed by the processes are accessable when they run under the nobody user
RUN chown -R www:www /var/www/html && \
  chown -R www:www /run && \
  chown -R www:www /var/lib/nginx && \
  chown -R www:www /var/log/nginx

WORKDIR /var/www/html

# Change current user to www
USER www

# Let supervisord start nginx & php-fpm
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Configure a healthcheck to validate that everything is up&running
HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8080/fpm-ping

