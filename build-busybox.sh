#!/bin/bash

BUSYBOX_VERSION="1_27_1"

mkdir -p output/{config,output,build}

cp config/* output/config/

docker run -ti \
  -e "ID=`id -u`" \
  -e "BUSYBOX_VERSION=$BUSYBOX_VERSION" \
  -e "CROSS_COMPILE=aarch64-linux-gnu-" \
  -u `id -u`:`id -g` \
  -v `pwd`/output:/target aarch64-builder /bin/bash -e -c '\
  echo "===== Getting build packages =====" && \
  cd /target/build/ && \
  echo "===== Fetching packages =====" && \
  ( [ ! -d busybox ] && git clone https://git.busybox.net/busybox -b $BUSYBOX_VERSION --single-branch ) || ( cd busybox && git fetch && git checkout $BUSYBOX_VERSION ) ; \
  echo "===== Building Busybox =====" && \
  cd /target/build/busybox && \
  cp /target/config/busybox.config .config && \
  ARCH=arm64 make oldconfig && \
  ARCH=arm64 make -j4 && \
  cp busybox /target/output/busybox'


