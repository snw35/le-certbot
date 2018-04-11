#!/usr/bin/env bash
set -e

# If we are passed arg flags then run against certbot certonly like an entrypoint
if [ "${1:0:1}" = '-' ]; then
	set -- certbot certonly "$@"
fi

# If crond is passed then check for certs
if [ "$1" = 'crond' ]; then

    # Get env vars
    if [ -z "${LE_EMAIL:-}" ]; then
        echo "LE_EMAIL environment variable is not set! Defaulting to example@example.com"
        declare -r LE_EMAIL='example@example.com'
    fi

    if [ -z "${LE_TEST:-}" ]; then
        declare -r LE_TEST='n'
    fi

    if [ -z "${LE_DOMAIN:-}" ]; then
        echo "LE_DOMAIN environment variable is not set!"
        echo "WARNING: certificates cannot be generated as domain is required!"
        echo "Checking for existing certs..."

        subdircount=`find /etc/letsencrypt/live/ -maxdepth 1 -type d | wc -l`

        if [ $subdircount -ge 1 ]
        then
            echo "Existing certificate directory(s) found. Running crond."
            exec "$@"
        else
            echo "ERROR: no exising certificate directory(s) found and LE_DOMAIN is not set!"
            echo "Exiting as no certificats can be generated and there are none to renew!"
            exit 1
        fi
    else
        # Certificate location
        privkey="/etc/letsencrypt/live/$LE_DOMAIN/privkey.pem"

        # Check for existing certificates
        if [ -f "$privkey" ]; then
            # If found, run crond
            exec "$@"
        else
            # If not, try to generate certs with the config given
            echo "No existing certificates found for the configured domain. Attempting to generate them..."

            if [ "$LE_TEST" = "n" ]; then
                certbot certonly --webroot -w /usr/share/nginx/html -d $LE_DOMAIN --email $LE_EMAIL --agree-tos --non-interactive --keep-until-expiring --rsa-key-size 4096 --hsts --uir --preferred-challenges http

                if [ $? -eq 0 ]; then
                    echo "Certificates generated. Pausing and running crond..."
                    sleep 2
                    exec "$@"
                else
                    echo "Error generating certificates!"
                    exit 1
                fi
            elif [ "$LE_TEST" = "y" ]; then
                echo "Test certificate requested. Generating test cert instead..."
                certbot certonly --webroot -w /usr/share/nginx/html -d $LE_DOMAIN --email $LE_EMAIL --agree-tos --non-interactive --keep-until-expiring --rsa-key-size 4096 --hsts --uir --preferred-challenges http --test-cert

                if [ $? -eq 0 ]; then
                    echo "Certificates generated. Pausing and running crond..."
                    sleep 2
                    exec "$@"
                else
                    echo "Error generating certificates!"
                    exit 1
                fi
            else
                echo "You must set LE_TEST to y if you want to generate a test certificate."
            fi
        fi
    fi
fi

# If other command, just run it
exec "$@"
