#!/bin/bash

DISTRO="stretch"
REPO="http://ftp.debian.org/debian"
ROOT=$1

if [ x"$ROOT" = "x" ]; then
 echo "missing root target"
 exit 
fi

EXTRA="iproute2,systemd-sysv,ntp,udev,vim,sudo,openssh-server,ifupdown,isc-dhcp-client,kmod,apt-transport-https,ca-certificates,locales"

function run_chroot {
  chroot $ROOT $@ 
}

qemu-debootstrap --arch=arm64 --variant=minbase ${DISTRO} $ROOT ${REPO} --include=$EXTRA

echo "en_US.UTF-8 UTF-8" >> ${ROOT}/etc/locale.gen
run_chroot locale-gen

#run_chroot apt-get update
#run_chroot hostname pine64-unnamed
