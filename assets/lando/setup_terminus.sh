#!/usr/bin/env bash

cd /usr/local/bin/
curl -L https://github.com/pantheon-systems/terminus/releases/download/$(curl --silent "https://api.github.com/repos/pantheon-systems/terminus/releases/latest" | perl -nle'print $& while m{"tag_name": "\K.*?(?=")}g')/terminus.phar --output terminus
chmod +x terminus
chown www-data:www-data terminus
