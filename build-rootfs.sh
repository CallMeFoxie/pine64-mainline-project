#!/bin/bash

DISTRO="stretch"
REPO="http://ftp.debian.org/debian"
ROOT=$1

if [ x"$ROOT" = "x" ]; then
 echo "missing root target"
 exit 
fi

EXTRA="iproute2,systemd-sysv,ntp,udev,vim,sudo,openssh-server,ifupdown,isc-dhcp-client,kmod"

run_chroot {
  chroot $ROOT $@ 
}

qemu-debootstrap --arch=arm64 --variant=minbase ${DISTRO} $ROOT ${REPO} --include=$EXTRA

echo "pine64-unnamed" > $ROOT/etc/hostname

run_chroot apt-get update
run_chroot hostname pine64-unnamed

echo -n > $ROOT/etc/fstab
echo "/dev/mmcblk0p1 /boot vfat errors=remount-ro 0 1" >> $ROOT/etc/fstab
echo "/dev/mmcblk0p2 /     ext4 defaults,noatime  0 1" >> $ROOT/etc/fstab
