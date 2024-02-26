#!/usr/bin/env bash

# Check if PHP_SPX environment variable exists and if its value is 1
if [ "${PHP_SPX}" = "1" ]; then
    apt-get install zlib1g-dev
    cd ~
    git clone https://github.com/NoiseByNorthwest/php-spx.git
    cd php-spx
    git checkout release/latest
    phpize
    ./configure
    make
    make install
    docker-php-ext-enable spx
    # Configure default configuration for SPX
    SPX_INI="/usr/local/etc/php/conf.d/docker-php-ext-spx.ini"
    {
        echo "extension=spx.so"
        echo "spx.http_enabled=1"
        echo "spx.http_key=\"dev\""
        echo "spx.http_ip_whitelist=\"*\""
        echo "spx.http_trusted_proxies=\"*\""
    } | tee ${SPX_INI}
    /etc/init.d/apache2 reload
else
    echo "PHP_SPX is not set to 1 or not present. Skipping SPX installation."
fi
