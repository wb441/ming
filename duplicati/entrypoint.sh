#!/bin/sh

DB="/config/Duplicati-server.sqlite"

if [ -n "$DUPLICATI_PASSWORD" ]; then
    echo "Setting Duplicati password from environment variable"

    # Remove old DB if password is unknown
    if [ ! -f "$DB" ]; then
        echo "No server DB found, creating new one"
    else
        echo "Deleting existing server DB to reset password"
        rm -f "$DB"
    fi
fi

# Start Duplicati normally
exec /usr/bin/duplicati-server --webservice-password="$DUPLICATI_PASSWORD" --webservice-interface=any
