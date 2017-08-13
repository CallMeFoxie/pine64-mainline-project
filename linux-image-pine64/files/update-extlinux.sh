#!/bin/sh

XVERSION=$1

[ -f /boot/extlinux/extlinux.conf ] && echo "Backing up old extlinux.conf" && mv /boot/extlinux/extlinux.conf /boot/extlinux/extlinux.conf.old 

for image in `ls -t /boot/vmlinuz-*`; do
  version=`echo $image | sed 's/\/boot\/vmlinuz-//'`
  fdt=''
  initrd=''

  echo "Adding linux-pine64-${version} to the list..."
  if [ -f /boot/initrd.img-$version ]; then
    initrd="INITRD /initrd.img-$version"
    echo "> found initrd"
  fi
  if [ -f /boot/dtb-${version}.dtb ]; then
    fdt="FDT /dtb-${version}.dtb"
    echo "> found dtb"
  fi

  echo >> /boot/extlinux/extlinux.conf << EOF
LABEL linux-pine64-$version
  KERNEL /vmlinuz-$version
  ${initrd}
  ${fdt}
  APPEND root=/dev/mmcblk0p2 console=ttyS0,115200 rootwait rw
EOF
done

if [ x"${XVERSION}" != "x" ]; then
  echo "Setting linux-pine64-${XVERSION}" as the default option
  echo >> /tmp/extlinux.conf << EOF
DEFAULT linux-pine64-${XVERSION}
EOF
  mv /boot/extlinux/extlinux.conf /tmp/extlinux-imgs.conf
  cat /tmp/extlinux.conf /tmp/extlinux-imgs.conf > /boot/extlinux/extlinux.conf
fi
