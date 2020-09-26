FROM php:7.4-fpm-alpine

WORKDIR /tmp
COPY php-optimizations.ini /usr/local/etc/php/conf.d/
COPY entrypoint.sh /
COPY autoconfig.php /

RUN \
    apk add --no-cache freetype libjpeg-turbo libsasl libldap libldapcpp openssl libzip graphicsmagick ffmpeg unzip wget \
    && apk add --no-cache --virtual .dev-deps \
        freetype-dev libjpeg-turbo-dev libzip-dev openldap-dev openssl-dev \
    && docker-php-ext-configure zip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure ldap \
    && docker-php-ext-install -j$(nproc) pdo_mysql exif zip gd opcache ldap \
    && wget -O ioncube.tar.gz https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_$(uname -m | sed 's/_/-/').tar.gz \
    && tar xfz ioncube.tar.gz \
    && PHP_EXT_DIR=$(php-config --extension-dir) \
    && cp "ioncube/ioncube_loader_lin_7.4.so" "$PHP_EXT_DIR" \
    && echo "zend_extension=ioncube_loader_lin_7.4.so" >> /usr/local/etc/php/conf.d/00_ioncube.ini \
    && rm -rf ioncube ioncube.tar.gz \
    && mkdir -p /user-files /www-files /var/run/php \
    && chown www-data:www-data /user-files /www-files /var/run/php \
    && chmod +x /entrypoint.sh \
    && apk del .dev-deps \
    && rm -rf /tmp/* /var/cache/apk/*

ENV FR_DB_HOST db
ENV FR_DB_PORT 3306
ENV FR_DB_NAME filerun
ENV FR_DB_USER filerun
ENV FR_DB_PASS filerun

USER www-data
VOLUME ["/www-files", "/user-files", "/var/run/php"]
ENTRYPOINT ["/entrypoint.sh"]