#!/bin/bash

export DOCKER_DIR=$(dirname $(readlink -f "$0"))
source $DOCKER_DIR/config

docker build \
	--build-arg http_proxy="$http_proxy" \
	--build-arg https_proxy="$https_proxy" \
	--build-arg no_proxy="$no_proxy" \
	--build-arg UID="$uid" \
	-t $DOCKERIMAGE .

