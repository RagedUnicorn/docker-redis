#!/bin/bash
# @author Michael Wiesendanger <michael.wiesendanger@gmail.com>
# @description run script for docker-redis container

set -euo pipefail

WD="${PWD}"

# variable setup
DOCKER_REDIS_TAG="ragedunicorn/redis"
DOCKER_REDIS_NAME="redis"
DOCKER_REDIS_ID=0

# get absolute path to script and change context to script folder
SCRIPTPATH="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"
cd "${SCRIPTPATH}"

# check if there is already an image created
docker inspect ${DOCKER_REDIS_NAME} &> /dev/null

if [ $? -eq 0 ]; then
  # start container
  docker start "${DOCKER_REDIS_NAME}"
else
  ## run image:
  # -p expose port
  # -d run in detached mode
  # -v mount a volume
  # --name define a name for the container(optional)
  DOCKER_REDIS_ID=$(docker run \
  -p 8081:8081 \
  -d \
  -v redis_data:/data \
  --name "${DOCKER_REDIS_NAME}" "${DOCKER_REDIS_TAG}")
fi

if [ $? -eq 0 ]; then
  # print some info about containers
  echo "$(date) [INFO]: Container info:"
  docker inspect -f '{{ .Config.Hostname }} {{ .Name }} {{ .Config.Image }} {{ .NetworkSettings.IPAddress }}' ${DOCKER_REDIS_NAME}
else
  echo "$(date) [ERROR]: Failed to start container - ${DOCKER_REDIS_NAME}"
fi

cd "${WD}"
