#!/bin/bash

readonly ARCH=$(dpkg --print-architecture)
readonly SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
readonly REPO_ROOT_DIR=$(cd "${SCRIPT_DIR}/.." && pwd)
readonly WORKSPACE_DIR=${REPO_ROOT_DIR}

cd "${SCRIPT_DIR}"
cd ..
KICAD_SRC_DIR=$(pwd)/kicad-src


checkYesNo(){
    local value

    value="${1,,}" # convert to lowercase

    if [[ "$value" =~ ^(yes|true|on|1|set)$ ]]; then
        return 0
    elif [[ "$value" =~ ^(no|false|off|0|unset)$ ]]; then
        return 1
    elif [ -z "$value" ]; then
        # If the value is not set, treat it silently as No
        return 1
    else
        echo "${RED}Invalid value: \`$value'. Will treat this as a \`Yes'${NC}"
        return 0
    fi
}

help(){
    echo "Usage:"
    echo "  mithril-dev [command]"
    echo ""
    echo "Available Commands"
    echo "  start                     Start and enters the container. "
    echo "       -g                   Enable gpu in the container "
    echo "       -n                   Specify which host networking to use "
    echo "  enter                     Enter a running rosdev image"
    echo "  kill                      Kill a running rosdev image"
    echo "  status                    Get status of rosdev"
    echo "  createDockerGroup         Add user to the docker group"
}

if [ "$1" == "-h" ] ; then
    help
    exit 0
fi

if [ "$1" == "--help" ] ; then
    help
    exit 0
fi


if [ -f /.dockerenv ]; then
    printf "${RED}I'm inside a container already, you should these commands outside${NC}\n"
    exit 0
fi

start(){
    docker run -d \
        -e DISPLAY=$DISPLAY \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        -v $HOME:$HOME \
        -v $KICAD_SRC_DIR:/kicad-src \
        --name keyboard-design-tools \
        kicad8 'while true; do sleep 1; done'
}

status(){
    echo "Status"
}

enter(){
    docker exec -it keyboard-design-tools /bin/bash
}

"$@"