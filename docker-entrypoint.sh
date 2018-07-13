#!/bin/sh
# @author Michael Wiesendanger <michael.wiesendanger@gmail.com>
# @description launch script for redis

set -euo pipefail

redis_app_password="/run/secrets/com.ragedunicorn.redis.app_password"

function set_init_done {
  touch "${REDIS_HOME}/.init"
  echo "$(date) [INFO]: Init script done"
}

function init {
  # track whether init process was already done
  if [ ! -f "${REDIS_HOME}/.init" ]; then
    echo "$(date) [INFO]: First time setup - running init script"

    if [ -f "${redis_app_password}" ]; then
      echo "$(date) [INFO]: Found docker secrets - using secrets to setup redis"

      redis_app_password="$(cat ${redis_app_password})"
    else
      echo "$(date) [INFO]: No docker secrets found - using environment variables"

      redis_app_password="${REDIS_APP_PASSWORD?Missing environment variable REDIS_APP_PASSWORD}"
    fi

    if [ ! -z "${REDIS_APP_PASSWORD+x}" ]; then
      unset "${REDIS_APP_PASSWORD}"
    fi

    if sed -i -e "s/# requirepass .*/requirepass \"${redis_app_password}\"/g" "${REDIS_CONF}"; then
      touch "${REDIS_HOME}/.init"
      echo "$(date) [INFO]: Successfully set redis database password"
    else
      echo "$(date) [ERROR]: Failed to set password for redis database"
      exit 1
    fi
  fi

  echo "$(date) [INFO]: Starting redis ..."
  exec su-exec "${REDIS_USER}" redis-server "${REDIS_CONF}"
}

init
