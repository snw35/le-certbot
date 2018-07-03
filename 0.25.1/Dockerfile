FROM alpine:3.7

RUN apk --update --no-cache add \
    python2 \
    augeas \
    py2-pip \
    libffi \
    libssl1.0 \
    openssl \
    bash

WORKDIR /root/

ENV CERTBOT_VERSION 0.25.1
ENV CERTBOT_DOWNLOAD_SHA256 757998cef7849969bed5b2f250acd8f9554d3b1f655f91b3d4c8d79357a0aa38

RUN apk --no-cache --virtual build.deps add \
    gcc \
    musl-dev \
    libffi-dev \
    openssl-dev \
    python2-dev \
    paxctl \
    && wget https://github.com/certbot/certbot/archive/v$CERTBOT_VERSION.tar.gz \
    && echo "$CERTBOT_DOWNLOAD_SHA256  v$CERTBOT_VERSION.tar.gz" | sha256sum -c - \
    && tar -xzf ./v$CERTBOT_VERSION.tar.gz \
    && pip install --upgrade pip \
    && pip install --no-cache ./certbot-$CERTBOT_VERSION \
    && rm -rf /root/certbot-$CERTBOT_VERSION \
    && rm -f /root/v$CERTBOT_VERSION.tar.gz \
    && paxctl -cm `which python` \
    && mkdir -p /var/log/letsencrypt \
    && ln -s /dev/stdout /var/log/letsencrypt/letsencrypt.log \
    && apk del build.deps

COPY docker-entrypoint.sh /

RUN echo "$((1 + RANDOM % 60)) 4 * * * certbot renew" > /etc/crontabs/root \
    && chmod +x /docker-entrypoint.sh

# Required env variables, defaults are handled in entrypoint script
# Email address to register letsencrypt account with
ENV LE_EMAIL ""

# Domain(s) to generate or renew certificates for, use LE_DOMAIN_2 for second, etc.
ENV LE_DOMAIN_1 ""

# Set to 'y' to generate test certificates instead
ENV LE_TEST ""

VOLUME /etc/letsencrypt

# Run crond by default, and pass args to entrypoint for certbot certonly
CMD ["crond", "-f"]
ENTRYPOINT ["/docker-entrypoint.sh"]
