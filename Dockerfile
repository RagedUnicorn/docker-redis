FROM alpine:3.7

LABEL com.ragedunicorn.maintainer="Michael Wiesendanger <michael.wiesendanger@gmail.com>"

#     ____           ___
#    / __ \___  ____/ (_)____
#   / /_/ / _ \/ __  / / ___/
#  / _, _/  __/ /_/ / (__  )
# /_/ |_|\___/\__,_/_/____/

# software versions
ENV \
  REDIS_VERSION=3.2.9 \
  SU_EXEC_VERSION=0.2-r0 \
  COREUTILS_VERSION=8.28-r0 \
  GCC_VERSION=6.4.0-r5 \
  LINUX_HEADERS_VERSION=4.4.6-r2 \
  MAKE_VERSION=4.2.1-r0 \
  MUSL_DEV_VERSION=1.1.18-r2

ENV \
  REDIS_USER=redis \
  REDIS_GROUP=redis \
  REDIS_DATA_DIR=/data \
  REDIS_SHASUM=8fad759f28bcb14b94254124d824f1f3ed7b6aa6

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

# add launch script
COPY docker-entrypoint.sh /
# add redis conf
COPY config/redis.conf /usr/local/etc/redis/redis.conf

RUN \
  mkdir "${REDIS_DATA_DIR}"; \
  chown "${REDIS_USER}":"${REDIS_GROUP}" "${REDIS_DATA_DIR}"; \
  chmod 644 /usr/local/etc/redis/redis.conf; \
  chown "${REDIS_USER}":"${REDIS_GROUP}" /usr/local/etc/redis/redis.conf; \
  chmod 755 docker-entrypoint.sh

EXPOSE 6379

VOLUME ["${REDIS_DATA_DIR}"]

ENTRYPOINT ["/docker-entrypoint.sh"]
