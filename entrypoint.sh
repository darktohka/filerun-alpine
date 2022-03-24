#!/bin/sh

# Install FileRun on first run
if [ ! -e /www-files/index.php ];  then
    echo "[FileRun fresh install]"
    wget -O /tmp/filerun.zip https://filerun.com/download-latest-php74
    unzip /tmp/filerun.zip -d /www-files
    rm /tmp/filerun.zip
    cp /autoconfig.php /www-files/system/data/
fi

php-fpm
