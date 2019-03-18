FROM alpine:3.9.2

LABEL com.ragedunicorn.maintainer="Michael Wiesendanger <michael.wiesendanger@gmail.com>"

#     ____           ___
#    / __ \___  ____/ (_)____
#   / /_/ / _ \/ __  / / ___/
#  / _, _/  __/ /_/ / (__  )
# /_/ |_|\___/\__,_/_/____/

# image args
ARG REDIS_USER=redis
ARG REDIS_GROUP=redis
ARG REDIS_APP_PASSWORD=app

# software versions
ENV \
  REDIS_VERSION=4.0.11 \
  SU_EXEC_VERSION=0.2-r0 \
  COREUTILS_VERSION=8.30-r0 \
  GCC_VERSION=8.2.0-r2 \
  LINUX_HEADERS_VERSION=4.18.13-r1 \
  MAKE_VERSION=4.2.1-r2 \
  MUSL_DEV_VERSION=1.1.20-r3

ENV \
  REDIS_USER="${REDIS_USER}" \
  REDIS_GROUP="${REDIS_GROUP}" \
  REDIS_APP_PASSWORD="${REDIS_APP_PASSWORD}" \
  REDIS_DATA_DIR=/data \
  REDIS_HOME=/usr/local/etc/redis \
  REDIS_CONF=/usr/local/etc/redis/redis.conf \
  REDIS_SHASUM=a13ccf0f7051f82dc1c979bd94f0b9a9ba039122

# explicitly set user/group IDs
RUN addgroup -S "${REDIS_GROUP}" -g 9999 && adduser -S -G "${REDIS_GROUP}" -u 9999 "${REDIS_USER}"

RUN \
  set -ex; \
  apk add --no-cache su-exec="${SU_EXEC_VERSION}"

RUN \
  set -ex; \
  apk add --no-cache --virtual .build-deps \
    coreutils="${COREUTILS_VERSION}" \
    gcc="${GCC_VERSION}" \
    linux-headers="${LINUX_HEADERS_VERSION}" \
    make="${MAKE_VERSION}" \
    musl-dev="${MUSL_DEV_VERSION}" && \
  if ! wget -O redis.tar.gz http://download.redis.io/releases/redis-"${REDIS_VERSION}".tar.gz; then \
    echo >&2 "Error: Failed to download Redis binary"; \
    exit 1; \
  fi && \
  echo "${REDIS_SHASUM} *redis.tar.gz" | sha1sum -c - && \
  mkdir -p /usr/src/redis && \
  tar -xzf redis.tar.gz -C /usr/src/redis --strip-components=1 && \
  rm redis.tar.gz && \
  make -C /usr/src/redis -j "$(nproc)" && \
  make -C /usr/src/redis install && \
  rm -r /usr/src/redis && \
  apk del .build-deps

# add redis conf
COPY config/redis.conf /usr/local/etc/redis/redis.conf

# add launch script
COPY docker-entrypoint.sh /

# add healthcheck script
COPY docker-healthcheck.sh /

RUN \
  mkdir "${REDIS_DATA_DIR}" && \
  chown "${REDIS_USER}":"${REDIS_GROUP}" "${REDIS_DATA_DIR}" && \
  chmod 644 /usr/local/etc/redis/redis.conf && \
  chown "${REDIS_USER}":"${REDIS_GROUP}" /usr/local/etc/redis/redis.conf && \
  chmod 755 /docker-entrypoint.sh && \
  chmod 755 /docker-healthcheck.sh

EXPOSE 6379

VOLUME ["${REDIS_DATA_DIR}"]

ENTRYPOINT ["/docker-entrypoint.sh"]
