#!/usr/bin/env bash

apt-get install zlib1g-dev
cd ~
git clone https://github.com/NoiseByNorthwest/php-spx.git
cd php-spx
git checkout release/latest
phpize
./configure
make
make install
