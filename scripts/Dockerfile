FROM debian:buster
ARG UID

USER root

ARG DEBIAN_FRONTEND=noninteractive
RUN bash -c 'if test -n "$http_proxy"; then echo "Acquire::http::proxy \"$http_proxy\";" > /etc/apt/apt.conf.d/99proxy; fi'
#RUN cat /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y --no-install-recommends \
	sbuild schroot debootstrap reprepro eatmydata gnupg ccache \
	locales ca-certificates cron sudo git bash


ENV USER build
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && locale-gen
RUN useradd -d /home/$USER -U -m -s /bin/bash -u $UID $USER

RUN echo "build:sbuild" | chpasswd
RUN echo "root:sbuild" | chpasswd

RUN echo "%build  ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/sbuildgrp
RUN chmod 0440 /etc/sudoers.d/sbuildgrp
RUN sbuild-adduser build

ENV CCACHE_DIR /var/cache/ccache-sbuild
RUN install --group=sbuild --mode=2775 -d $CCACHE_DIR
RUN ccache --max-size 4G
RUN mkdir -p /etc/schroot/sbuild/
RUN echo $CCACHE_DIR $CCACHE_DIR none rw,bind 0 0 >> /etc/schroot/sbuild/fstab
ADD ./sbuild-setup $CCACHE_DIR/

USER $USER

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN bash -c 'if test -n "$http_proxy"; then git config --global http.proxy "$http_proxy"; fi'
RUN bash -c 'if test -n "$https_proxy"; then git config --global https.proxy "$https_proxy"; fi'
RUN bash -c 'if test -n "$no_proxy"; then git config --global core.noproxy "$no_proxy"; fi'

RUN mkdir -p /home/$USER/sbuild-setup
RUN sudo -E sbuild-createchroot --include=eatmydata,ccache,gnupg unstable /home/$USER/chroot-sbuild http://deb.debian.org/debian
RUN bash -c 'if test -n "$http_proxy"; then echo "Acquire::http::proxy \"$http_proxy\";" | sudo tee /home/$USER/chroot-sbuild/etc/apt/apt.conf.d/99proxy; fi'
RUN echo "command-prefix=/var/cache/ccache-sbuild/sbuild-setup,eatmydata" | sudo tee -a /etc/schroot/chroot.d/unstable-amd64-sbuild-*
