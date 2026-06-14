#!/bin/sh

DB="/config/Duplicati-server.sqlite"

if [ -n "$DUPLICATI_PASSWORD" ]; then
    echo "Setting Duplicati password from environment variable"

    if [ ! -f "$DB" ]; then
        echo "No server DB found, creating new one"
    else
        echo "Deleting existing server DB to reset password"
        rm -f "$DB"
    fi
fi

# Give the filesystem a moment to settle before s6 starts Duplicati
sleep 2

# Do NOT start Duplicati manually — s6 will do it
exit 0
