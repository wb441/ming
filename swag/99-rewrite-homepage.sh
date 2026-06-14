#!/usr/bin/with-contenv bash

echo "Running homepage rewrite..."

# Only rewrite if the file exists
if [ -f /config/www/index.html ]; then
    sed -i "s/{{URL}}/$URL/g" /config/www/index.html
    sed -i "s/{{DIRECT_HOST}}/$DIRECT_HOST/g" /config/www/index.html
fi
