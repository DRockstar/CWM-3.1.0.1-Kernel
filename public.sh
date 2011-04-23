#!/bin/bash

rm Kernel/usr/initramfs_data.cpio > /dev/null 2>&1
rm Kernel/usr/initramfs_data.o > /dev/null 2>&1
rm Kernel/usr/initramfs_data.cpio.lzma > /dev/null 2>&1
rm Kernel/usr/initramfs_data.lzma.o > /dev/null 2>&1

cat Kernel/arch/arm/boot/zImage > /media/sf_Public/zImage

