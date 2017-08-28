#!/bin/bash

UBOOT_VERSION="v2017.09-rc2"
ATF_VERSION="allwinner"

mkdir -p output/

docker run -ti \
  -e "ID=`id -u`" \
  -e "UBOOT_VERSION=$UBOOT_VERSION" \
  -e "ATF_VERSION=$ATF_VERSION" \
  -e "CROSS_COMPILE=aarch64-linux-gnu-" \
  -u `id -u`:`id -g` \
  -v `pwd`/:/base \
     aarch64-builder \
        /bin/bash -e -c '\
  echo "===== Building ATF =====" && \
  cd /base/components/arm-trusted-firmware/ && \
  git clean -f -x -d && git fetch && git checkout $ATF_VERSION ; \
  make clean && \
  make -j4 PLAT=sun50iw1p1 DEBUG=0 bl31 && \
  export BL31=/components/arm-trusted-firmware/build/sun50iw1p1/release/bl31.bin && \
  echo "===== Building U-Boot =====" && \
  cd /base/components/u-boot/ && \
  git clean -f -x -d && git fetch && git checkout $UBOOT_VERSION ; \
  cp /base/config/uboot.config .config && \
  make oldconfig && \
  make -j4 && \
  cat spl/sunxi-spl.bin u-boot.itb > /base/output/u-boot-sunxi-image.spl'

