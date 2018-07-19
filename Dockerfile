FROM alpine:3.7

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
  REDIS_VERSION=4.0.9 \
  SU_EXEC_VERSION=0.2-r0 \
  COREUTILS_VERSION=8.28-r0 \
  GCC_VERSION=6.4.0-r5 \
  LINUX_HEADERS_VERSION=4.4.6-r2 \
  MAKE_VERSION=4.2.1-r0 \
  MUSL_DEV_VERSION=1.1.18-r3

ENV \
  REDIS_USER="${REDIS_USER}" \
  REDIS_GROUP="${REDIS_GROUP}" \
  REDIS_APP_PASSWORD="${REDIS_APP_PASSWORD}" \
  REDIS_DATA_DIR=/data \
  REDIS_HOME=/usr/local/etc/redis \
  REDIS_CONF=/usr/local/etc/redis/redis.conf \
  REDIS_SHASUM=8aa33d13c3ff5c4d4d2cc52932340893132c8aec

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
    musl-dev="${MUSL_DEV_VERSION}"; \
  wget -O redis.tar.gz http://download.redis.io/releases/redis-"${REDIS_VERSION}".tar.gz; \
  echo "${REDIS_SHASUM} *redis.tar.gz" | sha1sum -c -; \
  mkdir -p /usr/src/redis; \
  tar -xzf redis.tar.gz -C /usr/src/redis --strip-components=1; \
  rm redis.tar.gz; \
  make -C /usr/src/redis -j "$(nproc)"; \
  make -C /usr/src/redis install; \
  rm -r /usr/src/redis; \
  apk del .build-deps

# add redis conf
COPY config/redis.conf /usr/local/etc/redis/redis.conf

# add launch script
COPY docker-entrypoint.sh /

# add healthcheck script
COPY docker-healthcheck.sh /

RUN \
  mkdir "${REDIS_DATA_DIR}"; \
  chown "${REDIS_USER}":"${REDIS_GROUP}" "${REDIS_DATA_DIR}"; \
  chmod 644 /usr/local/etc/redis/redis.conf; \
  chown "${REDIS_USER}":"${REDIS_GROUP}" /usr/local/etc/redis/redis.conf; \
  chmod 755 /docker-entrypoint.sh && \
  chmod 755 /docker-healthcheck.sh

EXPOSE 6379

VOLUME ["${REDIS_DATA_DIR}"]

ENTRYPOINT ["/docker-entrypoint.sh"]
