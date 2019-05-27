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

E="docker exec -u $uid $DOCKERCONTAINER /bin/bash -c"

$E "sudo -E sbuild-createchroot --include=eatmydata,ccache,gnupg \
	unstable \
	/home/build/chroot-sbuild \
	http://deb.debian.org/debian"

$E "echo Acquire::http::proxy \\\"$http_proxy\\\"\; | sudo tee /home/build/chroot-sbuild/etc/apt/apt.conf.d/99proxy"
$E "echo \"command-prefix=/var/cache/ccache-sbuild/sbuild-setup,eatmydata\" | sudo tee -a /etc/schroot/chroot.d/unstable-amd64-sbuild-*"
