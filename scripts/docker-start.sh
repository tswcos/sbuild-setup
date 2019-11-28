#!/bin/bash

export DOCKER_DIR=$(dirname $(readlink -f "$0"))
source $DOCKER_DIR/config

#docker start --interactive=true --attach=true sbuild-container
docker run --env http_proxy=$http_proxy \
	--env https_proxy=$https_proxy \
	--env no_proxy=$no_proxy \
	--workdir /home/build \
	--cap-add SYS_ADMIN \
	-v $PARRENT_DIR:/home/build/sbuild-setup:rw \
	-u$uid \
	-i \
	--rm \
	-d \
	--name $DOCKERCONTAINER \
	$DOCKERIMAGE
