FROM php:7.4-fpm-alpine

WORKDIR /tmp

RUN \
# Create runtime user
    addgroup -g 4300 -S filerun \
    && adduser -u 4300 -S filerun -G filerun \
# Install dependencies
    && apk add --no-cache freetype libjpeg-turbo libsasl libldap openssl libzip imagemagick imagemagick-c++ ffmpeg unzip wget pngquant vips-tools \
# Install build-time dependencies
    && apk add --no-cache --virtual .dev-deps \
        freetype-dev libjpeg-turbo-dev libzip-dev openldap-dev openssl-dev imagemagick-dev \
# Configure PHP extensions
    && docker-php-ext-configure zip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure ldap \
# Install ImageMagick library
    && pecl install imagick \
    && docker-php-ext-enable imagick \
# Install the rest of the libraries
    && docker-php-ext-install -j$(nproc) pdo_mysql exif zip gd opcache ldap \
# Install IonCube loader according to architecture
    && wget -O ioncube.tar.gz https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_$(uname -m | sed 's/_/-/').tar.gz \
    && tar xfz ioncube.tar.gz \
    && PHP_EXT_DIR=$(php-config --extension-dir) \
    && cp "ioncube/ioncube_loader_lin_7.4.so" "$PHP_EXT_DIR" \
    && echo "zend_extension=ioncube_loader_lin_7.4.so" >> /usr/local/etc/php/conf.d/00_ioncube.ini \
    && rm -rf ioncube ioncube.tar.gz \
# Create mounts
    && mkdir -p /user-files /www-files /var/run/php \
    && chown -R filerun:filerun /www-files /var/run/php \
    && chown -R filerun:filerun /var/run/php \
# Cleanup
    && apk del .dev-deps \
    && rm -rf /tmp/* /var/cache/apk/*

ENV FR_DB_HOST db
ENV FR_DB_PORT 3306
ENV FR_DB_NAME filerun
ENV FR_DB_USER filerun
ENV FR_DB_PASS filerun

COPY php-optimizations.ini /usr/local/etc/php/conf.d/
COPY php-fpm-optimizations.ini /usr/local/etc/php-fpm.d/zzz-filerun.conf
COPY entrypoint.sh /
COPY autoconfig.php /
RUN chmod +x /entrypoint.sh

USER filerun
VOLUME ["/www-files", "/user-files", "/var/run/php"]
ENTRYPOINT ["/entrypoint.sh"]
