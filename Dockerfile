FROM alpine:latest
LABEL maintainer=stevesbrain

ENV BITLBEE_VERSION 3.5.1
ENV DISCORD_COMMIT 3e435b0
ENV FACEBOOK_COMMIT bc52372
ENV SKYPE_COMMIT a2c5b71
ENV STEAM_COMMIT 7fc8129
ENV TELEGRAM_COMMIT 065e0b7

RUN set -x \
    && apk update \
    && apk upgrade \
    && apk add --virtual build-dependencies \
	autoconf \
	automake \
	build-base \
	curl \
	git \
	json-glib-dev \
	libtool \
    && apk add --virtual runtime-dependencies \
	glib-dev \
	gnutls-dev \
	json-glib \
	libgcrypt-dev \
	libpurple \
	libwebp-dev \
	pidgin-dev \
    && cd /root \
    && mkdir bitlbee-src \
    && cd bitlbee-src \
    && curl -fsSL "http://get.bitlbee.org/src/bitlbee-${BITLBEE_VERSION}.tar.gz" -o bitlbee.tar.gz \
    && tar -zxf bitlbee.tar.gz --strip-components=1 \
    && mkdir /bitlbee-data \
    && ./configure --purple=1 --config=/bitlbee-data \
    && make \
    && make install \
    && make install-dev \
    && make install-etc \
    && cd /root \
    && git clone -n https://github.com/sm00th/bitlbee-discord \
    && cd /bitlbee-discord \
    && git checkout ${DISCORD_COMMIT} \
    && ./autogen.sh \
    && ./configure \
    && make \
    && make install \
    && cd /root \
    && git clone -n https://github.com/jgeboski/bitlbee-facebook \
    && cd bitlbee-facebook \
    && git checkout ${FACEBOOK_COMMIT} \
    && ./autogen.sh \
    && make \
    && make install \
    && cd /root \
    && git clone -n https://github.com/EionRobb/skype4pidgin \
    && cd skype4pidgin \
    && git checkout ${SKYPE_COMMIT} \
    && cd skypeweb \
    && make \
    && make install \
    && cd /root \
    && git clone -n https://github.com/bitlbee/bitlbee-steam \
    && cd bitlbee-steam \
    && git checkout ${STEAM_COMMIT} \
    && ./autogen.sh \
    && make \
    && make install \
    && cd /root \
    && git clone -n https://github.com/majn/telegram-purple \
    && cd /telegram-purple \
    && git checkout ${TELEGRAM_COMMIT} \
    && git submodule update --init --recursive \
    && ./configure \
    && make \
    && make install \
    && apk del --purge build-dependencies \
    && rm -rf /root/* \
    && rm -rf /var/cache/apk/* \
    && adduser -u 1000 -S bitlbee \
    && addgroup -g 1000 -S bitlbee \
    && chown -R bitlbee:bitlbee /bitlbee-data \
    && touch /var/run/bitlbee.pid \
    && chown bitlbee:bitlbee /var/run/bitlbee.pid; exit 0

USER bitlbee
VOLUME /bitlbee-data
ENTRYPOINT ["/usr/local/sbin/bitlbee", "-F", "-n", "-d", "/bitlbee-data"]
