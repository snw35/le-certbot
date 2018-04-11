FROM alpine:3.7

# Base dependencies
RUN apk --update --no-cache add \
    python2 \
    augeas \
    py2-pip \
    libffi \
    libssl1.0 \
    bash

WORKDIR /root/

ENV CERTBOT_VERSION 0.23.0
ENV CERTBOT_DOWNLOAD_SHA256 9c05e53a3fd1ab530234847ca9969d079fc01f1c192866b6a14a41e05e584c9c

# Build and install certbot
RUN apk --no-cache --virtual build.deps add \
    gcc \
    musl-dev \
    libffi-dev \
    openssl-dev \
    python2-dev \
    && wget https://github.com/certbot/certbot/archive/v$CERTBOT_VERSION.tar.gz \
    && echo "$CERTBOT_DOWNLOAD_SHA256  v$CERTBOT_VERSION.tar.gz" | sha256sum -c - \
    && tar -xzf ./v$CERTBOT_VERSION.tar.gz \
    && pip install --upgrade pip \
    && pip install --no-cache ./certbot-$CERTBOT_VERSION \
    && rm -rf /root/certbot-$CERTBOT_VERSION \
    && rm -f /root/v$CERTBOT_VERSION.tar.gz \
    && apk del build.deps \
    && adduser -u 10001 -S certbot

# Copy entrypoint
COPY docker-entrypoint.sh /

# Add cron job for certbot renew
RUN echo "$((1 + RANDOM % 60)) 4 * * * certbot renew" > /etc/crontabs/certbot \
        && chmod 0600 /etc/crontabs/certbot \
        && chmod +x /docker-entrypoint.sh

# Required env variables, defaults are handled in entrypoint script
# Email address to register letsencrypt account with
ENV LE_EMAIL changeme

# Domain to generate or renew certificates for
ENV LE_DOMAIN changeme

# Set to 'y' to generate test certificates instead
ENV LE_TEST n

# Mark letsencrypt directory as a volume
VOLUME /etc/letsencrypt

# Run crond by default, and pass args to entrypoint for certbot certonly
CMD ["crond", "-f"]
ENTRYPOINT ["/docker-entrypoint.sh"]
