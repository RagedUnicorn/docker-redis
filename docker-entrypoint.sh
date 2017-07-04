#!/bin/sh
# @author Michael Wiesendanger <michael.wiesendanger@gmail.com>
# @description launch script for redis

# abort when trying to use unset variable
set -o nounset

param1=${1:-}
param2=${2:-}
redis_user="redis"
redis_conf="/usr/local/etc/redis/redis.conf"
redis_home="/usr/local/etc/redis"
redis_secret="/run/secrets/com.ragedunicorn.redis.password"

# if secret is set update configuration accordingly
if [ -f "${redis_secret}" ]; then
  # track whether init process was already done
  if [ ! -f "${redis_home}"/.init ]; then
    echo "$(date) [INFO]: Set password for redis database using ${redis_secret}"
    if ! sed -i -e "s/# requirepass .*/requirepass \"$(cat ${redis_secret})\"/g" "${redis_conf}"; then
      echo "$(date) [ERROR]: Failed to set password for redis database"
      exit 1
    else
      touch "${redis_home}"/.init
      echo "$(date) [INFO]: Successfully set redis database password"
    fi
  fi
else
  echo "$(date) [WARNING]: Unable to find password or no password set. Starting redis without password \
  protection."
fi

if [ -n "${param1}" ]; then
  redis_user="${param1}"
fi

if [ -n "${param2}" ]; then
  redis_conf="${param2}"
fi

echo "$(date) [INFO]: Starting redis ..."
exec su-exec "${redis_user}" redis-server "${redis_conf}"
