#!/bin/bash

mkdir -p output/

docker run -ti \
  -e "CROSS_COMPILE=aarch64-linux-gnu-" \
  -u `id -u`:`id -g` \
  -v `pwd`/:/base \
     aarch64-builder \
        /bin/bash -e -c '\
  echo "===== Building ATF =====" && \
  cd /base/components/arm-trusted-firmware/ && \
  make clean && \
  make -j4 PLAT=sun50iw1p1 DEBUG=0 bl31 && \
  export BL31=/base/components/arm-trusted-firmware/build/sun50iw1p1/release/bl31.bin && \
  echo "===== Building U-Boot =====" && \
  cd /base/components/u-boot/ && \
  cp /base/config/uboot.config .config && \
  make clean && \
  make oldconfig && \
  make -j4 && \
  cat spl/sunxi-spl.bin u-boot.itb > /base/output/u-boot-sunxi-image.spl'

