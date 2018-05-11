#!/bin/sh
set -eox pipefail

host="127.0.0.1"
redis_secret="/run/secrets/com.ragedunicorn.redis.password"

if [ -f "${redis_secret}" ]; then
	if ping="$(redis-cli -h "$host" -a $(cat "${redis_secret}") ping)" && [ "$ping" = 'PONG' ]; then
		exit 0
	fi
else
	if ping="$(redis-cli -h "$host" ping)" && [ "$ping" = 'PONG' ]; then
		exit 0
	fi
fi

exit 1
