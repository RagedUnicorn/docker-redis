#!/bin/sh
# @author Michael Wiesendanger <michael.wiesendanger@gmail.com>
# @description launch script for mysql

# abort when trying to use unset variable
set -o nounset

param1=${1:-}
param2=${2:-}
redis_user="redis"
redis_conf="/usr/local/etc/redis/redis.conf"

if [ -n "${param1}" ]; then
  redis_user="${param1}"
fi

echo ${redis_user}

if [ -n "${param2}" ]; then
  redis_conf="${param2}"
fi

exec su-exec "${redis_user}" redis-server "${redis_conf}"
