#!/bin/sh

# Install FileRun on first run
if [ ! -e /www-files/index.php ];  then
  echo "[FileRun fresh install]"
  wget -O filerun.zip https://filerun.com/download-latest-php73
  unzip filerun.zip -d /www-files
  rm filerun.zip
  cp /autoconfig.php /www-files/system/data/
  chown -R www-data:www-data /var/run/php
  chown -R www-data:www-data /www-files
  chown www-data:www-data /user-files
fi

php-fpm