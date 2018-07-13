#!/bin/bash
# @author Michael Wiesendanger <michael.wiesendanger@gmail.com>
# @description build script for docker-redis container

set -euo pipefail

WD="${PWD}"

# variable setup
DOCKER_REDIS_TAG="ragedunicorn/redis"
DOCKER_REDIS_NAME="redis"
DOCKER_REDIS_DATA_VOLUME="redis_data"

# get absolute path to script and change context to script folder
SCRIPTPATH="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"
cd "${SCRIPTPATH}"

echo "$(date) [INFO]: Building container: ${DOCKER_REDIS_NAME}"

# build redis container
docker build -t "${DOCKER_REDIS_TAG}" ../

# check if redis data volume already exists
docker volume inspect "${DOCKER_REDIS_DATA_VOLUME}" > /dev/null 2>&1

if [ $? -eq 0 ]; then
  echo "$(date) [INFO]: Reusing existing volume: ${DOCKER_REDIS_DATA_VOLUME}"
else
  echo "$(date) [INFO]: Creating new volume: ${DOCKER_REDIS_DATA_VOLUME}"
  docker volume create --name "${DOCKER_REDIS_DATA_VOLUME}" > /dev/null
fi

cd "${WD}"
