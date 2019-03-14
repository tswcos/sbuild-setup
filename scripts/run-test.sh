#!/bin/bash

export DOCKER_DIR=$(dirname $(readlink -f "$0"))
source $DOCKER_DIR/config

E="docker exec -u $uid $DOCKERCONTAINER /bin/bash -c"
$E "cd /home/build/sbuild-setup && \
reprepro -b ./repo update unstable-cross && ./sbuild-loop.sh"
