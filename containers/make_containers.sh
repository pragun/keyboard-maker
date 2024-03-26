#!/bin/bash

readonly ARCH=$(dpkg --print-architecture)
readonly SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
readonly REPO_ROOT_DIR=$(cd "${SCRIPT_DIR}/.." && pwd)
readonly WORKSPACE_DIR=${REPO_ROOT_DIR}

cd "${SCRIPT_DIR}"

docker buildx build --progress=plain \
    --build-arg UID=`id -u` \
    --build-arg GID=`id -g` \
    --build-arg USER_NAME=`id -nu` \
    --build-arg HOME=$HOME \
    -t kicad8 -f kicad.DockerFile .
