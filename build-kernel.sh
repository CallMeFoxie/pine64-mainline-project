#!/bin/bash

KERNEL_VERSION="v4.13-rc7"

mkdir -p output/

docker run -ti \
  -e "ID=`id -u`" \
  -e "KERNEL_VERSION=$KERNEL_VERSION" \
  -e "CROSS_COMPILE=aarch64-linux-gnu-" \
  -u `id -u`:`id -g` \
  -v `pwd`/:/base \
     aarch64-builder \
       /bin/bash -e -c '\
  echo "===== Building Kernel =====" && \
  cd /base/components/linux/ && \
  git fetch && git clean -f -x -d && git checkout $KERNEL_VERSION && \
  cp /base/config/kernel.config .config && \
  ARCH=arm64 make oldconfig && \
  ARCH=arm64 make -j5 deb-pkg KBUILD_IMAGE=arch/arm64/boot/Image && \
  cp ../*.deb /base/output/'
