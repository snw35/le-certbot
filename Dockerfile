FROM python:3.11.3-alpine3.17

RUN apk --update --no-cache add \
    augeas \
    libffi \
    libssl1.1 \
    openssl \
    bash \
    coreutils

WORKDIR /root/

ENV CERTBOT_VERSION 2.5.0
ENV CERTBOT_URL https://github.com/certbot/certbot/archive
ENV CERTBOT_FILENAME v$CERTBOT_VERSION.tar.gz
ENV CERTBOT_SHA256 fbcd1582c3d2ac8f4b368c94f8d6a19837bdfea3a27da9b5af477177308d4b03

RUN apk --no-cache --virtual build.deps add \
    cargo \
    gcc \
    libffi-dev \
    musl-dev \
    openssl-dev \
    rust \
  && wget $CERTBOT_URL/$CERTBOT_FILENAME \
  && echo "$CERTBOT_SHA256  $CERTBOT_FILENAME" | sha256sum -c - \
  && tar -xzf ./$CERTBOT_FILENAME \
  && pip3 install --upgrade pip \
  && pip3 install --cache-dir=/tmp ./certbot-$CERTBOT_VERSION/certbot \
  && rm -rf /root/certbot-$CERTBOT_VERSION \
  && rm -f /root/$CERTBOT_FILENAME \
  && mkdir -p /var/log/letsencrypt \
  && apk del build.deps \
  && rm -rf /tmp/* \
  && certbot --help

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
