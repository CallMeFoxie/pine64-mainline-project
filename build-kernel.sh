#!/bin/bash

KERNEL_VERSION="4.13-rc6"

mkdir -p output/{config,output,build}

cp config/* output/config/

docker run -ti \
  -e "ID=`id -u`" \
  -e "KERNEL_VERSION=$KERNEL_VERSION" \
  -e "CROSS_COMPILE=aarch64-linux-gnu-" \
  -v `pwd`/output:/target aarch64-builder /bin/bash -e -c '\
  echo "===== Getting build packages =====" && \
  cd /target/build/ && \
  echo "===== Fetching packages =====" && \
  ( [ ! -f linux-$KERNEL_VERSION.tar.gz ] && wget https://git.kernel.org/torvalds/t/linux-$KERNEL_VERSION.tar.gz ) || : ; \
  echo "===== Building Kernel =====" && \
  cd /target/build/ && \
  ( [ ! -d linux-$KERNEL_VERSION ] && tar xvfp linux-$KERNEL_VERSION.tar.gz ) || : ; \
  cd /target/build/linux-$KERNEL_VERSION && \
  cp /target/config/kernel.config .config && \
  ARCH=arm64 make oldconfig && \
  ARCH=arm64 make -j5 deb-pkg KBUILD_IMAGE=arch/arm64/boot/Image && \
  cp ../*.deb /target/output/'
