#!/bin/bash

UBOOT_VERSION="v2017.09-rc2"
ATF_VERSION="allwinner"

mkdir -p output/{config,output,build}

cp config/* output/config/

docker run -ti \
  -e "ID=`id -u`" \
  -e "UBOOT_VERSION=$UBOOT_VERSION" \
  -e "ATF_VERSION=$ATF_VERSION" \
  -e "CROSS_COMPILE=aarch64-linux-gnu-" \
  -u `id -u`:`id -g` \
  -v `pwd`/output:/target aarch64-builder /bin/bash -e -c '\
  echo "===== Getting build packages =====" && \
  cd /target/build/ && \
  echo "===== Fetching packages =====" && \
  ( [ ! -d arm-trusted-firmware ] && git clone https://github.com/apritzel/arm-trusted-firmware.git -b $ATF_VERSION --single-branch ) || ( cd arm-trusted-firmware && git fetch && git checkout $ATF_VERSION ) ; \
  ( [ ! -d u-boot ] && git clone https://github.com/u-boot/u-boot.git -b $UBOOT_VERSION --single-branch ) || ( cd u-boot && git fetch && git checkout $UBOOT_VERSION ) ; \
  echo "===== Building ATF =====" && \
  cd /target/build/arm-trusted-firmware/ && \
  make clean && \
  make -j4 PLAT=sun50iw1p1 DEBUG=0 bl31 && \
  export BL31=/target/build/arm-trusted-firmware/build/sun50iw1p1/release/bl31.bin && \
  echo "===== Building U-Boot =====" && \
  cd /target/build/u-boot/ && \
  cp /target/config/uboot.config .config && \
  make oldconfig && \
  make -j4 && \
  cat spl/sunxi-spl.bin u-boot.itb > /target/output/u-boot-sunxi-image.spl'

