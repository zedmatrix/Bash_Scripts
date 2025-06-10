# Creating a Live ISO for CD/DVD/USB Project

## Initialization of rootfs for squashfs
using qemu:`qemu-img create lfs-stable.img 32G`<br>
temporary drive: `qemu-img create lfs-temp.img 10G`

Build your Linux From Scratch system to chapter 10 including extra utilities.
This is where you can exit just like the instructions in chapter 7 - saving the system.

## Saving rootfs
If the temporary drive is not formatted: `mkfs -v -t ext4 /dev/sdb1`
```
export LFS=/mnt/lfs
export USB=/mnt/usb
mountpoint -q $LFS/dev/shm && umount $LFS/dev/shm
umount $LFS/dev/pts
umount $LFS/{sys,proc,run,dev}
mount -v -t ext4 /dev/sdb1 $USB
cd $LFS
tar --exclude='./sources' -cJpf $USB/lfs-rootfs-12.3.tar.xz .
```

## Building Squashfs Tools
```
01_squashfs-tools-4.6.1
02-libisofs-1.5.6
03_libburn-1.5.6
04_libisoburn-1.5.6
05_mtools-4.0.48
```
Grub For UEFI is recommended.
