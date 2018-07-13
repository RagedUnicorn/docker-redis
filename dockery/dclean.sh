#!/bin/bash
# @author Michael Wiesendanger <michael.wiesendanger@gmail.com>
# @description cleanup script for docker-redis container.
# Does not delete other containers that where built from the dockerfile

# abort when trying to use unset variable
set -euo pipefail

WD="${PWD}"

# variable setup
DOCKER_REDIS_NAME="redis"

# get absolute path to script and change context to script folder
SCRIPTPATH="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"
cd "${SCRIPTPATH}"

# search for containers including non-running containers
docker ps -a | grep "${DOCKER_REDIS_NAME}" > /dev/null

# if a container can be found - delete it
if [ $? -eq 0 ]; then
  echo "$(date) [INFO]: Cleaning up container ${DOCKER_REDIS_NAME} ..."
  docker rm "${DOCKER_REDIS_NAME}" > /dev/null
else
  echo "$(date) [INFO]: No existing container with name: ${DOCKER_REDIS_NAME} found"
fi

cd "${WD}"
