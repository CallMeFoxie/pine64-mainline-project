#!/bin/bash

BUSYBOX_VERSION="1_27_2"

mkdir -p output/

docker run -ti \
  -e "ID=`id -u`" \
  -e "BUSYBOX_VERSION=$BUSYBOX_VERSION" \
  -e "CROSS_COMPILE=aarch64-linux-gnu-" \
  -u `id -u`:`id -g` \
  -v `pwd`/:/base \
     aarch64-builder \
       /bin/bash -e -c '\
  echo "===== Building Busybox =====" && \
  cd /base/components/busybox && \
  git clean -f -x -d && git fetch && git checkout $BUSYBOX_VERSION && \
  cp /base/config/busybox.config .config && \
  ARCH=arm64 make oldconfig && \
  ARCH=arm64 make -j4 && \
  cp busybox /target/output/busybox'


