#!/bin/bash

mkdir -p output/

docker run -ti \
  -e "CROSS_COMPILE=aarch64-linux-gnu-" \
  -u `id -u`:`id -g` \
  -v `pwd`/:/base \
     aarch64-builder \
       /bin/bash -e -c '\
  echo "===== Building Busybox =====" && \
  cd /base/components/busybox && \
  cp /base/config/busybox.config .config && \
  ARCH=arm64 make clean && \
  ARCH=arm64 make oldconfig && \
  ARCH=arm64 make -j4 && \
  cp busybox /base/output/busybox'


