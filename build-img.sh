#!/bin/bash

set -e
set -u

IMAGE=$1
PASSWORD="pine"

ROOTFS=/tmp/target

if [ x"$IMAGE" = "x" ]; then
  echo "missing IMAGE param"
fi

function run_chroot {
  chroot $ROOTFS $@
}

echo "Creating new image"
dd if=/dev/zero of=$IMAGE bs=1G count=4 # create an empty 4GB file
#truncate -s 4G $IMAGE

sfdisk $IMAGE < config/partitions

TARGET=$IMAGE

mkdir -p $ROOTFS

if [ -f $IMAGE ]; then
  XTARGET=`losetup -f -P --show $IMAGE`
  TARGET="${XTARGET}p"
  echo "Target is a file, mounting to $TARGET"
fi

echo "Creating filesystems..."
mkfs.ext2 ${TARGET}1
mkfs.ext4 ${TARGET}2

echo "Mounting to $ROOTFS"
mount ${TARGET}2 ${ROOTFS}

echo "Debootstrapping..."
./build-rootfs.sh $ROOTFS

echo "Mounting boot partition"
mount ${TARGET}1 ${ROOTFS}/boot

echo "Copying overlay extra files"
cp -rvp overlay/* ${ROOTFS}/

echo "Removing extra files"
rm ${ROOTFS}/etc/machine-id 
rm ${ROOTFS}/etc/ssh/ssh_host_*

echo "Adding kernel"
mkdir -p ${ROOTFS}/boot/extlinux
run_chroot apt-get update
run_chroot apt-get -y install linux-image-pine64

echo "Setting up users"
run_chroot useradd -s /bin/bash -m pine
run_chroot usermod -aG sudo pine
echo "pine:${PASSWORD}" | run_chroot /usr/sbin/chpasswd

echo "Doing extra tasks"
if [ -d extras ]; then
  cp extras/*.deb ${ROOTFS}/tmp/
  run_chroot /bin/bash -c 'dpkg -i /tmp/*.deb' # need expat from bash
  run_chroot apt-get -y -f install --no-install-recommends
fi

echo "Unmounting"
rm ${ROOTFS}/tmp/*
sync
umount ${ROOTFS}/boot
umount ${ROOTFS}

if [ -f $IMAGE ]; then
  echo "Detaching loopback file"
  losetup --detach $XTARGET
fi

echo "Adding SPL/U-Boot"
dd conv=notrunc if=output/u-boot-sunxi-image.spl of=$IMAGE bs=8k seek=1 

echo "All done!"
