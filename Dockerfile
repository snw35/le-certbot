FROM alpine:3.10.3

RUN apk --update --no-cache add \
    python3 \
    augeas \
    libffi \
    libssl1.1 \
    openssl \
    bash \
    coreutils

WORKDIR /root/

ENV CERTBOT_VERSION 0.40.1
ENV CERTBOT_URL https://github.com/certbot/certbot/archive
ENV CERTBOT_FILENAME v$CERTBOT_VERSION.tar.gz
ENV CERTBOT_SHA256 54299ee77a6c0eaf7e11e25bdf492d2a8ed671eba8fc4e7aa9f9d45b1743e41d

RUN apk --no-cache --virtual build.deps add \
    gcc \
    musl-dev \
    libffi-dev \
    openssl-dev \
    python3-dev \
    paxctl \
  && wget $CERTBOT_URL/$CERTBOT_FILENAME \
  && echo "$CERTBOT_SHA256  $CERTBOT_FILENAME" | sha256sum -c - \
  && tar -xzf ./$CERTBOT_FILENAME \
  && pip3 install --upgrade pip \
  && pip3 install --cache-dir=/tmp ./certbot-$CERTBOT_VERSION \
  && rm -rf /root/certbot-$CERTBOT_VERSION \
  && rm -f /root/$CERTBOT_FILENAME \
  && mkdir -p /var/log/letsencrypt \
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
