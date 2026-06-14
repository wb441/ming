#!/usr/bin/with-contenv bash

echo "Running homepage rewrite..."

# Compute DIRECT_HOST dynamically
if [ -n "$BALENA_DEVICE_UUID_SHORT" ]; then
    DIRECT_HOST="${BALENA_DEVICE_UUID_SHORT}.local"
else
    DIRECT_HOST="$(hostname).local"
fi

echo "DIRECT_HOST resolved to: $DIRECT_HOST"

# Wait for index.html to exist
for i in {1..10}; do
    if [ -f /config/www/index.html ]; then
        sed -i "s/{{URL}}/$URL/g" /config/www/index.html
        sed -i "s/{{DIRECT_HOST}}/$DIRECT_HOST/g" /config/www/index.html
        exit 0
    fi
    sleep 1
done

echo "index.html not found after 10 seconds"
