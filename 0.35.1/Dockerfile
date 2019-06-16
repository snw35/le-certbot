FROM alpine:3.9

RUN apk --update --no-cache add \
    python2 \
    augeas \
    py2-pip \
    libffi \
    libssl1.1 \
    openssl \
    bash

WORKDIR /root/

ENV CERTBOT_VERSION 0.35.1
ENV CERTBOT_URL https://github.com/certbot/certbot/archive
ENV CERTBOT_FILENAME v$CERTBOT_VERSION.tar.gz
ENV CERTBOT_SHA256 c4b4755866a2eaf5204abe3da25b9b8769b146e73d93a9527a22cda7d5a55070

RUN apk --no-cache --virtual build.deps add \
    gcc \
    musl-dev \
    libffi-dev \
    openssl-dev \
    python2-dev \
    paxctl \
  && wget $CERTBOT_URL/$CERTBOT_FILENAME \
  && echo "$CERTBOT_SHA256  $CERTBOT_FILENAME" | sha256sum -c - \
  && tar -xzf ./$CERTBOT_FILENAME \
  && pip install --upgrade pip \
  && pip install --cache-dir=/tmp ./certbot-$CERTBOT_VERSION \
  && rm -rf /root/certbot-$CERTBOT_VERSION \
  && rm -f /root/$CERTBOT_FILENAME \
  && paxctl -cm `which python` \
  && mkdir -p /var/log/letsencrypt \
  && ln -sf /dev/stdout /var/log/letsencrypt/letsencrypt.log \
  && apk del build.deps \
  && rm -rf /tmp/*

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
