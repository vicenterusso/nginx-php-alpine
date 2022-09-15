FROM alpine:3.15
LABEL Maintainer="Tim de Pater <code@trafex.nl>" \
      Description="Lightweight container with Nginx 1.18 & PHP 7.4.30 based on Alpine Linux 3.15."
      
# Composer - https://getcomposer.org/download/
ARG COMPOSER_VERSION="1.10.26"
ARG COMPOSER_SUM="cbfe1f85276c57abe464d934503d935aa213494ac286275c8dfabfa91e3dbdc4"

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
  curl \
      && \
    rm /etc/nginx/conf.d/default.conf


# Add Locales
RUN apk add --no-cache --update musl musl-utils musl-locales tzdata
ENV TZ=America/Sao_Paulo
RUN cp /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime

RUN echo 'export LC_ALL=pt_BR.UTF-8' >> /etc/profile.d/locale.sh && \
  sed -i 's|LANG=C.UTF-8|LANG=pt_BR.UTF-8|' /etc/profile.d/locale.sh

ENV LANG=pt_BR.UTF-8
ENV LC_COLLATE=pt_BR

# Install Composer
RUN set -eux \
    && curl -LO "https://getcomposer.org/download/${COMPOSER_VERSION}/composer.phar" \
    && echo "${COMPOSER_SUM}  composer.phar" | sha256sum -c - \
    && chmod +x composer.phar \
    && mv composer.phar /usr/local/bin/composer \
    && composer --version \
    && true


# Configure nginx
COPY config/nginx.conf /etc/nginx/nginx.conf

# Configure PHP-FPM
COPY config/fpm-pool.conf /etc/php7/php-fpm.d/www.conf
COPY config/php.ini /etc/php7/conf.d/custom.ini

# Configure supervisord
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Setup document root
RUN mkdir -p /var/www/html

# Make sure files/folders needed by the processes are accessable when they run under the nobody user
RUN chown -R nobody.nobody /var/www/html && \
  chown -R nobody.nobody /run && \
  chown -R nobody.nobody /var/lib/nginx && \
  chown -R nobody.nobody /var/log/nginx

# Switch to use a non-root user from here on
USER nobody

# Add application
WORKDIR /var/www/html
COPY --chown=nobody src/ /var/www/html/

# Expose the port nginx is reachable on
EXPOSE 8080

# Let supervisord start nginx & php-fpm
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Configure a healthcheck to validate that everything is up&running
HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8080/fpm-ping
